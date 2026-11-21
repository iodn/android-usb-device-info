/// A frame mode advertised by a USB Video Class streaming interface.
/// Frame intervals use the descriptor's units of 100 nanoseconds.
typedef UsbVideoMode = ({
  String format,
  int width,
  int height,
  List<int> intervals,
  bool continuous,
});

List<UsbVideoMode> readUsbVideoModes(Iterable<dynamic> descriptors) {
  final modes = <UsbVideoMode>[];
  final seen = <String>{};
  String? format;
  int? frameSubtype;
  for (final descriptor in descriptors.whereType<Map>()) {
    final type = descriptor['descriptorType'];
    if (type == 0x01 || type == 0x02 || type == 0x04) {
      format = null;
      frameSubtype = null;
    }
    final context = descriptor['context'];
    if (type != 0x24 ||
        context is! Map ||
        context['interfaceClass'] != 14 ||
        context['interfaceSubclass'] != 2) {
      continue;
    }
    final hex = descriptor['rawHex'];
    if (hex is! String) continue;
    final text = hex.replaceAll(' ', '');
    if (text.length < 6 || text.length.isOdd || text.length > 510) continue;
    final bytes = <int>[];
    for (var i = 0; i < text.length; i += 2) {
      final byte = int.tryParse(text.substring(i, i + 2), radix: 16);
      if (byte == null || byte < 0) break;
      bytes.add(byte);
    }
    if (bytes.length * 2 != text.length ||
        bytes.first != bytes.length ||
        bytes[1] != 0x24) {
      continue;
    }

    final subtype = bytes[2];
    if (subtype == 0x04 || subtype == 0x06 || subtype == 0x10) {
      frameSubtype = subtype + 1;
      format = subtype == 0x06
          ? 'MJPEG'
          : _fourCc(bytes) ??
                (subtype == 0x04 ? 'Uncompressed' : 'Frame-based');
      continue;
    }
    if (subtype != frameSubtype || format == null || bytes.length < 26)
      continue;
    final width = bytes[5] | bytes[6] << 8;
    final height = bytes[7] | bytes[8] << 8;
    if (width == 0 || height == 0) continue;
    final count = bytes[subtype == 0x11 ? 21 : 25];
    final continuous = count == 0;
    final intervalCount = continuous ? 3 : count;
    final intervals = <int>[];
    if (bytes.length >= 26 + 4 * intervalCount) {
      for (var i = 0; i < (continuous ? 2 : intervalCount); i++) {
        final j = 26 + 4 * i;
        final interval =
            bytes[j] |
            bytes[j + 1] << 8 |
            bytes[j + 2] << 16 |
            bytes[j + 3] << 24;
        if (interval > 0) intervals.add(interval);
      }
      intervals.sort();
    }
    final uniqueIntervals = intervals.toSet().toList(growable: false);
    if (seen.add('$format/$width/$height/$continuous/$uniqueIntervals')) {
      modes.add((
        format: format,
        width: width,
        height: height,
        intervals: uniqueIntervals,
        continuous: continuous,
      ));
    }
  }
  return modes;
}

String? _fourCc(List<int> bytes) {
  const guidSuffix = [0, 0, 0x10, 0, 0x80, 0, 0, 0xaa, 0, 0x38, 0x9b, 0x71];
  if (bytes.length < 21) return null;
  for (var i = 0; i < guidSuffix.length; i++) {
    if (bytes[9 + i] != guidSuffix[i]) return null;
  }
  final code = bytes.sublist(5, 9);
  return code.every((value) => value >= 32 && value <= 126)
      ? String.fromCharCodes(code)
      : null;
}
