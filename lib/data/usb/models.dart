class UsbDeviceSummary {
  UsbDeviceSummary({
    required this.deviceName,
    required this.vendorId,
    required this.productId,
    required this.deviceClass,
    required this.deviceSubclass,
    required this.deviceProtocol,
    required this.interfaceCount,
    required this.configurationCount,
    required this.hasPermission,
    this.manufacturerName,
    this.productName,
    this.serialNumber,
    this.usbVersion,
    this.speed,
    this.maxPowerMa,
    this.deviceId,
    this.portNumber,
    this.isInputDevice = false,
    this.inputSources,
  });

  final String deviceName;
  final int vendorId;
  final int productId;
  final int deviceClass;
  final int deviceSubclass;
  final int deviceProtocol;
  final int interfaceCount;
  final int configurationCount;
  final bool hasPermission;

  final String? manufacturerName;
  final String? productName;
  final String? serialNumber;
  final String? usbVersion;
  final String? speed;
  final int? maxPowerMa;

  final int? deviceId;
  final int? portNumber;
  final bool isInputDevice;
  final List<String>? inputSources;

  factory UsbDeviceSummary.fromMap(Map<Object?, Object?> map) {
    final rawSources = map['inputSources'];
    return UsbDeviceSummary(
      deviceName: (map['deviceName'] as String?) ?? '',
      vendorId: (map['vendorId'] as int?) ?? 0,
      productId: (map['productId'] as int?) ?? 0,
      deviceClass: (map['deviceClass'] as int?) ?? 0,
      deviceSubclass: (map['deviceSubclass'] as int?) ?? 0,
      deviceProtocol: (map['deviceProtocol'] as int?) ?? 0,
      interfaceCount: (map['interfaceCount'] as int?) ?? 0,
      configurationCount: (map['configurationCount'] as int?) ?? 0,
      hasPermission: (map['hasPermission'] as bool?) ?? false,
      manufacturerName: map['manufacturerName'] as String?,
      productName: map['productName'] as String?,
      serialNumber: map['serialNumber'] as String?,
      usbVersion: map['usbVersion'] as String?,
      speed: map['speed'] as String?,
      maxPowerMa: map['maxPowerMa'] as int?,
      deviceId: map['deviceId'] as int?,
      portNumber: map['portNumber'] as int?,
      isInputDevice: (map['isInputDevice'] as bool?) ?? false,
      inputSources: rawSources is List
          ? rawSources.whereType<String>().toList(growable: false)
          : null,
    );
  }
}

class UsbEndpointInfo {
  UsbEndpointInfo({
    required this.address,
    required this.direction,
    required this.type,
    required this.maxPacketSize,
    required this.interval,
    required this.attributes,
    required this.number,
  });

  final int address;
  final String direction;
  final String type;
  final int maxPacketSize;
  final int interval;
  final int attributes;
  final int number;

  factory UsbEndpointInfo.fromMap(Map<Object?, Object?> map) {
    return UsbEndpointInfo(
      address: (map['address'] as int?) ?? 0,
      direction: (map['direction'] as String?) ?? 'Unknown',
      type: (map['type'] as String?) ?? 'Unknown',
      maxPacketSize: (map['maxPacketSize'] as int?) ?? 0,
      interval: (map['interval'] as int?) ?? 0,
      attributes: (map['attributes'] as int?) ?? 0,
      number: (map['number'] as int?) ?? 0,
    );
  }
}

class UsbInterfaceInfo {
  UsbInterfaceInfo({
    required this.id,
    required this.interfaceClass,
    required this.interfaceSubclass,
    required this.interfaceProtocol,
    required this.endpointCount,
    required this.endpoints,
    this.alternateSetting = 0,
    this.name,
  });

  final int id;
  final int interfaceClass;
  final int interfaceSubclass;
  final int interfaceProtocol;
  final int endpointCount;
  final List<UsbEndpointInfo> endpoints;

  final int alternateSetting;
  final String? name;

  factory UsbInterfaceInfo.fromMap(Map<Object?, Object?> map) {
    final eps = (map['endpoints'] as List<Object?>? ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(UsbEndpointInfo.fromMap)
        .toList();

    return UsbInterfaceInfo(
      id: (map['id'] as int?) ?? 0,
      interfaceClass: (map['interfaceClass'] as int?) ?? 0,
      interfaceSubclass: (map['interfaceSubclass'] as int?) ?? 0,
      interfaceProtocol: (map['interfaceProtocol'] as int?) ?? 0,
      endpointCount: (map['endpointCount'] as int?) ?? eps.length,
      endpoints: eps,
      alternateSetting: (map['alternateSetting'] as int?) ?? 0,
      name: map['name'] as String?,
    );
  }
}

class UsbConfigurationInfo {
  UsbConfigurationInfo({
    required this.id,
    this.name,
    required this.attributes,
    this.maxPowerMa,
    required this.interfaceCount,
    required this.interfaces,
  });

  final int id;
  final String? name;
  final int attributes;
  final int? maxPowerMa;
  final int interfaceCount;
  final List<UsbInterfaceInfo> interfaces;

