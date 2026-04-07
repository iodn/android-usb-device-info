import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_mode_controller.dart';
import '../../../data/usb/models.dart';
import '../../../data/usb/usb_repository.dart';
import '../models/device_history_entry.dart';

const _kHistoryKey = 'device_history_v1';
const _kHistoryMaxItems = 50;

final deviceHistoryControllerProvider =
    AsyncNotifierProvider<DeviceHistoryController, List<DeviceHistoryEntry>>(
        DeviceHistoryController.new);

class DeviceHistoryController extends AsyncNotifier<List<DeviceHistoryEntry>> {
  @override
  Future<List<DeviceHistoryEntry>> build() async {
    return _loadFromPrefs();
  }

  Future<List<DeviceHistoryEntry>> _loadFromPrefs() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final raw = prefs.getString(_kHistoryKey);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((m) => DeviceHistoryEntry.fromMap(m.cast<Object?, Object?>()))
          .where((e) => e.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveToPrefs(List<DeviceHistoryEntry> items) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final encoded = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_kHistoryKey, encoded);
  }

  Future<void> _upsert(DeviceHistoryEntry entry) async {
    final current = state.asData?.value ?? await _loadFromPrefs();
    final existing = _findRelatedEntry(current, entry);
    final mergedPaths = <String>[
      entry.deviceName,
      ...(entry.knownDevicePaths ?? const <String>[]),
      ...(existing?.knownDevicePaths ?? const <String>[]),
      if ((existing?.deviceName ?? '').trim().isNotEmpty) existing!.deviceName,
    ].where((p) => p.trim().isNotEmpty).toSet().toList(growable: false);
    final mergedContinuityKeys = <String>[
      if ((entry.stableIdentityKey ?? '').trim().isNotEmpty) entry.stableIdentityKey!,
      ...(entry.continuityKeys ?? const <String>[]),
      if (((existing?.stableIdentityKey) ?? '').trim().isNotEmpty) existing!.stableIdentityKey!,
      ...(existing?.continuityKeys ?? const <String>[]),
    ].where((k) => k.trim().isNotEmpty).toSet().toList(growable: false);
    final mergedEntry = _mergeEntries(
      latest: entry,
      previous: existing,
      knownDevicePaths: mergedPaths,
      continuityKeys: mergedContinuityKeys,
    );
    final next = <DeviceHistoryEntry>[
      mergedEntry,
      ...current.where((e) => e.id != mergedEntry.id && e.id != existing?.id),
    ];
    final capped = next.length <= _kHistoryMaxItems
        ? next
        : next.take(_kHistoryMaxItems).toList();
    state = AsyncValue.data(capped);
    await _saveToPrefs(capped);
  }

  Future<void> recordFromListItem(UsbDeviceListItem item) async {
    final s = item.device;
    final now = DateTime.now();

    final entry = DeviceHistoryEntry(
      id: _makeStableIdFromSummary(s),
      testedAt: now,
      deviceName: s.deviceName,
      vendorId: s.vendorId,
      productId: s.productId,
      deviceClass: s.deviceClass,
      deviceSubclass: s.deviceSubclass,
      deviceProtocol: s.deviceProtocol,
      interfaceCount: s.interfaceCount,
      configurationCount: s.configurationCount,
      hasPermission: s.hasPermission,
      isInputDevice: s.isInputDevice,
      isHiddenDevice: s.isHiddenDevice,
      inputSources: s.inputSources,
      stableIdentityKey: s.stableIdentityKey,
      identityConfidence: s.identityConfidence,
      identityStrategy: s.identityStrategy,
      physicalLocationKey: s.physicalLocationKey,
      interfaceFingerprint: s.interfaceFingerprint,
      continuityKeys: s.continuityKeys,
      knownDevicePaths: [s.deviceName],
      vendorName: item.vendorName,
      productNameResolved: item.productName,
      manufacturerNameRaw: s.manufacturerName,
      productNameRaw: s.productName,
      serialNumber: s.serialNumber,
      usbVersion: s.usbVersion,
      speed: s.speed,
      deviceId: s.deviceId,
      portNumber: s.portNumber,
    );

    await _upsert(entry);
  }

  Future<void> recordFromView(UsbDeviceDetailViewData view, {Map<String, dynamic>? raw}) async {
    final s = view.details.summary;
    final now = DateTime.now();

    final entry = DeviceHistoryEntry(
      id: _makeStableIdFromSummary(s),
      testedAt: now,
      deviceName: s.deviceName,
      vendorId: s.vendorId,
      productId: s.productId,
      deviceClass: s.deviceClass,
      deviceSubclass: s.deviceSubclass,
      deviceProtocol: s.deviceProtocol,
      interfaceCount: s.interfaceCount,
      configurationCount: s.configurationCount,
      hasPermission: s.hasPermission,
      isInputDevice: s.isInputDevice,
      isHiddenDevice: s.isHiddenDevice,
      inputSources: s.inputSources,
      stableIdentityKey: s.stableIdentityKey,
      identityConfidence: s.identityConfidence,
      identityStrategy: s.identityStrategy,
      physicalLocationKey: s.physicalLocationKey,
      interfaceFingerprint: s.interfaceFingerprint,
      continuityKeys: s.continuityKeys,
      knownDevicePaths: [s.deviceName],
      vendorName: view.vendorName,
      productNameResolved: view.productName,
      manufacturerNameRaw: s.manufacturerName,
      productNameRaw: s.productName,
      serialNumber: s.serialNumber,
      usbVersion: s.usbVersion,
      speed: s.speed,
      deviceId: s.deviceId,
      portNumber: s.portNumber,
      // Prefer raw snapshot data when provided; otherwise derive from enriched view where possible
      maxPowerMa: raw?['summary']?['maxPowerMa'] as int? ?? s.maxPowerMa,
      deviceDescriptor: (raw?['deviceDescriptor'] is Map)
          ? (raw!['deviceDescriptor'] as Map).cast<String, Object?>()
          : (view.details.deviceDescriptor == null
              ? null
              : {
                  'usbVersion': view.details.deviceDescriptor!.usbVersion,
                  'deviceRelease': view.details.deviceDescriptor!.deviceRelease,
                  'maxPacketSize0': view.details.deviceDescriptor!.maxPacketSize0,
                  'numConfigurations': view.details.deviceDescriptor!.numConfigurations,
                  'iManufacturer': view.details.deviceDescriptor!.iManufacturer,
                  'iProduct': view.details.deviceDescriptor!.iProduct,
                  'iSerialNumber': view.details.deviceDescriptor!.iSerialNumber,
                }),
      configurations: (raw?['configurations'] is List)
          ? (raw!['configurations'] as List).cast<Object?>()
          : view.details.configurations
              .map((c) => {
                    'id': c.id,
                    'name': c.name,
                    'attributes': c.attributes,
                    'maxPowerMa': c.maxPowerMa,
                    'interfaceCount': c.interfaceCount,
                    'interfaces': c.interfaces
                        .map((i) => {
                              'id': i.id,
                              'alternateSetting': i.alternateSetting,
                              'name': i.name,
                              'interfaceClass': i.interfaceClass,
                              'interfaceSubclass': i.interfaceSubclass,
                              'interfaceProtocol': i.interfaceProtocol,
                              'endpointCount': i.endpointCount,
                              'endpoints': i.endpoints
                                  .map((e) => {
                                        'address': e.address,
                                        'direction': e.direction,
                                        'type': e.type,
                                        'maxPacketSize': e.maxPacketSize,
                                        'interval': e.interval,
                                        'attributes': e.attributes,
                                        'number': e.number,
                                      })
                                  .toList(),
                            })
                        .toList(),
                  })
              .toList(),
      interfaces: (raw?['interfaces'] is List)
          ? (raw!['interfaces'] as List).cast<Object?>()
          : view.details.interfaces
              .map((i) => {
                    'id': i.id,
                    'alternateSetting': i.alternateSetting,
                    'name': i.name,
                    'interfaceClass': i.interfaceClass,
                    'interfaceSubclass': i.interfaceSubclass,
                    'interfaceProtocol': i.interfaceProtocol,
                    'endpointCount': i.endpointCount,
                    'endpoints': i.endpoints
                        .map((e) => {
                              'address': e.address,
                              'direction': e.direction,
                              'type': e.type,
                              'maxPacketSize': e.maxPacketSize,
                              'interval': e.interval,
                              'attributes': e.attributes,
                              'number': e.number,
                            })
                        .toList(),
                  })
              .toList(),
      input: (raw?['input'] is Map)
          ? (raw!['input'] as Map).cast<String, Object?>()
          : (view.details.input == null
              ? null
              : {
                  'id': view.details.input!.id,
                  'name': view.details.input!.name,
                  'descriptor': view.details.input!.descriptor,
                  'isExternal': view.details.input!.isExternal,
                  'vendorId': view.details.input!.vendorId,
                  'productId': view.details.input!.productId,
                  'sources': view.details.input!.sources,
                  'keyboardType': view.details.input!.keyboardType,
                  'motionRanges': view.details.input!.motionRanges
                      .map((r) => {
                            'axis': r.axis,
                            'min': r.min,
                            'max': r.max,
                            'flat': r.flat,
                            'fuzz': r.fuzz,
                            'resolution': r.resolution,
                          })
                      .toList(),
                }),
      deviceState: (raw?['deviceState'] is Map) ? (raw!['deviceState'] as Map).cast<String, Object?>() : null,
      strings: (raw?['strings'] is Map) ? (raw!['strings'] as Map).cast<String, Object?>() : null,
      descriptorTree: (raw?['descriptorTree'] is List) ? (raw!['descriptorTree'] as List).cast<Object?>() : null,
      hidReports: (raw?['hidReports'] is List) ? (raw!['hidReports'] as List).cast<Object?>() : null,
    );

    await _upsert(entry);
  }

  Future<DeviceHistoryEntry?> removeById(String id) async {
    final current = state.asData?.value ?? await _loadFromPrefs();
    final idx = current.indexWhere((e) => e.id == id);
    if (idx == -1) return null;
    final removed = current[idx];
    final next = [...current]..removeAt(idx);
    state = AsyncValue.data(next);
    await _saveToPrefs(next);
    return removed;
  }

  Future<void> restore(DeviceHistoryEntry entry, {int? index}) async {
    final current = state.asData?.value ?? await _loadFromPrefs();
    final without = current.where((e) => e.id != entry.id).toList(growable: true);
    final i = (index == null) ? 0 : index.clamp(0, without.length);
    without.insert(i, entry);
    final capped = without.length <= _kHistoryMaxItems
        ? without
        : without.take(_kHistoryMaxItems).toList();
    state = AsyncValue.data(capped);
    await _saveToPrefs(capped);
  }

  Future<void> clearAll() async {
    state = const AsyncValue.data([]);
    await _saveToPrefs(const []);
  }

  Future<void> replaceAll(List<DeviceHistoryEntry> items) async {
    final capped = items.length <= _kHistoryMaxItems ? items : items.take(_kHistoryMaxItems).toList();
    state = AsyncValue.data(capped);
    await _saveToPrefs(capped);
  }

  String _makeStableIdFromSummary(UsbDeviceSummary s) {
    final stableIdentityKey = (s.stableIdentityKey ?? '').trim();
    if (stableIdentityKey.isNotEmpty) {
      return stableIdentityKey;
    }
    final serial = (s.serialNumber ?? '').trim();
    if (serial.isNotEmpty) {
      return 'vid:${s.vendorId}|pid:${s.productId}|sn:$serial';
    }
    final did = s.deviceId;
    if (did != null && did != 0) {
      return 'vid:${s.vendorId}|pid:${s.productId}|devId:$did|input:${s.isInputDevice}';
    }
    final dn = s.deviceName.trim();
    if (dn.isNotEmpty) {
      return 'path:$dn';
    }
    return 'vid:${s.vendorId}|pid:${s.productId}|cls:${s.deviceClass}|sub:${s.deviceSubclass}|pr:${s.deviceProtocol}|input:${s.isInputDevice}';
  }

  DeviceHistoryEntry? _findRelatedEntry(
    List<DeviceHistoryEntry> current,
    DeviceHistoryEntry entry,
  ) {
    for (final candidate in current) {
      if (candidate.id == entry.id) return candidate;
    }

    final entryStable = _normalized(entry.stableIdentityKey);
    if (entryStable != null) {
      for (final candidate in current) {
        if (_normalized(candidate.stableIdentityKey) == entryStable) return candidate;
      }
    }

    final entryContinuity = _normalizedSet(entry.continuityKeys);
    if (entryStable != null) entryContinuity.add(entryStable);
    for (final candidate in current) {
      final candidateContinuity = _normalizedSet(candidate.continuityKeys);
      final candidateStable = _normalized(candidate.stableIdentityKey);
      if (candidateStable != null) candidateContinuity.add(candidateStable);
      if (entryContinuity.isNotEmpty && entryContinuity.intersection(candidateContinuity).isNotEmpty) {
        return candidate;
      }
    }

    return null;
  }

  DeviceHistoryEntry _mergeEntries({
    required DeviceHistoryEntry latest,
    required DeviceHistoryEntry? previous,
    required List<String> knownDevicePaths,
    required List<String> continuityKeys,
  }) {
    final mergedStableIdentityKey = _preferredStableIdentity(
      latest.stableIdentityKey,
      latest.identityConfidence,
      previous?.stableIdentityKey,
      previous?.identityConfidence,
    );
    final mergedId = (mergedStableIdentityKey ?? '').trim().isNotEmpty
        ? mergedStableIdentityKey!.trim()
        : (previous?.id ?? latest.id);
    return DeviceHistoryEntry(
      id: mergedId,
      testedAt: latest.testedAt,
      deviceName: latest.deviceName,
      vendorId: latest.vendorId,
      productId: latest.productId,
      deviceClass: latest.deviceClass,
      deviceSubclass: latest.deviceSubclass,
      deviceProtocol: latest.deviceProtocol,
      interfaceCount: latest.interfaceCount,
      configurationCount: latest.configurationCount,
      hasPermission: latest.hasPermission,
      isInputDevice: latest.isInputDevice,
      isHiddenDevice: latest.isHiddenDevice,
      inputSources: latest.inputSources ?? previous?.inputSources,
      stableIdentityKey: mergedStableIdentityKey ?? previous?.stableIdentityKey,
      identityConfidence: _preferredIdentityConfidence(
        latest.stableIdentityKey,
        latest.identityConfidence,
        previous?.stableIdentityKey,
        previous?.identityConfidence,
      ),
      identityStrategy: _preferredIdentityStrategy(
        latest.stableIdentityKey,
        latest.identityConfidence,
        latest.identityStrategy,
        previous?.stableIdentityKey,
        previous?.identityConfidence,
        previous?.identityStrategy,
      ),
      physicalLocationKey: _preferNonBlank(latest.physicalLocationKey, previous?.physicalLocationKey),
      interfaceFingerprint: _preferNonBlank(latest.interfaceFingerprint, previous?.interfaceFingerprint),
      continuityKeys: continuityKeys,
      knownDevicePaths: knownDevicePaths,
      previousSnapshot: previous == null ? latest.previousSnapshot : _buildReconnectSnapshot(previous),
      vendorName: _preferNonBlank(latest.vendorName, previous?.vendorName),
      productNameResolved: _preferNonBlank(latest.productNameResolved, previous?.productNameResolved),
      manufacturerNameRaw: _preferNonBlank(latest.manufacturerNameRaw, previous?.manufacturerNameRaw),
      productNameRaw: _preferNonBlank(latest.productNameRaw, previous?.productNameRaw),
      serialNumber: _preferNonBlank(latest.serialNumber, previous?.serialNumber),
      usbVersion: _preferNonBlank(latest.usbVersion, previous?.usbVersion),
      speed: _preferNonBlank(latest.speed, previous?.speed),
      deviceId: latest.deviceId ?? previous?.deviceId,
      portNumber: latest.portNumber ?? previous?.portNumber,
      maxPowerMa: latest.maxPowerMa ?? previous?.maxPowerMa,
      deviceDescriptor: latest.deviceDescriptor ?? previous?.deviceDescriptor,
      configurations: latest.configurations ?? previous?.configurations,
      interfaces: latest.interfaces ?? previous?.interfaces,
      input: latest.input ?? previous?.input,
      deviceState: latest.deviceState ?? previous?.deviceState,
      strings: latest.strings ?? previous?.strings,
      descriptorTree: latest.descriptorTree ?? previous?.descriptorTree,
      hidReports: latest.hidReports ?? previous?.hidReports,
    );
  }

  Map<String, Object?> _buildReconnectSnapshot(DeviceHistoryEntry entry) {
    return <String, Object?>{
      'testedAt': entry.testedAt.toIso8601String(),
      'deviceName': entry.deviceName,
      'vendorId': entry.vendorId,
      'productId': entry.productId,
      'deviceClass': entry.deviceClass,
      'deviceSubclass': entry.deviceSubclass,
      'deviceProtocol': entry.deviceProtocol,
      'interfaceCount': entry.interfaceCount,
      'configurationCount': entry.configurationCount,
      'hasPermission': entry.hasPermission,
      'isInputDevice': entry.isInputDevice,
      'isHiddenDevice': entry.isHiddenDevice,
      'inputSources': entry.inputSources,
      'stableIdentityKey': entry.stableIdentityKey,
      'identityConfidence': entry.identityConfidence,
      'identityStrategy': entry.identityStrategy,
      'physicalLocationKey': entry.physicalLocationKey,
      'interfaceFingerprint': entry.interfaceFingerprint,
      'vendorName': entry.vendorName,
      'productNameResolved': entry.productNameResolved,
      'manufacturerNameRaw': entry.manufacturerNameRaw,
      'productNameRaw': entry.productNameRaw,
      'serialNumber': entry.serialNumber,
      'usbVersion': entry.usbVersion,
      'speed': entry.speed,
      'deviceId': entry.deviceId,
      'portNumber': entry.portNumber,
      'maxPowerMa': entry.maxPowerMa,
    };
  }

  String? _preferredStableIdentity(
    String? latestKey,
    String? latestConfidence,
    String? previousKey,
    String? previousConfidence,
  ) {
    final latest = _normalized(latestKey);
    final previous = _normalized(previousKey);
    if (latest == null) return previous;
    if (previous == null) return latest;
    return _identityConfidenceRank(latestConfidence) >= _identityConfidenceRank(previousConfidence)
        ? latest
        : previous;
  }

  String? _preferredIdentityConfidence(
    String? latestKey,
    String? latestConfidence,
    String? previousKey,
    String? previousConfidence,
  ) {
    final latest = _normalized(latestKey);
    final previous = _normalized(previousKey);
    if (latest == null) return previousConfidence;
    if (previous == null) return latestConfidence;
    return _identityConfidenceRank(latestConfidence) >= _identityConfidenceRank(previousConfidence)
        ? latestConfidence
        : previousConfidence;
  }

  String? _preferredIdentityStrategy(
    String? latestKey,
    String? latestConfidence,
    String? latestStrategy,
    String? previousKey,
    String? previousConfidence,
    String? previousStrategy,
  ) {
    final latest = _normalized(latestKey);
    final previous = _normalized(previousKey);
    if (latest == null) return previousStrategy;
    if (previous == null) return latestStrategy;
    return _identityConfidenceRank(latestConfidence) >= _identityConfidenceRank(previousConfidence)
        ? latestStrategy
        : previousStrategy;
  }

  int _identityConfidenceRank(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  String? _preferNonBlank(String? latest, String? previous) {
    final latestTrimmed = latest?.trim();
    if (latestTrimmed != null && latestTrimmed.isNotEmpty) return latestTrimmed;
    final previousTrimmed = previous?.trim();
    if (previousTrimmed != null && previousTrimmed.isNotEmpty) return previousTrimmed;
    return null;
  }

  String? _normalized(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Set<String> _normalizedSet(List<String>? values) {
    return values
            ?.map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet() ??
        <String>{};
  }
}
