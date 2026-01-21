import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/key_value_row.dart';
import '../../core/widgets/section_card.dart';
import '../../data/usb/models.dart';
import '../../data/usb/providers.dart';
import '../../data/usb/usb_repository.dart';
import '../history/controllers/device_history_controller.dart';
import 'controllers/device_detail_controller.dart';

class DeviceDetailScreen extends ConsumerStatefulWidget {
  const DeviceDetailScreen({super.key, required this.deviceName});
  static const routeName = 'device';
  final String deviceName;

  @override
  ConsumerState<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends ConsumerState<DeviceDetailScreen> {
  ProviderSubscription<AsyncValue<UsbDeviceDetailViewData>>? _sub;
  ProviderSubscription<AsyncValue<Map<String, dynamic>>>? _rawSub;
  UsbDeviceDetailViewData? _lastView;
  Map<String, dynamic>? _lastRaw;

  @override
  void initState() {
    super.initState();
    void recordView(UsbDeviceDetailViewData data) {
      _lastView = data;
      final raw = _lastRaw;
      ref.read(deviceHistoryControllerProvider.notifier).recordFromView(data, raw: raw);
    }

    void recordRaw(Map<String, dynamic> raw) {
      _lastRaw = raw;
      final view = _lastView;
      if (view != null) {
        ref.read(deviceHistoryControllerProvider.notifier).recordFromView(view, raw: raw);
      }
    }

    final firstView = ref.read(deviceDetailControllerProvider(widget.deviceName));
    final v0 = firstView.asData?.value;
    if (v0 != null) recordView(v0);

    _sub = ref.listenManual<AsyncValue<UsbDeviceDetailViewData>>(
      deviceDetailControllerProvider(widget.deviceName),
      (prev, next) {
        final data = next.asData?.value;
        if (data != null) recordView(data);
      },
    );

    final firstRaw = ref.read(deviceDetailRawControllerProvider(widget.deviceName));
    final r0 = firstRaw.asData?.value;
    if (r0 != null) recordRaw(r0);

    _rawSub = ref.listenManual<AsyncValue<Map<String, dynamic>>>(
      deviceDetailRawControllerProvider(widget.deviceName),
      (prev, next) {
        final data = next.asData?.value;
        if (data != null) recordRaw(data);
      },
    );
  }

  @override
  void dispose() {
    _sub?.close();
    _rawSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(deviceDetailControllerProvider(widget.deviceName));
    final rawAsync = ref.watch(deviceDetailRawControllerProvider(widget.deviceName));
    return Scaffold(
      appBar: AppBar(title: const Text('Device info')),
      body: SafeArea(
        child: async.when(
          data: (data) => rawAsync.when(
            data: (raw) => _DeviceDetailBody(view: data, raw: raw),
            loading: () => _DeviceDetailBody(view: data, raw: null),
            error: (e, st) => _DeviceDetailBody(view: data, raw: null),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => _ErrorBody(error: e.toString()),
        ),
      ),
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
        Text('Unable to read device details.', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(error),
      ],
    );
  }
}

class _DeviceDetailBody extends StatelessWidget {
  const _DeviceDetailBody({required this.view, required this.raw});
  final UsbDeviceDetailViewData view;
  final Map<String, dynamic>? raw;

  @override
  Widget build(BuildContext context) {
    final s = view.details.summary;
    final theme = Theme.of(context);

    final title = view.productName ?? s.productName ?? (s.isInputDevice ? 'Input device' : 'USB Device');
    final subtitle = view.vendorName ?? s.manufacturerName ?? 'Unknown vendor';

    final isInput = s.isInputDevice;
    final needsPermission = !isInput && !s.hasPermission;

    final tree = _asList(raw?['descriptorTree']);
    final strings = _asMap(raw?['strings']);
    final hidReports = _asList(raw?['hidReports']);
    final deviceState = _asMap(raw?['deviceState']);

    final langs = _asList(strings['languageIds']).map((e) => _asInt(e)).whereType<int>().toList(growable: false);
    final devStrings = _asMap(strings['device']);
    final ifStrings = _asList(strings['interfaces']);

    final status = _asMap(deviceState['deviceStatus']);
    final ifAlt = _asList(deviceState['interfaceAltSettings']);
    final activeCfg = deviceState['activeConfiguration'];

    final hasState = activeCfg != null || status.isNotEmpty || ifAlt.isNotEmpty;
    final hasStrings = langs.isNotEmpty || devStrings.isNotEmpty || ifStrings.isNotEmpty;
    final hasTree = tree.isNotEmpty;
    final hasHid = hidReports.isNotEmpty;

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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.deviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (needsPermission) _PermissionBanner(deviceName: s.deviceName, vendorId: s.vendorId, productId: s.productId),
        if (needsPermission) const SizedBox(height: 12),
        _identitySection(context),
        const SizedBox(height: 12),
        _usbSpecSection(context),
        const SizedBox(height: 12),
        _locationSection(context),
        const SizedBox(height: 12),
        if (!isInput) ...[
          _descriptorSection(context),
          const SizedBox(height: 12),
          _powerSection(context),
          const SizedBox(height: 12),
          _configurationsSection(context),
          const SizedBox(height: 12),
          _interfacesSection(context),
          if (hasState) ...[
            const SizedBox(height: 12),
            _advancedStatusSection(context, deviceState),
          ],
          if (hasStrings) ...[
            const SizedBox(height: 12),
            _advancedStringsSection(context, strings),
          ],
          if (hasTree) ...[
            const SizedBox(height: 12),
            _advancedDescriptorTreeSection(context, tree),
          ],
          if (hasHid) ...[
            const SizedBox(height: 12),
            _advancedHidReportsSection(context, hidReports),
          ],
        ] else ...[
          _inputDeviceSection(context),
        ],
      ],
    );
  }