  factory UsbConfigurationInfo.fromMap(Map<Object?, Object?> map) {
    final ifaces = (map['interfaces'] as List<Object?>? ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(UsbInterfaceInfo.fromMap)
        .toList();

    return UsbConfigurationInfo(
      id: (map['id'] as int?) ?? 0,
      name: map['name'] as String?,
      attributes: (map['attributes'] as int?) ?? 0,
      maxPowerMa: map['maxPowerMa'] as int?,
      interfaceCount: (map['interfaceCount'] as int?) ?? ifaces.length,
      interfaces: ifaces,
    );
  }
}

class UsbDeviceDescriptorInfo {
  UsbDeviceDescriptorInfo({
    this.bcdUsb,
    this.usbVersion,
    this.bcdDevice,
    this.deviceRelease,
    this.maxPacketSize0,
    this.numConfigurations,
    this.iManufacturer,
    this.iProduct,
    this.iSerialNumber,
  });

  final int? bcdUsb;
  final String? usbVersion;
  final int? bcdDevice;
  final String? deviceRelease;
  final int? maxPacketSize0;
  final int? numConfigurations;
  final int? iManufacturer;
  final int? iProduct;
  final int? iSerialNumber;

  factory UsbDeviceDescriptorInfo.fromMap(Map<Object?, Object?> map) {
    return UsbDeviceDescriptorInfo(
      bcdUsb: map['bcdUsb'] as int?,
      usbVersion: map['usbVersion'] as String?,
      bcdDevice: map['bcdDevice'] as int?,
      deviceRelease: map['deviceRelease'] as String?,
      maxPacketSize0: map['maxPacketSize0'] as int?,
      numConfigurations: map['numConfigurations'] as int?,
      iManufacturer: map['iManufacturer'] as int?,
      iProduct: map['iProduct'] as int?,
      iSerialNumber: map['iSerialNumber'] as int?,
    );
  }
}

class InputMotionRangeInfo {
  InputMotionRangeInfo({
    required this.axis,
    required this.min,
    required this.max,
    required this.flat,
    required this.fuzz,
    required this.resolution,
  });

  final int axis;
  final double min;
  final double max;
  final double flat;
  final double fuzz;
  final double resolution;

  factory InputMotionRangeInfo.fromMap(Map<Object?, Object?> map) {
    double asD(Object? v) => (v is num) ? v.toDouble() : 0.0;
    return InputMotionRangeInfo(
      axis: (map['axis'] as int?) ?? 0,
      min: asD(map['min']),
      max: asD(map['max']),
      flat: asD(map['flat']),
      fuzz: asD(map['fuzz']),
      resolution: asD(map['resolution']),
    );
  }
}

class InputDeviceInfo {
  InputDeviceInfo({
    required this.id,
    required this.name,
    required this.descriptor,
    required this.isExternal,
    required this.vendorId,
    required this.productId,
    required this.sources,
    required this.keyboardType,
    required this.motionRanges,
  });

  final int id;
  final String? name;
  final String? descriptor;
  final bool isExternal;
  final int vendorId;
  final int productId;
  final List<String> sources;
  final int keyboardType;
  final List<InputMotionRangeInfo> motionRanges;

  factory InputDeviceInfo.fromMap(Map<Object?, Object?> map) {
    final rawSources = map['sources'];
    final rawRanges = map['motionRanges'];
    return InputDeviceInfo(
      id: (map['id'] as int?) ?? 0,
      name: map['name'] as String?,
      descriptor: map['descriptor'] as String?,
      isExternal: (map['isExternal'] as bool?) ?? false,
      vendorId: (map['vendorId'] as int?) ?? 0,
      productId: (map['productId'] as int?) ?? 0,
      sources: rawSources is List ? rawSources.whereType<String>().toList() : const [],
      keyboardType: (map['keyboardType'] as int?) ?? 0,
      motionRanges: rawRanges is List
          ? rawRanges
              .whereType<Map<Object?, Object?>>()
              .map(InputMotionRangeInfo.fromMap)
              .toList()
          : const [],
    );
  }
}

class UsbDeviceDetails {
  UsbDeviceDetails({
    required this.summary,
    required this.interfaces,
    this.configurations = const [],
    this.deviceDescriptor,
    this.input,
  });

  final UsbDeviceSummary summary;
  final List<UsbInterfaceInfo> interfaces;

  final List<UsbConfigurationInfo> configurations;
  final UsbDeviceDescriptorInfo? deviceDescriptor;

  final InputDeviceInfo? input;

  factory UsbDeviceDetails.fromMap(Map<Object?, Object?> map) {
    final summary = UsbDeviceSummary.fromMap(
      (map['summary'] as Map<Object?, Object?>?) ?? const {},
    );

    final ifaces = (map['interfaces'] as List<Object?>? ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(UsbInterfaceInfo.fromMap)
        .toList();

    final cfgs = (map['configurations'] as List<Object?>? ?? const [])
        .whereType<Map<Object?, Object?>>()
        .map(UsbConfigurationInfo.fromMap)
        .toList();

    final ddRaw = map['deviceDescriptor'];
    final dd = (ddRaw is Map<Object?, Object?>) ? UsbDeviceDescriptorInfo.fromMap(ddRaw) : null;

    final inRaw = map['input'];
    final input = (inRaw is Map<Object?, Object?>) ? InputDeviceInfo.fromMap(inRaw) : null;

    return UsbDeviceDetails(
      summary: summary,
      interfaces: ifaces,
      configurations: cfgs,
      deviceDescriptor: dd,
      input: input,
    );
  }
}

class UsbEvent {
  UsbEvent({required this.type, this.deviceName});

  final String type;
  final String? deviceName;

  factory UsbEvent.fromMap(Map<Object?, Object?> map) {
    return UsbEvent(
      type: (map['type'] as String?) ?? 'unknown',
      deviceName: map['deviceName'] as String?,
    );
  }
}
