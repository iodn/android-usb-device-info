import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/key_value_row.dart';
import '../../core/widgets/section_card.dart';
import '../../data/usb/providers.dart';
import '../device/device_detail_screen.dart';
import '../home/controllers/device_list_controller.dart';
import 'controllers/device_history_controller.dart';
import 'models/device_history_entry.dart';

T? _tryRead<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    return null;
  }
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map) return v.cast<String, dynamic>();
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic v) {
  if (v is List) return v;
  return const <dynamic>[];
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

Map<String, dynamic> _asJsonMap(dynamic v) {
  if (v == null) return <String, dynamic>{};
  if (v is Map) return v.cast<String, dynamic>();
  final m = _tryRead(() => (v as dynamic).toJson());
  if (m is Map) return m.cast<String, dynamic>();
  return <String, dynamic>{};
}

Map<String, dynamic> _extractHistoryRaw(DeviceHistoryEntry entry) {
  final out = <String, dynamic>{};

  void merge(dynamic v) {
    final m = _asJsonMap(v);
    if (m.isEmpty) return;
    out.addAll(m);
  }

  // Include any known maps that some older exports may have used
  merge(_tryRead(() => (entry as dynamic).raw));
  merge(_tryRead(() => (entry as dynamic).detailsRaw));
  merge(_tryRead(() => (entry as dynamic).rawDetails));
  merge(_tryRead(() => (entry as dynamic).usbRaw));
  merge(_tryRead(() => (entry as dynamic).advanced));
  merge(_tryRead(() => (entry as dynamic).snapshot));
  merge(_tryRead(() => (entry as dynamic).extra));
  merge(_tryRead(() => (entry as dynamic).metadata));

  // Also merge the entry fields themselves so new exports are recognized
  try {
    out.addAll(entry.toMap().map((k, v) => MapEntry('$k', v)));
  } catch (_) {}

  return out;
}

class _HistoryAdvanced {
  const _HistoryAdvanced({
    required this.deviceDescriptor,
    required this.maxPowerMa,
    required this.configurations,
    required this.interfaces,
    required this.input,
    required this.deviceState,
    required this.strings,
    required this.descriptorTree,
    required this.hidReports,
  });

  final Map<String, dynamic> deviceDescriptor;
  final int? maxPowerMa;
  final List<dynamic> configurations;
  final List<dynamic> interfaces;
  final Map<String, dynamic> input;
  final Map<String, dynamic> deviceState;
  final Map<String, dynamic> strings;
  final List<dynamic> descriptorTree;
  final List<dynamic> hidReports;

  static _HistoryAdvanced fromEntry(DeviceHistoryEntry entry) {
    final raw = _extractHistoryRaw(entry);

    Map<String, dynamic> pickMap(String key, List<String> altKeys) {
      final m0 = _asMap(raw[key]);
      if (m0.isNotEmpty) return m0;
      for (final k in altKeys) {
        final m1 = _asMap(raw[k]);
        if (m1.isNotEmpty) return m1;
      }
      final dyn = _tryRead(() => (entry as dynamic));
      if (dyn != null) {
        for (final k in [key, ...altKeys]) {
          final mv = _tryRead(() => (dyn as dynamic).$k);
          final mm = _asJsonMap(mv);
          if (mm.isNotEmpty) return mm;
        }
      }
      return <String, dynamic>{};
    }

    List<dynamic> pickList(String key, List<String> altKeys) {
      final l0 = _asList(raw[key]);
      if (l0.isNotEmpty) return l0;
      for (final k in altKeys) {
        final l1 = _asList(raw[k]);
        if (l1.isNotEmpty) return l1;
      }
      final dyn = _tryRead(() => (entry as dynamic));
      if (dyn != null) {
        for (final k in [key, ...altKeys]) {
          final lv = _tryRead(() => (dyn as dynamic).$k);
          final ll = _asList(lv);
          if (ll.isNotEmpty) return ll;
        }
      }
      return const <dynamic>[];
    }

    int? pickInt(String key, List<String> altKeys) {
      final v0 = raw[key];
      final i0 = _asInt(v0);
      if (i0 != null) return i0;
      for (final k in altKeys) {
        final i1 = _asInt(raw[k]);
        if (i1 != null) return i1;
      }
      final dyn = _tryRead(() => (entry as dynamic));
      if (dyn != null) {
        for (final k in [key, ...altKeys]) {
          final iv = _tryRead(() => (dyn as dynamic).$k);
          final ii = _asInt(iv);
          if (ii != null) return ii;
        }
      }
      return null;
    }

    final deviceDescriptor = pickMap('deviceDescriptor', const ['device_descriptor', 'descriptor', 'dd']);
    final configurations = pickList('configurations', const ['configs', 'configurationList']);
    final interfaces = pickList('interfaces', const ['ifaces', 'interfaceList']);
    final input = pickMap('input', const ['inputDevice', 'inputDetails']);
    final deviceState = pickMap('deviceState', const ['state', 'usbState']);
    final strings = pickMap('strings', const ['stringDescriptors', 'usbStrings']);
    final descriptorTree = pickList('descriptorTree', const ['tree', 'descriptors']);
    final hidReports = pickList('hidReports', const ['hid', 'hidReportDescriptors']);

    int? maxPowerMa = pickInt('maxPowerMa', const ['maxPower', 'powerMa']);
    if (maxPowerMa == null && configurations.isNotEmpty) {
      final cfg0 = _asJsonMap(configurations.first);
      maxPowerMa = _asInt(cfg0['maxPowerMa']);
    }
    if (maxPowerMa == null) {
      final summary = _asMap(raw['summary']);
      maxPowerMa = _asInt(summary['maxPowerMa']);
    }

    return _HistoryAdvanced(
      deviceDescriptor: deviceDescriptor,
      maxPowerMa: maxPowerMa,
      configurations: configurations,
      interfaces: interfaces,
      input: input,
      deviceState: deviceState,
      strings: strings,
      descriptorTree: descriptorTree,
      hidReports: hidReports,
    );
  }
}

class _HistoryResolved {
  const _HistoryResolved({
    required this.vendorName,
    required this.productName,
    required this.className,
    required this.subclassName,
    required this.protocolName,
    required this.interfaceResolved,
  });

  final String? vendorName;
  final String? productName;
  final String? className;
  final String? subclassName;
  final String? protocolName;
  final List<({String? className, String? subclassName, String? protocolName})> interfaceResolved;
}

final _historyResolvedProvider = FutureProvider.family<_HistoryResolved, DeviceHistoryEntry>((ref, entry) async {
  final db = await ref.watch(usbIdsDbProvider.future);

  final v0 = (entry.vendorName ?? '').trim();
  final p0 = (entry.productNameResolved ?? '').trim();

  final vendorName = v0.isNotEmpty ? v0 : await db.vendorName(entry.vendorId);
  final productName = p0.isNotEmpty ? p0 : await db.productName(entry.vendorId, entry.productId);

  final className = await db.usbClassName(entry.deviceClass);
  final subclassName = await db.usbSubclassName(entry.deviceClass, entry.deviceSubclass);
  final protocolName = await db.usbProtocolName(entry.deviceClass, entry.deviceSubclass, entry.deviceProtocol);

  final adv = _HistoryAdvanced.fromEntry(entry);
  final ifResolved = <({String? className, String? subclassName, String? protocolName})>[];

  for (final it in adv.interfaces) {
    final m = _asJsonMap(it);
    final ic = _asInt(m['interfaceClass']) ?? 0;
    final isub = _asInt(m['interfaceSubclass']) ?? 0;
    final ip = _asInt(m['interfaceProtocol']) ?? 0;
    final icn = await db.usbClassName(ic);
    final isn = await db.usbSubclassName(ic, isub);
    final ipn = await db.usbProtocolName(ic, isub, ip);
    ifResolved.add((className: icn, subclassName: isn, protocolName: ipn));
  }

  return _HistoryResolved(
    vendorName: vendorName,
    productName: productName,
    className: className,
    subclassName: subclassName,
    protocolName: protocolName,
    interfaceResolved: ifResolved,
  );
});

class HistoryEntryDetailScreen extends ConsumerWidget {
  const HistoryEntryDetailScreen({super.key, required this.entryId});

  static const routeName = 'historyEntry';
  final String entryId;

  static String _connectionKey({
    required int vendorId,
    required int productId,
    required String deviceName,
    required String? serialNumber,
  }) {
    final vid = vendorId & 0xffff;
    final pid = productId & 0xffff;
    final sn = (serialNumber ?? '').trim();
    final dn = deviceName.trim();
    final identity = sn.isNotEmpty ? 'sn:$sn' : 'dn:$dn';
    return '${vid.toRadixString(16).padLeft(4, '0')}:${pid.toRadixString(16).padLeft(4, '0')}:$identity';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(deviceHistoryControllerProvider);
    final devicesAsync = ref.watch(deviceListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History detail'),
        actions: [
          historyAsync.maybeWhen(
            data: (items) {
              final entry = items.cast<DeviceHistoryEntry?>().firstWhere(
                    (e) => e?.id == entryId,
                    orElse: () => null,
                  );
              if (entry == null) return const SizedBox.shrink();
              final connected = _isConnected(entry, devicesAsync.asData?.value);
              return IconButton(
                tooltip: 'Open live device info',
                onPressed: connected ? () => _openLive(context, entry) : null,
                icon: const Icon(Icons.open_in_new_rounded),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => _ErrorBody(error: e.toString()),
          data: (items) {
            final entry = items.cast<DeviceHistoryEntry?>().firstWhere(
                  (e) => e?.id == entryId,
                  orElse: () => null,
                );
            if (entry == null) return const _NotFoundBody();

            final connected = _isConnected(entry, devicesAsync.asData?.value);
            final resolvedAsync = ref.watch(_historyResolvedProvider(entry));

            return resolvedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => _ErrorBody(error: e.toString()),
              data: (resolved) => _Body(
                entry: entry,
                resolved: resolved,
                connected: connected,
                onOpenLive: connected ? () => _openLive(context, entry) : null,
              ),
            );
          },
        ),
      ),
    );
  }

  static bool _isConnected(DeviceHistoryEntry entry, List<dynamic>? currentItems) {
    if (currentItems == null) return false;
    final keys = <String>{};
    for (final it in currentItems) {
      final d = (it as dynamic).device;
      keys.add(
        _connectionKey(
          vendorId: d.vendorId as int,
          productId: d.productId as int,
          deviceName: d.deviceName as String,
          serialNumber: d.serialNumber as String?,
        ),
      );
    }
    final key = _connectionKey(
      vendorId: entry.vendorId,
      productId: entry.productId,
      deviceName: entry.deviceName,
      serialNumber: entry.serialNumber,
    );
    return keys.contains(key);
  }

  static void _openLive(BuildContext context, DeviceHistoryEntry entry) {
    final enc = Uri.encodeComponent(entry.deviceName);
    context.pushNamed(DeviceDetailScreen.routeName, pathParameters: {'id': enc});
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.entry,
    required this.resolved,
    required this.connected,
    required this.onOpenLive,
  });

  final DeviceHistoryEntry entry;
  final _HistoryResolved resolved;
  final bool connected;
  final VoidCallback? onOpenLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final adv = _HistoryAdvanced.fromEntry(entry);

    final title = (resolved.productName ?? entry.productNameRaw ?? '').trim().isNotEmpty
        ? (resolved.productName ?? entry.productNameRaw)!
        : (entry.isInputDevice ? 'Input device' : 'USB device');

    final subtitle = (resolved.vendorName ?? entry.manufacturerNameRaw ?? '').trim().isNotEmpty
        ? (resolved.vendorName ?? entry.manufacturerNameRaw)!
        : 'Unknown vendor';

    final isInput = entry.isInputDevice;

    final hasDescriptor = adv.deviceDescriptor.isNotEmpty;
    final hasPower = adv.maxPowerMa != null;
    final hasCfgs = adv.configurations.isNotEmpty;
    final hasIfaces = adv.interfaces.isNotEmpty;
    final hasInput = adv.input.isNotEmpty;
    final hasState = adv.deviceState.isNotEmpty;
    final hasStrings = adv.strings.isNotEmpty;
    final hasTree = adv.descriptorTree.isNotEmpty;
    final hasHid = adv.hidReports.isNotEmpty;

    final showPermissionHint = !isInput && !entry.hasPermission && !(hasDescriptor || hasStrings || hasTree || hasHid || hasState);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isInput ? Icons.keyboard_alt_rounded : Icons.usb_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.deviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Chip(
                            icon: connected ? Icons.cable_rounded : Icons.cable_outlined,
                            label: connected ? 'Connected' : 'Not connected',
                            tonal: !connected,
                          ),
                          if (isInput)
                            _Chip(
                              icon: (entry.inputSources ?? const []).contains('mouse')
                                  ? Icons.mouse_rounded
                                  : (entry.inputSources ?? const []).contains('keyboard')
                                      ? Icons.keyboard_rounded
                                      : Icons.input_rounded,
                              label: (entry.inputSources == null || entry.inputSources!.isEmpty)
                                  ? 'Input device'
                                  : 'Input: ${entry.inputSources!.join(', ')}',
                              tonal: true,
                            )
                          else
                            (entry.hasPermission
                                ? const _Chip(icon: Icons.verified_rounded, label: 'Permission', tonal: false)
                                : const _Chip(icon: Icons.lock_outline_rounded, label: 'Needs permission', tonal: true)),
                        ],
                      ),
                      if (onOpenLive != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: onOpenLive,
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Open live device info'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (showPermissionHint) ...[
          _PermissionHintCard(isConnected: connected, onOpenLive: onOpenLive),
          const SizedBox(height: 12),
        ],
        _identitySection(),
        const SizedBox(height: 12),
        _usbSpecSection(),
        const SizedBox(height: 12),
        _locationSection(),
        if (!isInput) ...[
          if (hasDescriptor) ...[
            const SizedBox(height: 12),
            _deviceDescriptorSection(context, adv.deviceDescriptor),
          ],
          if (hasPower) ...[
            const SizedBox(height: 12),
            _powerSection(adv.maxPowerMa),
          ],
          if (hasCfgs) ...[
            const SizedBox(height: 12),
            _configurationsSection(context, adv.configurations),
          ],
          if (hasIfaces) ...[
            const SizedBox(height: 12),
            _interfacesSection(context, adv.interfaces, resolved.interfaceResolved),
          ],
          if (hasState) ...[
            const SizedBox(height: 12),
            _advancedStatusSection(context, adv.deviceState),
          ],
          if (hasStrings) ...[
            const SizedBox(height: 12),
            _advancedStringsSection(context, adv.strings),
          ],
          if (hasTree) ...[
            const SizedBox(height: 12),
            _advancedDescriptorTreeSection(context, adv.descriptorTree),
          ],
          if (hasHid) ...[
            const SizedBox(height: 12),
            _advancedHidReportsSection(context, adv.hidReports),
          ],
        ] else ...[
          if (hasInput) ...[
            const SizedBox(height: 12),
            _inputDeviceSection(context, adv.input),
          ],
        ],
      ],
    );
  }

  Widget _identitySection() {
    return SectionCard(
      title: 'Identity',
      subtitle: 'IDs, vendor/product strings',
      leading: const Icon(Icons.badge_outlined),
      child: Column(
        children: [
          KeyValueRow(label: 'Vendor ID', value: Fmt.decAndHex16(entry.vendorId)),
          KeyValueRow(label: 'Product ID', value: Fmt.decAndHex16(entry.productId)),
          KeyValueRow(label: 'Vendor', value: Fmt.formatNullable(resolved.vendorName ?? entry.manufacturerNameRaw)),
          KeyValueRow(label: 'Product', value: Fmt.formatNullable(resolved.productName ?? entry.productNameRaw)),
          KeyValueRow(label: 'Serial', value: Fmt.formatNullable(entry.serialNumber)),
        ],
      ),
    );
  }

  Widget _usbSpecSection() {
    return SectionCard(
      title: 'USB specification',
      subtitle: 'Version, speed, class/protocol',
      leading: const Icon(Icons.tune_rounded),
      child: Column(
        children: [
          KeyValueRow(label: 'USB version', value: Fmt.formatNullable(entry.usbVersion)),
          KeyValueRow(label: 'Speed', value: Fmt.speedLabel(entry.speed)),
          KeyValueRow(label: 'Device class', value: _join(resolved.className, entry.deviceClass)),
          KeyValueRow(label: 'Subclass', value: _join(resolved.subclassName, entry.deviceSubclass)),
          KeyValueRow(label: 'Protocol', value: _join(resolved.protocolName, entry.deviceProtocol)),
          KeyValueRow(label: 'Interfaces', value: '${entry.interfaceCount}'),
          KeyValueRow(label: 'Configurations', value: '${entry.configurationCount}'),
        ],
      ),
    );
  }

  Widget _locationSection() {
    return SectionCard(
      title: 'Location',
      subtitle: 'Android identifiers and bus hints',
      leading: const Icon(Icons.pin_drop_outlined),
      child: Column(
        children: [
          KeyValueRow(label: 'Device path', value: entry.deviceName),
          KeyValueRow(label: 'Android deviceId', value: entry.deviceId == null ? 'Unknown' : '${entry.deviceId}'),
          KeyValueRow(label: 'Port number', value: entry.portNumber == null ? 'Unknown' : '${entry.portNumber}'),
          KeyValueRow(
            label: 'Type',
            value: entry.isInputDevice ? 'Input device (keyboard/mouse via InputManager)' : 'USB device (UsbManager)',
            allowCopy: false,
          ),
        ],
      ),
    );
  }

  Widget _deviceDescriptorSection(BuildContext context, Map<String, dynamic> dd) {
    if (dd.isEmpty) return const SizedBox.shrink();

    final usbVersion = (dd['usbVersion'] as String?)?.trim();
    final deviceRelease = (dd['deviceRelease'] as String?)?.trim();
    final maxPkt0 = _asInt(dd['maxPacketSize0']);
    final numCfg = _asInt(dd['numConfigurations']);
    final iMan = _asInt(dd['iManufacturer']);
    final iProd = _asInt(dd['iProduct']);
    final iSer = _asInt(dd['iSerialNumber']);

    if ((usbVersion == null || usbVersion.isEmpty) &&
        (deviceRelease == null || deviceRelease.isEmpty) &&
        maxPkt0 == null &&
        numCfg == null &&
        iMan == null &&
        iProd == null &&
        iSer == null) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Device descriptor',
      subtitle: 'Raw USB descriptor fields',
      leading: const Icon(Icons.article_outlined),
      child: _ExpandableBlock(
        title: 'Show descriptor fields',
        initiallyExpanded: true,
        child: Column(
          children: [
            if (usbVersion != null && usbVersion.isNotEmpty) KeyValueRow(label: 'USB spec (bcdUSB)', value: usbVersion),
            if (deviceRelease != null && deviceRelease.isNotEmpty)
              KeyValueRow(label: 'Device release (bcdDevice)', value: deviceRelease),
            if (maxPkt0 != null) KeyValueRow(label: 'EP0 max packet', value: '$maxPkt0'),
            if (numCfg != null) KeyValueRow(label: 'Num configurations', value: '$numCfg'),
            if (iMan != null) KeyValueRow(label: 'iManufacturer', value: '$iMan'),
            if (iProd != null) KeyValueRow(label: 'iProduct', value: '$iProd'),
            if (iSer != null) KeyValueRow(label: 'iSerialNumber', value: '$iSer'),
          ],
        ),
      ),
    );
  }

  Widget _powerSection(int? maxPowerMa) {
    if (maxPowerMa == null) return const SizedBox.shrink();
    return SectionCard(
      title: 'Power',
      subtitle: 'Configuration power budget',
      leading: const Icon(Icons.bolt_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(label: 'Max power (config 0)', value: '$maxPowerMa mA'),
        ],
      ),
    );
  }

  Widget _configurationsSection(BuildContext context, List<dynamic> cfgs) {
    if (cfgs.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'Configurations',
      subtitle: 'All reported USB configurations',
      leading: const Icon(Icons.layers_outlined),
      child: Column(
        children: [
          for (int i = 0; i < cfgs.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            _ConfigBlock(cfg: _asJsonMap(cfgs[i]), index: i),
          ],
        ],
      ),
    );
  }

  Widget _interfacesSection(
    BuildContext context,
    List<dynamic> ifaces,
    List<({String? className, String? subclassName, String? protocolName})> resolvedIfs,
  ) {
    if (ifaces.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'Interfaces & endpoints',
      subtitle: 'Parsed interface and endpoint descriptors',
      leading: const Icon(Icons.account_tree_outlined),
      child: Column(
        children: [
          for (int idx = 0; idx < ifaces.length; idx++) ...[
            if (idx > 0) const Divider(height: 24),
            _InterfaceBlock(
              index: idx,
              iface: _asJsonMap(ifaces[idx]),
              resolved: resolvedIfs.length > idx ? resolvedIfs[idx] : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _inputDeviceSection(BuildContext context, Map<String, dynamic> input) {
    if (input.isEmpty) return const SizedBox.shrink();

    final name = (input['name'] as String?)?.trim();
    final descriptor = (input['descriptor'] as String?)?.trim();
    final isExternal = input['isExternal'] == true;
    final sources = _asList(input['sources']).map((e) => '$e').where((s) => s.trim().isNotEmpty).toList(growable: false);
    final keyboardType = _asInt(input['keyboardType']);
    final motionRanges = _asList(input['motionRanges']);

    final hasAny = (name != null && name.isNotEmpty) ||
        (descriptor != null && descriptor.isNotEmpty) ||
        sources.isNotEmpty ||
        keyboardType != null ||
        motionRanges.isNotEmpty ||
        input.containsKey('isExternal');

    if (!hasAny) return const SizedBox.shrink();

    return SectionCard(
      title: 'Input device',
      subtitle: 'Keyboard/mouse info from InputManager',
      leading: const Icon(Icons.keyboard_alt_outlined),
      child: Column(
        children: [
          if (name != null && name.isNotEmpty) KeyValueRow(label: 'Name', value: name),
          if (descriptor != null && descriptor.isNotEmpty) KeyValueRow(label: 'Descriptor', value: descriptor),
          if (input.containsKey('isExternal')) KeyValueRow(label: 'External', value: isExternal ? 'Yes' : 'No'),
          if (sources.isNotEmpty) KeyValueRow(label: 'Sources', value: sources.join(', ')),
          if (keyboardType != null) KeyValueRow(label: 'Keyboard type', value: '$keyboardType'),
          if (motionRanges.isNotEmpty) ...[
            KeyValueRow(label: 'Motion ranges', value: '${motionRanges.length}'),
            const SizedBox(height: 8),
            _ExpandableBlock(
              title: 'Show motion ranges',
              child: Column(
                children: [
                  for (final r in motionRanges.take(16)) ...[
                    KeyValueRow(
                      label: Fmt.axisLabel(_asInt(_asMap(r)['axis']) ?? 0),
                      value:
                          '${(_asMap(r)['min'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'} → ${(_asMap(r)['max'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'} (res ${(_asMap(r)['resolution'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'})',
                    ),
                  ],
                  if (motionRanges.length > 16)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing first 16 ranges.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _advancedStatusSection(BuildContext context, Map<String, dynamic> state) {
    final activeCfg = state['activeConfiguration'];
    final status = _asMap(state['deviceStatus']);
    final ifAlt = _asList(state['interfaceAltSettings']);
    if (activeCfg == null && status.isEmpty && ifAlt.isEmpty) return const SizedBox.shrink();

    final selfPowered = status['selfPowered'];
    final remoteWake = status['remoteWakeup'];
    final rawStatus = status['raw'];

    return SectionCard(
      title: 'Device state',
      subtitle: 'Active config, status bits, alt settings',
      leading: const Icon(Icons.memory_rounded),
      child: Column(
        children: [
          KeyValueRow(label: 'Active configuration', value: activeCfg == null ? 'Unknown' : '$activeCfg'),
          if (rawStatus != null)
            KeyValueRow(
              label: 'Device status',
              value: '${Fmt.decAndHex16(rawStatus is int ? rawStatus : int.tryParse('$rawStatus') ?? 0)}',
            ),
          if (selfPowered != null)
            KeyValueRow(label: 'Self-powered', value: selfPowered == true ? 'Yes' : 'No'),
          if (remoteWake != null)
            KeyValueRow(label: 'Remote wakeup', value: remoteWake == true ? 'Yes' : 'No'),
          if (ifAlt.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ExpandableBlock(
              title: 'Interface alternate settings',
              child: Column(
                children: [
                  for (final it in ifAlt.take(32)) ...[
                    KeyValueRow(
                      label: 'IF ${_asInt(_asMap(it)['interfaceNumber']) ?? '?'}',
                      value: 'Alt ${_asInt(_asMap(it)['alternateSetting'])?.toString() ?? 'Unknown'}',
                      allowCopy: false,
                    ),
                  ],
                  if (ifAlt.length > 32)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing first 32 interfaces.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _advancedStringsSection(BuildContext context, Map<String, dynamic> strings) {
    final langs = _asList(strings['languageIds']).map(_asInt).whereType<int>().toList(growable: false);
    final preferred = _asInt(strings['preferredLanguageId']);
    final dev = _asMap(strings['device']);
    final ifs = _asList(strings['interfaces']);
    if (langs.isEmpty && dev.isEmpty && ifs.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'String descriptors',
      subtitle: 'Languages and iManufacturer/iProduct/iSerial + iInterface',
      leading: const Icon(Icons.translate_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (langs.isNotEmpty)
            KeyValueRow(
              label: 'Languages',
              value: langs.map(Fmt.hex16).join(', '),
            ),
          if (preferred != null) KeyValueRow(label: 'Preferred', value: Fmt.hex16(preferred)),
          if (dev.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Device strings',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            if ((dev['manufacturer'] as String?)?.trim().isNotEmpty ?? false)
              KeyValueRow(label: 'Manufacturer', value: (dev['manufacturer'] as String).trim()),
            if ((dev['product'] as String?)?.trim().isNotEmpty ?? false) KeyValueRow(label: 'Product', value: (dev['product'] as String).trim()),
            if ((dev['serial'] as String?)?.trim().isNotEmpty ?? false) KeyValueRow(label: 'Serial', value: (dev['serial'] as String).trim()),
          ],
          if (ifs.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ExpandableBlock(
              title: 'Interface strings',
              child: Column(
                children: [
                  for (final it in ifs.take(48)) ...[
                    KeyValueRow(
                      label:
                          'IF ${_asInt(_asMap(it)['interfaceNumber']) ?? '?'} (Alt ${_asInt(_asMap(it)['alternateSetting']) ?? 0})',
                      value: (_asMap(it)['value'] as String?)?.trim().isEmpty ?? true ? 'Unknown' : (_asMap(it)['value'] as String),
                    ),
                  ],
                  if (ifs.length > 48)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing first 48 interface strings.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _advancedDescriptorTreeSection(BuildContext context, List<dynamic> tree) {
    if (tree.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'Descriptor tree',
      subtitle: '${tree.length} descriptors parsed',
      leading: const Icon(Icons.schema_rounded),
      child: _ExpandableBlock(
        title: 'Show descriptors',
        child: Column(
          children: [
            for (final n in tree.take(64)) ...[
              _DescriptorNodeTile(node: _asMap(n)),
              const SizedBox(height: 8),
            ],
            if (tree.length > 64)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing first 64 descriptors.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _advancedHidReportsSection(BuildContext context, List<dynamic> reports) {
    if (reports.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'HID report descriptors',
      subtitle: '${reports.length} interface(s)',
      leading: const Icon(Icons.keyboard_command_key_rounded),
      child: Column(
        children: [
          for (final r in reports) ...[
            _HidReportBlock(report: _asMap(r)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  static String _join(String? name, int id) {
    final n = (name == null || name.trim().isEmpty) ? 'Unknown' : name;
    return '$n (${Fmt.decAndHex8(id)})';
  }
}

class _PermissionHintCard extends StatelessWidget {
  const _PermissionHintCard({required this.isConnected, required this.onOpenLive});

  final bool isConnected;
  final VoidCallback? onOpenLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_rounded, color: theme.colorScheme.onErrorContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Advanced details not captured',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This history entry does not include raw descriptors, strings, or HID reports. These fields require USB permission at capture time.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
            ),
            if (isConnected && onOpenLive != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onOpenLive,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open live device info'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.tonal});

  final IconData icon;
  final String label;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = tonal ? theme.colorScheme.tertiaryContainer : theme.colorScheme.secondaryContainer;
    final fg = tonal ? theme.colorScheme.onTertiaryContainer : theme.colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: fg)),
        ],
      ),
    );
  }
}

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.search_off_rounded, size: 48),
        const SizedBox(height: 12),
        Text('Entry not found', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('This history item no longer exists.'),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.error_outline_rounded, size: 48),
        const SizedBox(height: 12),
        Text('Unable to open history detail.', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(error),
      ],
    );
  }
}

class _ConfigBlock extends StatelessWidget {
  const _ConfigBlock({required this.cfg, required this.index});

  final Map<String, dynamic> cfg;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final id = _asInt(cfg['id']);
    final name = (cfg['name'] as String?)?.trim();
    final attrs = _asInt(cfg['attributes']) ?? 0;
    final interfaceCount = _asInt(cfg['interfaceCount']);
    final maxPowerMa = _asInt(cfg['maxPowerMa']);
    final interfaces = _asList(cfg['interfaces']);

    final hasAny = id != null ||
        (name != null && name.isNotEmpty) ||
        attrs != 0 ||
        interfaceCount != null ||
        maxPowerMa != null ||
        interfaces.isNotEmpty;

    if (!hasAny) return const SizedBox.shrink();

    final attrsHex = Fmt.decAndHex8(attrs);
    final attrsLabel = Fmt.usbConfigAttributesLabel(attrs);
    final maxPower = maxPowerMa == null ? null : '$maxPowerMa mA';

    final title = 'Configuration ${id ?? index}${(name != null && name.isNotEmpty) ? ' — $name' : ''}';

    return _ExpandableBlock(
      title: title,
      initiallyExpanded: index == 0,
      child: Column(
        children: [
          if (name != null && name.isNotEmpty) KeyValueRow(label: 'Name', value: name),
          if (attrs != 0) KeyValueRow(label: 'Attributes', value: '$attrsHex • $attrsLabel'),
          if (maxPower != null) KeyValueRow(label: 'Max power', value: maxPower),
          if (interfaceCount != null) KeyValueRow(label: 'Interfaces', value: '$interfaceCount'),
          if (interfaces.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Interfaces (summary)',
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            for (final i in interfaces.take(8)) ...[
              KeyValueRow(
                label: 'IF ${_asInt(_asMap(i)['id']) ?? '?'}',
                value: 'Class ${Fmt.decAndHex8(_asInt(_asMap(i)['interfaceClass']) ?? 0)} • EP ${_asInt(_asMap(i)['endpointCount']) ?? 0}',
                allowCopy: false,
              ),
            ],
            if (interfaces.length > 8)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing first 8 interfaces.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _InterfaceBlock extends StatelessWidget {
  const _InterfaceBlock({required this.index, required this.iface, required this.resolved});

  final int index;
  final Map<String, dynamic> iface;
  final ({String? className, String? subclassName, String? protocolName})? resolved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final id = _asInt(iface['id']);
    final alt = _asInt(iface['alternateSetting']) ?? 0;
    final name = (iface['name'] as String?)?.trim();
    final classId = _asInt(iface['interfaceClass']) ?? 0;
    final subclassId = _asInt(iface['interfaceSubclass']) ?? 0;
    final protocolId = _asInt(iface['interfaceProtocol']) ?? 0;
    final endpointCount = _asInt(iface['endpointCount']);
    final endpoints = _asList(iface['endpoints']);

    if (id == null && classId == 0 && subclassId == 0 && protocolId == 0 && endpoints.isEmpty && (name == null || name.isEmpty)) {
      return const SizedBox.shrink();
    }

    String join(String? n, int id) => '${(n == null || n.trim().isEmpty) ? 'Unknown' : n} (${Fmt.decAndHex8(id)})';

    return _ExpandableBlock(
      title: 'Interface ${id ?? index} • ${join(resolved?.className, classId)}',
      initiallyExpanded: index == 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name != null && name.isNotEmpty) KeyValueRow(label: 'Name', value: name),
          KeyValueRow(label: 'Alt setting', value: '$alt'),
          KeyValueRow(label: 'Class', value: join(resolved?.className, classId)),
          KeyValueRow(label: 'Subclass', value: join(resolved?.subclassName, subclassId)),
          KeyValueRow(label: 'Protocol', value: join(resolved?.protocolName, protocolId)),
          const SizedBox(height: 10),
          Text('Endpoints (${endpointCount ?? endpoints.length})',
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          if (endpoints.isEmpty)
            Text('No endpoints', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          else
            Column(
              children: [
                for (final ep in endpoints) ...[
                  _EndpointTile(ep: _asMap(ep)),
                  const SizedBox(height: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _EndpointTile extends StatelessWidget {
  const _EndpointTile({required this.ep});

  final Map<String, dynamic> ep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final address = _asInt(ep['address']) ?? 0;
    final direction = (ep['direction'] as String?)?.trim() ?? 'Unknown';
    final type = (ep['type'] as String?)?.trim() ?? 'Unknown';
    final maxPacketSize = _asInt(ep['maxPacketSize']) ?? 0;
    final interval = _asInt(ep['interval']) ?? 0;
    final attributes = _asInt(ep['attributes']) ?? 0;
    final number = _asInt(ep['number']) ?? 0;

    IconData icon;
    final t = type.toLowerCase();
    if (t.contains('interrupt')) {
      icon = Icons.flash_on_rounded;
    } else if (t.contains('bulk')) {
      icon = Icons.swap_horiz_rounded;
    } else if (t.contains('isochronous')) {
      icon = Icons.av_timer_rounded;
    } else {
      icon = Icons.circle_outlined;
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$type • $direction', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Addr ${Fmt.decAndHex8(address)} • EP# $number • Attr ${Fmt.decAndHex8(attributes)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('MaxPkt $maxPacketSize', style: theme.textTheme.labelMedium),
                Text('Interval $interval', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableBlock extends StatelessWidget {
  const _ExpandableBlock({required this.title, required this.child, this.initiallyExpanded = false});

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        initiallyExpanded: initiallyExpanded,
        title: Text(title, style: theme.textTheme.titleMedium),
        children: [child],
      ),
    );
  }
}

class _DescriptorNodeTile extends StatelessWidget {
  const _DescriptorNodeTile({required this.node});

  final Map<String, dynamic> node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final off = _asInt(node['offset']);
    final len = _asInt(node['length']);
    final typeName = (node['descriptorTypeName'] as String?) ?? 'Unknown';
    final type = _asInt(node['descriptorType']);
    final fields = _asMap(node['fields']);
    final rawHex = (node['rawHex'] as String?) ?? '';

    if (off == null && len == null && type == null && fields.isEmpty && rawHex.trim().isEmpty) return const SizedBox.shrink();

    final headline = '0x${off == null ? '??' : off.toRadixString(16)} • $typeName (${type == null ? '?' : Fmt.decAndHex8(type)}) • ${len ?? '?'} bytes';

    String? hint;
    if (fields.isNotEmpty) {
      if (type == 0x02) {
        final cfgVal = fields['bConfigurationValue'];
        final total = fields['wTotalLength'];
        hint = 'Cfg ${cfgVal ?? '?'} • Total ${total ?? '?'}';
      } else if (type == 0x04) {
        hint = 'IF ${fields['bInterfaceNumber'] ?? '?'} • Alt ${fields['bAlternateSetting'] ?? 0} • EP ${fields['bNumEndpoints'] ?? '?'}';
      } else if (type == 0x05) {
        hint = 'EP ${fields['endpointNumber'] ?? '?'} • ${fields['direction'] ?? ''} • ${fields['transferTypeName'] ?? ''}';
      } else if (type == 0x21) {
        hint = 'HID • ReportLen ${fields['reportDescriptorLength'] ?? '?'}';
      } else if (type == 0x24) {
        hint = 'CS IF • Subtype ${fields['bDescriptorSubType'] ?? '?'}';
      }
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(headline, style: theme.textTheme.titleSmall),
            if (hint != null) ...[
              const SizedBox(height: 2),
              Text(hint!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
            if (fields.isNotEmpty) ...[
              const SizedBox(height: 10),
              _ExpandableBlock(
                title: 'Fields',
                child: Column(
                  children: [
                    for (final e in fields.entries.take(14)) ...[
                      KeyValueRow(label: e.key, value: '${e.value}'),
                    ],
                    if (fields.length > 14)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Showing first 14 fields.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (rawHex.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _ExpandableBlock(
                title: 'Raw bytes (hex)',
                child: SelectableText(
                  Fmt.hexWrap(rawHex, group: 2, groupsPerLine: 16),
                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HidReportBlock extends StatelessWidget {
  const _HidReportBlock({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ifNum = _asInt(report['interfaceNumber']);
    final repLen = _asInt(report['reportLength']);
    final hex = report['reportHex'] as String?;
    final summary = _asMap(report['summary']);
    final hasKb = summary['hasKeyboard'] == true;
    final hasMouse = summary['hasMouse'] == true;
    final reportIdCount = _asInt(summary['reportIdCount']);
    final usagePages = _asList(summary['usagePages']).map(_asInt).whereType<int>().toList(growable: false);
    final collections = _asInt(summary['collectionCount']);

    final chips = <String>[];
    if (hasKb) chips.add('Keyboard');
    if (hasMouse) chips.add('Mouse');
    if (reportIdCount != null) chips.add('Report IDs: $reportIdCount');
    if (collections != null) chips.add('Collections: $collections');
    if (usagePages.isNotEmpty) chips.add('Usage pages: ${usagePages.map(Fmt.hex16).join(', ')}');

    return _ExpandableBlock(
      title: 'Interface ${ifNum ?? '?'} • Report ${repLen ?? '?'} bytes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chips.isNotEmpty) ...[
            for (final c in chips) ...[
              Text(c, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 8),
          ],
          if (hex == null || hex.isEmpty)
            Text(
              'Report descriptor not available.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            _ExpandableBlock(
              title: 'Raw report descriptor (hex)',
              initiallyExpanded: false,
              child: SelectableText(
                Fmt.hexWrap(hex, group: 2, groupsPerLine: 16),
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            ),
        ],
      ),
    );
  }
}