  Widget _identitySection(BuildContext context) {
    final s = view.details.summary;
    final vendor = view.vendorName ?? s.manufacturerName;
    final product = view.productName ?? s.productName;
    return SectionCard(
      title: 'Identity',
      subtitle: 'IDs, vendor/product strings',
      leading: const Icon(Icons.badge_outlined),
      child: Column(
        children: [
          KeyValueRow(label: 'Vendor ID', value: Fmt.decAndHex16(s.vendorId)),
          KeyValueRow(label: 'Product ID', value: Fmt.decAndHex16(s.productId)),
          KeyValueRow(label: 'Vendor', value: Fmt.formatNullable(vendor)),
          KeyValueRow(label: 'Product', value: Fmt.formatNullable(product)),
          KeyValueRow(label: 'Serial', value: Fmt.formatNullable(s.serialNumber)),
        ],
      ),
    );
  }

  Widget _usbSpecSection(BuildContext context) {
    final s = view.details.summary;
    return SectionCard(
      title: 'USB specification',
      subtitle: 'Version, speed, class/protocol',
      leading: const Icon(Icons.tune_rounded),
      child: Column(
        children: [
          KeyValueRow(label: 'USB version', value: Fmt.formatNullable(s.usbVersion)),
          KeyValueRow(label: 'Speed', value: Fmt.speedLabel(s.speed)),
          KeyValueRow(label: 'Device class', value: _joinNameAndIds(view.deviceClassName, s.deviceClass)),
          KeyValueRow(label: 'Subclass', value: _joinNameAndIds(view.deviceSubclassName, s.deviceSubclass)),
          KeyValueRow(label: 'Protocol', value: _joinNameAndIds(view.deviceProtocolName, s.deviceProtocol)),
          KeyValueRow(label: 'Interfaces', value: '${s.interfaceCount}'),
          KeyValueRow(label: 'Configurations', value: '${s.configurationCount}'),
        ],
      ),
    );
  }

  Widget _locationSection(BuildContext context) {
    final s = view.details.summary;
    return SectionCard(
      title: 'Location',
      subtitle: 'Android identifiers and bus hints',
      leading: const Icon(Icons.pin_drop_outlined),
      child: Column(
        children: [
          KeyValueRow(label: 'Device path', value: s.deviceName),
          KeyValueRow(label: 'Android deviceId', value: s.deviceId == null ? 'Unknown' : '${s.deviceId}'),
          KeyValueRow(label: 'Port number', value: s.portNumber == null ? 'Unknown' : '${s.portNumber}'),
          KeyValueRow(
            label: 'Type',
            value: s.isInputDevice ? 'Input device (keyboard/mouse via InputManager)' : 'USB device (UsbManager)',
            allowCopy: false,
          ),
        ],
      ),
    );
  }

