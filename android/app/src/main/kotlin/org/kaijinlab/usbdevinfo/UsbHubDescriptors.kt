package org.kaijinlab.usbdevinfo

internal const val USB_HUB_DESCRIPTOR = 0x29
internal const val USB_SUPERSPEED_HUB_DESCRIPTOR = 0x2A
internal const val USB_SUPERSPEED_ENDPOINT_COMPANION = 0x30
internal const val USB_SUPERSPEEDPLUS_ISOCH_ENDPOINT_COMPANION = 0x31

internal fun parseUsbHubDescriptor(bytes: ByteArray): Map<String, Any?>? {
  if (bytes.size < 7 || bytes.unsigned(0) != bytes.size) return null
  val type = bytes.unsigned(1)
  if (type != USB_HUB_DESCRIPTOR && type != USB_SUPERSPEED_HUB_DESCRIPTOR) return null
  val superSpeed = type == USB_SUPERSPEED_HUB_DESCRIPTOR
  val ports = bytes.unsigned(2)
  val bitmapBytes = ports / 8 + 1
  val minimumSize = if (superSpeed) 12 else 7 + 2 * bitmapBytes
  if (ports == 0 || (superSpeed && ports > 15) || bytes.size < minimumSize) return null

  val characteristics = bytes.le16(3)
  val powerMode = characteristics and 0x03
  val overCurrentMode = (characteristics shr 3) and 0x03
  val removableOffset = if (superSpeed) 10 else 7
  val nonRemovablePorts = (1..ports).filter { port ->
    (bytes.unsigned(removableOffset + port / 8) and (1 shl (port % 8))) != 0
  }

  val fields = linkedMapOf<String, Any?>(
    "bNbrPorts" to ports,
    "powerGoodMs" to (bytes.unsigned(5) * 2),
    "hubControllerCurrentMa" to (bytes.unsigned(6) * if (superSpeed) 4 else 1),
    "nonRemovablePorts" to nonRemovablePorts,
    "powerSwitchingModeName" to when (powerMode) {
      0 -> "Ganged"
      1 -> "Individual"
      else -> "No switching"
    },
    "overCurrentProtectionModeName" to when (overCurrentMode) {
      0 -> "Global"
      1 -> "Individual"
      else -> "None"
    },
    "wHubCharacteristics" to characteristics,
    "powerSwitchingMode" to powerMode,
    "overCurrentProtectionMode" to overCurrentMode,
    "compoundDevice" to ((characteristics and 0x04) != 0),
    "bPwrOn2PwrGood" to bytes.unsigned(5),
    "bHubContrCurrent" to bytes.unsigned(6)
  )

  if (superSpeed) {
    fields["bHubHdrDecLat"] = bytes.unsigned(7)
    fields["hubHeaderDecodeLatencyNs"] = bytes.unsigned(7) * 100
    fields["hubDelayNs"] = bytes.le16(8)
  } else {
    val ttThinkTime = (characteristics shr 5) and 0x03
    fields["ttThinkTime"] = ttThinkTime
    fields["ttThinkTimeName"] = "${(ttThinkTime + 1) * 8} FS bit times"
    fields["portIndicatorsSupported"] = (characteristics and 0x80) != 0
  }
  return fields
}

internal fun parseSuperSpeedEndpointCompanion(bytes: ByteArray): Map<String, Int>? {
  if (bytes.size != 6 || bytes.unsigned(0) != 6 ||
      bytes.unsigned(1) != USB_SUPERSPEED_ENDPOINT_COMPANION) return null
  return mapOf(
    "bMaxBurst" to bytes.unsigned(2),
    "bmAttributes" to bytes.unsigned(3),
    "wBytesPerInterval" to bytes.le16(4)
  )
}

internal fun parseSuperSpeedPlusEndpointCompanion(bytes: ByteArray): Map<String, Long>? {
  if (bytes.size != 8 || bytes.unsigned(0) != 8 ||
      bytes.unsigned(1) != USB_SUPERSPEEDPLUS_ISOCH_ENDPOINT_COMPANION) return null
  return mapOf("dwBytesPerInterval" to (bytes.le16(4).toLong() or (bytes.le16(6).toLong() shl 16)))
}

private fun ByteArray.unsigned(offset: Int): Int = this[offset].toInt() and 0xff
private fun ByteArray.le16(offset: Int): Int = unsigned(offset) or (unsigned(offset + 1) shl 8)
