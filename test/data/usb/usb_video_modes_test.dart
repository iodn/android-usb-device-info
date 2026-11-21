import 'package:flutter_test/flutter_test.dart';

import 'package:USBDevInfo/data/usb/usb_video_modes.dart';

Map<String, dynamic> streamingDescriptor(List<int> bytes) => {
  'descriptorType': 0x24,
  'context': {'interfaceClass': 14, 'interfaceSubclass': 2},
  'rawHex': bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
};

List<int> frame({
  int subtype = 0x07,
  int width = 1920,
  int height = 1080,
  bool continuous = false,
  required List<int> intervals,
}) {
  final bytes = List<int>.filled(26 + intervals.length * 4, 0);
  bytes[0] = bytes.length;
  bytes[1] = 0x24;
  bytes[2] = subtype;
  bytes[3] = 1;
  bytes[5] = width & 0xff;
  bytes[6] = width >> 8;
  bytes[7] = height & 0xff;
  bytes[8] = height >> 8;
  bytes[subtype == 0x11 ? 21 : 25] = continuous ? 0 : intervals.length;
  for (var i = 0; i < intervals.length; i++) {
    for (var byte = 0; byte < 4; byte++) {
      bytes[26 + 4 * i + byte] = (intervals[i] >> (8 * byte)) & 0xff;
    }
  }
  return bytes;
}

void main() {
  test('reports and deduplicates advertised MJPEG modes', () {
    final format = streamingDescriptor([5, 0x24, 0x06, 1, 1]);
    final mode = streamingDescriptor(frame(intervals: [666667, 333333]));
    final modes = readUsbVideoModes([format, mode, mode]);
    expect(modes, hasLength(1));
    expect(modes.single.format, 'MJPEG');
    expect(modes.single.width, 1920);
    expect(modes.single.height, 1080);
    expect(modes.single.intervals, [333333, 666667]);
    expect(modes.single.continuous, isFalse);
  });

  test(
    'reads frame-based interval bounds without treating the step as a rate',
    () {
      final format = streamingDescriptor([
        21,
        0x24,
        0x10,
        1,
        1,
        0x48,
        0x32,
        0x36,
        0x34,
        0,
        0,
        0x10,
        0,
        0x80,
        0,
        0,
        0xaa,
        0,
        0x38,
        0x9b,
        0x71,
      ]);
      final modes = readUsbVideoModes([
        format,
        streamingDescriptor(
          frame(
            subtype: 0x11,
            continuous: true,
            intervals: [166667, 1000000, 10000],
          ),
        ),
      ]);
      expect(modes.single.format, 'H264');
      expect(modes.single.continuous, isTrue);
      expect(modes.single.intervals, [166667, 1000000]);
    },
  );

  test('ignores unrelated interfaces and keeps valid geometry if rates are truncated', () {
    final format = streamingDescriptor([5, 0x24, 0x06, 1, 1]);
    final bytes = frame(intervals: [333333]);
    bytes[25] = 20;
    final modes = readUsbVideoModes([
      format,
      streamingDescriptor(bytes),
      {'descriptorType': 4},
      streamingDescriptor(bytes),
      {
        'descriptorType': 0x24,
        'context': {'interfaceClass': 14, 'interfaceSubclass': 2},
        'rawHex': 'zzzzzz',
      },
    ]);
    expect(modes, hasLength(1));
    expect(modes.single.width, 1920);
    expect(modes.single.intervals, isEmpty);
  });
}
