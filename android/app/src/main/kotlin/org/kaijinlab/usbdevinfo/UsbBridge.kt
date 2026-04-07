package org.kaijinlab.usbdevinfo

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.ComponentName
import android.content.pm.PackageInfo
import android.hardware.input.InputManager
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.media.midi.MidiDeviceInfo
import android.media.midi.MidiManager
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
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.util.Log
import android.view.InputDevice
import android.content.pm.PackageManager
import androidx.annotation.MainThread
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap
import kotlin.math.min

class UsbBridge(
  private val activity: Activity,
  messenger: BinaryMessenger,
  private val requestRuntimePermission: (String) -> Unit
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

  companion object {
    private const val sysfsDevicePrefix = "sysfs:"
  }

  private val tag = "USBDevInfo"
  private val permissionPrefsName = "usbdevinfo.runtime_permissions"
  private val permissionFailurePrefsName = "usbdevinfo.permission_failures"
  private val ctx: Context = activity.applicationContext
  private val usbManager: UsbManager = ctx.getSystemService(Context.USB_SERVICE) as UsbManager
  private val audioManager: AudioManager? = try { ctx.getSystemService(Context.AUDIO_SERVICE) as AudioManager } catch (_: Throwable) { null }
  private val midiManager: MidiManager? = if (Build.VERSION.SDK_INT >= 23) {
    try { ctx.getSystemService(Context.MIDI_SERVICE) as MidiManager } catch (_: Throwable) { null }
  } else {
    null
  }
  private val inputManager: InputManager? = try { ctx.getSystemService(Context.INPUT_SERVICE) as InputManager } catch (_: Throwable) { null }
  private val permissionPrefs by lazy { ctx.getSharedPreferences(permissionPrefsName, Context.MODE_PRIVATE) }
  private val permissionFailurePrefs by lazy { ctx.getSharedPreferences(permissionFailurePrefsName, Context.MODE_PRIVATE) }
  private val mainHandler = Handler(Looper.getMainLooper())
  private val methodChannel = MethodChannel(messenger, "usbdevinfo/methods")
  private val eventChannel = EventChannel(messenger, "usbdevinfo/events")
  private var eventSink: EventChannel.EventSink? = null
  private data class PendingRuntimePerm(
    val permission: String,
    val result: MethodChannel.Result,
    val deviceName: String?,
    val vid: Int?,
    val pid: Int?,
    val deviceClass: Int?
  )
  private val pendingCameraPermissionResults = mutableListOf<PendingRuntimePerm>()
  private data class PendingPerm(
    val originalName: String,
    val vid: Int,
    val pid: Int,
    val deviceClass: Int,
    val result: MethodChannel.Result,
    @Volatile var completed: Boolean = false
  )
  private val permissionByName = ConcurrentHashMap<String, PendingPerm>()
  private val permissionByVidPid = ConcurrentHashMap<String, PendingPerm>()
  private val permissionAction = "${ctx.packageName}.USB_PERMISSION"

  private val usbDeviceChangeReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      val action = intent.action ?: return
      if (action != UsbManager.ACTION_USB_DEVICE_ATTACHED && action != UsbManager.ACTION_USB_DEVICE_DETACHED) return
      val device: UsbDevice? = intent.getParcelableExtraCompat(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
      emitUsbDeviceChange(action, device?.deviceName)
    }
  }

  private val usbPermissionReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      if (intent.action != permissionAction) return
      val device: UsbDevice? = intent.getParcelableExtraCompat(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
      var granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
      val newName = device?.deviceName
      val vid = device?.vendorId ?: -1
      val pid = device?.productId ?: -1
      val key = if (vid >= 0 && pid >= 0) "$vid:$pid" else null

      var pending: PendingPerm? = null
      if (newName != null) pending = permissionByName.remove(newName)
      if (pending == null && key != null) pending = permissionByVidPid.remove(key)

      // Re-check actual hasPermission on any current instance of this VID:PID
      if (granted && vid >= 0 && pid >= 0) {
        val anyOk = try { usbManager.deviceList.values.any { it.vendorId == vid && it.productId == pid && usbManager.hasPermission(it) } } catch (_: Throwable) { false }
        if (!anyOk) granted = false
      }

      if (pending != null) {
        if (newName != null && newName != pending.originalName) {
          recordUsbFailure(
            deviceName = pending.originalName,
            vid = pending.vid,
            pid = pending.pid,
            reasonCode = "usb_reenumerated",
            message = "The USB device re-enumerated under a new Android path during permission flow."
          )
          emitEvent(mapOf(
            "type" to "permission_instance_changed",
            "originalName" to pending.originalName,
            "newName" to newName,
            "vid" to pending.vid,
            "pid" to pending.pid
          ))
        }
        if (!granted) {
          recordUsbFailure(
            deviceName = pending.originalName,
            vid = pending.vid,
            pid = pending.pid,
            reasonCode = "usb_permission_denied",
            message = "USB permission was denied or interrupted by Android."
          )
        }
        val finalState = when {
          newName != null && newName != pending.originalName -> "reenumerated"
          granted -> "granted"
          else -> "temporarily_denied"
        }
        logPermissionEvent(
          phase = "callback",
          permissionType = "usb",
          deviceName = pending.originalName,
          vid = pending.vid,
          pid = pending.pid,
          deviceClass = pending.deviceClass,
          callbackResult = granted,
          finalState = finalState
        )
        completePending(pending, granted)
      }

      emitEvent(mapOf("type" to "permission_result", "deviceName" to newName, "granted" to granted))
      emitUsbDeviceChange("permission_result", newName)
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
      emitUsbDeviceChange("activity_intent:$action", device?.deviceName)
    }
  }

  private fun registerReceiver() {
    val deviceFilter = IntentFilter().apply {
      addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
      addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
    }
    val permissionFilter = IntentFilter().apply {
      addAction(permissionAction)
    }
    if (Build.VERSION.SDK_INT >= 33) {
      ctx.registerReceiver(usbDeviceChangeReceiver, deviceFilter, Context.RECEIVER_NOT_EXPORTED)
      ctx.registerReceiver(usbPermissionReceiver, permissionFilter, Context.RECEIVER_NOT_EXPORTED)
    } else {
      @Suppress("DEPRECATION")
      ctx.registerReceiver(usbDeviceChangeReceiver, deviceFilter)
      @Suppress("DEPRECATION")
      ctx.registerReceiver(usbPermissionReceiver, permissionFilter)
    }
  }

  private fun unregisterReceiver() {
    try { ctx.unregisterReceiver(usbDeviceChangeReceiver) } catch (_: Throwable) { }
    try { ctx.unregisterReceiver(usbPermissionReceiver) } catch (_: Throwable) { }
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

  @MainThread
  private fun emitUsbDeviceChange(reason: String, deviceName: String?) {
    emitEvent(
      mapOf(
        "type" to "devices_changed",
        "reason" to reason,
        "deviceName" to deviceName
      )
    )
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    emitEvent(mapOf("type" to "ready"))
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }

  private fun completePending(p: PendingPerm, granted: Boolean) {
    p.completed = true
    try { p.result.success(granted) } catch (_: Throwable) {}
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    try {
      when (call.method) {
        "listDevices" -> result.success(listDevices())
        "getRuntimePermissionDiagnostics" -> result.success(
          getRuntimePermissionDiagnostics(
            deviceName = call.argument<String>("deviceName"),
            vid = call.argument<Int>("vendorId"),
            pid = call.argument<Int>("productId"),
            isAudio = call.argument<Boolean>("isAudio") == true,
            needsMicrophonePermission = call.argument<Boolean>("needsMicrophonePermission") == true,
            isVideo = call.argument<Boolean>("isVideo") == true,
            isInputDevice = call.argument<Boolean>("isInputDevice") == true,
            isHiddenDevice = call.argument<Boolean>("isHiddenDevice") == true,
            deviceClass = call.argument<Int>("deviceClass"),
            hasUsbPermissionHint = call.argument<Boolean>("hasUsbPermission")
          )
        )
        "requestCameraPermission" -> requestCameraPermission(
          result = result,
          deviceName = call.argument<String>("deviceName"),
          vid = call.argument<Int>("vendorId"),
          pid = call.argument<Int>("productId"),
          deviceClass = call.argument<Int>("deviceClass")
        )
        "requestPermission" -> {
          val deviceName = call.argument<String>("deviceName") ?: ""
          val vid = call.argument<Int>("vendorId")
          val pid = call.argument<Int>("productId")
          val serialNumber = call.argument<String>("serialNumber")
          val physicalLocationKey = call.argument<String>("physicalLocationKey")
          val interfaceFingerprint = call.argument<String>("interfaceFingerprint")
          val stableIdentityKey = call.argument<String>("stableIdentityKey")
          requestPermission(deviceName, result, vid, pid, serialNumber, physicalLocationKey, interfaceFingerprint, stableIdentityKey)
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

  fun onRuntimePermissionResult(permission: String, granted: Boolean) {
    when (permission) {
      Manifest.permission.CAMERA -> {
        val pending = pendingCameraPermissionResults.toList()
        pendingCameraPermissionResults.clear()
        val callbackDevice = pending.firstOrNull()
        emitEvent(mapOf("type" to "camera_permission_result", "granted" to granted))
        for (entry in pending) {
          try { entry.result.success(granted) } catch (_: Throwable) { }
        }
        logPermissionEvent(
          phase = "callback",
          permissionType = "camera",
          deviceName = callbackDevice?.deviceName,
          vid = callbackDevice?.vid,
          pid = callbackDevice?.pid,
          deviceClass = callbackDevice?.deviceClass,
          callbackResult = granted,
          finalState = runtimePermissionState(permission)["runtimeStatus"] as? String
        )
        if (!granted) {
          recordRuntimeFailure(
            permission = Manifest.permission.CAMERA,
            reasonCode = "camera_permission_denied",
            message = "Camera runtime permission was denied or interrupted by Android."
          )
        }
      }
    }
  }

  private fun getRuntimePermissionDiagnostics(
    deviceName: String? = null,
    vid: Int? = null,
    pid: Int? = null,
    isAudio: Boolean = false,
    needsMicrophonePermission: Boolean = false,
    isVideo: Boolean = false,
    isInputDevice: Boolean = false,
    isHiddenDevice: Boolean = false,
    deviceClass: Int? = null,
    hasUsbPermissionHint: Boolean? = null
  ): Map<String, Any?> {
    val device = findUsbDevice(deviceName, vid, pid)
    val hasUsbPermission = when {
      isInputDevice -> true
      isHiddenDevice -> false
      device != null -> safeGet { usbManager.hasPermission(device) } == true
      hasUsbPermissionHint != null -> hasUsbPermissionHint
      else -> false
    }
    val devicePresent = when {
      isInputDevice || isHiddenDevice -> true
      device != null -> true
      else -> false
    }
    val usbLastFailure = readUsbFailure(deviceName, vid, pid)
    val runtimeLastFailure = when {
      isVideo -> readRuntimeFailure(Manifest.permission.CAMERA)
      needsMicrophonePermission -> readRuntimeFailure(Manifest.permission.RECORD_AUDIO)
      else -> null
    }
    val lastFailure = usbLastFailure ?: runtimeLastFailure
    return mapOf(
      "microphone" to runtimePermissionState(Manifest.permission.RECORD_AUDIO),
      "camera" to runtimePermissionState(Manifest.permission.CAMERA),
      "usb" to usbPermissionDiagnostics(
        deviceName = deviceName,
        isInputDevice = isInputDevice,
        isHiddenDevice = isHiddenDevice,
        devicePresent = devicePresent,
        hasPermission = hasUsbPermission,
        lastFailure = usbLastFailure
      ),
      "device" to mapOf(
        "deviceName" to deviceName,
        "deviceClass" to deviceClass,
        "deviceClassLabel" to usbDeviceClassLabel(deviceClass),
        "isAudioClass" to isAudio,
        "isVideoClass" to isVideo,
        "isInputDevice" to isInputDevice,
        "isHiddenDevice" to isHiddenDevice
      ),
      "android" to mapOf(
        "sdkInt" to Build.VERSION.SDK_INT,
        "release" to (Build.VERSION.RELEASE ?: "Unknown"),
        "behaviorNotes" to androidBehaviorNotes(isAudio = needsMicrophonePermission, isVideo = isVideo, isHiddenDevice = isHiddenDevice)
      ),
      "lastFailure" to lastFailure
    )
  }

  private fun runtimePermissionState(permission: String): Map<String, Any?> {
    val declared = isPermissionDeclared(permission)
    val granted = declared && try {
      ContextCompat.checkSelfPermission(ctx, permission) == PackageManager.PERMISSION_GRANTED
    } catch (_: Throwable) {
      false
    }
    val wasRequested = wasPermissionRequested(permission)
    val shouldShowRationale = declared && !granted && try {
      ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
    } catch (_: Throwable) {
      false
    }
    return mapOf(
      "declared" to declared,
      "granted" to granted,
      "wasRequested" to wasRequested,
      "shouldShowRationale" to shouldShowRationale,
      "manifestStatus" to if (declared) "declared" else "missing",
      "runtimeStatus" to when {
        !declared -> "unavailable"
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M -> "not_required"
        granted -> "granted"
        wasRequested && shouldShowRationale -> "temporarily_denied"
        wasRequested && !shouldShowRationale -> "permanently_denied"
        else -> "missing"
      }
    )
  }

  private fun requestCameraPermission(
    result: MethodChannel.Result,
    deviceName: String? = null,
    vid: Int? = null,
    pid: Int? = null,
    deviceClass: Int? = null
  ) {
    if (!isPermissionDeclared(Manifest.permission.CAMERA) || Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      logPermissionEvent(
        phase = "attempt",
        permissionType = "camera",
        deviceName = deviceName,
        vid = vid,
        pid = pid,
        deviceClass = deviceClass,
        finalState = "not_required_or_not_declared"
      )
      result.success(true)
      return
    }
    val granted = try {
      ContextCompat.checkSelfPermission(ctx, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
    } catch (_: Throwable) {
      false
    }
    if (granted) {
      logPermissionEvent(
        phase = "attempt",
        permissionType = "camera",
        deviceName = deviceName,
        vid = vid,
        pid = pid,
        deviceClass = deviceClass,
        finalState = "already_granted"
      )
      result.success(true)
      return
    }

    pendingCameraPermissionResults.add(
      PendingRuntimePerm(
        permission = Manifest.permission.CAMERA,
        result = result,
        deviceName = deviceName,
        vid = vid,
        pid = pid,
        deviceClass = deviceClass
      )
    )
    if (pendingCameraPermissionResults.size > 1) return

    markPermissionRequested(Manifest.permission.CAMERA)
    logPermissionEvent(
      phase = "attempt",
      permissionType = "camera",
      deviceName = deviceName,
      vid = vid,
      pid = pid,
      deviceClass = deviceClass,
      finalState = "requested"
    )
    try {
      requestRuntimePermission(Manifest.permission.CAMERA)
    } catch (_: Throwable) {
      logPermissionEvent(
        phase = "final",
        permissionType = "camera",
        deviceName = deviceName,
        vid = vid,
        pid = pid,
        deviceClass = deviceClass,
        finalState = "request_failed"
      )
      recordRuntimeFailure(
        permission = Manifest.permission.CAMERA,
        reasonCode = "camera_permission_request_failed",
        message = "Android failed to start the camera permission request."
      )
      val pending = pendingCameraPermissionResults.toList()
      pendingCameraPermissionResults.clear()
      for (entry in pending) {
        try { entry.result.success(false) } catch (_: Throwable) { }
      }
    }
  }

  private fun isPermissionDeclared(permission: String): Boolean {
    val requested = try {
      val info: PackageInfo = if (Build.VERSION.SDK_INT >= 33) {
        ctx.packageManager.getPackageInfo(
          ctx.packageName,
          PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong())
        )
      } else {
        @Suppress("DEPRECATION")
        ctx.packageManager.getPackageInfo(ctx.packageName, PackageManager.GET_PERMISSIONS)
      }
      info.requestedPermissions?.toSet() ?: emptySet()
    } catch (_: Throwable) {
      emptySet()
    }
    return requested.contains(permission)
  }

  private fun wasPermissionRequested(permission: String): Boolean {
    return try {
      permissionPrefs.getBoolean("requested:$permission", false)
    } catch (_: Throwable) {
      false
    }
  }

  private fun markPermissionRequested(permission: String) {
    try {
      permissionPrefs.edit().putBoolean("requested:$permission", true).apply()
    } catch (_: Throwable) { }
  }

  private fun usbPermissionDiagnostics(
    deviceName: String?,
    isInputDevice: Boolean,
    isHiddenDevice: Boolean,
    devicePresent: Boolean,
    hasPermission: Boolean,
    lastFailure: Map<String, Any?>?
  ): Map<String, Any?> {
    val status: String
    val detail: String
    if (isInputDevice) {
      status = "not_applicable"
      detail = "InputManager devices do not use per-device UsbManager permission."
    } else if (isHiddenDevice) {
      status = "unavailable"
      detail = "Hidden sysfs topology entries are not eligible for UsbManager permission requests."
    } else if (!devicePresent) {
      status = "device_disconnected"
      detail = "Android no longer reports this USB device."
    } else if (hasPermission) {
      status = "granted"
      detail = "UsbManager permission is currently granted for this device."
    } else {
      val reasonCode = lastFailure?.get("reasonCode") as? String
      status = when (reasonCode) {
        "usb_permission_denied", "usb_permission_timeout" -> "temporarily_denied"
        "usb_reenumerated" -> "reenumerated"
        else -> "missing"
      }
      detail = (lastFailure?.get("message") as? String)
        ?: "Android blocks direct access until USB permission is granted."
    }
    return mapOf(
      "deviceName" to deviceName,
      "devicePresent" to devicePresent,
      "granted" to hasPermission,
      "status" to status,
      "detail" to detail
    )
  }

  private fun androidBehaviorNotes(
    isAudio: Boolean,
    isVideo: Boolean,
    isHiddenDevice: Boolean
  ): List<String> {
    val notes = ArrayList<String>()
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      notes.add("Android ${Build.VERSION.SDK_INT} uses runtime permissions for dangerous permissions such as microphone and camera.")
    } else {
      notes.add("Android ${Build.VERSION.SDK_INT} grants manifest-declared microphone and camera permissions at install time.")
    }
    if (isAudio && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      notes.add("Android 11+ may warn and ignore 'always use' for direct USB audio capture if RECORD_AUDIO is not granted.")
    }
    if (isVideo && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      notes.add("Android 9+ requires CAMERA before USB video-class permission can be granted.")
    }
    if (isHiddenDevice) {
      notes.add("Sysfs topology entries are outside normal UsbManager enumeration, so Android framework permission does not apply.")
    }
    return notes
  }

  private fun usbDeviceClassLabel(deviceClass: Int?): String {
    return when (deviceClass) {
      null -> "Unknown"
      0 -> "Defined at interface level"
      UsbConstants.USB_CLASS_AUDIO -> "Audio"
      UsbConstants.USB_CLASS_COMM -> "CDC / communications"
      UsbConstants.USB_CLASS_HID -> "HID"
      UsbConstants.USB_CLASS_PHYSICA -> "Physical"
      UsbConstants.USB_CLASS_PRINTER -> "Printer"
      UsbConstants.USB_CLASS_MASS_STORAGE -> "Mass storage"
      UsbConstants.USB_CLASS_HUB -> "Hub"
      UsbConstants.USB_CLASS_CDC_DATA -> "CDC data"
      14 -> "Video"
      else -> "Class $deviceClass"
    }
  }

  private fun permissionFailureKey(deviceName: String?, vid: Int?, pid: Int?): String {
    return when {
      vid != null && pid != null && vid > 0 && pid > 0 -> "vidpid:$vid:$pid"
      !deviceName.isNullOrBlank() -> "name:$deviceName"
      else -> "global"
    }
  }

  private fun recordUsbFailure(
    deviceName: String?,
    vid: Int?,
    pid: Int?,
    reasonCode: String,
    message: String
  ) {
    recordFailure(
      namespace = "usb",
      key = permissionFailureKey(deviceName, vid, pid),
      scope = "usb",
      reasonCode = reasonCode,
      message = message
    )
  }

  private fun recordRuntimeFailure(permission: String, reasonCode: String, message: String) {
    recordFailure(
      namespace = "runtime",
      key = permission,
      scope = permission,
      reasonCode = reasonCode,
      message = message
    )
  }

  private fun logPermissionEvent(
    phase: String,
    permissionType: String,
    deviceName: String? = null,
    vid: Int? = null,
    pid: Int? = null,
    deviceClass: Int? = null,
    callbackResult: Boolean? = null,
    finalState: String? = null
  ) {
    val parts = linkedMapOf<String, String>()
    parts["phase"] = phase
    parts["permission"] = permissionType
    if (!deviceName.isNullOrBlank()) parts["device"] = deviceName
    if (vid != null && vid >= 0) parts["vid"] = String.format(Locale.US, "0x%04X", vid)
    if (pid != null && pid >= 0) parts["pid"] = String.format(Locale.US, "0x%04X", pid)
    if (deviceClass != null && deviceClass >= 0) parts["deviceClass"] = "$deviceClass"
    if (callbackResult != null) parts["callbackResult"] = callbackResult.toString()
    if (!finalState.isNullOrBlank()) parts["finalState"] = finalState
    Log.i(tag, "permission_event ${parts.entries.joinToString(" ") { "${it.key}=${it.value}" }}")
  }

  private fun recordFailure(
    namespace: String,
    key: String,
    scope: String,
    reasonCode: String,
    message: String
  ) {
    try {
      permissionFailurePrefs.edit()
        .putString("$namespace:$key:scope", scope)
        .putString("$namespace:$key:reason", reasonCode)
        .putString("$namespace:$key:message", message)
        .putLong("$namespace:$key:time", System.currentTimeMillis())
        .apply()
    } catch (_: Throwable) { }
  }

  private fun readUsbFailure(deviceName: String?, vid: Int?, pid: Int?): Map<String, Any?>? {
    val keys = linkedSetOf<String>()
    keys.add(permissionFailureKey(deviceName, vid, pid))
    if (!deviceName.isNullOrBlank()) keys.add("name:$deviceName")
    if (vid != null && pid != null && vid > 0 && pid > 0) keys.add("vidpid:$vid:$pid")
    for (key in keys) {
      val out = readFailure("usb", key)
      if (out != null) return out
    }
    return null
  }

  private fun readRuntimeFailure(permission: String): Map<String, Any?>? {
    return readFailure("runtime", permission)
  }

  private fun readFailure(namespace: String, key: String): Map<String, Any?>? {
    return try {
      val reason = permissionFailurePrefs.getString("$namespace:$key:reason", null) ?: return null
      mapOf(
        "scope" to permissionFailurePrefs.getString("$namespace:$key:scope", null),
        "reasonCode" to reason,
        "message" to permissionFailurePrefs.getString("$namespace:$key:message", null),
        "timestampMs" to permissionFailurePrefs.getLong("$namespace:$key:time", 0L)
      )
    } catch (_: Throwable) {
      null
    }
  }

  private fun findUsbDevice(
    deviceName: String?,
    vidArg: Int?,
    pidArg: Int?,
    serialHint: String? = null,
    physicalLocationKeyHint: String? = null,
    interfaceFingerprintHint: String? = null,
    stableIdentityKeyHint: String? = null
  ): UsbDevice? {
    val byName = if (!deviceName.isNullOrBlank()) findUsbByName(deviceName) else null
    if (byName != null) return byName
    val candidates = try {
      val all = usbManager.deviceList.values.toList()
      if (vidArg != null && pidArg != null && vidArg > 0 && pidArg > 0) {
        all.filter { it.vendorId == vidArg && it.productId == pidArg }
      } else {
        all
      }
    } catch (_: Throwable) {
      emptyList()
    }
    if (candidates.isEmpty()) return null
    if (candidates.size == 1) return candidates.first()

    val serialNorm = normalizeIdentityPart(serialHint)
    val stableHint = stableIdentityKeyHint?.trim()?.takeIf { it.isNotEmpty() }
    var bestScore = Int.MIN_VALUE
    var best: UsbDevice? = null
    for (candidate in candidates) {
      val summary = deviceSummaryUsb(candidate)
      var score = 0
      if (stableHint != null && stableHint == (summary["stableIdentityKey"] as? String)) score += 1000
      val continuityKeys = (summary["continuityKeys"] as? List<*>)?.filterIsInstance<String>() ?: emptyList()
      if (stableHint != null && continuityKeys.contains(stableHint)) score += 700
      if (serialNorm != null && serialNorm == normalizeIdentityPart(summary["serialNumber"] as? String)) score += 600
      if (!physicalLocationKeyHint.isNullOrBlank() && physicalLocationKeyHint == summary["physicalLocationKey"] as? String) score += 450
      if (!interfaceFingerprintHint.isNullOrBlank() && interfaceFingerprintHint == summary["interfaceFingerprint"] as? String) score += 250
      if (!deviceName.isNullOrBlank() && deviceName == summary["deviceName"] as? String) score += 2000
      if (score > bestScore) {
        bestScore = score
        best = candidate
      }
    }
    return best ?: candidates.firstOrNull()
  }

  private fun listDevices(): List<Map<String, Any?>> {
    val usb = usbManager.deviceList.values.toList()
    val out = ArrayList<Map<String, Any?>>(usb.size + 16)
    val usbVidPid = HashSet<String>(usb.size * 2)
    val frameworkPaths = HashSet<String>(usb.size * 2)
    for (d in usb) {
      usbVidPid.add("${d.vendorId}:${d.productId}")
      frameworkPaths.add(d.deviceName)
      out.add(deviceSummaryUsb(d))
    }
    out.addAll(listSysfsHiddenDevices(frameworkPaths, usbVidPid))
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

  private fun requestPermission(
    deviceName: String,
    result: MethodChannel.Result,
    vidArg: Int?,
    pidArg: Int?,
    serialNumber: String?,
    physicalLocationKey: String?,
    interfaceFingerprint: String?,
    stableIdentityKey: String?
  ) {
    if (isInputKey(deviceName)) {
      logPermissionEvent(
        phase = "attempt",
        permissionType = "usb",
        deviceName = deviceName,
        vid = vidArg,
        pid = pidArg,
        deviceClass = UsbConstants.USB_CLASS_HID,
        finalState = "not_applicable_input_device"
      )
      result.success(true)
      return
    }
    if (isSysfsDeviceName(deviceName)) {
      logPermissionEvent(
        phase = "attempt",
        permissionType = "usb",
        deviceName = deviceName,
        vid = vidArg,
        pid = pidArg,
        finalState = "unavailable_hidden_topology"
      )
      recordUsbFailure(
        deviceName = deviceName,
        vid = vidArg,
        pid = pidArg,
        reasonCode = "usb_hidden_topology_entry",
        message = "Android cannot request UsbManager permission for hidden sysfs topology entries."
      )
      result.success(false)
      return
    }
    val device = findUsbDevice(
      deviceName,
      vidArg,
      pidArg,
      serialHint = serialNumber,
      physicalLocationKeyHint = physicalLocationKey,
      interfaceFingerprintHint = interfaceFingerprint,
      stableIdentityKeyHint = stableIdentityKey
    )
    if (device == null) {
      logPermissionEvent(
        phase = "attempt",
        permissionType = "usb",
        deviceName = deviceName,
        vid = vidArg,
        pid = pidArg,
        finalState = "device_disconnected"
      )
      recordUsbFailure(
        deviceName = deviceName,
        vid = vidArg,
        pid = pidArg,
        reasonCode = "device_disconnected",
        message = "The USB device is no longer present, so Android cannot request USB permission."
      )
      result.success(false)
      return
    }
    val deviceClass = device.deviceClass
    if (usbManager.hasPermission(device)) {
      logPermissionEvent(
        phase = "attempt",
        permissionType = "usb",
        deviceName = device.deviceName,
        vid = device.vendorId,
        pid = device.productId,
        deviceClass = deviceClass,
        finalState = "already_granted"
      )
      result.success(true)
      return
    }

    val vid = device.vendorId
    val pid = device.productId
    val key = "$vid:$pid"

    // Replace any existing pending entries for this device
    permissionByName.remove(deviceName)?.let { /* drop */ }
    permissionByVidPid.remove(key)?.let { /* drop */ }

    val pending = PendingPerm(deviceName, vid, pid, deviceClass, result)
    permissionByName[deviceName] = pending
    permissionByVidPid[key] = pending
    logPermissionEvent(
      phase = "attempt",
      permissionType = "usb",
      deviceName = device.deviceName,
      vid = vid,
      pid = pid,
      deviceClass = deviceClass,
      finalState = "requested"
    )

    val baseFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
    val flags = baseFlags or PendingIntent.FLAG_UPDATE_CURRENT
    val intent = Intent(permissionAction).setPackage(ctx.packageName)
    val pendingIntent = PendingIntent.getBroadcast(ctx, deviceName.hashCode(), intent, flags)
    usbManager.requestPermission(device, pendingIntent)

    // Fallback timeout: if broadcast is lost or device re-enumerates, re-check hasPermission shortly
    mainHandler.postDelayed({
      if (pending.completed) return@postDelayed
      val still = permissionByVidPid.remove(key)
      if (still != null && !still.completed) {
        // Look for any connected device with the same VID:PID that already has permission
        val match = usbManager.deviceList.values.firstOrNull { it.vendorId == vid && it.productId == pid && usbManager.hasPermission(it) }
        val ok = match != null
        permissionByName.remove(still.originalName)
        completePending(still, ok)
        logPermissionEvent(
          phase = "final",
          permissionType = "usb",
          deviceName = still.originalName,
          vid = vid,
          pid = pid,
          deviceClass = still.deviceClass,
          callbackResult = ok,
          finalState = if (ok) "granted_after_timeout_recheck" else "timeout"
        )
        if (!ok) {
          recordUsbFailure(
            deviceName = still.originalName,
            vid = vid,
            pid = pid,
            reasonCode = "usb_permission_timeout",
            message = "Android did not deliver a stable USB permission result before timeout."
          )
        }
        emitEvent(mapOf(
          "type" to if (ok) "permission_timeout_granted" else "permission_timeout_failed",
          "originalName" to still.originalName,
          "vid" to vid,
          "pid" to pid
        ))
      }
    }, 1500L)
  }

  private fun getDeviceDetails(deviceName: String): Map<String, Any?> {
    if (isInputKey(deviceName)) {
      val id = parseInputId(deviceName)
      val dev = if (id == null) null else safeGet { inputManager?.getInputDevice(id) }
      if (dev == null) {
        val summary = mapOf(
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
        )
        val issues = listOf(
          availabilityIssue(
            scope = "device",
            reasonCode = "device_disconnected",
            message = "Device disconnected. Android no longer reports this input device."
          )
        )
        return mapOf(
          "summary" to summary,
          "interfaces" to emptyList<Map<String, Any?>>(),
          "configurations" to emptyList<Map<String, Any?>>(),
          "deviceDescriptor" to null,
          "input" to null,
          "audio" to null,
          "midi" to null,
          "topology" to null,
          "identity" to identityFromSummary(summary),
          "descriptorTree" to null,
          "strings" to null,
          "hidReports" to null,
          "deviceState" to null,
          "availabilityIssues" to issues
        )
      }
      val vid = inputVendorId(dev)
      val pid = inputProductId(dev)
      val summary = deviceSummaryInput(dev, vid, pid)
      return mapOf(
        "summary" to summary,
        "interfaces" to emptyList<Map<String, Any?>>(),
        "configurations" to emptyList<Map<String, Any?>>(),
        "deviceDescriptor" to null,
        "input" to buildInputDetails(dev, vid, pid),
        "audio" to null,
        "midi" to null,
        "topology" to null,
        "identity" to identityFromSummary(summary),
        "descriptorTree" to null,
        "strings" to null,
        "hidReports" to null,
        "deviceState" to null,
        "availabilityIssues" to emptyList<Map<String, Any?>>()
      )
    }

    if (isSysfsDeviceName(deviceName)) {
      val sysfs = findSysfsEntryByDeviceName(deviceName)
      val issues = ArrayList<Map<String, Any?>>()
      if (sysfs == null) {
        issues.add(
          availabilityIssue(
            scope = "device",
            reasonCode = "device_disconnected",
            message = "Device disconnected. The sysfs topology entry is no longer present."
          )
        )
      } else {
        issues.add(
          availabilityIssue(
            scope = "usb_access",
            reasonCode = "framework_hidden_topology_entry",
            message = "Android framework does not expose this hidden topology entry through UsbManager."
          )
        )
        issues.add(
          availabilityIssue(
            scope = "direct_usb_details",
            reasonCode = "selinux_sysfs_restriction",
            message = "Blocked by SELinux/sysfs restriction. Hidden topology entries cannot be opened for direct descriptor, string, or state reads."
          )
        )
      }
      val summary = sysfs?.summary ?: mapOf(
        "deviceName" to deviceName,
        "vendorId" to 0,
        "productId" to 0,
        "deviceClass" to 0,
        "deviceSubclass" to 0,
        "deviceProtocol" to 0,
        "interfaceCount" to 0,
        "configurationCount" to 0,
        "hasPermission" to false,
        "isInputDevice" to false,
        "isHiddenDevice" to true
      )
      return mapOf(
        "summary" to summary,
        "interfaces" to emptyList<Map<String, Any?>>(),
        "configurations" to emptyList<Map<String, Any?>>(),
        "deviceDescriptor" to null,
        "input" to null,
        "audio" to null,
        "midi" to null,
        "topology" to sysfs?.topology,
        "identity" to identityFromSummary(summary),
        "descriptorTree" to null,
        "strings" to null,
        "hidReports" to null,
        "deviceState" to null,
        "availabilityIssues" to issues
      )
    }

    val device = findUsbByName(deviceName) ?: run {
      val summary = mapOf(
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
      )
      val issues = listOf(
        availabilityIssue(
          scope = "device",
          reasonCode = "device_disconnected",
          message = "Device disconnected. Android no longer reports this USB device."
        )
      )
      return mapOf(
        "summary" to summary,
        "interfaces" to emptyList<Map<String, Any?>>(),
        "configurations" to emptyList<Map<String, Any?>>(),
        "deviceDescriptor" to null,
        "input" to null,
        "audio" to null,
        "midi" to null,
        "topology" to null,
        "identity" to identityFromSummary(summary),
        "descriptorTree" to null,
        "strings" to null,
        "hidReports" to null,
        "deviceState" to null,
        "availabilityIssues" to issues
      )
    }

    val hasPerm = usbManager.hasPermission(device)
    val summary0 = deviceSummaryUsb(device)
    val interfaces0 = buildInterfaces(device)
    val configurations0 = buildConfigurations(device)
    val deviceDescriptor0 = readDeviceDescriptor(device)
    val audio0 = buildAudioDetails(device, summary0)
    val midi0 = buildMidiDetails(device, summary0)
    val topology0 = topologyFromUsbSummary(summary0)
    val baseIssues = buildDeviceAdvisories(device)

    if (!hasPerm) {
      val issues = ArrayList<Map<String, Any?>>(baseIssues.size + 4)
      issues.addAll(baseIssues)
      issues.add(
        availabilityIssue(
          scope = "usb_permission",
          reasonCode = "no_usb_permission",
          message = "No USB permission. Android blocks direct access to raw descriptors, string descriptors, HID reports, and live device state until access is granted."
        )
      )
      return mapOf(
        "summary" to summary0,
        "interfaces" to interfaces0,
        "configurations" to configurations0,
        "deviceDescriptor" to deviceDescriptor0,
        "input" to null,
        "audio" to audio0,
        "midi" to midi0,
        "topology" to topology0,
        "identity" to identityFromSummary(summary0),
        "descriptorTree" to null,
        "strings" to null,
        "hidReports" to null,
        "deviceState" to null,
        "availabilityIssues" to issues
      )
    }

    var conn: UsbDeviceConnection? = null
    try {
      conn = usbManager.openDevice(device)
      if (conn == null) {
        val issues = ArrayList<Map<String, Any?>>(baseIssues.size + 2)
        issues.addAll(baseIssues)
        issues.add(
          availabilityIssue(
            scope = "usb_open",
            reasonCode = "usb_open_failed",
            message = "Android granted USB permission, but opening the device failed. The device may have disconnected or the framework refused direct access."
          )
        )
        return mapOf(
          "summary" to summary0,
          "interfaces" to interfaces0,
          "configurations" to configurations0,
          "deviceDescriptor" to deviceDescriptor0,
          "input" to null,
          "audio" to audio0,
          "midi" to midi0,
          "topology" to topology0,
          "identity" to identityFromSummary(summary0),
          "descriptorTree" to null,
          "strings" to null,
          "hidReports" to null,
          "deviceState" to null,
          "availabilityIssues" to issues
        )
      }

      val raw = tryGetRawDescriptors(conn)
      val tree = if (raw == null) null else parseDescriptorTree(raw)
      val dd = deviceDescriptor0 ?: (if (raw == null) null else parseDeviceDescriptorFromRaw(raw))

      val controlTransfers = ArrayList<Map<String, Any?>>()
      val languages = readStringLanguageIds(conn, controlTransfers)
      val preferredLang = pickPreferredLangId(languages)

      val deviceStrings = if (dd == null) null else readDeviceStrings(conn, dd, preferredLang, controlTransfers)
      val interfaceStrings = if (tree == null) null else readInterfaceStrings(conn, tree, preferredLang, controlTransfers)

      val stringsBlock = mapOf(
        "languageIds" to languages,
        "preferredLanguageId" to preferredLang,
        "device" to deviceStrings,
        "interfaces" to interfaceStrings
      )

      val stateBlock = readDeviceState(conn, device, tree, controlTransfers)

      val hidReports = if (tree == null) emptyList<Map<String, Any?>>() else readHidReports(conn, device, tree, controlTransfers)

      val summary = mergeSummaryStrings(summary0, deviceStrings)
      val issues = ArrayList<Map<String, Any?>>(baseIssues)
      if (raw == null) {
        issues.add(
          availabilityIssue(
            scope = "raw_descriptors",
            reasonCode = "framework_not_exposed",
            message = "Android framework does not expose raw USB descriptors for this device on this build."
          )
        )
      }
      if (deviceStrings == null) {
        issues.add(
          availabilityIssue(
            scope = "string_descriptors",
            reasonCode = if (dd == null) "raw_descriptors_missing" else "string_read_failed",
            message = if (dd == null) {
              "String descriptors are unavailable because raw descriptor metadata could not be read."
            } else {
              "String descriptors were not returned by the device or Android did not expose them."
            }
          )
        )
      }
      if (tree != null && hidReports.isEmpty() && hasHidInterface(device)) {
        issues.add(
          availabilityIssue(
            scope = "hid_reports",
            reasonCode = "hid_report_unavailable",
            message = "Android did not expose a HID report descriptor for this HID interface."
          )
        )
      }

      return mapOf(
        "summary" to summary,
        "interfaces" to interfaces0,
        "configurations" to configurations0,
        "deviceDescriptor" to dd,
        "input" to null,
        "audio" to audio0,
        "midi" to midi0,
        "topology" to topology0,
        "identity" to identityFromSummary(summary),
        "descriptorTree" to tree,
        "strings" to stringsBlock,
        "hidReports" to hidReports,
        "deviceState" to stateBlock,
        "controlTransfers" to controlTransfers,
        "availabilityIssues" to issues
      )
    } catch (_: Throwable) {
      val issues = ArrayList<Map<String, Any?>>(baseIssues.size + 2)
      issues.addAll(baseIssues)
      issues.add(
        availabilityIssue(
          scope = "direct_usb_details",
          reasonCode = "device_disconnected_or_framework_error",
          message = "Direct USB reads failed. The device may have disconnected or Android returned a framework error."
        )
      )
      return mapOf(
        "summary" to summary0,
        "interfaces" to interfaces0,
        "configurations" to configurations0,
        "deviceDescriptor" to deviceDescriptor0,
        "input" to null,
        "audio" to audio0,
        "midi" to midi0,
        "topology" to topology0,
        "identity" to identityFromSummary(summary0),
        "descriptorTree" to null,
        "strings" to null,
        "hidReports" to null,
        "deviceState" to null,
        "availabilityIssues" to issues
      )
    } finally {
      try { conn?.close() } catch (_: Throwable) { }
    }
  }

  private fun availabilityIssue(
    scope: String,
    reasonCode: String,
    message: String,
    status: String = "unavailable"
  ): Map<String, Any?> {
    return mapOf(
      "scope" to scope,
      "reasonCode" to reasonCode,
      "status" to status,
      "message" to message
    )
  }

  private fun buildDeviceAdvisories(device: UsbDevice): List<Map<String, Any?>> {
    val issues = ArrayList<Map<String, Any?>>()
    if (hasAudioClass(device)) {
      val mic = runtimePermissionState(Manifest.permission.RECORD_AUDIO)
      if (mic["declared"] != true) {
        issues.add(
          availabilityIssue(
            scope = "direct_audio_capture",
            reasonCode = "record_audio_not_declared",
            status = "advisory",
            message = "Requires RECORD_AUDIO for direct audio capture device access. This build does not request microphone permission."
          )
        )
      } else if (mic["granted"] != true) {
        issues.add(
          availabilityIssue(
            scope = "direct_audio_capture",
            reasonCode = "record_audio_not_granted",
            status = "advisory",
            message = "Requires RECORD_AUDIO for direct audio capture device access. Microphone permission is not currently granted."
          )
        )
      }
    }
    if (hasVideoClass(device) && Build.VERSION.SDK_INT >= 28) {
      val camera = runtimePermissionState(Manifest.permission.CAMERA)
      if (camera["declared"] != true) {
        issues.add(
          availabilityIssue(
            scope = "usb_video",
            reasonCode = "camera_not_declared",
            status = "advisory",
            message = "Requires CAMERA for USB video device access on this Android version. This build is missing the camera permission declaration."
          )
        )
      } else if (camera["granted"] != true) {
        issues.add(
          availabilityIssue(
            scope = "usb_video",
            reasonCode = "camera_not_granted",
            status = "advisory",
            message = "Requires CAMERA for USB video device access on this Android version. Camera permission is not currently granted."
          )
        )
      }
    }
    return issues
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

  private data class SysfsDeviceEntry(
    val summary: Map<String, Any?>,
    val topology: Map<String, Any?>
  )

  private fun isSysfsDeviceName(deviceName: String): Boolean = deviceName.startsWith(sysfsDevicePrefix)

  private fun findSysfsEntryByDeviceName(deviceName: String): SysfsDeviceEntry? {
    val sysfsName = deviceName.removePrefix(sysfsDevicePrefix)
    val dir = File("/sys/bus/usb/devices", sysfsName)
    return readSysfsDeviceEntry(dir, emptySet(), emptySet())
  }

  private fun listSysfsHiddenDevices(
    frameworkPaths: Set<String>,
    usbVidPid: Set<String>
  ): List<Map<String, Any?>> {
    val root = File("/sys/bus/usb/devices")
    val dirs = safeGet { root.listFiles()?.toList() } ?: return emptyList()
    val out = ArrayList<Map<String, Any?>>()
    for (dir in dirs) {
      val entry = readSysfsDeviceEntry(dir, frameworkPaths, usbVidPid) ?: continue
      out.add(entry.summary)
    }
    return out
  }

  private fun readSysfsDeviceEntry(
    dir: File,
    frameworkPaths: Set<String>,
    usbVidPid: Set<String>
  ): SysfsDeviceEntry? {
    val name = dir.name
    if (!dir.isDirectory) return null
    if (name.contains(":")) return null
    if (name == "usbmon0") return null

    val vendor = readHexFile(dir, "idVendor")
    val product = readHexFile(dir, "idProduct")
    val busNum = readIntFile(dir, "busnum")
    val devNum = readIntFile(dir, "devnum")
    val devPath = if (busNum != null && devNum != null) {
      "/dev/bus/usb/${busNum.toString().padStart(3, '0')}/${devNum.toString().padStart(3, '0')}"
    } else {
      null
    }
    if (devPath != null && frameworkPaths.contains(devPath)) return null
    if (vendor != null && product != null && devPath == null && usbVidPid.contains("$vendor:$product")) return null

    val deviceClass = readHexFile(dir, "bDeviceClass") ?: 0
    val deviceSubclass = readHexFile(dir, "bDeviceSubClass") ?: 0
    val deviceProtocol = readHexFile(dir, "bDeviceProtocol") ?: 0
    val interfaceCount = readIntFile(dir, "bNumInterfaces") ?: 0
    val configurationCount = readIntFile(dir, "bNumConfigurations") ?: 0
    val manufacturer = readTextFile(dir, "manufacturer")
    val productName = readTextFile(dir, "product")
    val serial = readTextFile(dir, "serial")
    val usbVersion = readTextFile(dir, "version")
    val speed = readTextFile(dir, "speed")
    val maxPowerMa = readSysfsPowerMa(dir)
    val parentName = safeGet { dir.canonicalFile.parentFile?.name }
      ?.takeIf { it.isNotBlank() && it != "devices" && !it.contains(":") }
    val devpath = readTextFile(dir, "devpath")
    val portChain = parsePortChain(devpath, name)
    val treeDepth = portChain.size
    val upstreamHub = when {
      parentName.isNullOrBlank() && busNum != null -> "Root hub usb$busNum"
      parentName.isNullOrBlank() -> null
      parentName.startsWith("usb") -> "Root hub $parentName"
      else -> parentName
    }
    val children = safeGet {
      dir.listFiles()?.mapNotNull { child ->
        val childName = child.name
        if (!child.isDirectory || childName.contains(":")) null else childName
      }?.sorted()
    } ?: emptyList()
    val siblings = if (parentName == null) {
      emptyList()
    } else {
      safeGet {
        dir.canonicalFile.parentFile?.listFiles()?.mapNotNull { child ->
          val childName = child.name
          if (!child.isDirectory || childName == name || childName.contains(":")) null else childName
        }?.sorted()
      } ?: emptyList()
    }

    val interfaceFingerprint = "sysfs:$deviceClass:$deviceSubclass:$deviceProtocol:$interfaceCount"
    val identity = buildStableIdentityMap(
      deviceName = "$sysfsDevicePrefix$name",
      vendorId = vendor ?: 0,
      productId = product ?: 0,
      deviceClass = deviceClass,
      deviceSubclass = deviceSubclass,
      deviceProtocol = deviceProtocol,
      serialNumber = serial,
      interfaceFingerprint = interfaceFingerprint,
      busNumber = busNum,
      portChain = portChain,
      portNumber = null,
      isInputDevice = false
    )
    val summary = mapOf(
      "capabilities" to buildCapabilityBadges(
        deviceClass = deviceClass,
        deviceSubclass = deviceSubclass,
        interfaces = emptyList(),
        isInputDevice = false,
        inputSources = emptyList()
      ),
      "deviceName" to "$sysfsDevicePrefix$name",
      "deviceId" to null,
      "portNumber" to null,
      "vendorId" to (vendor ?: 0),
      "productId" to (product ?: 0),
      "deviceClass" to deviceClass,
      "deviceSubclass" to deviceSubclass,
      "deviceProtocol" to deviceProtocol,
      "interfaceCount" to interfaceCount,
      "configurationCount" to configurationCount,
      "hasPermission" to false,
      "manufacturerName" to manufacturer,
      "productName" to productName,
      "serialNumber" to serial,
      "usbVersion" to usbVersion,
      "speed" to speed,
      "maxPowerMa" to maxPowerMa,
      "isInputDevice" to false,
      "isHiddenDevice" to true,
      "stableIdentityKey" to identity["stableIdentityKey"],
      "identityConfidence" to identity["identityConfidence"],
      "identityStrategy" to identity["identityStrategy"],
      "physicalLocationKey" to identity["physicalLocationKey"],
      "interfaceFingerprint" to identity["interfaceFingerprint"],
      "continuityKeys" to identity["continuityKeys"]
    )
    val topology = mapOf(
      "source" to "sysfs",
      "sysfsName" to name,
      "sysfsPath" to dir.absolutePath,
      "busNumber" to busNum,
      "deviceNumber" to devNum,
      "devPath" to devPath,
      "parentSysfsName" to parentName,
      "upstreamHub" to upstreamHub,
      "children" to children,
      "siblings" to siblings,
      "devpath" to devpath,
      "treeDepth" to treeDepth,
      "portChain" to portChain,
      "speed" to speed,
      "usbVersion" to usbVersion,
      "maxPowerRaw" to readTextFile(dir, "bMaxPower"),
      "maxChild" to readIntFile(dir, "maxchild"),
      "removable" to readTextFile(dir, "removable"),
      "authorized" to readIntFile(dir, "authorized")
    )
    return SysfsDeviceEntry(summary, topology)
  }

  private fun parsePortChain(devpath: String?, sysfsName: String): List<Int> {
    val raw = when {
      !devpath.isNullOrBlank() -> devpath
      sysfsName.contains('-') -> sysfsName.substringAfter('-', "")
      else -> ""
    }.trim()
    if (raw.isEmpty()) return emptyList()
    return raw.split('.')
      .mapNotNull { it.trim().toIntOrNull() }
  }

  private fun readTextFile(dir: File, name: String): String? {
    val value = safeGet { File(dir, name).readText(Charsets.UTF_8).trim() } ?: return null
    return value.ifBlank { null }
  }

  private fun readIntFile(dir: File, name: String): Int? {
    val text = readTextFile(dir, name) ?: return null
    return text.toIntOrNull()
  }

  private fun readHexFile(dir: File, name: String): Int? {
    val text = readTextFile(dir, name) ?: return null
    return text.toIntOrNull(16)
  }

  private fun readSysfsPowerMa(dir: File): Int? {
    val raw = readTextFile(dir, "bMaxPower") ?: return null
    val digits = raw.filter { it.isDigit() }
    if (digits.isEmpty()) return null
    return digits.toIntOrNull()
  }

  private fun topologyFromUsbSummary(summary: Map<String, Any?>): Map<String, Any?>? {
    val deviceName = summary["deviceName"] as? String ?: return null
    if (!deviceName.startsWith("/dev/bus/usb/")) return null
    val parts = deviceName.split('/').filter { it.isNotEmpty() }
    if (parts.size < 4) return null
    val busNum = parts.getOrNull(parts.size - 2)?.toIntOrNull()
    val devNum = parts.lastOrNull()?.toIntOrNull()
    val portNumber = summary["portNumber"] as? Int
    val portChain = if (portNumber == null || portNumber <= 0) emptyList() else listOf(portNumber)
    return mapOf(
      "source" to "usb_manager",
      "devPath" to deviceName,
      "busNumber" to busNum,
      "deviceNumber" to devNum,
      "upstreamHub" to if (busNum == null) null else "Root hub usb$busNum",
      "treeDepth" to portChain.size,
      "portChain" to portChain,
      "speed" to summary["speed"],
      "usbVersion" to summary["usbVersion"],
      "portNumber" to portNumber
    )
  }

  private fun hasAudioClass(device: UsbDevice): Boolean {
    if (device.deviceClass == UsbConstants.USB_CLASS_AUDIO) return true
    for (i in 0 until device.interfaceCount) {
      val intf = safeGet { device.getInterface(i) } ?: continue
      if (intf.interfaceClass == UsbConstants.USB_CLASS_AUDIO) return true
    }
    return false
  }

  private fun hasVideoClass(device: UsbDevice): Boolean {
    if (device.deviceClass == 14) return true
    for (i in 0 until device.interfaceCount) {
      val intf = safeGet { device.getInterface(i) } ?: continue
      if (intf.interfaceClass == 14) return true
    }
    return false
  }

  private fun hasHidInterface(device: UsbDevice): Boolean {
    if (device.deviceClass == UsbConstants.USB_CLASS_HID) return true
    for (i in 0 until device.interfaceCount) {
      val intf = safeGet { device.getInterface(i) } ?: continue
      if (intf.interfaceClass == UsbConstants.USB_CLASS_HID) return true
    }
    return false
  }

  private fun buildAudioDetails(device: UsbDevice, summary: Map<String, Any?>): Map<String, Any?>? {
    if (Build.VERSION.SDK_INT < 23) return null
    val usbAudioClass = hasAudioClass(device)
    val manager = audioManager ?: return if (usbAudioClass) {
      mapOf(
        "isUsbAudioClass" to true,
        "platformAvailable" to false,
        "availabilityNote" to "Android framework does not expose AudioManager USB endpoint details on this device or Android version.",
        "matchedEndpointCount" to 0,
        "connectedUsbAudioEndpointCount" to 0,
        "matchedEndpoints" to emptyList<Map<String, Any?>>()
      )
    } else {
      null
    }

    val all = safeGet { manager.getDevices(AudioManager.GET_DEVICES_ALL).toList() } ?: emptyList()
    val usbAudioEndpoints = all.filter { it.type == AudioDeviceInfo.TYPE_USB_DEVICE || it.type == AudioDeviceInfo.TYPE_USB_HEADSET }
    val matched = matchAudioEndpoints(device, summary, usbAudioEndpoints)

    if (!usbAudioClass && matched.isEmpty()) return null

    return mapOf(
      "isUsbAudioClass" to usbAudioClass,
      "platformAvailable" to true,
      "availabilityNote" to when {
        matched.isNotEmpty() -> null
        usbAudioClass -> "Android framework does not expose a matchable AudioDeviceInfo endpoint for this USB audio device."
        else -> "Android framework does not expose this device as a USB audio endpoint."
      },
      "matchedEndpointCount" to matched.size,
      "connectedUsbAudioEndpointCount" to usbAudioEndpoints.size,
      "matchedEndpoints" to matched.map(::audioDeviceToMap)
    )
  }

  private fun hasMidiInterface(device: UsbDevice): Boolean {
    for (i in 0 until device.interfaceCount) {
      val intf = safeGet { device.getInterface(i) } ?: continue
      if (intf.interfaceClass == UsbConstants.USB_CLASS_AUDIO && intf.interfaceSubclass == 0x03) {
        return true
      }
    }
    return false
  }

  private fun buildMidiDetails(device: UsbDevice, summary: Map<String, Any?>): Map<String, Any?>? {
    if (Build.VERSION.SDK_INT < 23) return null
    val probableMidi = hasMidiInterface(device)
    val manager = midiManager ?: return if (probableMidi) {
      mapOf(
        "probableUsbMidi" to true,
        "platformAvailable" to false,
        "availabilityNote" to "Android framework does not expose MidiManager device details on this device or Android version.",
        "matchedDeviceCount" to 0,
        "matchedDevices" to emptyList<Map<String, Any?>>()
      )
    } else {
      null
    }

    val midiDevices = collectMidiDevices(manager)
    val matched = midiDevices.filter { matchesMidiDevice(device, summary, it) }
    if (!probableMidi && matched.isEmpty()) return null

    return mapOf(
      "probableUsbMidi" to probableMidi,
      "platformAvailable" to true,
      "availabilityNote" to when {
        matched.isNotEmpty() -> null
        probableMidi -> "Android sees MIDI-like USB descriptors, but no matching MidiManager device is exposed."
        else -> "Android framework does not expose this device as a MIDI endpoint."
      },
      "connectedMidiDeviceCount" to midiDevices.size,
      "matchedDeviceCount" to matched.size,
      "matchedDevices" to matched.map { midiDeviceToMap(manager, it) }
    )
  }

  private fun collectMidiDevices(manager: MidiManager): List<MidiDeviceInfo> {
    val byId = LinkedHashMap<Int, MidiDeviceInfo>()
    for (dev in safeGet { manager.devices.toList() } ?: emptyList()) {
      byId[dev.id] = dev
    }
    if (Build.VERSION.SDK_INT >= 33) {
      for (transport in listOf(
        MidiManager.TRANSPORT_MIDI_BYTE_STREAM,
        MidiManager.TRANSPORT_UNIVERSAL_MIDI_PACKETS
      )) {
        val extra = safeGet { manager.getDevicesForTransport(transport).toList() } ?: emptyList()
        for (dev in extra) byId[dev.id] = dev
      }
    }
    return byId.values.toList()
  }

  private fun matchesMidiDevice(
    usbDevice: UsbDevice,
    summary: Map<String, Any?>,
    midiDevice: MidiDeviceInfo
  ): Boolean {
    val props = safeGet { midiDevice.properties } ?: return false
    val directUsb = readUsbDeviceProperty(props)
    if (directUsb != null) {
      val samePath = directUsb.deviceName == usbDevice.deviceName
      val sameIds = directUsb.vendorId == usbDevice.vendorId && directUsb.productId == usbDevice.productId
      if (samePath || sameIds) return true
    }

    val product = ((summary["productName"] as? String) ?: safeGet { usbDevice.productName } ?: "")
      .trim()
      .lowercase(Locale.US)
    val manufacturer = ((summary["manufacturerName"] as? String) ?: safeGet { usbDevice.manufacturerName } ?: "")
      .trim()
      .lowercase(Locale.US)
    val serial = ((summary["serialNumber"] as? String) ?: safeReadSerial(usbDevice) ?: "")
      .trim()
      .lowercase(Locale.US)
    val text = midiPropertiesText(props)

    if (serial.isNotEmpty() && text.contains(serial)) return true
    if (product.isNotEmpty() && text.contains(product)) return true
    if (manufacturer.isNotEmpty() && text.contains(manufacturer)) return true
    return false
  }

  private fun midiDeviceToMap(manager: MidiManager, info: MidiDeviceInfo): Map<String, Any?> {
    val props = safeGet { info.properties }
    val transports = supportedMidiTransports(manager, info)
    val ports = safeGet { info.ports?.toList() } ?: emptyList()
    return mapOf(
      "id" to info.id,
      "type" to info.type,
      "typeName" to midiDeviceTypeName(info.type),
      "inputPortCount" to info.inputPortCount,
      "outputPortCount" to info.outputPortCount,
      "isPrivate" to safeGet { info.isPrivate },
      "defaultProtocol" to reflectInt(info, "getDefaultProtocol"),
      "transports" to transports,
      "properties" to midiPropertiesToMap(props),
      "ports" to ports.map(::midiPortToMap)
    )
  }

  private fun supportedMidiTransports(manager: MidiManager, info: MidiDeviceInfo): List<String> {
    if (Build.VERSION.SDK_INT < 33) return listOf("MIDI 1.0 byte stream")
    val labels = ArrayList<String>(2)
    val byteStream = safeGet { manager.getDevicesForTransport(MidiManager.TRANSPORT_MIDI_BYTE_STREAM).any { it.id == info.id } } == true
    val ump = safeGet { manager.getDevicesForTransport(MidiManager.TRANSPORT_UNIVERSAL_MIDI_PACKETS).any { it.id == info.id } } == true
    if (byteStream) labels.add("MIDI 1.0 byte stream")
    if (ump) labels.add("UMP")
    if (labels.isEmpty()) labels.add("Unknown")
    return labels
  }

  private fun midiPortToMap(port: MidiDeviceInfo.PortInfo): Map<String, Any?> {
    return mapOf(
      "type" to port.type,
      "typeName" to if (port.type == MidiDeviceInfo.PortInfo.TYPE_INPUT) "Input" else "Output",
      "portNumber" to port.portNumber,
      "name" to port.name
    )
  }

  private fun midiDeviceTypeName(type: Int): String {
    return when (type) {
      MidiDeviceInfo.TYPE_USB -> "USB"
      MidiDeviceInfo.TYPE_VIRTUAL -> "Virtual"
      MidiDeviceInfo.TYPE_BLUETOOTH -> "Bluetooth"
      else -> "Type $type"
    }
  }

  private fun midiPropertiesToMap(props: android.os.Bundle?): Map<String, Any?> {
    if (props == null) return emptyMap()
    val out = LinkedHashMap<String, Any?>()
    for (key in props.keySet()) {
      val value = props.get(key)
      out[key] = when (value) {
        is UsbDevice -> mapOf(
          "deviceName" to value.deviceName,
          "vendorId" to value.vendorId,
          "productId" to value.productId
        )
        is CharSequence -> value.toString()
        is Number, is Boolean -> value
        else -> value?.toString()
      }
    }
    return out
  }

  private fun midiPropertiesText(props: android.os.Bundle): String {
    return buildString {
      for (key in props.keySet()) {
        val value = props.get(key)
        if (value != null) {
          append(value.toString().lowercase(Locale.US))
          append('\n')
        }
      }
    }
  }

  private fun readUsbDeviceProperty(props: android.os.Bundle): UsbDevice? {
    val key = MidiDeviceInfo.PROPERTY_USB_DEVICE
    return try {
      if (Build.VERSION.SDK_INT >= 33) props.getParcelable(key, UsbDevice::class.java)
      else @Suppress("DEPRECATION") props.getParcelable(key) as? UsbDevice
    } catch (_: Throwable) {
      null
    }
  }

  private fun matchAudioEndpoints(
    device: UsbDevice,
    summary: Map<String, Any?>,
    endpoints: List<AudioDeviceInfo>
  ): List<AudioDeviceInfo> {
    if (endpoints.isEmpty()) return emptyList()
    if (endpoints.size == 1 && hasAudioClass(device)) return endpoints

    val product = ((summary["productName"] as? String) ?: safeGet { device.productName } ?: "")
      .trim()
      .lowercase(Locale.US)
    val manufacturer = ((summary["manufacturerName"] as? String) ?: safeGet { device.manufacturerName } ?: "")
      .trim()
      .lowercase(Locale.US)
    val vidHex = "%04x".format(Locale.US, device.vendorId).lowercase(Locale.US)
    val pidHex = "%04x".format(Locale.US, device.productId).lowercase(Locale.US)

    var bestScore = 0
    val scored = endpoints.map { ep ->
      val productName = (safeGet { ep.productName }?.toString() ?: "").trim().lowercase(Locale.US)
      val address = (reflectString(ep, "getAddress") ?: "").trim().lowercase(Locale.US)
      var score = 0
      if (product.isNotEmpty()) {
        if (productName == product) score += 10
        else if (productName.contains(product) || product.contains(productName)) score += 6
      }
      if (manufacturer.isNotEmpty() && productName.contains(manufacturer)) score += 2
      if (address.isNotEmpty()) {
        if (address.contains("$vidHex:$pidHex") || address.contains("$vidHex/$pidHex")) score += 8
        if (address.contains(vidHex)) score += 2
        if (address.contains(pidHex)) score += 2
      }
      if (ep.type == AudioDeviceInfo.TYPE_USB_HEADSET) score += 1
      if (score > bestScore) bestScore = score
      ep to score
    }

    if (bestScore > 0) return scored.filter { it.second == bestScore }.map { it.first }
    return if (hasAudioClass(device) && endpoints.size == 1) endpoints else emptyList()
  }

  private fun audioDeviceToMap(dev: AudioDeviceInfo): Map<String, Any?> {
    val productName = safeGet { dev.productName }?.toString()
    val address = reflectString(dev, "getAddress")
    return mapOf(
      "id" to dev.id,
      "type" to dev.type,
      "typeName" to audioDeviceTypeName(dev.type),
      "productName" to productName,
      "address" to address,
      "isSource" to dev.isSource,
      "isSink" to dev.isSink,
      "sampleRates" to readIntArray(dev, "getSampleRates"),
      "channelCounts" to readIntArray(dev, "getChannelCounts"),
      "channelMasks" to readIntArray(dev, "getChannelMasks"),
      "channelIndexMasks" to readIntArray(dev, "getChannelIndexMasks"),
      "encodings" to readIntArray(dev, "getEncodings").map(::audioEncodingName),
      "audioProfiles" to readObjectList(dev, "getAudioProfiles").map(::audioProfileToMap),
      "audioDescriptors" to readObjectList(dev, "getAudioDescriptors").map(::audioDescriptorToMap)
    )
  }

  private fun audioProfileToMap(profile: Any): Map<String, Any?> {
    val format = reflectInt(profile, "getFormat")
    val sampleRates = readIntArray(profile, "getSampleRates")
    val channelMasks = readIntArray(profile, "getChannelMasks")
    val channelIndexMasks = readIntArray(profile, "getChannelIndexMasks")
    return mapOf(
      "format" to format,
      "formatName" to if (format == null) null else audioEncodingName(format),
      "sampleRates" to sampleRates,
      "channelMasks" to channelMasks,
      "channelIndexMasks" to channelIndexMasks,
      "encapsulationType" to reflectInt(profile, "getEncapsulationType")
    )
  }

  private fun audioDescriptorToMap(descriptor: Any): Map<String, Any?> {
    val bytes = reflectByteArray(descriptor, "getDescriptor")
    return mapOf(
      "standard" to reflectInt(descriptor, "getStandard"),
      "encapsulationType" to reflectInt(descriptor, "getEncapsulationType"),
      "length" to bytes?.size,
      "descriptorHex" to if (bytes == null) null else toHex(bytes, 2048)
    )
  }

  private fun audioDeviceTypeName(type: Int): String {
    return when (type) {
      AudioDeviceInfo.TYPE_USB_DEVICE -> "USB device"
      AudioDeviceInfo.TYPE_USB_HEADSET -> "USB headset"
      else -> "Type $type"
    }
  }

  private fun audioEncodingName(encoding: Int): String {
    return when (encoding) {
      0 -> "Invalid"
      2 -> "PCM 16-bit"
      3 -> "PCM 8-bit"
      4 -> "PCM float"
      13 -> "PCM 24-bit packed"
      21 -> "PCM 32-bit"
      14 -> "AC3"
      5 -> "AC4"
      6 -> "DTS"
      7 -> "DTS HD"
      8 -> "Dolby TrueHD"
      9 -> "IEC61937"
      10 -> "E-AC3"
      11 -> "E-AC3 JOC"
      12 -> "Dolby MAT"
      15 -> "MPEG-H BL"
      16 -> "MPEG-H BL L3"
      17 -> "MPEG-H LC L3"
      18 -> "AAC LC"
      19 -> "AAC HE V1"
      20 -> "AAC HE V2"
      else -> "Encoding $encoding"
    }
  }

  private fun readObjectList(target: Any, methodName: String): List<Any> {
    val raw = reflectAny(target, methodName) ?: return emptyList()
    return when (raw) {
      is Array<*> -> raw.filterNotNull()
      is Iterable<*> -> raw.filterNotNull()
      else -> emptyList()
    }
  }

  private fun readIntArray(target: Any, methodName: String): List<Int> {
    val raw = reflectAny(target, methodName) ?: return emptyList()
    return when (raw) {
      is IntArray -> raw.toList()
      is Array<*> -> raw.mapNotNull { (it as? Number)?.toInt() }
      is Iterable<*> -> raw.mapNotNull { (it as? Number)?.toInt() }
      else -> emptyList()
    }
  }

  private fun reflectString(target: Any, methodName: String): String? {
    return when (val v = reflectAny(target, methodName)) {
      null -> null
      is CharSequence -> v.toString()
      else -> v.toString()
    }
  }

  private fun reflectInt(target: Any, methodName: String): Int? {
    val v = reflectAny(target, methodName)
    return when (v) {
      is Int -> v
      is Number -> v.toInt()
      else -> null
    }
  }

  private fun reflectByteArray(target: Any, methodName: String): ByteArray? {
    val v = reflectAny(target, methodName)
    return v as? ByteArray
  }

  private fun reflectAny(target: Any, methodName: String): Any? {
    return try {
      target.javaClass.getMethod(methodName).invoke(target)
    } catch (_: Throwable) {
      null
    }
  }

  private fun normalizeIdentityPart(value: String?): String? {
    val normalized = value
      ?.trim()
      ?.lowercase(Locale.US)
      ?.replace(Regex("[^a-z0-9._:-]+"), "_")
      ?.trim('_')
    return normalized?.takeIf { it.isNotEmpty() }
  }

  private fun interfaceFingerprintForUsbDevice(device: UsbDevice): String {
    if (device.interfaceCount <= 0) return "none"
    val parts = ArrayList<String>(device.interfaceCount)
    for (i in 0 until device.interfaceCount) {
      val intf = safeGet { device.getInterface(i) } ?: continue
      val alt = getUsbInterfaceAlternateSetting(intf)
      parts.add(
        listOf(
          intf.id,
          alt,
          intf.interfaceClass,
          intf.interfaceSubclass,
          intf.interfaceProtocol,
          intf.endpointCount
        ).joinToString(".")
      )
    }
    return if (parts.isEmpty()) "none" else parts.joinToString(";")
  }

  private fun modelFingerprint(
    vendorId: Int,
    productId: Int,
    deviceClass: Int,
    deviceSubclass: Int,
    deviceProtocol: Int,
    interfaceFingerprint: String
  ): String {
    return "vidpid:$vendorId:$productId|dc:$deviceClass:$deviceSubclass:$deviceProtocol|if:$interfaceFingerprint"
  }

  private fun physicalLocationKey(busNumber: Int?, portChain: List<Int>, portNumber: Int?): String? {
    if (busNumber == null) return null
    if (portChain.isNotEmpty()) {
      return "bus:$busNumber|ports:${portChain.joinToString(".")}"
    }
    if (portNumber != null && portNumber > 0) {
      return "bus:$busNumber|port:$portNumber"
    }
    return null
  }

  private fun parseBusNumber(deviceName: String?): Int? {
    val path = deviceName ?: return null
    if (!path.startsWith("/dev/bus/usb/")) return null
    val parts = path.split('/').filter { it.isNotEmpty() }
    return parts.getOrNull(parts.size - 2)?.toIntOrNull()
  }

  private fun buildStableIdentityMap(
    deviceName: String,
    vendorId: Int,
    productId: Int,
    deviceClass: Int,
    deviceSubclass: Int,
    deviceProtocol: Int,
    serialNumber: String?,
    interfaceFingerprint: String,
    busNumber: Int?,
    portChain: List<Int>,
    portNumber: Int?,
    isInputDevice: Boolean
  ): Map<String, Any?> {
    val serialKey = normalizeIdentityPart(serialNumber)
    val physicalKey = physicalLocationKey(busNumber, portChain, portNumber)
    val continuityKeys = LinkedHashSet<String>()
    val modelKey = modelFingerprint(
      vendorId = vendorId,
      productId = productId,
      deviceClass = deviceClass,
      deviceSubclass = deviceSubclass,
      deviceProtocol = deviceProtocol,
      interfaceFingerprint = interfaceFingerprint
    )

    val stableKey: String
    val strategy: String
    val confidence: String
    if (serialKey != null) {
      stableKey = "serial:$vendorId:$productId:$serialKey"
      strategy = "serial_number"
      confidence = "high"
      continuityKeys.add(stableKey)
    } else if (physicalKey != null) {
      stableKey = "port:$vendorId:$productId:$physicalKey:$interfaceFingerprint"
      strategy = "physical_port"
      confidence = "high"
      continuityKeys.add(stableKey)
    } else if (interfaceFingerprint != "none") {
      stableKey = "interface:$vendorId:$productId:$interfaceFingerprint"
      strategy = "interface_fingerprint"
      confidence = if (isInputDevice) "medium" else "medium"
      continuityKeys.add(stableKey)
    } else {
      stableKey = "model:$modelKey"
      strategy = "model_fingerprint"
      confidence = "low"
      continuityKeys.add(stableKey)
    }

    if (serialKey != null) continuityKeys.add("serial:$vendorId:$productId:$serialKey")
    if (physicalKey != null) continuityKeys.add("port:$vendorId:$productId:$physicalKey:$interfaceFingerprint")
    if (interfaceFingerprint != "none") continuityKeys.add("interface:$vendorId:$productId:$interfaceFingerprint")
    continuityKeys.add("model:$modelKey")

    return mapOf(
      "stableIdentityKey" to stableKey,
      "identityConfidence" to confidence,
      "identityStrategy" to strategy,
      "physicalLocationKey" to physicalKey,
      "interfaceFingerprint" to interfaceFingerprint,
      "continuityKeys" to continuityKeys.toList(),
      "currentPath" to deviceName
    )
  }

  private fun identityFromSummary(summary: Map<String, Any?>): Map<String, Any?> {
    return mapOf(
      "stableIdentityKey" to summary["stableIdentityKey"],
      "identityConfidence" to summary["identityConfidence"],
      "identityStrategy" to summary["identityStrategy"],
      "physicalLocationKey" to summary["physicalLocationKey"],
      "interfaceFingerprint" to summary["interfaceFingerprint"],
      "continuityKeys" to (summary["continuityKeys"] ?: emptyList<String>()),
      "currentPath" to summary["deviceName"]
    )
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
    val busNumber = parseBusNumber(device.deviceName)
    val portChain = if (portNumber == null || portNumber <= 0) emptyList() else listOf(portNumber)
    val interfaceFingerprint = interfaceFingerprintForUsbDevice(device)
    val identity = buildStableIdentityMap(
      deviceName = device.deviceName,
      vendorId = device.vendorId,
      productId = device.productId,
      deviceClass = device.deviceClass,
      deviceSubclass = device.deviceSubclass,
      deviceProtocol = device.deviceProtocol,
      serialNumber = serial,
      interfaceFingerprint = interfaceFingerprint,
      busNumber = busNumber,
      portChain = portChain,
      portNumber = portNumber,
      isInputDevice = false
    )
    val capabilities = buildCapabilityBadges(
      deviceClass = device.deviceClass,
      deviceSubclass = device.deviceSubclass,
      interfaces = (0 until device.interfaceCount).mapNotNull { idx -> safeGet { device.getInterface(idx) } },
      isInputDevice = false,
      inputSources = emptyList()
    )
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
      "isInputDevice" to false,
      "capabilities" to capabilities,
      "stableIdentityKey" to identity["stableIdentityKey"],
      "identityConfidence" to identity["identityConfidence"],
      "identityStrategy" to identity["identityStrategy"],
      "physicalLocationKey" to identity["physicalLocationKey"],
      "interfaceFingerprint" to identity["interfaceFingerprint"],
      "continuityKeys" to identity["continuityKeys"]
    )
  }

  private fun deviceSummaryInput(dev: InputDevice, vid: Int, pid: Int): Map<String, Any?> {
    val sources = inputSources(dev)
    val name = safeGet { dev.name } ?: "Input device"
    val descriptor = inputDescriptor(dev)
    val interfaceFingerprint = normalizeIdentityPart(descriptor) ?: normalizeIdentityPart(sources.joinToString(",")) ?: "input"
    val identity = buildStableIdentityMap(
      deviceName = inputKey(dev.id),
      vendorId = vid,
      productId = pid,
      deviceClass = UsbConstants.USB_CLASS_HID,
      deviceSubclass = 0,
      deviceProtocol = 0,
      serialNumber = descriptor,
      interfaceFingerprint = interfaceFingerprint,
      busNumber = null,
      portChain = emptyList(),
      portNumber = null,
      isInputDevice = true
    )
    val capabilities = buildCapabilityBadges(
      deviceClass = UsbConstants.USB_CLASS_HID,
      deviceSubclass = 0,
      interfaces = emptyList(),
      isInputDevice = true,
      inputSources = sources
    )
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
      "inputSources" to sources,
      "capabilities" to capabilities,
      "stableIdentityKey" to identity["stableIdentityKey"],
      "identityConfidence" to identity["identityConfidence"],
      "identityStrategy" to identity["identityStrategy"],
      "physicalLocationKey" to identity["physicalLocationKey"],
      "interfaceFingerprint" to identity["interfaceFingerprint"],
      "continuityKeys" to identity["continuityKeys"]
    )
  }

  private fun buildCapabilityBadges(
    deviceClass: Int,
    deviceSubclass: Int,
    interfaces: List<UsbInterface>,
    isInputDevice: Boolean,
    inputSources: List<String>
  ): List<String> {
    val caps = LinkedHashSet<String>()
    if (isInputDevice || inputSources.isNotEmpty() || deviceClass == UsbConstants.USB_CLASS_HID) caps.add("HID")
    if (isInputDevice && inputSources.isNotEmpty()) caps.add("Input")
    if (deviceClass == UsbConstants.USB_CLASS_AUDIO) caps.add("Audio")
    if (deviceClass == 14) caps.add("Video")
    if (deviceClass == UsbConstants.USB_CLASS_COMM) caps.add("CDC")
    if (deviceClass == UsbConstants.USB_CLASS_MASS_STORAGE) caps.add("Storage")
    if (deviceClass == UsbConstants.USB_CLASS_HUB) caps.add("Hub")
    if (interfaces.size > 1 || deviceClass == 0) caps.add("Composite")

    for (intf in interfaces) {
      when (intf.interfaceClass) {
        UsbConstants.USB_CLASS_AUDIO -> {
          caps.add("Audio")
          if (intf.interfaceSubclass == 0x03) caps.add("MIDI")
        }
        14 -> caps.add("Video")
        UsbConstants.USB_CLASS_HID -> caps.add("HID")
        UsbConstants.USB_CLASS_COMM -> caps.add("CDC")
        UsbConstants.USB_CLASS_MASS_STORAGE -> caps.add("Storage")
        UsbConstants.USB_CLASS_HUB -> caps.add("Hub")
      }
    }

    if (deviceClass == UsbConstants.USB_CLASS_AUDIO && deviceSubclass == 0x03) caps.add("MIDI")
    return caps.toList()
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

  private data class DescriptorContext(
    val interfaceNumber: Int? = null,
    val alternateSetting: Int? = null,
    val interfaceClass: Int? = null,
    val interfaceSubclass: Int? = null,
    val interfaceProtocol: Int? = null,
    val endpointAddress: Int? = null
  )

  private fun parseDescriptorTree(raw: ByteArray): List<Map<String, Any?>> {
    val out = ArrayList<Map<String, Any?>>()
    var i = 0
    var context = DescriptorContext()
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
      if (type == 0x24 || type == 0x25) {
        base["context"] = descriptorContextToMap(context)
      }
      val parsed = parseKnownDescriptor(bytes, context)
      if (parsed != null) base["fields"] = parsed
      out.add(base)
      when (type) {
        0x01, 0x02 -> context = DescriptorContext()
        0x04 -> {
          val fields = parsed
          context = DescriptorContext(
            interfaceNumber = fields?.get("bInterfaceNumber") as? Int,
            alternateSetting = fields?.get("bAlternateSetting") as? Int,
            interfaceClass = fields?.get("bInterfaceClass") as? Int,
            interfaceSubclass = fields?.get("bInterfaceSubClass") as? Int,
            interfaceProtocol = fields?.get("bInterfaceProtocol") as? Int
          )
        }
        0x05 -> {
          context = context.copy(
            endpointAddress = (parsed?.get("bEndpointAddress") as? Int)
          )
        }
      }
      i += len
    }
    return out
  }

  private fun descriptorContextToMap(context: DescriptorContext): Map<String, Any?> {
    return mapOf(
      "interfaceNumber" to context.interfaceNumber,
      "alternateSetting" to context.alternateSetting,
      "interfaceClass" to context.interfaceClass,
      "interfaceSubclass" to context.interfaceSubclass,
      "interfaceProtocol" to context.interfaceProtocol,
      "endpointAddress" to context.endpointAddress
    )
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
    0x29 -> "Hub"
    0x2A -> "SuperSpeed Endpoint Companion"
    0x30 -> "SuperSpeedPlus Isoch Endpoint Companion"
    else -> "Unknown"
  }

  private fun parseKnownDescriptor(bytes: ByteArray, context: DescriptorContext): Map<String, Any?>? {
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
      0x24 -> parseClassSpecificInterface(bytes, context)
      0x25 -> parseClassSpecificEndpoint(bytes, context)
      0x29 -> parseHubDesc(bytes)
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
    val out = LinkedHashMap<String, Any?>()
    out["bDevCapabilityType"] = capType
    out["capabilityTypeName"] = deviceCapabilityTypeName(capType)
    when (capType) {
      0x02 -> if (b.size >= 7) {
        val attrs = le32(b, 3)
        out["bmAttributes"] = attrs
        out["supportsLpm"] = (attrs and 0x02) != 0
      }
      0x03 -> if (b.size >= 10) {
        val attrs = u8(b[3])
        val supportedSpeeds = le16(b[4], b[5])
        val functionality = u8(b[6])
        val exitLatU1 = u8(b[7])
        val exitLatU2 = le16(b[8], b[9])
        out["bmAttributes"] = attrs
        out["supportsLtm"] = (attrs and 0x02) != 0
        out["wSpeedsSupported"] = supportedSpeeds
        out["supportedSpeedNames"] = decodeSuperSpeedFlags(supportedSpeeds)
        out["bFunctionalitySupport"] = functionality
        out["functionalitySupportName"] = superSpeedFunctionalityName(functionality)
        out["bU1DevExitLat"] = exitLatU1
        out["bU2DevExitLat"] = exitLatU2
      }
      0x04 -> if (b.size >= 19) {
        out["containerId"] = littleEndianGuid(b, 3)
      }
      0x05 -> if (b.size >= 20) {
        out["bReserved"] = u8(b[3])
        out["platformCapabilityUuid"] = littleEndianGuid(b, 4)
        if (b.size > 20) out["capabilityDataHex"] = hexSlice(b, 20, b.size - 20)
      }
      else -> if (b.size > 3) {
        out["capabilityDataHex"] = hexSlice(b, 3, b.size - 3)
      }
    }
    return out
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

  private fun parseClassSpecificInterface(b: ByteArray, context: DescriptorContext): Map<String, Any?>? {
    if (b.size < 3) return null
    val sub = u8(b[2])
    val base = LinkedHashMap<String, Any?>()
    base["bDescriptorSubType"] = sub
    base["interfaceClassContext"] = context.interfaceClass
    base["interfaceSubclassContext"] = context.interfaceSubclass
    base["interfaceProtocolContext"] = context.interfaceProtocol
    when (context.interfaceClass) {
      UsbConstants.USB_CLASS_AUDIO -> parseAudioClassSpecificInterface(b, context, base)
      UsbConstants.USB_CLASS_COMM -> parseCdcClassSpecificInterface(b, base)
      14 -> parseVideoClassSpecificInterface(b, context, base)
      else -> base["descriptorSubtypeName"] = genericClassSpecificSubtypeName(sub)
    }
    return base
  }

  private fun parseClassSpecificEndpoint(b: ByteArray, context: DescriptorContext): Map<String, Any?>? {
    if (b.size < 3) return null
    val subtype = u8(b[2])
    val base = LinkedHashMap<String, Any?>()
    base["bDescriptorSubType"] = subtype
    base["interfaceClassContext"] = context.interfaceClass
    base["interfaceSubclassContext"] = context.interfaceSubclass
    base["endpointAddressContext"] = context.endpointAddress
    when (context.interfaceClass) {
      UsbConstants.USB_CLASS_AUDIO -> parseAudioClassSpecificEndpoint(b, context, base)
      14 -> parseVideoClassSpecificEndpoint(b, context, base)
      else -> base["descriptorSubtypeName"] = genericClassSpecificSubtypeName(subtype)
    }
    return base
  }

  private fun parseHubDesc(b: ByteArray): Map<String, Any?>? {
    if (b.size < 7) return null
    val ports = u8(b[2])
    val characteristics = le16(b[3], b[4])
    val powerOnToPowerGood = u8(b[5])
    val maxCurrent = u8(b[6])
    return mapOf(
      "bNbrPorts" to ports,
      "wHubCharacteristics" to characteristics,
      "powerSwitchingMode" to (characteristics and 0x03),
      "powerSwitchingModeName" to hubPowerSwitchingModeName(characteristics and 0x03),
      "compoundDevice" to (((characteristics shr 2) and 0x01) == 1),
      "overCurrentProtectionMode" to ((characteristics shr 3) and 0x03),
      "overCurrentProtectionModeName" to hubOverCurrentModeName((characteristics shr 3) and 0x03),
      "ttThinkTime" to ((characteristics shr 5) and 0x03),
      "ttThinkTimeName" to hubThinkTimeName((characteristics shr 5) and 0x03),
      "portIndicatorsSupported" to (((characteristics shr 7) and 0x01) == 1),
      "bPwrOn2PwrGood" to powerOnToPowerGood,
      "powerGoodMs" to powerOnToPowerGood * 2,
      "bHubContrCurrent" to maxCurrent
    )
  }

  private fun parseAudioClassSpecificInterface(
    b: ByteArray,
    context: DescriptorContext,
    base: MutableMap<String, Any?>
  ) {
    val subtype = u8(b[2])
    base["descriptorSubtypeName"] = audioDescriptorSubtypeName(subtype, context.interfaceSubclass, false)
    base["audioSubclassName"] = audioSubclassName(context.interfaceSubclass)
    when (context.interfaceSubclass) {
      0x01 -> parseAudioControlDescriptor(b, subtype, base)
      0x02 -> parseAudioStreamingDescriptor(b, subtype, base)
      0x03 -> parseMidiStreamingDescriptor(b, subtype, base)
    }
  }

  private fun parseAudioClassSpecificEndpoint(
    b: ByteArray,
    context: DescriptorContext,
    base: MutableMap<String, Any?>
  ) {
    val subtype = u8(b[2])
    base["descriptorSubtypeName"] = audioDescriptorSubtypeName(subtype, context.interfaceSubclass, true)
    base["audioSubclassName"] = audioSubclassName(context.interfaceSubclass)
    when (context.interfaceSubclass) {
      0x02 -> if (b.size >= 4) {
        base["bmAttributes"] = u8(b[3])
        if (b.size >= 5) base["bLockDelayUnits"] = u8(b[4])
        if (b.size >= 7) base["wLockDelay"] = le16(b[5], b[6])
      }
      0x03 -> if (subtype == 0x01 && b.size >= 4) {
        val jackCount = u8(b[3])
        base["bNumEmbMIDIJack"] = jackCount
        if (b.size > 4) {
          base["baAssocJackID"] = (4 until min(b.size, 4 + jackCount)).map { u8(b[it]) }
        }
      }
    }
  }

  private fun parseAudioControlDescriptor(
    b: ByteArray,
    subtype: Int,
    base: MutableMap<String, Any?>
  ) {
    when (subtype) {
      0x01 -> {
        if (b.size >= 5) base["bcdADC"] = bcdToVersionString(le16(b[3], b[4]))
        if (b.size >= 7) base["wTotalLength"] = le16(b[5], b[6])
        if (b.size >= 8) base["bInCollection"] = u8(b[7])
        if (b.size >= 9) base["baInterfaceNr"] = (8 until b.size).map { u8(b[it]) }
      }
      0x02 -> {
        if (b.size >= 6) {
          val terminalType = le16(b[4], b[5])
          base["bTerminalID"] = u8(b[3])
          base["wTerminalType"] = terminalType
          base["terminalTypeName"] = audioTerminalTypeName(terminalType)
        }
        if (b.size >= 7) base["bAssocTerminal"] = u8(b[6])
        if (b.size >= 8) base["bNrChannels"] = u8(b[7])
        if (b.size >= 10) base["wChannelConfig"] = le16(b[8], b[9])
        if (b.size >= 11) base["iChannelNames"] = u8(b[10])
        if (b.size >= 12) base["iTerminal"] = u8(b[11])
      }
      0x03 -> {
        if (b.size >= 6) {
          val terminalType = le16(b[4], b[5])
          base["bTerminalID"] = u8(b[3])
          base["wTerminalType"] = terminalType
          base["terminalTypeName"] = audioTerminalTypeName(terminalType)
        }
        if (b.size >= 7) base["bAssocTerminal"] = u8(b[6])
        if (b.size >= 8) base["bSourceID"] = u8(b[7])
        if (b.size >= 9) base["iTerminal"] = u8(b[8])
      }
      0x04 -> {
        if (b.size >= 5) {
          val sourceCount = u8(b[4])
          base["bUnitID"] = u8(b[3])
          base["bNrInPins"] = sourceCount
          if (b.size >= 5 + sourceCount) {
            base["baSourceID"] = (0 until sourceCount).map { u8(b[5 + it]) }
          }
        }
      }
      0x05 -> {
        if (b.size >= 5) {
          val sourceCount = u8(b[4])
          base["bUnitID"] = u8(b[3])
          base["bNrInPins"] = sourceCount
          if (b.size >= 5 + sourceCount) {
            base["baSourceID"] = (0 until sourceCount).map { u8(b[5 + it]) }
            if (b.size > 5 + sourceCount) base["iSelector"] = u8(b[5 + sourceCount])
          }
        }
      }
      0x06 -> {
        if (b.size >= 5) {
          base["bUnitID"] = u8(b[3])
          base["bSourceID"] = u8(b[4])
          if (b.size >= 6) {
            val controlSize = u8(b[5])
            base["bControlSize"] = controlSize
            val controlBytes = (6 until maxOf(6, b.size - 1)).map { u8(b[it]) }
            if (controlBytes.isNotEmpty()) base["bmaControlsRaw"] = controlBytes
          }
          base["iFeature"] = u8(b[b.size - 1])
        }
      }
      0x07, 0x08, 0x09 -> {
        if (b.size >= 5) base["bUnitID"] = u8(b[3])
        if (b.size >= 6) base["bSourceID"] = u8(b[4])
      }
      0x0A, 0x0B, 0x0C -> if (b.size >= 4) {
        base["bClockID"] = u8(b[3])
        if (b.size >= 5) base["bmAttributes"] = u8(b[4])
      }
      0x0D -> if (b.size >= 6) {
        base["bClockID"] = u8(b[3])
        base["bSourceID"] = u8(b[4])
        base["bSourceInID"] = u8(b[5])
      }
    }
  }

  private fun parseAudioStreamingDescriptor(
    b: ByteArray,
    subtype: Int,
    base: MutableMap<String, Any?>
  ) {
    when (subtype) {
      0x01 -> {
        if (b.size >= 4) base["bTerminalLink"] = u8(b[3])
        if (b.size >= 5) base["bDelay"] = u8(b[4])
        if (b.size >= 7) base["wFormatTag"] = le16(b[5], b[6])
        if (b.size >= 6) base["bFormatType"] = u8(b[5])
      }
      0x02 -> {
        if (b.size >= 4) base["bFormatType"] = u8(b[3])
        if (b.size >= 5) base["bNrChannels"] = u8(b[4])
        if (b.size >= 6) base["bSubframeSize"] = u8(b[5])
        if (b.size >= 7) base["bBitResolution"] = u8(b[6])
        if (b.size >= 8) {
          val freqCount = u8(b[7])
          base["bSamFreqType"] = freqCount
          if (freqCount > 0 && b.size >= 8 + (freqCount * 3)) {
            val rates = ArrayList<Int>(freqCount)
            var off = 8
            repeat(freqCount) {
              rates.add(le24(b, off))
              off += 3
            }
            base["sampleRates"] = rates
          }
        }
      }
      0x03 -> if (b.size > 3) {
        base["formatSpecificHex"] = hexSlice(b, 3, b.size - 3)
      }
    }
  }

  private fun parseMidiStreamingDescriptor(
    b: ByteArray,
    subtype: Int,
    base: MutableMap<String, Any?>
  ) {
    when (subtype) {
      0x01 -> {
        if (b.size >= 5) base["bcdMSC"] = bcdToVersionString(le16(b[3], b[4]))
        if (b.size >= 7) base["wTotalLength"] = le16(b[5], b[6])
      }
      0x02 -> if (b.size >= 5) {
        base["bJackType"] = u8(b[3])
        base["jackTypeName"] = midiJackTypeName(u8(b[3]))
        base["bJackID"] = u8(b[4])
        if (b.size >= 6) base["iJack"] = u8(b[5])
      }
      0x03 -> if (b.size >= 6) {
        val pins = u8(b[5])
        base["bJackType"] = u8(b[3])
        base["jackTypeName"] = midiJackTypeName(u8(b[3]))
        base["bJackID"] = u8(b[4])
        base["bNrInputPins"] = pins
        val sources = ArrayList<Map<String, Int>>(pins)
        var off = 6
        while (off + 1 < b.size && sources.size < pins) {
          sources.add(mapOf("sourceId" to u8(b[off]), "sourcePin" to u8(b[off + 1])))
          off += 2
        }
        if (sources.isNotEmpty()) base["sources"] = sources
        if (off < b.size) base["iJack"] = u8(b[off])
      }
      0x04 -> if (b.size >= 5) {
        val pins = u8(b[4])
        base["bElementID"] = u8(b[3])
        base["bNrInputPins"] = pins
        if (b.size >= 5 + (pins * 2)) {
          val sources = ArrayList<Map<String, Int>>(pins)
          var off = 5
          repeat(pins) {
            sources.add(mapOf("sourceId" to u8(b[off]), "sourcePin" to u8(b[off + 1])))
            off += 2
          }
          base["sources"] = sources
        }
      }
    }
  }

  private fun parseCdcClassSpecificInterface(b: ByteArray, base: MutableMap<String, Any?>) {
    val sub = u8(b[2])
    base["descriptorSubtypeName"] = cdcDescriptorSubtypeName(sub)
    when (sub) {
      0x00 -> if (b.size >= 5) base["bcdCDC"] = bcdToVersionString(le16(b[3], b[4]))
      0x01 -> if (b.size >= 5) {
        val caps = u8(b[3])
        base["bmCapabilities"] = caps
        base["capabilityNames"] = cdcCallManagementCapabilities(caps)
        base["bDataInterface"] = u8(b[4])
      }
      0x02 -> if (b.size >= 4) {
        val caps = u8(b[3])
        base["bmCapabilities"] = caps
        base["capabilityNames"] = cdcAcmCapabilities(caps)
      }
      0x03 -> if (b.size >= 5) {
        base["bmCapabilities"] = u8(b[3])
        base["bDataInterface"] = u8(b[4])
      }
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
      0x07 -> if (b.size >= 5) {
        base["iCountryCodeRelDate"] = u8(b[3])
        val codes = ArrayList<Int>()
        var off = 4
        while (off + 1 < b.size) {
          codes.add(le16(b[off], b[off + 1]))
          off += 2
        }
        base["wCountryCodes"] = codes
      }
      0x0F -> if (b.size >= 13) {
        base["iMACAddress"] = u8(b[3])
        base["bmEthernetStatistics"] = le32(b, 4)
        base["wMaxSegmentSize"] = le16(b[8], b[9])
        base["wNumberMCFilters"] = le16(b[10], b[11])
        base["bNumberPowerFilters"] = u8(b[12])
      }
      0x10 -> if (b.size >= 8) {
        base["wFormatTag"] = le16(b[3], b[4])
        base["bmDataCapabilities"] = le16(b[5], b[6])
        base["bmNetworkCapabilities"] = u8(b[7])
      }
    }
  }

  private fun parseVideoClassSpecificInterface(
    b: ByteArray,
    context: DescriptorContext,
    base: MutableMap<String, Any?>
  ) {
    val subtype = u8(b[2])
    base["descriptorSubtypeName"] = videoDescriptorSubtypeName(subtype, context.interfaceSubclass, false)
    base["videoSubclassName"] = videoSubclassName(context.interfaceSubclass)
    when (context.interfaceSubclass) {
      0x01 -> parseVideoControlDescriptor(b, subtype, base)
      0x02 -> parseVideoStreamingDescriptor(b, subtype, base)
    }
  }

  private fun parseVideoClassSpecificEndpoint(
    b: ByteArray,
    context: DescriptorContext,
    base: MutableMap<String, Any?>
  ) {
    val subtype = u8(b[2])
    base["descriptorSubtypeName"] = videoDescriptorSubtypeName(subtype, context.interfaceSubclass, true)
    base["videoSubclassName"] = videoSubclassName(context.interfaceSubclass)
    if (b.size >= 4) base["bmAttributes"] = u8(b[3])
  }

  private fun parseVideoControlDescriptor(
    b: ByteArray,
    subtype: Int,
    base: MutableMap<String, Any?>
  ) {
    when (subtype) {
      0x01 -> {
        if (b.size >= 5) base["bcdUVC"] = bcdToVersionString(le16(b[3], b[4]))
        if (b.size >= 7) base["wTotalLength"] = le16(b[5], b[6])
        if (b.size >= 11) base["dwClockFrequency"] = le32(b, 7)
        if (b.size >= 12) base["bInCollection"] = u8(b[11])
        if (b.size >= 13) base["baInterfaceNr"] = (12 until b.size).map { u8(b[it]) }
      }
      0x02 -> if (b.size >= 6) {
        val terminalType = le16(b[4], b[5])
        base["bTerminalID"] = u8(b[3])
        base["wTerminalType"] = terminalType
        base["terminalTypeName"] = videoTerminalTypeName(terminalType)
        if (b.size >= 7) base["bAssocTerminal"] = u8(b[6])
        if (b.size >= 8) base["iTerminal"] = u8(b[7])
      }
      0x03 -> if (b.size >= 8) {
        val terminalType = le16(b[4], b[5])
        base["bTerminalID"] = u8(b[3])
        base["wTerminalType"] = terminalType
        base["terminalTypeName"] = videoTerminalTypeName(terminalType)
        base["bAssocTerminal"] = u8(b[6])
        base["bSourceID"] = u8(b[7])
        if (b.size >= 9) base["iTerminal"] = u8(b[8])
      }
      0x04 -> if (b.size >= 5) {
        val sourceCount = u8(b[4])
        base["bUnitID"] = u8(b[3])
        base["bNrInPins"] = sourceCount
        if (b.size >= 5 + sourceCount) {
          base["baSourceID"] = (0 until sourceCount).map { u8(b[5 + it]) }
          if (b.size > 5 + sourceCount) base["iSelector"] = u8(b[5 + sourceCount])
        }
      }
      0x05 -> if (b.size >= 5) {
        base["bUnitID"] = u8(b[3])
        base["bSourceID"] = u8(b[4])
        if (b.size >= 7) base["wMaxMultiplier"] = le16(b[5], b[6])
      }
      0x06 -> if (b.size >= 20) {
        base["bUnitID"] = u8(b[3])
        base["guidExtensionCode"] = littleEndianGuid(b, 4)
        base["bNumControls"] = u8(b[20])
      }
      0x07 -> if (b.size >= 5) {
        base["bUnitID"] = u8(b[3])
        base["bSourceID"] = u8(b[4])
      }
    }
  }

  private fun parseVideoStreamingDescriptor(
    b: ByteArray,
    subtype: Int,
    base: MutableMap<String, Any?>
  ) {
    when (subtype) {
      0x01, 0x02 -> {
        if (b.size >= 4) base["bNumFormats"] = u8(b[3])
        if (b.size >= 6) base["wTotalLength"] = le16(b[4], b[5])
        if (b.size >= 7) base["bEndpointAddress"] = u8(b[6])
        if (b.size >= 9) base["bTerminalLink"] = u8(b[8])
      }
      0x03 -> if (b.size >= 4) {
        base["bEndpointAddress"] = u8(b[3])
      }
      0x04, 0x06, 0x0A, 0x0C, 0x10, 0x12 -> {
        if (b.size >= 4) base["bFormatIndex"] = u8(b[3])
        if (b.size >= 5) base["bNumFrameDescriptors"] = u8(b[4])
        if (b.size >= 21) base["guidFormat"] = littleEndianGuid(b, 5)
      }
      0x05, 0x07, 0x11 -> if (b.size >= 9) {
        base["bFrameIndex"] = u8(b[3])
        base["wWidth"] = le16(b[5], b[6])
        base["wHeight"] = le16(b[7], b[8])
      }
      0x0D -> if (b.size >= 6) {
        base["bColorPrimaries"] = u8(b[3])
        base["bTransferCharacteristics"] = u8(b[4])
        base["bMatrixCoefficients"] = u8(b[5])
      }
    }
  }

  private fun genericClassSpecificSubtypeName(subtype: Int): String {
    return "Subtype ${String.format(Locale.US, "0x%02X", subtype)}"
  }

  private fun audioSubclassName(subclass: Int?): String? = when (subclass) {
    0x01 -> "AudioControl"
    0x02 -> "AudioStreaming"
    0x03 -> "MIDIStreaming"
    else -> null
  }

  private fun audioDescriptorSubtypeName(subtype: Int, subclass: Int?, endpoint: Boolean): String {
    if (endpoint) {
      return when (subclass) {
        0x02 -> if (subtype == 0x01) "Audio data endpoint" else genericClassSpecificSubtypeName(subtype)
        0x03 -> if (subtype == 0x01) "MIDI streaming endpoint" else genericClassSpecificSubtypeName(subtype)
        else -> genericClassSpecificSubtypeName(subtype)
      }
    }
    return when (subclass) {
      0x01 -> when (subtype) {
        0x01 -> "Audio control header"
        0x02 -> "Input terminal"
        0x03 -> "Output terminal"
        0x04 -> "Mixer unit"
        0x05 -> "Selector unit"
        0x06 -> "Feature unit"
        0x07 -> "Processing / effect unit"
        0x08 -> "Extension / processing unit"
        0x09 -> "Class-specific endpoint extension"
        0x0A -> "Clock source"
        0x0B -> "Clock selector"
        0x0C -> "Clock multiplier"
        0x0D -> "Sample rate converter"
        else -> genericClassSpecificSubtypeName(subtype)
      }
      0x02 -> when (subtype) {
        0x01 -> "Audio streaming general"
        0x02 -> "Format type"
        0x03 -> "Format specific"
        else -> genericClassSpecificSubtypeName(subtype)
      }
      0x03 -> when (subtype) {
        0x01 -> "MIDI streaming header"
        0x02 -> "MIDI IN jack"
        0x03 -> "MIDI OUT jack"
        0x04 -> "MIDI element"
        else -> genericClassSpecificSubtypeName(subtype)
      }
      else -> genericClassSpecificSubtypeName(subtype)
    }
  }

  private fun cdcDescriptorSubtypeName(subtype: Int): String = when (subtype) {
    0x00 -> "CDC header"
    0x01 -> "Call management"
    0x02 -> "Abstract control management"
    0x03 -> "Direct line management"
    0x04 -> "Telephone ringer"
    0x05 -> "Telephone call and line state reporting"
    0x06 -> "Union functional descriptor"
    0x07 -> "Country selection"
    0x08 -> "Telephone operational modes"
    0x09 -> "USB terminal"
    0x0A -> "Network channel"
    0x0B -> "Protocol unit"
    0x0C -> "Extension unit"
    0x0D -> "Multi-channel management"
    0x0E -> "CAPI control"
    0x0F -> "Ethernet networking"
    0x10 -> "ATM networking"
    else -> genericClassSpecificSubtypeName(subtype)
  }

  private fun videoSubclassName(subclass: Int?): String? = when (subclass) {
    0x01 -> "VideoControl"
    0x02 -> "VideoStreaming"
    0x03 -> "Video Interface Collection"
    else -> null
  }

  private fun videoDescriptorSubtypeName(subtype: Int, subclass: Int?, endpoint: Boolean): String {
    if (endpoint) {
      return if (subtype == 0x01) "Video endpoint" else genericClassSpecificSubtypeName(subtype)
    }
    return when (subclass) {
      0x01 -> when (subtype) {
        0x01 -> "Video control header"
        0x02 -> "Input terminal"
        0x03 -> "Output terminal"
        0x04 -> "Selector unit"
        0x05 -> "Processing unit"
        0x06 -> "Extension unit"
        0x07 -> "Encoding unit"
        else -> genericClassSpecificSubtypeName(subtype)
      }
      0x02 -> when (subtype) {
        0x01 -> "Video streaming input header"
        0x02 -> "Video streaming output header"
        0x03 -> "Still image frame"
        0x04 -> "Format uncompressed"
        0x05 -> "Frame uncompressed"
        0x06 -> "Format MJPEG"
        0x07 -> "Frame MJPEG"
        0x0A -> "Format MPEG-2 TS"
        0x0C -> "Format DV"
        0x0D -> "Color matching"
        0x10 -> "Format frame-based"
        0x11 -> "Frame frame-based"
        0x12 -> "Format stream-based"
        else -> genericClassSpecificSubtypeName(subtype)
      }
      else -> genericClassSpecificSubtypeName(subtype)
    }
  }

  private fun deviceCapabilityTypeName(type: Int): String = when (type) {
    0x01 -> "Wireless USB"
    0x02 -> "USB 2.0 extension"
    0x03 -> "SuperSpeed USB"
    0x04 -> "Container ID"
    0x05 -> "Platform"
    0x06 -> "Power delivery"
    0x0A -> "SuperSpeed Plus"
    else -> "Capability ${String.format(Locale.US, "0x%02X", type)}"
  }

  private fun audioTerminalTypeName(type: Int): String = when (type) {
    0x0101 -> "USB streaming"
    0x0201 -> "Microphone"
    0x0202 -> "Desktop microphone"
    0x0203 -> "Personal microphone"
    0x0204 -> "Omni microphone"
    0x0205 -> "Microphone array"
    0x0301 -> "Speaker"
    0x0302 -> "Headphones"
    0x0304 -> "Desktop speaker"
    0x0306 -> "Headset"
    0x0601 -> "Digital audio interface"
    else -> "Terminal ${String.format(Locale.US, "0x%04X", type)}"
  }

  private fun videoTerminalTypeName(type: Int): String = when (type) {
    0x0101 -> "USB streaming"
    0x0201 -> "Camera"
    0x0202 -> "Media transport input"
    0x0301 -> "Display"
    0x0302 -> "Media transport output"
    else -> "Terminal ${String.format(Locale.US, "0x%04X", type)}"
  }

  private fun midiJackTypeName(type: Int): String = when (type) {
    0x01 -> "Embedded"
    0x02 -> "External"
    else -> "Jack ${String.format(Locale.US, "0x%02X", type)}"
  }

  private fun cdcCallManagementCapabilities(flags: Int): List<String> {
    val out = ArrayList<String>(2)
    if ((flags and 0x01) != 0) out.add("Device handles call management")
    if ((flags and 0x02) != 0) out.add("Uses a dedicated data interface")
    return out
  }

  private fun cdcAcmCapabilities(flags: Int): List<String> {
    val out = ArrayList<String>(4)
    if ((flags and 0x01) != 0) out.add("Comm feature")
    if ((flags and 0x02) != 0) out.add("Line coding and state")
    if ((flags and 0x04) != 0) out.add("Send break")
    if ((flags and 0x08) != 0) out.add("Network connection")
    return out
  }

  private fun decodeSuperSpeedFlags(flags: Int): List<String> {
    val out = ArrayList<String>(4)
    if ((flags and 0x01) != 0) out.add("Low-speed")
    if ((flags and 0x02) != 0) out.add("Full-speed")
    if ((flags and 0x04) != 0) out.add("High-speed")
    if ((flags and 0x08) != 0) out.add("SuperSpeed")
    return out
  }

  private fun superSpeedFunctionalityName(value: Int): String {
    return when (value and 0x0F) {
      0 -> "Low-speed"
      1 -> "Full-speed"
      2 -> "High-speed"
      3 -> "SuperSpeed"
      else -> "$value"
    }
  }

  private fun hubPowerSwitchingModeName(value: Int): String = when (value) {
    0 -> "Ganged"
    1 -> "Individual"
    2 -> "No switching"
    else -> "$value"
  }

  private fun hubOverCurrentModeName(value: Int): String = when (value) {
    0 -> "Global"
    1 -> "Individual"
    2 -> "None"
    else -> "$value"
  }

  private fun hubThinkTimeName(value: Int): String = when (value) {
    0 -> "8 FS bit times"
    1 -> "16 FS bit times"
    2 -> "24 FS bit times"
    3 -> "32 FS bit times"
    else -> "$value"
  }

  private fun le24(bytes: ByteArray, offset: Int): Int {
    if (offset + 2 >= bytes.size) return 0
    return u8(bytes[offset]) or
      (u8(bytes[offset + 1]) shl 8) or
      (u8(bytes[offset + 2]) shl 16)
  }

  private fun le32(bytes: ByteArray, offset: Int): Int {
    if (offset + 3 >= bytes.size) return 0
    return u8(bytes[offset]) or
      (u8(bytes[offset + 1]) shl 8) or
      (u8(bytes[offset + 2]) shl 16) or
      (u8(bytes[offset + 3]) shl 24)
  }

  private fun littleEndianGuid(bytes: ByteArray, offset: Int): String? {
    if (offset + 15 >= bytes.size) return null
    val d1 = le32(bytes, offset).toLong() and 0xffffffffL
    val d2 = le16(bytes[offset + 4], bytes[offset + 5])
    val d3 = le16(bytes[offset + 6], bytes[offset + 7])
    val tail = (offset + 8 until offset + 16)
      .joinToString("") { String.format(Locale.US, "%02x", u8(bytes[it])) }
    return String.format(Locale.US, "%08x-%04x-%04x-%s-%s", d1, d2, d3, tail.substring(0, 4), tail.substring(4))
  }

  private fun hexSlice(bytes: ByteArray, offset: Int, length: Int): String {
    if (offset >= bytes.size || length <= 0) return ""
    val end = min(bytes.size, offset + length)
    return toHex(bytes.copyOfRange(offset, end), 2048)
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

  private fun readStringLanguageIds(
    conn: UsbDeviceConnection,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): List<Int> {
    val buf = ByteArray(255)
    val r = conn.controlTransfer(0x80, 0x06, (0x03 shl 8) or 0, 0, buf, buf.size, 1200)
    controlTransfers?.add(
      controlTransferResult(
        label = "GET_DESCRIPTOR String LANGIDs",
        requestType = 0x80,
        request = 0x06,
        value = (0x03 shl 8) or 0,
        index = 0,
        requestedLength = buf.size,
        actualLength = r,
        response = if (r > 0) buf.copyOf(r) else null
      )
    )
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

  private fun readStringDescriptor(
    conn: UsbDeviceConnection,
    index: Int,
    langId: Int,
    controlTransfers: MutableList<Map<String, Any?>>? = null,
    label: String? = null
  ): String? {
    if (index <= 0) return null
    val buf = ByteArray(255)
    val r = conn.controlTransfer(0x80, 0x06, (0x03 shl 8) or (index and 0xFF), langId, buf, buf.size, 1200)
    controlTransfers?.add(
      controlTransferResult(
        label = label ?: "GET_DESCRIPTOR String #$index",
        requestType = 0x80,
        request = 0x06,
        value = (0x03 shl 8) or (index and 0xFF),
        index = langId,
        requestedLength = buf.size,
        actualLength = r,
        response = if (r > 0) buf.copyOf(r) else null
      )
    )
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

  private fun readDeviceStrings(
    conn: UsbDeviceConnection,
    dd: Map<String, Any?>,
    langId: Int,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): Map<String, Any?> {
    val iMan = (dd["iManufacturer"] as? Int) ?: 0
    val iProd = (dd["iProduct"] as? Int) ?: 0
    val iSer = (dd["iSerialNumber"] as? Int) ?: 0
    val man = readStringDescriptor(conn, iMan, langId, controlTransfers, "GET_DESCRIPTOR iManufacturer")
    val prod = readStringDescriptor(conn, iProd, langId, controlTransfers, "GET_DESCRIPTOR iProduct")
    val ser = readStringDescriptor(conn, iSer, langId, controlTransfers, "GET_DESCRIPTOR iSerialNumber")
    return mapOf("manufacturer" to man, "product" to prod, "serial" to ser, "iManufacturer" to iMan, "iProduct" to iProd, "iSerialNumber" to iSer)
  }

  private fun readInterfaceStrings(
    conn: UsbDeviceConnection,
    tree: List<Map<String, Any?>>,
    langId: Int,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): List<Map<String, Any?>> {
    val out = ArrayList<Map<String, Any?>>()
    for (node in tree) {
      val t = node["descriptorType"] as? Int ?: continue
      if (t != 0x04) continue
      val fields = node["fields"] as? Map<*, *> ?: continue
      val ifNum = (fields["bInterfaceNumber"] as? Int) ?: continue
      val alt = (fields["bAlternateSetting"] as? Int) ?: 0
      val idx = (fields["iInterface"] as? Int) ?: 0
      if (idx <= 0) continue
      val value = readStringDescriptor(
        conn,
        idx,
        langId,
        controlTransfers,
        "GET_DESCRIPTOR iInterface IF $ifNum alt $alt"
      )
      out.add(mapOf("interfaceNumber" to ifNum, "alternateSetting" to alt, "iInterface" to idx, "value" to value))
    }
    return out
  }

  private fun readDeviceState(
    conn: UsbDeviceConnection,
    device: UsbDevice,
    tree: List<Map<String, Any?>>?,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): Map<String, Any?> {
    val activeCfg = ctrlGetConfiguration(conn, controlTransfers)
    val status = ctrlGetStatus(conn, controlTransfers)
    val ifAlt = readAltSettings(conn, device, tree, controlTransfers)
    return mapOf(
      "activeConfiguration" to activeCfg,
      "deviceStatus" to status,
      "interfaceAltSettings" to ifAlt
    )
  }

  private fun ctrlGetConfiguration(
    conn: UsbDeviceConnection,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): Int? {
    val buf = ByteArray(1)
    val r = conn.controlTransfer(0x80, 0x08, 0, 0, buf, 1, 1200)
    controlTransfers?.add(
      controlTransferResult(
        label = "GET_CONFIGURATION",
        requestType = 0x80,
        request = 0x08,
        value = 0,
        index = 0,
        requestedLength = 1,
        actualLength = r,
        response = if (r > 0) buf.copyOf(r) else null
      )
    )
    if (r != 1) return null
    return u8(buf[0])
  }

  private fun ctrlGetStatus(
    conn: UsbDeviceConnection,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): Map<String, Any?>? {
    val buf = ByteArray(2)
    val r = conn.controlTransfer(0x80, 0x00, 0, 0, buf, 2, 1200)
    controlTransfers?.add(
      controlTransferResult(
        label = "GET_STATUS device",
        requestType = 0x80,
        request = 0x00,
        value = 0,
        index = 0,
        requestedLength = 2,
        actualLength = r,
        response = if (r > 0) buf.copyOf(r) else null
      )
    )
    if (r != 2) return null
    val v = le16(buf[0], buf[1])
    val selfPowered = (v and 0x0001) != 0
    val remoteWakeup = (v and 0x0002) != 0
    return mapOf("raw" to v, "selfPowered" to selfPowered, "remoteWakeup" to remoteWakeup)
  }

  private fun readAltSettings(
    conn: UsbDeviceConnection,
    device: UsbDevice,
    tree: List<Map<String, Any?>>?,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): List<Map<String, Any?>> {
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
      val alt = ctrlGetInterface(conn, n, controlTransfers)
      out.add(mapOf("interfaceNumber" to n, "alternateSetting" to alt))
    }
    return out
  }

  private fun ctrlGetInterface(
    conn: UsbDeviceConnection,
    interfaceNumber: Int,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): Int? {
    val buf = ByteArray(1)
    val r = conn.controlTransfer(0x81, 0x0A, 0, interfaceNumber, buf, 1, 1200)
    controlTransfers?.add(
      controlTransferResult(
        label = "GET_INTERFACE IF $interfaceNumber",
        requestType = 0x81,
        request = 0x0A,
        value = 0,
        index = interfaceNumber,
        requestedLength = 1,
        actualLength = r,
        response = if (r > 0) buf.copyOf(r) else null
      )
    )
    if (r != 1) return null
    return u8(buf[0])
  }

  private fun readHidReports(
    conn: UsbDeviceConnection,
    device: UsbDevice,
    tree: List<Map<String, Any?>>,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): List<Map<String, Any?>> {
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
      val bytes = ctrlGetHidReportDescriptor(conn, ifNum, repLen, controlTransfers)
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

  private fun ctrlGetHidReportDescriptor(
    conn: UsbDeviceConnection,
    interfaceNumber: Int,
    reportLen: Int,
    controlTransfers: MutableList<Map<String, Any?>>? = null
  ): ByteArray? {
    val len = reportLen.coerceIn(1, 8192)
    val buf = ByteArray(len)
    val r = conn.controlTransfer(0x81, 0x06, (0x22 shl 8) or 0, interfaceNumber, buf, len, 1800)
    controlTransfers?.add(
      controlTransferResult(
        label = "GET_DESCRIPTOR HID report IF $interfaceNumber",
        requestType = 0x81,
        request = 0x06,
        value = (0x22 shl 8) or 0,
        index = interfaceNumber,
        requestedLength = len,
        actualLength = r,
        response = if (r > 0) buf.copyOf(r) else null
      )
    )
    if (r <= 0) return null
    return if (r == buf.size) buf else buf.copyOf(r)
  }

  private fun controlTransferResult(
    label: String,
    requestType: Int,
    request: Int,
    value: Int,
    index: Int,
    requestedLength: Int,
    actualLength: Int,
    response: ByteArray?
  ): Map<String, Any?> {
    return mapOf(
      "label" to label,
      "requestType" to requestType,
      "request" to request,
      "value" to value,
      "index" to index,
      "requestedLength" to requestedLength,
      "actualLength" to actualLength,
      "success" to (actualLength >= 0),
      "responseHex" to if (response == null || actualLength <= 0) null else toHex(response, 4096)
    )
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
