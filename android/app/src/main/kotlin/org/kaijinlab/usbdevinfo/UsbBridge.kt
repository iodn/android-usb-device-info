package org.kaijinlab.usbdevinfo

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.ComponentName
import android.content.pm.PackageManager
import android.hardware.input.InputManager
import android.hardware.usb.UsbConfiguration
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.InputDevice
import androidx.annotation.MainThread
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap
import kotlin.math.min

class UsbBridge(
  private val activity: FlutterActivity,
  messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

  private val tag = "USBDevInfo"
  private val ctx: Context = activity.applicationContext
  private val usbManager: UsbManager = ctx.getSystemService(Context.USB_SERVICE) as UsbManager
  private val inputManager: InputManager? = try { ctx.getSystemService(Context.INPUT_SERVICE) as InputManager } catch (_: Throwable) { null }
  private val mainHandler = Handler(Looper.getMainLooper())
  private val methodChannel = MethodChannel(messenger, "usbdevinfo/methods")
  private val eventChannel = EventChannel(messenger, "usbdevinfo/events")
  private var eventSink: EventChannel.EventSink? = null
  private val permissionResults = ConcurrentHashMap<String, MethodChannel.Result>()
  private val permissionAction = "${ctx.packageName}.USB_PERMISSION"

  private val receiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      when (intent.action) {
        UsbManager.ACTION_USB_DEVICE_ATTACHED, UsbManager.ACTION_USB_DEVICE_DETACHED -> {
          val device: UsbDevice? = intent.getParcelableExtraCompat(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
          emitEvent(
            mapOf(
              "type" to "devices_changed",
              "reason" to (intent.action ?: "unknown"),
              "deviceName" to device?.deviceName
            )
          )
        }
        permissionAction -> {
          val device: UsbDevice? = intent.getParcelableExtraCompat(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
          val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
          val name = device?.deviceName
          if (name != null) {
            permissionResults.remove(name)?.success(granted)
          }
          emitEvent(mapOf("type" to "permission_result", "deviceName" to name, "granted" to granted))
          emitEvent(mapOf("type" to "devices_changed", "reason" to "permission_result", "deviceName" to name))
        }
      }
    }
  }

  private val inputListener = object : InputManager.InputDeviceListener {
    override fun onInputDeviceAdded(deviceId: Int) {
      emitEvent(mapOf("type" to "devices_changed", "reason" to "input_added", "deviceName" to inputKey(deviceId)))
    }
    override fun onInputDeviceRemoved(deviceId: Int) {
      emitEvent(mapOf("type" to "devices_changed", "reason" to "input_removed", "deviceName" to inputKey(deviceId)))
    }
    override fun onInputDeviceChanged(deviceId: Int) {
      emitEvent(mapOf("type" to "devices_changed", "reason" to "input_changed", "deviceName" to inputKey(deviceId)))
    }
  }

  fun start() {
    methodChannel.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
    registerReceiver()
    registerInputListener()
  }

  fun stop() {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    unregisterReceiver()
    unregisterInputListener()
  }

  fun handleIntent(intent: Intent?) {
    if (intent == null) return
    val action = intent.action ?: return
    if (action == UsbManager.ACTION_USB_DEVICE_ATTACHED || action == UsbManager.ACTION_USB_DEVICE_DETACHED) {
      val device: UsbDevice? = intent.getParcelableExtraCompat(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
      emitEvent(
        mapOf(
          "type" to "devices_changed",
          "reason" to "activity_intent:$action",
          "deviceName" to device?.deviceName
        )
      )
    }
  }

  private fun registerReceiver() {
    val filter = IntentFilter().apply {
      addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
      addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
      addAction(permissionAction)
    }
    if (Build.VERSION.SDK_INT >= 33) {
      ctx.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
    } else {
      @Suppress("DEPRECATION")
      ctx.registerReceiver(receiver, filter)
    }
  }

  private fun unregisterReceiver() {
    try { ctx.unregisterReceiver(receiver) } catch (_: Throwable) { }
  }

  private fun registerInputListener() {
    try { inputManager?.registerInputDeviceListener(inputListener, mainHandler) } catch (t: Throwable) {
      Log.w(tag, "InputManager listener not available: ${t.message}")
    }
  }

  private fun unregisterInputListener() {
    try { inputManager?.unregisterInputDeviceListener(inputListener) } catch (_: Throwable) { }
  }

  @MainThread
  private fun emitEvent(event: Map<String, Any?>) {
    eventSink?.success(event)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    emitEvent(mapOf("type" to "ready"))
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    try {
      when (call.method) {
        "listDevices" -> result.success(listDevices())
        "requestPermission" -> {
          val deviceName = call.argument<String>("deviceName") ?: ""
          requestPermission(deviceName, result)
        }
        "getDeviceDetails" -> {
          val deviceName = call.argument<String>("deviceName") ?: ""
          result.success(getDeviceDetails(deviceName))
        }
        "setUsbAttachComponentEnabled" -> {
          val enabled = call.argument<Boolean>("enabled") ?: false
          try {
            val alias = ComponentName(activity, activity.packageName + ".UsbAttachAlias")
            val newState = if (enabled) PackageManager.COMPONENT_ENABLED_STATE_ENABLED else PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            activity.packageManager.setComponentEnabledSetting(
              alias,
              newState,
              PackageManager.DONT_KILL_APP
            )
            result.success(true)
          } catch (t: Throwable) {
            Log.w(tag, "Failed to toggle alias: ${t.message}")
            result.success(false)
          }
        }
        else -> result.notImplemented()
      }
    } catch (se: SecurityException) {
      result.error("security_exception", se.message, null)
    } catch (t: Throwable) {
      Log.e(tag, "Method failed: ${call.method}", t)
      result.error("error", t.message, null)
    }
  }

  private fun listDevices(): List<Map<String, Any?>> {
    val usb = usbManager.deviceList.values.toList()
    val out = ArrayList<Map<String, Any?>>(usb.size + 8)
    val usbVidPid = HashSet<String>(usb.size * 2)
    for (d in usb) {
      usbVidPid.add("${d.vendorId}:${d.productId}")
      out.add(deviceSummaryUsb(d))
    }
    out.addAll(listExternalInputDevices(usbVidPid))
    return out
  }

  private fun listExternalInputDevices(usbVidPid: Set<String>): List<Map<String, Any?>> {
    val im = inputManager ?: return emptyList()
    val ids = getInputDeviceIdsCompat(im) ?: return emptyList()
    val out = ArrayList<Map<String, Any?>>()
    for (id in ids) {
      val dev = safeGet { im.getInputDevice(id) } ?: continue
      val isExternal = inputIsExternal(dev)
      if (!isExternal) continue
      val sourcesMask = dev.sources
      val isKb = (sourcesMask and InputDevice.SOURCE_KEYBOARD) == InputDevice.SOURCE_KEYBOARD
      val isMouse = (sourcesMask and InputDevice.SOURCE_MOUSE) == InputDevice.SOURCE_MOUSE
      if (!isKb && !isMouse) continue
      val vid = inputVendorId(dev)
      val pid = inputProductId(dev)
      if (vid <= 0 || pid <= 0) continue
      if (usbVidPid.contains("$vid:$pid")) continue
      out.add(deviceSummaryInput(dev, vid, pid))
    }
    return out
  }

  private fun requestPermission(deviceName: String, result: MethodChannel.Result) {
    if (isInputKey(deviceName)) {
      result.success(true)
      return
    }
    val device = findUsbByName(deviceName)
    if (device == null) {
      result.success(false)
      return
    }
    if (usbManager.hasPermission(device)) {
      result.success(true)
      return
    }
    permissionResults[deviceName] = result
    val baseFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
    val flags = baseFlags or PendingIntent.FLAG_UPDATE_CURRENT
    val intent = Intent(permissionAction).setPackage(ctx.packageName)
    val pending = PendingIntent.getBroadcast(ctx, deviceName.hashCode(), intent, flags)
    usbManager.requestPermission(device, pending)
  }

  private fun getDeviceDetails(deviceName: String): Map<String, Any?> {
    if (isInputKey(deviceName)) {
      val id = parseInputId(deviceName)
      val dev = if (id == null) null else safeGet { inputManager?.getInputDevice(id) }
      if (dev == null) {
        return mapOf(
          "summary" to mapOf(
            "deviceName" to deviceName,
            "vendorId" to 0,
            "productId" to 0,
            "deviceClass" to UsbConstants.USB_CLASS_HID,
            "deviceSubclass" to 0,
            "deviceProtocol" to 0,
            "interfaceCount" to 0,
            "configurationCount" to 0,
            "hasPermission" to true,
            "isInputDevice" to true
          ),
          "interfaces" to emptyList<Map<String, Any?>>(),
          "configurations" to emptyList<Map<String, Any?>>(),
          "deviceDescriptor" to null,
          "input" to null,
          "descriptorTree" to null,
          "strings" to null,
          "hidReports" to null,
          "deviceState" to null
        )
      }
      val vid = inputVendorId(dev)
      val pid = inputProductId(dev)
      return mapOf(
        "summary" to deviceSummaryInput(dev, vid, pid),
        "interfaces" to emptyList<Map<String, Any?>>(),
        "configurations" to emptyList<Map<String, Any?>>(),
        "deviceDescriptor" to null,
        "input" to buildInputDetails(dev, vid, pid),
        "descriptorTree" to null,
        "strings" to null,
        "hidReports" to null,
        "deviceState" to null
      )
    }

    val device = findUsbByName(deviceName) ?: return mapOf(
      "summary" to mapOf(
        "deviceName" to deviceName,
        "vendorId" to 0,
        "productId" to 0,
        "deviceClass" to 0,
        "deviceSubclass" to 0,
        "deviceProtocol" to 0,
        "interfaceCount" to 0,
        "configurationCount" to 0,
        "hasPermission" to false,
        "isInputDevice" to false
      ),
      "interfaces" to emptyList<Map<String, Any?>>(),
      "configurations" to emptyList<Map<String, Any?>>(),
      "deviceDescriptor" to null,
      "input" to null,
      "descriptorTree" to null,
      "strings" to null,
      "hidReports" to null,
      "deviceState" to null
    )

    val hasPerm = usbManager.hasPermission(device)
    val summary0 = deviceSummaryUsb(device)
    val interfaces0 = buildInterfaces(device)
    val configurations0 = buildConfigurations(device)
    val deviceDescriptor0 = readDeviceDescriptor(device)

    if (!hasPerm) {
      return mapOf(
        "summary" to summary0,
        "interfaces" to interfaces0,
        "configurations" to configurations0,
        "deviceDescriptor" to deviceDescriptor0,
        "input" to null,
        "descriptorTree" to null,
        "strings" to null,
        "hidReports" to null,
        "deviceState" to null
      )
    }

    var conn: UsbDeviceConnection? = null
    try {
      conn = usbManager.openDevice(device)
      if (conn == null) {
        return mapOf(
          "summary" to summary0,
          "interfaces" to interfaces0,
          "configurations" to configurations0,
          "deviceDescriptor" to deviceDescriptor0,
          "input" to null,
          "descriptorTree" to null,
          "strings" to null,
          "hidReports" to null,
          "deviceState" to null
        )
      }

      val raw = tryGetRawDescriptors(conn)
      val tree = if (raw == null) null else parseDescriptorTree(raw)
      val dd = deviceDescriptor0 ?: (if (raw == null) null else parseDeviceDescriptorFromRaw(raw))

      val languages = readStringLanguageIds(conn)
      val preferredLang = pickPreferredLangId(languages)

      val deviceStrings = if (dd == null) null else readDeviceStrings(conn, dd, preferredLang)
      val interfaceStrings = if (tree == null) null else readInterfaceStrings(conn, tree, preferredLang)

      val stringsBlock = mapOf(
        "languageIds" to languages,
        "preferredLanguageId" to preferredLang,
        "device" to deviceStrings,
        "interfaces" to interfaceStrings
      )

      val stateBlock = readDeviceState(conn, device, tree)

      val hidReports = if (tree == null) emptyList<Map<String, Any?>>() else readHidReports(conn, device, tree)

      val summary = mergeSummaryStrings(summary0, deviceStrings)

      return mapOf(
        "summary" to summary,
        "interfaces" to interfaces0,
        "configurations" to configurations0,
        "deviceDescriptor" to dd,
        "input" to null,
        "descriptorTree" to tree,
        "strings" to stringsBlock,
        "hidReports" to hidReports,
        "deviceState" to stateBlock
      )
    } catch (_: Throwable) {
      return mapOf(
        "summary" to summary0,
        "interfaces" to interfaces0,
        "configurations" to configurations0,
        "deviceDescriptor" to deviceDescriptor0,
        "input" to null,
        "descriptorTree" to null,
        "strings" to null,
        "hidReports" to null,
        "deviceState" to null
      )
    } finally {
      try { conn?.close() } catch (_: Throwable) { }
    }
  }

  private fun mergeSummaryStrings(summary: Map<String, Any?>, deviceStrings: Map<String, Any?>?): Map<String, Any?> {
    if (deviceStrings == null) return summary
    val out = HashMap<String, Any?>(summary.size + 4)
    out.putAll(summary)
    val man = deviceStrings["manufacturer"] as? String
    val prod = deviceStrings["product"] as? String
    val ser = deviceStrings["serial"] as? String
    if (!man.isNullOrBlank() && (out["manufacturerName"] as? String).isNullOrBlank()) out["manufacturerName"] = man
    if (!prod.isNullOrBlank() && (out["productName"] as? String).isNullOrBlank()) out["productName"] = prod
    if (!ser.isNullOrBlank() && (out["serialNumber"] as? String).isNullOrBlank()) out["serialNumber"] = ser
    return out
  }

  private fun deviceSummaryUsb(device: UsbDevice): Map<String, Any?> {
    val hasPerm = usbManager.hasPermission(device)
    var manufacturer: String? = null
    var product: String? = null
    var serial: String? = null
    if (hasPerm) {
      manufacturer = safeGet { device.manufacturerName }
      product = safeGet { device.productName }
      serial = safeReadSerial(device)
    }
    val usbVersionStr = readUsbVersion(device)
    val speedStr = readSpeed(device)
    val maxPower = readMaxPowerMa(device)
    val portNumber = readPortNumber(device)
    return mapOf(
      "deviceName" to device.deviceName,
      "deviceId" to device.deviceId,
      "portNumber" to portNumber,
      "vendorId" to device.vendorId,
      "productId" to device.productId,
      "deviceClass" to device.deviceClass,
      "deviceSubclass" to device.deviceSubclass,
      "deviceProtocol" to device.deviceProtocol,
      "interfaceCount" to device.interfaceCount,
      "configurationCount" to device.configurationCount,
      "hasPermission" to hasPerm,
      "manufacturerName" to manufacturer,
      "productName" to product,
      "serialNumber" to serial,
      "usbVersion" to usbVersionStr,
      "speed" to speedStr,
      "maxPowerMa" to maxPower,
      "isInputDevice" to false
    )
  }

  private fun deviceSummaryInput(dev: InputDevice, vid: Int, pid: Int): Map<String, Any?> {
    val sources = inputSources(dev)
    val name = safeGet { dev.name } ?: "Input device"
    return mapOf(
      "deviceName" to inputKey(dev.id),
      "deviceId" to dev.id,
      "portNumber" to null,
      "vendorId" to vid,
      "productId" to pid,
      "deviceClass" to UsbConstants.USB_CLASS_HID,
      "deviceSubclass" to 0,
      "deviceProtocol" to 0,
      "interfaceCount" to 0,
      "configurationCount" to 0,
      "hasPermission" to true,
      "manufacturerName" to null,
      "productName" to name,
      "serialNumber" to null,
      "usbVersion" to null,
      "speed" to null,
      "maxPowerMa" to null,
      "isInputDevice" to true,
      "inputSources" to sources
    )
  }

  private fun buildInterfaces(device: UsbDevice): List<Map<String, Any?>> {
    val out = ArrayList<Map<String, Any?>>(device.interfaceCount)
    for (i in 0 until device.interfaceCount) {
      val intf = device.getInterface(i)
      out.add(interfaceToMap(intf))
    }
    return out
  }

  private fun buildConfigurations(device: UsbDevice): List<Map<String, Any?>> {
    val out = ArrayList<Map<String, Any?>>()
    val count = device.configurationCount
    if (count <= 0) return out
    for (c in 0 until count) {
      val cfg = device.getConfiguration(c)
      val ifaces = ArrayList<Map<String, Any?>>(cfg.interfaceCount)
      for (i in 0 until cfg.interfaceCount) {
        ifaces.add(interfaceToMap(cfg.getInterface(i)))
      }
      out.add(
        mapOf(
          "id" to cfg.id,
          "name" to safeGet { cfg.name },
          "attributes" to getUsbConfigurationAttributes(cfg),
          "maxPowerMa" to cfg.maxPower,
          "interfaceCount" to cfg.interfaceCount,
          "interfaces" to ifaces
        )
      )
    }
    return out
  }

  private fun interfaceToMap(intf: UsbInterface): Map<String, Any?> {
    val endpoints = ArrayList<Map<String, Any?>>(intf.endpointCount)
    for (i in 0 until intf.endpointCount) {
      val ep = intf.getEndpoint(i)
      endpoints.add(endpointToMap(ep))
    }
    return mapOf(
      "id" to intf.id,
      "alternateSetting" to getUsbInterfaceAlternateSetting(intf),
      "name" to safeGet { intf.name },
      "interfaceClass" to intf.interfaceClass,
      "interfaceSubclass" to intf.interfaceSubclass,
      "interfaceProtocol" to intf.interfaceProtocol,
      "endpointCount" to intf.endpointCount,
      "endpoints" to endpoints
    )
  }

  private fun endpointToMap(ep: UsbEndpoint): Map<String, Any?> {
    return mapOf(
      "address" to ep.address,
      "direction" to directionLabel(ep.direction),
      "type" to endpointTypeLabel(ep.type),
      "maxPacketSize" to ep.maxPacketSize,
      "interval" to ep.interval,
      "attributes" to getUsbEndpointAttributes(ep),
      "number" to ep.endpointNumber
    )
  }

  private fun directionLabel(direction: Int): String = when (direction) {
    UsbConstants.USB_DIR_IN -> "IN"
    UsbConstants.USB_DIR_OUT -> "OUT"
    else -> "Unknown"
  }

  private fun endpointTypeLabel(type: Int): String = when (type) {
    UsbConstants.USB_ENDPOINT_XFER_CONTROL -> "Control"
    UsbConstants.USB_ENDPOINT_XFER_ISOC -> "Isochronous"
    UsbConstants.USB_ENDPOINT_XFER_BULK -> "Bulk"
    UsbConstants.USB_ENDPOINT_XFER_INT -> "Interrupt"
    else -> "Unknown"
  }

  private fun buildInputDetails(dev: InputDevice, vid: Int, pid: Int): Map<String, Any?> {
    val ranges = ArrayList<Map<String, Any?>>()
    val motionRanges: List<Any> = inputMotionRanges(dev)
    for (r in motionRanges) {
      val axis = callInt(r, "getAxis") ?: 0
      val minV = callFloat(r, "getMin") ?: 0f
      val maxV = callFloat(r, "getMax") ?: 0f
      val flat = callFloat(r, "getFlat") ?: 0f
      val fuzz = callFloat(r, "getFuzz") ?: 0f
      val res = callFloat(r, "getResolution") ?: 0f
      ranges.add(
        mapOf(
          "axis" to axis,
          "min" to minV.toDouble(),
          "max" to maxV.toDouble(),
          "flat" to flat.toDouble(),
          "fuzz" to fuzz.toDouble(),
          "resolution" to res.toDouble()
        )
      )
    }
    return mapOf(
      "id" to dev.id,
      "name" to safeGet { dev.name },
      "descriptor" to inputDescriptor(dev),
      "isExternal" to inputIsExternal(dev),
      "vendorId" to vid,
      "productId" to pid,
      "sources" to inputSources(dev),
      "keyboardType" to inputKeyboardType(dev),
      "motionRanges" to ranges
    )
  }

  private fun inputSources(dev: InputDevice): List<String> {
    val s = dev.sources
    val out = ArrayList<String>(4)
    if ((s and InputDevice.SOURCE_KEYBOARD) == InputDevice.SOURCE_KEYBOARD) out.add("keyboard")
    if ((s and InputDevice.SOURCE_MOUSE) == InputDevice.SOURCE_MOUSE) out.add("mouse")
    if ((s and InputDevice.SOURCE_TOUCHPAD) == InputDevice.SOURCE_TOUCHPAD) out.add("touchpad")
    if ((s and InputDevice.SOURCE_JOYSTICK) == InputDevice.SOURCE_JOYSTICK) out.add("joystick")
    if (out.isEmpty()) out.add("unknown")
    return out
  }

  private fun findUsbByName(deviceName: String): UsbDevice? {
    val map = usbManager.deviceList
    for (d in map.values) {
      if (d.deviceName == deviceName) return d
    }
    return null
  }

  private fun safeReadSerial(device: UsbDevice): String? {
    return try {
      val conn: UsbDeviceConnection? = usbManager.openDevice(device)
      val s = safeGet { conn?.serial }
      conn?.close()
      s ?: safeGet { device.serialNumber }
    } catch (_: Throwable) {
      null
    }
  }

  private fun readUsbVersion(device: UsbDevice): String? {
    val fromRaw = readDeviceDescriptor(device)?.get("usbVersion") as? String
    if (!fromRaw.isNullOrBlank()) return fromRaw
    return try {
      val m = UsbDevice::class.java.getMethod("getVersion")
      (m.invoke(device) as? String)?.trim()
    } catch (_: Throwable) {
      null
    }
  }

  private fun readSpeed(device: UsbDevice): String? {
    return try {
      val m = UsbDevice::class.java.getMethod("getSpeed")
      val speed = (m.invoke(device) as? Int) ?: return null
      when (speed) {
        1 -> "Low speed (1.5 Mbps)"
        2 -> "Full speed (12 Mbps)"
        3 -> "High speed (480 Mbps)"
        4 -> "SuperSpeed (5 Gbps)"
        5 -> "SuperSpeed+ (10+ Gbps)"
        else -> "Unknown"
      }
    } catch (_: Throwable) {
      null
    }
  }

  private fun readMaxPowerMa(device: UsbDevice): Int? {
    return try {
      if (device.configurationCount <= 0) return null
      val cfg: UsbConfiguration = device.getConfiguration(0)
      cfg.maxPower
    } catch (_: Throwable) {
      null
    }
  }

  private fun readPortNumber(device: UsbDevice): Int? {
    return try {
      val m = UsbDevice::class.java.getMethod("getPortNumber")
      (m.invoke(device) as? Int)
    } catch (_: Throwable) {
      null
    }
  }

  private fun readDeviceDescriptor(device: UsbDevice): Map<String, Any?>? {
    if (!usbManager.hasPermission(device)) return null
    return try {
      val conn = usbManager.openDevice(device) ?: return null
      val raw = tryGetRawDescriptors(conn)
      conn.close()
      if (raw == null || raw.size < 18) return null
      parseDeviceDescriptorFromRaw(raw)
    } catch (_: Throwable) {
      null
    }
  }

  private fun parseDeviceDescriptorFromRaw(raw: ByteArray): Map<String, Any?>? {
    if (raw.size < 18) return null
    val bcdUsb = le16(raw[2], raw[3])
    val bcdDevice = le16(raw[12], raw[13])
    val maxPkt0 = u8(raw[7])
    val numCfg = u8(raw[17])
    val iMan = u8(raw[14])
    val iProd = u8(raw[15])
    val iSer = u8(raw[16])
    return mapOf(
      "bcdUsb" to bcdUsb,
      "usbVersion" to bcdToVersionString(bcdUsb),
      "bcdDevice" to bcdDevice,
      "deviceRelease" to bcdToVersionString(bcdDevice),
      "maxPacketSize0" to maxPkt0,
      "numConfigurations" to numCfg,
      "iManufacturer" to iMan,
      "iProduct" to iProd,
      "iSerialNumber" to iSer
    )
  }

  private fun tryGetRawDescriptors(conn: UsbDeviceConnection): ByteArray? {
    return try {
      val m = UsbDeviceConnection::class.java.getMethod("getRawDescriptors")
      m.invoke(conn) as? ByteArray
    } catch (_: Throwable) {
      null
    }
  }

  private fun u8(b: Byte): Int = b.toInt() and 0xFF
  private fun le16(lo: Byte, hi: Byte): Int = u8(lo) or (u8(hi) shl 8)

  private fun bcdToVersionString(bcd: Int): String {
    val major = (bcd ushr 8) and 0xFF
    val minorTens = (bcd ushr 4) and 0x0F
    val minorOnes = bcd and 0x0F
    val minor = minorTens * 10 + minorOnes
    return String.format(Locale.US, "%d.%02d", major, minor)
  }

  private fun getUsbEndpointAttributes(ep: UsbEndpoint): Int {
    return try {
      val m = UsbEndpoint::class.java.getMethod("getAttributes")
      (m.invoke(ep) as? Int) ?: 0
    } catch (_: Throwable) {
      0
    }
  }

  private fun getUsbConfigurationAttributes(cfg: UsbConfiguration): Int {
    return try {
      val m = UsbConfiguration::class.java.getMethod("getAttributes")
      (m.invoke(cfg) as? Int) ?: 0
    } catch (_: Throwable) {
      0
    }
  }

  private fun getUsbInterfaceAlternateSetting(intf: UsbInterface): Int {
    return try {
      val m = UsbInterface::class.java.getMethod("getAlternateSetting")
      (m.invoke(intf) as? Int) ?: 0
    } catch (_: Throwable) {
      0
    }
  }

  private fun getInputDeviceIdsCompat(im: InputManager): IntArray? {
    return try {
      val m = InputManager::class.java.getMethod("getInputDeviceIds")
      m.invoke(im) as? IntArray
    } catch (_: Throwable) {
      null
    }
  }

  private fun inputIsExternal(dev: InputDevice): Boolean {
    return try {
      val m = InputDevice::class.java.getMethod("isExternal")
      (m.invoke(dev) as? Boolean) ?: false
    } catch (_: Throwable) {
      safeGet { dev.isExternal } ?: false
    }
  }

  private fun inputVendorId(dev: InputDevice): Int {
    return try {
      val m = InputDevice::class.java.getMethod("getVendorId")
      (m.invoke(dev) as? Int) ?: 0
    } catch (_: Throwable) {
      0
    }
  }

  private fun inputProductId(dev: InputDevice): Int {
    return try {
      val m = InputDevice::class.java.getMethod("getProductId")
      (m.invoke(dev) as? Int) ?: 0
    } catch (_: Throwable) {
      0
    }
  }

  private fun inputDescriptor(dev: InputDevice): String? {
    return try {
      val m = InputDevice::class.java.getMethod("getDescriptor")
      (m.invoke(dev) as? String)
    } catch (_: Throwable) {
      null
    }
  }

  private fun inputKeyboardType(dev: InputDevice): Int {
    return try {
      val m = InputDevice::class.java.getMethod("getKeyboardType")
      (m.invoke(dev) as? Int) ?: 0
    } catch (_: Throwable) {
      0
    }
  }

  private fun inputMotionRanges(dev: InputDevice): List<Any> {
    return try {
      val m = InputDevice::class.java.getMethod("getMotionRanges")
      @Suppress("UNCHECKED_CAST")
      (m.invoke(dev) as? List<Any>) ?: emptyList()
    } catch (_: Throwable) {
      emptyList()
    }
  }

  private fun callInt(target: Any, method: String): Int? {
    return try {
      val m = target::class.java.getMethod(method)
      (m.invoke(target) as? Int)
    } catch (_: Throwable) {
      null
    }
  }

  private fun callFloat(target: Any, method: String): Float? {
    return try {
      val m = target::class.java.getMethod(method)
      (m.invoke(target) as? Float)
    } catch (_: Throwable) {
      null
    }
  }

  private fun isInputKey(name: String): Boolean = name.startsWith("input:")
  private fun inputKey(id: Int): String = "input:$id"

  private fun parseInputId(name: String): Int? {
    if (!isInputKey(name)) return null
    return name.removePrefix("input:").toIntOrNull()
  }

  private fun <T> safeGet(block: () -> T): T? {
    return try { block() } catch (_: Throwable) { null }
  }

  @Suppress("DEPRECATION")
  private fun <T> Intent.getParcelableExtraCompat(key: String, clazz: Class<T>): T? {
    return if (Build.VERSION.SDK_INT >= 33) {
      getParcelableExtra(key, clazz)
    } else {
      getParcelableExtra(key) as? T
    }
  }

  private fun parseDescriptorTree(raw: ByteArray): List<Map<String, Any?>> {
    val out = ArrayList<Map<String, Any?>>()
    var i = 0
    while (i + 2 <= raw.size) {
      val len = u8(raw[i])
      if (len <= 0) break
      if (i + len > raw.size) break
      val type = u8(raw[i + 1])
      val bytes = raw.copyOfRange(i, i + len)
      val base = HashMap<String, Any?>()
      base["offset"] = i
      base["length"] = len
      base["descriptorType"] = type
      base["descriptorTypeName"] = descriptorTypeName(type)
      base["rawHex"] = toHex(bytes, 2048)
      val parsed = parseKnownDescriptor(bytes)
      if (parsed != null) base["fields"] = parsed
      out.add(base)
      i += len
    }
    return out
  }

  private fun descriptorTypeName(type: Int): String = when (type) {
    0x01 -> "Device"
    0x02 -> "Configuration"
    0x03 -> "String"
    0x04 -> "Interface"
    0x05 -> "Endpoint"
    0x06 -> "Device Qualifier"
    0x07 -> "Other Speed Configuration"
    0x08 -> "Interface Power"
    0x0F -> "BOS"
    0x10 -> "Device Capability"
    0x21 -> "HID"
    0x22 -> "HID Report"
    0x24 -> "Class-specific Interface"
    0x25 -> "Class-specific Endpoint"
    0x2A -> "SuperSpeed Endpoint Companion"
    0x30 -> "SuperSpeedPlus Isoch Endpoint Companion"
    else -> "Unknown"
  }

  private fun parseKnownDescriptor(bytes: ByteArray): Map<String, Any?>? {
    val type = u8(bytes[1])
    return when (type) {
      0x01 -> parseDeviceDesc(bytes)
      0x02 -> parseConfigDesc(bytes)
      0x04 -> parseInterfaceDesc(bytes)
      0x05 -> parseEndpointDesc(bytes)
      0x21 -> parseHidDesc(bytes)
      0x0F -> parseBosDesc(bytes)
      0x10 -> parseDeviceCapabilityDesc(bytes)
      0x2A -> parseSsEndpointCompanion(bytes)
      0x24 -> parseClassSpecificInterface(bytes)
      0x25 -> parseClassSpecificEndpoint(bytes)
      else -> null
    }
  }

  private fun parseDeviceDesc(b: ByteArray): Map<String, Any?>? {
    if (b.size < 18) return null
    val bcdUsb = le16(b[2], b[3])
    val bcdDev = le16(b[12], b[13])
    val vid = le16(b[8], b[9])
    val pid = le16(b[10], b[11])
    return mapOf(
      "bcdUsb" to bcdUsb,
      "usbVersion" to bcdToVersionString(bcdUsb),
      "deviceClass" to u8(b[4]),
      "deviceSubclass" to u8(b[5]),
      "deviceProtocol" to u8(b[6]),
      "maxPacketSize0" to u8(b[7]),
      "idVendor" to vid,
      "idProduct" to pid,
      "bcdDevice" to bcdDev,
      "deviceRelease" to bcdToVersionString(bcdDev),
      "iManufacturer" to u8(b[14]),
      "iProduct" to u8(b[15]),
      "iSerialNumber" to u8(b[16]),
      "numConfigurations" to u8(b[17])
    )
  }

  private fun parseConfigDesc(b: ByteArray): Map<String, Any?>? {
    if (b.size < 9) return null
    val totalLength = le16(b[2], b[3])
    val numInterfaces = u8(b[4])
    val cfgValue = u8(b[5])
    val iCfg = u8(b[6])
    val attrs = u8(b[7])
    val maxPowerUnits = u8(b[8])
    val maxPowerMa = maxPowerUnits * 2
    val selfPowered = (attrs and 0x40) != 0
    val remoteWake = (attrs and 0x20) != 0
    return mapOf(
      "wTotalLength" to totalLength,
      "bNumInterfaces" to numInterfaces,
      "bConfigurationValue" to cfgValue,
      "iConfiguration" to iCfg,
      "bmAttributes" to attrs,
      "selfPowered" to selfPowered,
      "remoteWakeup" to remoteWake,
      "bMaxPower" to maxPowerUnits,
      "maxPowerMa" to maxPowerMa
    )
  }

  private fun parseInterfaceDesc(b: ByteArray): Map<String, Any?>? {
    if (b.size < 9) return null
    return mapOf(
      "bInterfaceNumber" to u8(b[2]),
      "bAlternateSetting" to u8(b[3]),
      "bNumEndpoints" to u8(b[4]),
      "bInterfaceClass" to u8(b[5]),
      "bInterfaceSubClass" to u8(b[6]),
      "bInterfaceProtocol" to u8(b[7]),
      "iInterface" to u8(b[8])
    )
  }

  private fun parseEndpointDesc(b: ByteArray): Map<String, Any?>? {
    if (b.size < 7) return null
    val addr = u8(b[2])
    val attrs = u8(b[3])
    val maxPkt = le16(b[4], b[5])
    val interval = u8(b[6])
    val dirIn = (addr and 0x80) != 0
    val epNum = addr and 0x0F
    val xfer = attrs and 0x03
    val xferName = when (xfer) {
      0 -> "Control"
      1 -> "Isochronous"
      2 -> "Bulk"
      3 -> "Interrupt"
      else -> "Unknown"
    }
    return mapOf(
      "bEndpointAddress" to addr,
      "direction" to if (dirIn) "IN" else "OUT",
      "endpointNumber" to epNum,
      "bmAttributes" to attrs,
      "transferType" to xfer,
      "transferTypeName" to xferName,
      "wMaxPacketSize" to maxPkt,
      "bInterval" to interval
    )
  }

  private fun parseHidDesc(b: ByteArray): Map<String, Any?>? {
    if (b.size < 9) return null
    val bcdHid = le16(b[2], b[3])
    val country = u8(b[4])
    val numDesc = u8(b[5])
    val list = ArrayList<Map<String, Any?>>()
    var off = 6
    var n = 0
    while (n < numDesc && off + 3 <= b.size) {
      val dt = u8(b[off])
      val dl = le16(b[off + 1], b[off + 2])
      list.add(mapOf("descriptorType" to dt, "descriptorTypeName" to descriptorTypeName(dt), "length" to dl))
      off += 3
      n++
    }
    val reportLen = list.firstOrNull { (it["descriptorType"] as? Int) == 0x22 }?.get("length") as? Int
    return mapOf(
      "bcdHID" to bcdHid,
      "hidVersion" to bcdToVersionString(bcdHid),
      "bCountryCode" to country,
      "bNumDescriptors" to numDesc,
      "descriptors" to list,
      "reportDescriptorLength" to reportLen
    )
  }

  private fun parseBosDesc(b: ByteArray): Map<String, Any?>? {
    if (b.size < 5) return null
    val totalLength = le16(b[2], b[3])
    val numCaps = u8(b[4])
    return mapOf("wTotalLength" to totalLength, "bNumDeviceCaps" to numCaps)
  }

  private fun parseDeviceCapabilityDesc(b: ByteArray): Map<String, Any?>? {
    if (b.size < 3) return null
    val capType = u8(b[2])
    return mapOf("bDevCapabilityType" to capType)
  }

  private fun parseSsEndpointCompanion(b: ByteArray): Map<String, Any?>? {
    if (b.size < 6) return null
    val maxBurst = u8(b[2])
    val attrs = u8(b[3])
    val bytesPerInterval = le16(b[4], b[5])
    return mapOf(
      "bMaxBurst" to maxBurst,
      "bmAttributes" to attrs,
      "wBytesPerInterval" to bytesPerInterval
    )
  }

  private fun parseClassSpecificInterface(b: ByteArray): Map<String, Any?>? {
    if (b.size < 3) return null
    val sub = u8(b[2])
    val base = HashMap<String, Any?>()
    base["bDescriptorSubType"] = sub
    when (sub) {
      0x00 -> if (b.size >= 5) base["bcdCDC"] = bcdToVersionString(le16(b[3], b[4]))
      0x01 -> if (b.size >= 5) base["bmCapabilities"] = u8(b[4])
      0x02 -> if (b.size >= 4) base["bmCapabilities"] = u8(b[3])
      0x06 -> if (b.size >= 5) {
        base["bMasterInterface"] = u8(b[3])
        val slaves = ArrayList<Int>()
        var i = 4
        while (i < b.size) {
          slaves.add(u8(b[i]))
          i++
        }
        base["bSlaveInterfaces"] = slaves
      }
      0x0F -> if (b.size >= 13) {
        base["iMACAddress"] = u8(b[3])
        base["bmEthernetStatistics"] = (u8(b[4]) or (u8(b[5]) shl 8) or (u8(b[6]) shl 16) or (u8(b[7]) shl 24))
        base["wMaxSegmentSize"] = le16(b[8], b[9])
        base["wNumberMCFilters"] = le16(b[10], b[11])
        base["bNumberPowerFilters"] = u8(b[12])
      }
    }
    return base
  }

  private fun parseClassSpecificEndpoint(b: ByteArray): Map<String, Any?>? {
    if (b.size < 3) return null
    return mapOf("bDescriptorSubType" to u8(b[2]))
  }

  private fun toHex(bytes: ByteArray, maxBytes: Int): String {
    val n = min(bytes.size, maxBytes)
    val sb = StringBuilder(n * 2)
    for (i in 0 until n) {
      sb.append(String.format(Locale.US, "%02x", u8(bytes[i])))
    }
    if (bytes.size > maxBytes) sb.append("…")
    return sb.toString()
  }

  private fun readStringLanguageIds(conn: UsbDeviceConnection): List<Int> {
    val buf = ByteArray(255)
    val r = conn.controlTransfer(0x80, 0x06, (0x03 shl 8) or 0, 0, buf, buf.size, 1200)
    if (r <= 2) return emptyList()
    if (u8(buf[1]) != 0x03) return emptyList()
    val out = ArrayList<Int>()
    var i = 2
    while (i + 1 < r) {
      out.add(le16(buf[i], buf[i + 1]))
      i += 2
    }
    return out
  }

  private fun pickPreferredLangId(languageIds: List<Int>): Int {
    if (languageIds.isEmpty()) return 0x0409
    if (languageIds.contains(0x0409)) return 0x0409
    return languageIds[0]
  }

  private fun readStringDescriptor(conn: UsbDeviceConnection, index: Int, langId: Int): String? {
    if (index <= 0) return null
    val buf = ByteArray(255)
    val r = conn.controlTransfer(0x80, 0x06, (0x03 shl 8) or (index and 0xFF), langId, buf, buf.size, 1200)
    if (r <= 2) return null
    if (u8(buf[1]) != 0x03) return null
    val len = min(u8(buf[0]), r)
    if (len <= 2) return null
    return try {
      val data = buf.copyOfRange(2, len)
      String(data, charset("UTF-16LE")).trim()
    } catch (_: Throwable) {
      null
    }
  }

  private fun readDeviceStrings(conn: UsbDeviceConnection, dd: Map<String, Any?>, langId: Int): Map<String, Any?> {
    val iMan = (dd["iManufacturer"] as? Int) ?: 0
    val iProd = (dd["iProduct"] as? Int) ?: 0
    val iSer = (dd["iSerialNumber"] as? Int) ?: 0
    val man = readStringDescriptor(conn, iMan, langId)
    val prod = readStringDescriptor(conn, iProd, langId)
    val ser = readStringDescriptor(conn, iSer, langId)
    return mapOf("manufacturer" to man, "product" to prod, "serial" to ser, "iManufacturer" to iMan, "iProduct" to iProd, "iSerialNumber" to iSer)
  }

  private fun readInterfaceStrings(conn: UsbDeviceConnection, tree: List<Map<String, Any?>>, langId: Int): List<Map<String, Any?>> {
    val out = ArrayList<Map<String, Any?>>()
    for (node in tree) {
      val t = node["descriptorType"] as? Int ?: continue
      if (t != 0x04) continue
      val fields = node["fields"] as? Map<*, *> ?: continue
      val ifNum = (fields["bInterfaceNumber"] as? Int) ?: continue
      val alt = (fields["bAlternateSetting"] as? Int) ?: 0
      val idx = (fields["iInterface"] as? Int) ?: 0
      if (idx <= 0) continue
      val value = readStringDescriptor(conn, idx, langId)
      out.add(mapOf("interfaceNumber" to ifNum, "alternateSetting" to alt, "iInterface" to idx, "value" to value))
    }
    return out
  }

  private fun readDeviceState(conn: UsbDeviceConnection, device: UsbDevice, tree: List<Map<String, Any?>>?): Map<String, Any?> {
    val activeCfg = ctrlGetConfiguration(conn)
    val status = ctrlGetStatus(conn)
    val ifAlt = readAltSettings(conn, device, tree)
    return mapOf(
      "activeConfiguration" to activeCfg,
      "deviceStatus" to status,
      "interfaceAltSettings" to ifAlt
    )
  }

  private fun ctrlGetConfiguration(conn: UsbDeviceConnection): Int? {
    val buf = ByteArray(1)
    val r = conn.controlTransfer(0x80, 0x08, 0, 0, buf, 1, 1200)
    if (r != 1) return null
    return u8(buf[0])
  }

  private fun ctrlGetStatus(conn: UsbDeviceConnection): Map<String, Any?>? {
    val buf = ByteArray(2)
    val r = conn.controlTransfer(0x80, 0x00, 0, 0, buf, 2, 1200)
    if (r != 2) return null
    val v = le16(buf[0], buf[1])
    val selfPowered = (v and 0x0001) != 0
    val remoteWakeup = (v and 0x0002) != 0
    return mapOf("raw" to v, "selfPowered" to selfPowered, "remoteWakeup" to remoteWakeup)
  }

  private fun readAltSettings(conn: UsbDeviceConnection, device: UsbDevice, tree: List<Map<String, Any?>>?): List<Map<String, Any?>> {
    val ifNums = HashSet<Int>()
    if (tree != null) {
      for (node in tree) {
        val t = node["descriptorType"] as? Int ?: continue
        if (t != 0x04) continue
        val fields = node["fields"] as? Map<*, *> ?: continue
        val n = fields["bInterfaceNumber"] as? Int ?: continue
        ifNums.add(n)
      }
    }
    if (ifNums.isEmpty()) {
      for (i in 0 until device.interfaceCount) {
        ifNums.add(device.getInterface(i).id)
      }
    }
    val out = ArrayList<Map<String, Any?>>()
    for (n in ifNums.sorted()) {
      val alt = ctrlGetInterface(conn, n)
      out.add(mapOf("interfaceNumber" to n, "alternateSetting" to alt))
    }
    return out
  }

  private fun ctrlGetInterface(conn: UsbDeviceConnection, interfaceNumber: Int): Int? {
    val buf = ByteArray(1)
    val r = conn.controlTransfer(0x81, 0x0A, 0, interfaceNumber, buf, 1, 1200)
    if (r != 1) return null
    return u8(buf[0])
  }

  private fun readHidReports(conn: UsbDeviceConnection, device: UsbDevice, tree: List<Map<String, Any?>>): List<Map<String, Any?>> {
    val out = ArrayList<Map<String, Any?>>()
    val hidByInterface = HashMap<Int, Int>()
    var currentIf: Int? = null
    for (node in tree) {
      val t = node["descriptorType"] as? Int ?: continue
      if (t == 0x04) {
        val fields = node["fields"] as? Map<*, *> ?: continue
        currentIf = fields["bInterfaceNumber"] as? Int
      } else if (t == 0x21) {
        val fields = node["fields"] as? Map<*, *> ?: continue
        val repLen = fields["reportDescriptorLength"] as? Int
        val ifNum = currentIf
        if (ifNum != null && repLen != null && repLen > 0) {
          hidByInterface[ifNum] = repLen
        }
      }
    }

    for ((ifNum, repLen) in hidByInterface.entries.sortedBy { it.key }) {
      val intf = findUsbInterfaceByNumber(device, ifNum)
      if (intf != null) {
        try { conn.claimInterface(intf, true) } catch (_: Throwable) { }
      }
      val bytes = ctrlGetHidReportDescriptor(conn, ifNum, repLen)
      if (intf != null) {
        try { conn.releaseInterface(intf) } catch (_: Throwable) { }
      }
      val hex = if (bytes == null) null else toHex(bytes, 4096)
      val summary = if (bytes == null) null else parseHidReportSummary(bytes)
      out.add(
        mapOf(
          "interfaceNumber" to ifNum,
          "reportLength" to repLen,
          "reportHex" to hex,
          "summary" to summary
        )
      )
    }
    return out
  }

  private fun findUsbInterfaceByNumber(device: UsbDevice, ifNum: Int): UsbInterface? {
    for (i in 0 until device.interfaceCount) {
      val intf = device.getInterface(i)
      if (intf.id == ifNum) return intf
    }
    return null
  }

  private fun ctrlGetHidReportDescriptor(conn: UsbDeviceConnection, interfaceNumber: Int, reportLen: Int): ByteArray? {
    val len = reportLen.coerceIn(1, 8192)
    val buf = ByteArray(len)
    val r = conn.controlTransfer(0x81, 0x06, (0x22 shl 8) or 0, interfaceNumber, buf, len, 1800)
    if (r <= 0) return null
    return if (r == buf.size) buf else buf.copyOf(r)
  }

  private fun parseHidReportSummary(bytes: ByteArray): Map<String, Any?> {
    val usagePages = LinkedHashSet<Int>()
    val reportIds = LinkedHashSet<Int>()
    var collections = 0
    var currentUsagePage = 0
    var seenKeyboard = false
    var seenMouse = false

    var i = 0
    while (i < bytes.size) {
      val b = u8(bytes[i])
      if (b == 0xFE) {
        if (i + 2 >= bytes.size) break
        val size = u8(bytes[i + 1])
        i += 3 + size
        continue
      }
      val sizeCode = b and 0x03
      val size = when (sizeCode) { 0 -> 0; 1 -> 1; 2 -> 2; else -> 4 }
      val type = (b ushr 2) and 0x03
      val tag = (b ushr 4) and 0x0F
      val dataStart = i + 1
      val dataEnd = min(bytes.size, dataStart + size)
      val value = readHidValue(bytes, dataStart, dataEnd)

      if (type == 1 && tag == 0x0) {
        currentUsagePage = value
        usagePages.add(value)
      } else if (type == 1 && tag == 0x8) {
        if (value in 1..255) reportIds.add(value)
      } else if (type == 2 && tag == 0x0) {
        if (currentUsagePage == 0x01 && value == 0x02) seenMouse = true
        if (currentUsagePage == 0x01 && value == 0x06) seenKeyboard = true
      } else if (type == 0 && tag == 0xA) {
        collections++
      }

      i = dataEnd
    }

    return mapOf(
      "usagePages" to usagePages.toList(),
      "reportIdCount" to reportIds.size,
      "collectionCount" to collections,
      "hasKeyboard" to seenKeyboard,
      "hasMouse" to seenMouse
    )
  }

  private fun readHidValue(bytes: ByteArray, start: Int, end: Int): Int {
    val len = end - start
    if (len <= 0) return 0
    var v = 0
    for (i in 0 until len) {
      v = v or (u8(bytes[start + i]) shl (8 * i))
    }
    return v
  }
}
