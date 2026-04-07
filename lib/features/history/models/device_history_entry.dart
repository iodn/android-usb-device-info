import 'package:meta/meta.dart';

@immutable
class DeviceHistoryEntry {
  const DeviceHistoryEntry({
    required this.id,
    required this.testedAt,
    required this.deviceName,
    required this.vendorId,
    required this.productId,
    required this.deviceClass,
    required this.deviceSubclass,
    required this.deviceProtocol,
    required this.interfaceCount,
    required this.configurationCount,
    required this.hasPermission,
    required this.isInputDevice,
    this.isHiddenDevice = false,
    this.inputSources,
    this.stableIdentityKey,
    this.identityConfidence,
    this.identityStrategy,
    this.physicalLocationKey,
    this.interfaceFingerprint,
    this.continuityKeys,
    this.knownDevicePaths,
    this.previousSnapshot,
    this.vendorName,
    this.productNameResolved,
    this.manufacturerNameRaw,
    this.productNameRaw,
    this.serialNumber,
    this.usbVersion,
    this.speed,
    this.deviceId,
    this.portNumber,
    this.maxPowerMa,
    this.deviceDescriptor,
    this.configurations,
    this.interfaces,
    this.input,
    this.deviceState,
    this.strings,
    this.descriptorTree,
    this.hidReports,
  });

  final String id;
  final DateTime testedAt;

  final String deviceName;

  final int vendorId;
  final int productId;

  final int deviceClass;
  final int deviceSubclass;
  final int deviceProtocol;

  final int interfaceCount;
  final int configurationCount;

  final bool hasPermission;

  final bool isInputDevice;
  final bool isHiddenDevice;
  final List<String>? inputSources;
  final String? stableIdentityKey;
  final String? identityConfidence;
  final String? identityStrategy;
  final String? physicalLocationKey;
  final String? interfaceFingerprint;
  final List<String>? continuityKeys;
  final List<String>? knownDevicePaths;
  final Map<String, Object?>? previousSnapshot;

  final String? vendorName;
  final String? productNameResolved;

  final String? manufacturerNameRaw;
  final String? productNameRaw;
  final String? serialNumber;

  final String? usbVersion;
  final String? speed;

  final int? deviceId;
  final int? portNumber;

