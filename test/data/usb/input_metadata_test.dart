import 'package:USBDevInfo/data/usb/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('input metadata round-trips through report and history maps', () {
    final input = InputDeviceInfo.fromMap({
      'id': 4,
      'sources': ['gamepad', 'joystick'],
      'supportedButtons': ['A', 'R1'],
      'motionRanges': [
        {
          'axis': 15,
          'axisName': 'HAT X',
          'source': 'joystick',
          'min': -1,
          'max': 1,
        },
      ],
    });
    final restored = InputDeviceInfo.fromMap(input.toMap());
    expect(restored.sources, ['gamepad', 'joystick']);
    expect(restored.supportedButtons, ['A', 'R1']);
    expect(restored.motionRanges.single.axisName, 'HAT X');
    expect(restored.motionRanges.single.source, 'joystick');
    expect(restored.motionRanges.single.min, -1);
  });

  test(
    'older history rows still parse without axis labels or button inventory',
    () {
      final input = InputDeviceInfo.fromMap({
        'id': 2,
        'motionRanges': [
          {'axis': 0, 'min': 0, 'max': 100},
        ],
      });
      expect(input.supportedButtons, isEmpty);
      expect(input.motionRanges.single.axisName, isNull);
      expect(input.motionRanges.single.source, isNull);
    },
  );
}
