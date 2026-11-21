typedef UsbInterfaceAssociation = ({
  int configuration,
  int firstInterface,
  int interfaceCount,
  int functionClass,
  int functionSubclass,
  int functionProtocol,
  int stringIndex,
  String? name,
});

/// Reads the functions advertised by interface association descriptors.
List<UsbInterfaceAssociation> readUsbInterfaceAssociations(
  Iterable<dynamic> descriptors,
) {
  final associations = <UsbInterfaceAssociation>[];
  int? configuration;
  for (final descriptor in descriptors.whereType<Map>()) {
    final fields = descriptor['fields'];
    switch (descriptor['descriptorType']) {
      case 0x01:
      case 0x07:
        configuration = null;
      case 0x02:
        configuration = fields is Map
            ? _byte(fields['bConfigurationValue'])
            : null;
      case 0x0B:
        if (configuration == null || configuration == 0 || fields is! Map) {
          continue;
        }
        final first = _byte(fields['bFirstInterface']);
        final count = _byte(fields['bInterfaceCount']);
        final functionClass = _byte(fields['bFunctionClass']);
        final subclass = _byte(fields['bFunctionSubClass']);
        final protocol = _byte(fields['bFunctionProtocol']);
        final stringIndex = _byte(fields['iFunction']);
        final functionName = fields['functionName'];
        if (first == null ||
            count == null ||
            count == 0 ||
            first + count > 256 ||
            functionClass == null ||
            subclass == null ||
            protocol == null ||
            stringIndex == null) {
          continue;
        }
        associations.add((
          configuration: configuration,
          firstInterface: first,
          interfaceCount: count,
          functionClass: functionClass,
          functionSubclass: subclass,
          functionProtocol: protocol,
          stringIndex: stringIndex,
          name:
              stringIndex != 0 &&
                  functionName is String &&
                  functionName.trim().isNotEmpty
              ? functionName.trim()
              : null,
        ));
    }
  }
  return associations;
}

int? _byte(Object? value) =>
    value is int && value >= 0 && value <= 255 ? value : null;