  // Advanced/Raw snapshot data captured at record time
  final int? maxPowerMa;
  final Map<String, Object?>? deviceDescriptor;
  final List<Object?>? configurations;
  final List<Object?>? interfaces;
  final Map<String, Object?>? input;
  final Map<String, Object?>? deviceState;
  final Map<String, Object?>? strings;
  final List<Object?>? descriptorTree;
  final List<Object?>? hidReports;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'testedAt': testedAt.toIso8601String(),
        'deviceName': deviceName,
        'vendorId': vendorId,
        'productId': productId,
        'deviceClass': deviceClass,
        'deviceSubclass': deviceSubclass,
        'deviceProtocol': deviceProtocol,
        'interfaceCount': interfaceCount,
        'configurationCount': configurationCount,
        'hasPermission': hasPermission,
        'isInputDevice': isInputDevice,
        'isHiddenDevice': isHiddenDevice,
        'inputSources': inputSources,
        'stableIdentityKey': stableIdentityKey,
        'identityConfidence': identityConfidence,
        'identityStrategy': identityStrategy,
        'physicalLocationKey': physicalLocationKey,
        'interfaceFingerprint': interfaceFingerprint,
        'continuityKeys': continuityKeys,
        'knownDevicePaths': knownDevicePaths,
        'previousSnapshot': previousSnapshot,
        'vendorName': vendorName,
        'productNameResolved': productNameResolved,
        'manufacturerNameRaw': manufacturerNameRaw,
        'productNameRaw': productNameRaw,
        'serialNumber': serialNumber,
        'usbVersion': usbVersion,
        'speed': speed,
        'deviceId': deviceId,
        'portNumber': portNumber,
        'maxPowerMa': maxPowerMa,
        'deviceDescriptor': deviceDescriptor,
        'configurations': configurations,
        'interfaces': interfaces,
        'input': input,
        'deviceState': deviceState,
        'strings': strings,
        'descriptorTree': descriptorTree,
        'hidReports': hidReports,
      };

  factory DeviceHistoryEntry.fromMap(Map<Object?, Object?> map) {
    final rawSources = map['inputSources'];
    final rawContinuityKeys = map['continuityKeys'];
    final rawKnownPaths = map['knownDevicePaths'];
    return DeviceHistoryEntry(
      id: (map['id'] as String?) ?? '',
      testedAt: DateTime.tryParse((map['testedAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      deviceName: (map['deviceName'] as String?) ?? '',
      vendorId: (map['vendorId'] as int?) ?? 0,
      productId: (map['productId'] as int?) ?? 0,
      deviceClass: (map['deviceClass'] as int?) ?? 0,
      deviceSubclass: (map['deviceSubclass'] as int?) ?? 0,
      deviceProtocol: (map['deviceProtocol'] as int?) ?? 0,
      interfaceCount: (map['interfaceCount'] as int?) ?? 0,
      configurationCount: (map['configurationCount'] as int?) ?? 0,
      hasPermission: (map['hasPermission'] as bool?) ?? false,
      isInputDevice: (map['isInputDevice'] as bool?) ?? false,
      isHiddenDevice: (map['isHiddenDevice'] as bool?) ?? false,
      inputSources: rawSources is List
          ? rawSources.whereType<String>().toList(growable: false)
          : null,
      stableIdentityKey: map['stableIdentityKey'] as String?,
      identityConfidence: map['identityConfidence'] as String?,
      identityStrategy: map['identityStrategy'] as String?,
      physicalLocationKey: map['physicalLocationKey'] as String?,
      interfaceFingerprint: map['interfaceFingerprint'] as String?,
      continuityKeys: rawContinuityKeys is List
          ? rawContinuityKeys.whereType<String>().toList(growable: false)
          : null,
      knownDevicePaths: rawKnownPaths is List
          ? rawKnownPaths.whereType<String>().toList(growable: false)
          : null,
      previousSnapshot: (map['previousSnapshot'] is Map)
          ? (map['previousSnapshot'] as Map).cast<String, Object?>()
          : null,
      vendorName: map['vendorName'] as String?,
      productNameResolved: map['productNameResolved'] as String?,
      manufacturerNameRaw: map['manufacturerNameRaw'] as String?,
      productNameRaw: map['productNameRaw'] as String?,
      serialNumber: map['serialNumber'] as String?,
      usbVersion: map['usbVersion'] as String?,
      speed: map['speed'] as String?,
      deviceId: map['deviceId'] as int?,
      portNumber: map['portNumber'] as int?,
      maxPowerMa: map['maxPowerMa'] as int?,
      deviceDescriptor: (map['deviceDescriptor'] is Map)
          ? (map['deviceDescriptor'] as Map).cast<String, Object?>()
          : null,
      configurations: (map['configurations'] is List) ? (map['configurations'] as List).cast<Object?>() : null,
      interfaces: (map['interfaces'] is List) ? (map['interfaces'] as List).cast<Object?>() : null,
      input: (map['input'] is Map) ? (map['input'] as Map).cast<String, Object?>() : null,
      deviceState: (map['deviceState'] is Map) ? (map['deviceState'] as Map).cast<String, Object?>() : null,
      strings: (map['strings'] is Map) ? (map['strings'] as Map).cast<String, Object?>() : null,
      descriptorTree: (map['descriptorTree'] is List) ? (map['descriptorTree'] as List).cast<Object?>() : null,
      hidReports: (map['hidReports'] is List) ? (map['hidReports'] as List).cast<Object?>() : null,
    );
  }

  DeviceHistoryEntry copyWith({
    DateTime? testedAt,
    List<String>? inputSources,
    List<String>? continuityKeys,
    List<String>? knownDevicePaths,
    Map<String, Object?>? previousSnapshot,
    String? vendorName,
    String? productNameResolved,
    Map<String, Object?>? deviceDescriptor,
    List<Object?>? configurations,
    List<Object?>? interfaces,
    Map<String, Object?>? input,
    Map<String, Object?>? deviceState,
    Map<String, Object?>? strings,
    List<Object?>? descriptorTree,
    List<Object?>? hidReports,
    int? maxPowerMa,
  }) {
    return DeviceHistoryEntry(
      id: id,
      testedAt: testedAt ?? this.testedAt,
      deviceName: deviceName,
      vendorId: vendorId,
      productId: productId,
      deviceClass: deviceClass,
      deviceSubclass: deviceSubclass,
      deviceProtocol: deviceProtocol,
      interfaceCount: interfaceCount,
      configurationCount: configurationCount,
      hasPermission: hasPermission,
      isInputDevice: isInputDevice,
      isHiddenDevice: isHiddenDevice,
      inputSources: inputSources ?? this.inputSources,
      stableIdentityKey: stableIdentityKey,
      identityConfidence: identityConfidence,
      identityStrategy: identityStrategy,
      physicalLocationKey: physicalLocationKey,
      interfaceFingerprint: interfaceFingerprint,
      continuityKeys: continuityKeys ?? this.continuityKeys,
      knownDevicePaths: knownDevicePaths ?? this.knownDevicePaths,
      previousSnapshot: previousSnapshot ?? this.previousSnapshot,
      vendorName: vendorName ?? this.vendorName,
      productNameResolved: productNameResolved ?? this.productNameResolved,
      manufacturerNameRaw: manufacturerNameRaw,
      productNameRaw: productNameRaw,
      serialNumber: serialNumber,
      usbVersion: usbVersion,
      speed: speed,
      deviceId: deviceId,
      portNumber: portNumber,
      maxPowerMa: maxPowerMa ?? this.maxPowerMa,
      deviceDescriptor: deviceDescriptor ?? this.deviceDescriptor,
      configurations: configurations ?? this.configurations,
      interfaces: interfaces ?? this.interfaces,
      input: input ?? this.input,
      deviceState: deviceState ?? this.deviceState,
      strings: strings ?? this.strings,
      descriptorTree: descriptorTree ?? this.descriptorTree,
      hidReports: hidReports ?? this.hidReports,
    );
  }
}
