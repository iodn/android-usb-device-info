import 'package:USBDevInfo/data/usb/usb_interface_associations.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object> _configuration(int id, {int type = 0x02}) => {
  'descriptorType': type,
  'fields': {'bConfigurationValue': id},
};

Map<String, Object> _association(int first, int count, {String? name}) => {
  'descriptorType': 0x0B,
  'fields': {
    'bFirstInterface': first,
    'bInterfaceCount': count,
    'bFunctionClass': 0x0E,
    'bFunctionSubClass': 0x03,
    'bFunctionProtocol': 0,
    'iFunction': 4,
    'functionName': ?name,
  },
};

void main() {
  test('keeps advertised functions scoped to their configuration', () {
    final functions = readUsbInterfaceAssociations([
      _configuration(1),
      _association(0, 2, name: '  Camera and microphone  '),
      {'descriptorType': 0x04},
      _association(2, 1, name: '   '),
      _configuration(2),
      _association(0, 2),
    ]);

    expect(functions.first, (
      configuration: 1,
      firstInterface: 0,
      interfaceCount: 2,
      functionClass: 0x0E,
      functionSubclass: 0x03,
      functionProtocol: 0,
      stringIndex: 4,
      name: 'Camera and microphone',
    ));
    expect(functions[1].name, isNull);
    expect(functions[2].name, isNull);
    expect(
      functions.map(
        (function) => (function.configuration, function.firstInterface),
      ),
      [(1, 0), (1, 2), (2, 0)],
    );
  });

  test('ignores malformed and other-speed associations', () {
    expect(
      readUsbInterfaceAssociations([
        _association(0, 2),
        _configuration(1),
        {'descriptorType': 0x0B},
        _association(0, 0),
        _association(255, 2),
        _configuration(1, type: 0x07),
        _association(0, 2),
      ]),
      isEmpty,
    );
  });
}
