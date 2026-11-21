package org.kaijinlab.usbdevinfo

internal const val USB_AUDIO_CLASS_1 = 0x00
internal const val USB_AUDIO_CLASS_2 = 0x20

internal fun parseAudioStreamingFields(protocol: Int?, bytes: ByteArray): Map<String, Any?> {
  if (bytes.size < 3 || bytes.uint(0) != bytes.size || bytes.uint(1) != 0x24) return emptyMap()
  return when (protocol) {
    USB_AUDIO_CLASS_1 -> when (bytes.uint(2)) {
      1 -> if (bytes.size >= 7) {
        val tag = bytes.le16(5)
        val format = when (tag) {
          1 -> "PCM"
          2 -> "PCM8"
          3 -> "IEEE float"
          4 -> "A-law"
          5 -> "µ-law"
          0x1001 -> "MPEG"
          0x1002 -> "AC-3"
          else -> null
        }
        mapOf("bTerminalLink" to bytes.uint(3), "bDelay" to bytes.uint(4), "wFormatTag" to tag,
          "formatNames" to listOfNotNull(format))
      } else emptyMap()
      2 -> parseAudioV1Format(bytes)
      else -> emptyMap()
    }
    USB_AUDIO_CLASS_2 -> when (bytes.uint(2)) {
      1 -> if (bytes.size >= 16) {
        val formatType = bytes.uint(5)
        val formats = bytes.le32(6)
        val names = if (formatType == 1) buildList {
          listOf("PCM", "PCM8", "IEEE float", "A-law", "µ-law").forEachIndexed { bit, name ->
            if ((formats and (1L shl bit)) != 0L) add(name)
          }
          if ((formats and (1L shl 31)) != 0L) add("Raw data")
        } else emptyList()
        mapOf(
          "bTerminalLink" to bytes.uint(3),
          "bmControls" to bytes.uint(4),
          "bFormatType" to formatType,
          "bmFormats" to formats,
          "formatNames" to names,
          "bNrChannels" to bytes.uint(10),
          "bmChannelConfig" to bytes.le32(11),
          "iChannelNames" to bytes.uint(15)
        )
      } else emptyMap()
      2 -> if (bytes.size >= 4) {
        val formatType = bytes.uint(3)
        when {
          (formatType == 1 || formatType == 3) && bytes.size >= 6 -> mapOf(
            "bFormatType" to formatType,
            "bSubslotSize" to bytes.uint(4),
            "bBitResolution" to bytes.uint(5)
          )
          formatType == 2 && bytes.size >= 8 -> mapOf(
            "bFormatType" to formatType,
            "wMaxBitRate" to bytes.le16(4),
            "wSlotsPerFrame" to bytes.le16(6)
          )
          else -> mapOf("bFormatType" to formatType)
        }
      } else emptyMap()
      else -> emptyMap()
    }
    else -> emptyMap()
  }
}

private fun parseAudioV1Format(bytes: ByteArray): Map<String, Any?> {
  if (bytes.size < 4) return emptyMap()
  val formatType = bytes.uint(3)
  val fields = linkedMapOf<String, Any?>("bFormatType" to formatType)
  val rateCountOffset = when {
    (formatType == 1 || formatType == 3) && bytes.size >= 8 -> {
      fields["bNrChannels"] = bytes.uint(4)
      fields["bSubframeSize"] = bytes.uint(5)
      fields["bBitResolution"] = bytes.uint(6)
      7
    }
    formatType == 2 && bytes.size >= 9 -> {
      fields["wMaxBitRate"] = bytes.le16(4)
      fields["wSamplesPerFrame"] = bytes.le16(6)
      8
    }
    else -> return fields
  }
  val rateCount = bytes.uint(rateCountOffset)
  val offset = rateCountOffset + 1
  fields["bSamFreqType"] = rateCount
  if (rateCount == 0 && bytes.size >= offset + 6) {
    val lower = bytes.le24(offset)
    val upper = bytes.le24(offset + 3)
    if (lower > 0 && upper >= lower) {
      fields["sampleRateMinHz"] = lower
      fields["sampleRateMaxHz"] = upper
    }
  } else if (rateCount > 0 && bytes.size >= offset + rateCount * 3) {
    fields["sampleRates"] = (0 until rateCount).map { bytes.le24(offset + it * 3) }
      .filter { it > 0 }.distinct()
  }
  return fields
}

internal fun parseAudioEndpointFields(protocol: Int?, bytes: ByteArray): Map<String, Any?> {
  if (bytes.size < 3 || bytes.uint(0) != bytes.size || bytes.uint(1) != 0x25 || bytes.uint(2) != 1) {
    return emptyMap()
  }
  return when {
    protocol == USB_AUDIO_CLASS_1 && bytes.size >= 7 -> mapOf(
      "bmAttributes" to bytes.uint(3), "bLockDelayUnits" to bytes.uint(4), "wLockDelay" to bytes.le16(5)
    )
    protocol == USB_AUDIO_CLASS_2 && bytes.size >= 8 -> mapOf(
      "bmAttributes" to bytes.uint(3), "bmControls" to bytes.uint(4),
      "bLockDelayUnits" to bytes.uint(5), "wLockDelay" to bytes.le16(6)
    )
    else -> emptyMap()
  }
}

internal fun parseAudioV2ControlFields(bytes: ByteArray): Map<String, Any?> {
  if (bytes.size < 3 || bytes.uint(0) != bytes.size || bytes.uint(1) != 0x24) return emptyMap()
  return when (bytes.uint(2)) {
    1 -> if (bytes.size >= 9) mapOf(
      "bCategory" to bytes.uint(5), "wTotalLength" to bytes.le16(6), "bmControls" to bytes.uint(8)
    ) else emptyMap()
    2 -> if (bytes.size >= 17) mapOf(
      "bTerminalID" to bytes.uint(3), "wTerminalType" to bytes.le16(4),
      "bAssocTerminal" to bytes.uint(6), "bCSourceID" to bytes.uint(7),
      "bNrChannels" to bytes.uint(8), "bmChannelConfig" to bytes.le32(9),
      "iChannelNames" to bytes.uint(13), "bmControls" to bytes.le16(14),
      "iTerminal" to bytes.uint(16)
    ) else emptyMap()
    3 -> if (bytes.size >= 12) mapOf(
      "bTerminalID" to bytes.uint(3), "wTerminalType" to bytes.le16(4),
      "bAssocTerminal" to bytes.uint(6), "bSourceID" to bytes.uint(7),
      "bCSourceID" to bytes.uint(8), "bmControls" to bytes.le16(9),
      "iTerminal" to bytes.uint(11)
    ) else emptyMap()
    0x0A -> if (bytes.size >= 8) mapOf(
      "bClockID" to bytes.uint(3), "bmAttributes" to bytes.uint(4), "bmControls" to bytes.uint(5),
      "bAssocTerminal" to bytes.uint(6), "iClockSource" to bytes.uint(7)
    ) else emptyMap()
    else -> emptyMap()
  }
}

private fun ByteArray.uint(offset: Int): Int = this[offset].toInt() and 0xff
private fun ByteArray.le16(offset: Int): Int = uint(offset) or (uint(offset + 1) shl 8)
private fun ByteArray.le24(offset: Int): Int = le16(offset) or (uint(offset + 2) shl 16)
private fun ByteArray.le32(offset: Int): Long = le16(offset).toLong() or (le16(offset + 2).toLong() shl 16)