  Widget _descriptorSection(BuildContext context) {
    final d = view.details.deviceDescriptor;
    final theme = Theme.of(context);
    if (d == null) return const SizedBox.shrink();
    return SectionCard(
      title: 'Device descriptor',
      subtitle: 'Raw USB descriptor fields',
      leading: const Icon(Icons.article_outlined),
      child: _ExpandableBlock(
        title: 'Show descriptor fields',
        initiallyExpanded: true,
        child: Column(
          children: [
            KeyValueRow(label: 'USB spec (bcdUSB)', value: d.usbVersion ?? 'Unknown'),
            KeyValueRow(label: 'Device release (bcdDevice)', value: d.deviceRelease ?? 'Unknown'),
            KeyValueRow(label: 'EP0 max packet', value: d.maxPacketSize0 == null ? 'Unknown' : '${d.maxPacketSize0}'),
            KeyValueRow(label: 'Num configurations', value: d.numConfigurations == null ? 'Unknown' : '${d.numConfigurations}'),
            KeyValueRow(label: 'iManufacturer', value: d.iManufacturer == null ? 'Unknown' : '${d.iManufacturer}'),
            KeyValueRow(label: 'iProduct', value: d.iProduct == null ? 'Unknown' : '${d.iProduct}'),
            KeyValueRow(label: 'iSerialNumber', value: d.iSerialNumber == null ? 'Unknown' : '${d.iSerialNumber}'),
          ],
        ),
      ),
    );
  }

