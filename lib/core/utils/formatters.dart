import 'package:intl/intl.dart';

class Fmt {
  static String hex16(int v) =>
      '0x${v.toRadixString(16).padLeft(4, '0').toUpperCase()}';
  static String hex8(int v) =>
      '0x${v.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  static String hex32(int v) =>
      '0x${v.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  static String decAndHex16(int v) => '${hex16(v)} ($v)';
  static String decAndHex8(int v) => '${hex8(v)} ($v)';
  static String decAndHex32(int v) => '${hex32(v)} ($v)';

  static String formatNullable(String? v, {String fallback = 'Unknown'}) {
    final s = v?.trim();
    return (s == null || s.isEmpty) ? fallback : s;
  }

  static String speedLabel(String? speed) {
    if (speed == null || speed.isEmpty) return 'Unknown';
    return speed;
  }

  static String yesNo(bool? v, {String unknown = 'Unknown'}) {
    if (v == null) return unknown;
    return v ? 'Yes' : 'No';
  }

  static String nowShort() => DateFormat('HH:mm:ss').format(DateTime.now());

  static String usbConfigAttributesLabel(int attributes) {
    final selfPowered = (attributes & 0x40) != 0;
    final remoteWake = (attributes & 0x20) != 0;
    final parts = <String>[];
    parts.add(selfPowered ? 'Self-powered' : 'Bus-powered');
    if (remoteWake) parts.add('Remote wakeup');
    return parts.join(' • ');
  }

  static String axisLabel(int axis) {
    const map = <int, String>{
      0: 'X',
      1: 'Y',
      2: 'Pressure',
      3: 'Size',
      4: 'Touch Major',
      5: 'Touch Minor',
      6: 'Tool Major',
      7: 'Tool Minor',
      8: 'Orientation',
      9: 'Vscroll',
      10: 'Hscroll',
      11: 'Z',
      12: 'Rx',
      13: 'Ry',
      14: 'Rz',
      15: 'Hat X',
      16: 'Hat Y',
      17: 'Ltrigger',
      18: 'Rtrigger',
      19: 'Throttle',
      20: 'Rudder',
      21: 'Wheel',
      22: 'Gas',
      23: 'Brake',
      24: 'Distance',
      25: 'Tilt',
      26: 'Scroll',
      27: 'Relative X',
      28: 'Relative Y',
      32: 'Generic 1',
      33: 'Generic 2',
      34: 'Generic 3',
      35: 'Generic 4',
      36: 'Generic 5',
      37: 'Generic 6',
      38: 'Generic 7',
      39: 'Generic 8',
      40: 'Generic 9',
      41: 'Generic 10',
      42: 'Generic 11',
      43: 'Generic 12',
      44: 'Generic 13',
      45: 'Generic 14',
      46: 'Generic 15',
      47: 'Generic 16',
    };
    return map[axis] ?? 'Axis $axis';
  }

  static String hexWrap(
    String hex, {
    int group = 2,
    int groupsPerLine = 16,
  }) {
    final cleaned = hex
        .replaceAll(RegExp(r'0x', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (cleaned.isEmpty) return '';
    final g = group <= 0 ? 2 : group;
    final perLine = groupsPerLine <= 0 ? 16 : groupsPerLine;

    final out = StringBuffer();
    var groupsOnLine = 0;

    for (var i = 0; i < cleaned.length; i += g) {
      final end = (i + g <= cleaned.length) ? (i + g) : cleaned.length;
      final part = cleaned.substring(i, end).toUpperCase().padLeft(g, '0');

      if (out.isNotEmpty) {
        if (groupsOnLine >= perLine) {
          out.write('\n');
          groupsOnLine = 0;
        } else {
          out.write(' ');
        }
      }

      out.write(part);
      groupsOnLine++;
    }

    return out.toString();
  }
}
