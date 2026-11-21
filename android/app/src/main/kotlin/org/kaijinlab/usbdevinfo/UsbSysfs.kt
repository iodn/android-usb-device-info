package org.kaijinlab.usbdevinfo

import java.io.File
import java.io.IOException
import java.util.Locale

private val usbSysfsDeviceName = Regex("(?:usb[1-9][0-9]*|[1-9][0-9]*-[1-9][0-9]*(?:\\.[1-9][0-9]*)*)")

internal data class UsbSysfsDevice(
  val directory: File,
  val busNumber: Int,
  val deviceNumber: Int,
  val vendorId: Int,
  val productId: Int
) {
  val devicePath: String
    get() = String.format(Locale.ROOT, "/dev/bus/usb/%03d/%03d", busNumber, deviceNumber)

  val negotiatedSpeed: String?
    get() {
      val rate = readUsbSysfsAttribute(directory, "speed") ?: return null
      val megabits = rate.toDoubleOrNull() ?: return null
      return if (megabits.isFinite() && megabits > 0) "$rate Mbps" else null
    }

  val portChain: List<Int>
    get() = directory.name.substringAfter('-', "").split('.').mapNotNull(String::toIntOrNull)
}

internal fun isUsbSysfsDeviceName(name: String): Boolean = usbSysfsDeviceName.matches(name)

internal fun readUsbSysfsDevice(directory: File): UsbSysfsDevice? {
  if (!isUsbSysfsDeviceName(directory.name)) return null
  fun number(name: String, radix: Int = 10): Int? =
    readUsbSysfsAttribute(directory, name)?.toIntOrNull(radix)
  val bus = number("busnum")?.takeIf { it > 0 } ?: return null
  val device = number("devnum")?.takeIf { it in 1..127 } ?: return null
  val vendor = number("idVendor", 16)?.takeIf { it in 0..0xffff } ?: return null
  val product = number("idProduct", 16)?.takeIf { it in 0..0xffff } ?: return null
  return UsbSysfsDevice(directory, bus, device, vendor, product)
}

internal fun List<UsbSysfsDevice>.matchUsbDevice(
  path: String,
  vendorId: Int,
  productId: Int
): UsbSysfsDevice? = singleOrNull {
  it.devicePath == path && it.vendorId == vendorId && it.productId == productId
}

private fun readUsbSysfsAttribute(directory: File, name: String): String? = try {
  File(directory, name).readText().trim()
} catch (_: IOException) {
  null
} catch (_: SecurityException) {
  null
}