  Widget _powerSection(BuildContext context) {
    final s = view.details.summary;
    if (s.maxPowerMa == null) return const SizedBox.shrink();
    return SectionCard(
      title: 'Power',
      subtitle: 'Configuration power budget',
      leading: const Icon(Icons.bolt_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(label: 'Max power (config 0)', value: '${s.maxPowerMa} mA'),
        ],
      ),
    );
  }

  Widget _configurationsSection(BuildContext context) {
    final cfgs = view.details.configurations;
    if (cfgs.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'Configurations',
      subtitle: 'All reported USB configurations',
      leading: const Icon(Icons.layers_outlined),
      child: Column(
        children: [
          for (int i = 0; i < cfgs.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            _ConfigBlock(cfg: cfgs[i], index: i),
          ],
        ],
      ),
    );
  }

  Widget _interfacesSection(BuildContext context) {
    final ifaces = view.details.interfaces;
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
              iface: ifaces[idx],
              resolved: view.interfaceClassNames.length > idx ? view.interfaceClassNames[idx] : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _inputDeviceSection(BuildContext context) {
    final theme = Theme.of(context);
    final input = view.details.input;
    final s = view.details.summary;
    if (input == null) return const SizedBox.shrink();
    return SectionCard(
      title: 'Input device',
      subtitle: 'Keyboard/mouse info from InputManager',
      leading: const Icon(Icons.keyboard_alt_outlined),
      child: Column(
        children: [
          KeyValueRow(label: 'Name', value: Fmt.formatNullable(input.name)),
          KeyValueRow(label: 'Descriptor', value: Fmt.formatNullable(input.descriptor)),
          KeyValueRow(label: 'External', value: input.isExternal ? 'Yes' : 'No'),
          KeyValueRow(label: 'VID', value: Fmt.decAndHex16(s.vendorId)),
          KeyValueRow(label: 'PID', value: Fmt.decAndHex16(s.productId)),
          KeyValueRow(label: 'Sources', value: input.sources.isEmpty ? 'Unknown' : input.sources.join(', ')),
          KeyValueRow(label: 'Keyboard type', value: '${input.keyboardType}'),
          KeyValueRow(label: 'Motion ranges', value: '${input.motionRanges.length}'),
          if (input.motionRanges.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ExpandableBlock(
              title: 'Show motion ranges',
              child: Column(
                children: [
                  for (final r in input.motionRanges.take(16)) ...[
                    KeyValueRow(
                      label: Fmt.axisLabel(r.axis),
                      value: '${r.min.toStringAsFixed(2)} → ${r.max.toStringAsFixed(2)} (res ${r.resolution.toStringAsFixed(2)})',
                    ),
                  ],
                  if (input.motionRanges.length > 16)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Showing first 16 ranges.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
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
    final theme = Theme.of(context);
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
          KeyValueRow(
            label: 'Device status',
            value: rawStatus == null
                ? 'Unknown'
                : '${Fmt.decAndHex16(rawStatus is int ? rawStatus : int.tryParse('$rawStatus') ?? 0)}',
          ),
          KeyValueRow(label: 'Self-powered', value: selfPowered == null ? 'Unknown' : (selfPowered == true ? 'Yes' : 'No')),
          KeyValueRow(label: 'Remote wakeup', value: remoteWake == null ? 'Unknown' : (remoteWake == true ? 'Yes' : 'No')),
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
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);

    final langs = _asList(strings['languageIds']).map((e) => _asInt(e)).whereType<int>().toList(growable: false);
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
          if (preferred != null)
            KeyValueRow(
              label: 'Preferred',
              value: Fmt.hex16(preferred),
            ),
          if (dev.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Device strings', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            KeyValueRow(label: 'Manufacturer', value: Fmt.formatNullable(dev['manufacturer'] as String?)),
            KeyValueRow(label: 'Product', value: Fmt.formatNullable(dev['product'] as String?)),
            KeyValueRow(label: 'Serial', value: Fmt.formatNullable(dev['serial'] as String?)),
          ],
          if (ifs.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ExpandableBlock(
              title: 'Interface strings',
              child: Column(
                children: [
                  for (final it in ifs.take(48)) ...[
                    KeyValueRow(
                      label: 'IF ${_asInt(_asMap(it)['interfaceNumber']) ?? '?'} (Alt ${_asInt(_asMap(it)['alternateSetting']) ?? 0})',
                      value: (_asMap(it)['value'] as String?)?.trim().isEmpty ?? true ? 'Unknown' : (_asMap(it)['value'] as String),
                    ),
                  ],
                  if (ifs.length > 48)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing first 48 interface strings.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);
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
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _advancedHidReportsSection(BuildContext context, List<dynamic> reports) {
    final theme = Theme.of(context);
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

  String _joinNameAndIds(String? name, int id) {
    final n = (name == null || name.trim().isEmpty) ? 'Unknown' : name;
    return '$n (${Fmt.decAndHex8(id)})';
  }
}

class _PermissionBanner extends ConsumerWidget {
  static const EventChannel _events = EventChannel('usbdevinfo/events');
  static const MethodChannel _methods = MethodChannel('usbdevinfo/methods');

  const _PermissionBanner({required this.deviceName, required this.vendorId, required this.productId});
  final int vendorId;
  final int productId;

  static Stream<Map<String, dynamic>> _eventStream() => _events.receiveBroadcastStream().map((e) {
        if (e is Map) return e.cast<String, dynamic>();
        return <String, dynamic>{};
      });
  final String deviceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = _eventStream();
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
                    'Permission required',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'To read strings (manufacturer/product/serial), parse raw descriptors, and fetch HID report descriptors, Android requires per-device permission.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
            ),
            const SizedBox(height: 12),
            StreamBuilder<Map<String, dynamic>>(
              stream: events,
              builder: (context, snapshot) {
                final data = snapshot.data ?? const {};
                final type = (data['type'] as String?) ?? '';
                final instanceChanged = type == 'permission_instance_changed' && (data['originalName'] == deviceName);
                final timeoutFailed = type == 'permission_timeout_failed';
                final showHint = instanceChanged || timeoutFailed;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (showHint) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          instanceChanged
                              ? 'The device reconnected as a new instance. Please grant permission again.'
                              : 'Permission broadcast was missed. Retrying can help after the device stabilizes.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () async {
                          // Ensure Android runtime mic permission for USB Audio devices
                          try { await _methods.invokeMethod('requestRecordAudioPermission'); } catch (_) {}
                          await Future.delayed(const Duration(milliseconds: 50));
                  await ref.read(usbIdsDbProvider.future);
                  final repo = ref.read(usbRepositoryProvider);
                  final ok = await repo.requestPermission(deviceName, vendorId: vendorId, productId: productId);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Permission granted' : 'Permission not granted')),
                  );
                  if (ok) {
                    ref.invalidate(deviceDetailControllerProvider(deviceName));
                    ref.invalidate(deviceDetailRawControllerProvider(deviceName));
                  }
                },
                        icon: const Icon(Icons.vpn_key_rounded),
                        label: const Text('Grant permission'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigBlock extends StatelessWidget {
  const _ConfigBlock({required this.cfg, required this.index});
  final UsbConfigurationInfo cfg;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attrsHex = Fmt.decAndHex8(cfg.attributes);
    final attrsLabel = Fmt.usbConfigAttributesLabel(cfg.attributes);
    final maxPower = cfg.maxPowerMa == null ? 'Unknown' : '${cfg.maxPowerMa} mA';
    return _ExpandableBlock(
      title: 'Configuration ${cfg.id}${(cfg.name?.trim().isNotEmpty ?? false) ? ' — ${cfg.name}' : ''}',
      initiallyExpanded: index == 0,
      child: Column(
        children: [
          KeyValueRow(label: 'Name', value: Fmt.formatNullable(cfg.name)),
          KeyValueRow(label: 'Attributes', value: '$attrsHex • $attrsLabel'),
          KeyValueRow(label: 'Max power', value: maxPower),
          KeyValueRow(label: 'Interfaces', value: '${cfg.interfaceCount}'),
          if (cfg.interfaces.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Interfaces (summary)',
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            for (final i in cfg.interfaces.take(8)) ...[
              KeyValueRow(
                label: 'IF ${i.id}',
                value: 'Class ${Fmt.decAndHex8(i.interfaceClass)} • EP ${i.endpointCount}',
                allowCopy: false,
              ),
            ],
            if (cfg.interfaces.length > 8)
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
  final UsbInterfaceInfo iface;
  final ({String? className, String? subclassName, String? protocolName})? resolved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classId = iface.interfaceClass;
    final subclassId = iface.interfaceSubclass;
    final protocolId = iface.interfaceProtocol;
    final className = resolved?.className;
    final subclassName = resolved?.subclassName;
    final protocolName = resolved?.protocolName;

    String join(String? n, int id) => '${(n == null || n.trim().isEmpty) ? 'Unknown' : n} (${Fmt.decAndHex8(id)})';

    return _ExpandableBlock(
      title: 'Interface ${iface.id} • ${join(className, classId)}',
      initiallyExpanded: index == 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (iface.name != null && iface.name!.trim().isNotEmpty) KeyValueRow(label: 'Name', value: iface.name!),
          KeyValueRow(label: 'Alt setting', value: '${iface.alternateSetting}'),
          KeyValueRow(label: 'Class', value: join(className, classId)),
          KeyValueRow(label: 'Subclass', value: join(subclassName, subclassId)),
          KeyValueRow(label: 'Protocol', value: join(protocolName, protocolId)),
          const SizedBox(height: 10),
          Text('Endpoints (${iface.endpointCount})', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          if (iface.endpoints.isEmpty)
            Text('No endpoints', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))
          else
            Column(
              children: [
                for (final ep in iface.endpoints) ...[
                  _EndpointTile(ep: ep),
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
  final UsbEndpointInfo ep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dir = ep.direction;
    final type = ep.type;
    IconData icon;
    if (type.toLowerCase().contains('interrupt')) {
      icon = Icons.flash_on_rounded;
    } else if (type.toLowerCase().contains('bulk')) {
      icon = Icons.swap_horiz_rounded;
    } else if (type.toLowerCase().contains('isochronous')) {
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
                  Text('$type • $dir', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Addr ${Fmt.decAndHex8(ep.address)} • EP# ${ep.number} • Attr ${Fmt.decAndHex8(ep.attributes)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('MaxPkt ${ep.maxPacketSize}', style: theme.textTheme.labelMedium),
                Text('Interval ${ep.interval}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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

    final rawHex = (node['rawHex'] as String?) ?? '';

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
            if (rawHex.isNotEmpty) ...[
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
    final usagePages = _asList(summary['usagePages']).map((e) => _asInt(e)).whereType<int>().toList(growable: false);
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
