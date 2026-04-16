import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/key_value_row.dart';
import '../../core/widgets/section_card.dart';
import '../../data/usb/models.dart';
import '../../data/usb/providers.dart';
import '../../data/usb/usb_repository.dart';
import '../history/controllers/device_history_controller.dart';
import '../history/models/device_history_entry.dart';
import 'controllers/device_detail_controller.dart';
import 'permission_state_logic.dart';

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
  bool _microphonePermissionWasGranted = false;
  bool _cameraPermissionWasGranted = false;

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
    final exportView = async.asData?.value;
    final exportRaw = rawAsync.asData?.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.deviceInfoTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.deviceAdvancedRawViewTooltip,
            onPressed: exportView == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _AdvancedRawViewScreen(
                          view: exportView,
                          raw: exportRaw,
                        ),
                      ),
                    ),
            icon: const Icon(Icons.developer_mode_rounded),
          ),
          IconButton(
            tooltip: context.l10n.deviceExportRawDumpTooltip,
            onPressed: exportView == null
                ? null
                : () => _showRawDumpExportSheet(
                      context,
                      view: exportView,
                      raw: exportRaw,
                    ),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
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
        Text(context.l10n.deviceUnableToReadDetails, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(error),
      ],
    );
  }
}

class _DeviceDetailBody extends ConsumerStatefulWidget {
  const _DeviceDetailBody({required this.view, required this.raw});
  final UsbDeviceDetailViewData view;
  final Map<String, dynamic>? raw;

  @override
  ConsumerState<_DeviceDetailBody> createState() => _DeviceDetailBodyState();
}

class _DeviceDetailBodyState extends ConsumerState<_DeviceDetailBody> {
  bool _microphonePermissionWasGranted = false;
  bool _cameraPermissionWasGranted = false;

  UsbDeviceDetailViewData get view => widget.view;
  Map<String, dynamic>? get raw => widget.raw;

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    final raw = widget.raw;
    final s = view.details.summary;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final title = view.productName ?? s.productName ?? (s.isInputDevice ? l10n.homeInputDeviceLabel : l10n.homeUsbDeviceLabel);
    final subtitle = view.vendorName ?? s.manufacturerName ?? l10n.homeUnknownVendor;

    final isInput = s.isInputDevice;
    final needsPermission = !isInput && !s.isHiddenDevice && !s.hasPermission;
    final isAudio = _hasUsbClass(s, view.details.interfaces, 1);
    final isVideo = _hasUsbClass(s, view.details.interfaces, 14);

    final tree = _asList(raw?['descriptorTree']);
    final strings = _asMap(raw?['strings']);
    final hidReports = _asList(raw?['hidReports']);
    final deviceState = _asMap(raw?['deviceState']);
    final audio = _asMap(raw?['audio']);
    final midi = _asMap(raw?['midi']);
    final topology = _asMap(raw?['topology']);
    final availabilityIssues = _asList(raw?['availabilityIssues'])
        .map(_asMap)
        .where((issue) => issue.isNotEmpty)
        .toList(growable: false);
    final frameworkLimitations = _collectFrameworkLimitations(
      summary: s,
      availabilityIssues: availabilityIssues,
      audio: audio,
      midi: midi,
    );
    final classSections = _buildClassDescriptorSections(tree);

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
    final hasAudio = audio.isNotEmpty && (audio['isUsbAudioClass'] == true || _asList(audio['matchedEndpoints']).isNotEmpty);
    final hasMidi = midi.isNotEmpty && (midi['probableUsbMidi'] == true || _asList(midi['matchedDevices']).isNotEmpty);
    final needsMicrophonePermission = deviceNeedsMicrophonePermission(
      isAudioClass: isAudio,
      audio: audio,
    );
    final diagnosticsArgs = (
      deviceName: s.deviceName,
      vendorId: s.vendorId,
      productId: s.productId,
      isAudioClass: isAudio,
      needsMicrophonePermission: needsMicrophonePermission,
      isVideo: isVideo,
      isInputDevice: s.isInputDevice,
      isHiddenDevice: s.isHiddenDevice,
      deviceClass: s.deviceClass,
      hasUsbPermission: s.hasPermission,
    );
    final diagnosticsAsync = ref.watch(runtimePermissionDiagnosticsProvider(diagnosticsArgs));
    final diagnostics = diagnosticsAsync.asData?.value ?? const <String, dynamic>{};
    if (runtimePermissionIsGranted(_asMap(diagnostics['microphone']))) {
      _microphonePermissionWasGranted = true;
    }
    if (runtimePermissionIsGranted(_asMap(diagnostics['camera']))) {
      _cameraPermissionWasGranted = true;
    }
    final historyItems = ref.watch(deviceHistoryControllerProvider).asData?.value ?? const <DeviceHistoryEntry>[];
    final historyMatch = _findMatchingHistoryEntry(s, historyItems);

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
        if (needsPermission)
          _PermissionBanner(
            deviceName: s.deviceName,
            vendorId: s.vendorId,
            productId: s.productId,
            serialNumber: s.serialNumber,
            physicalLocationKey: s.physicalLocationKey,
            interfaceFingerprint: s.interfaceFingerprint,
            stableIdentityKey: s.stableIdentityKey,
            needsMicrophonePermission: needsMicrophonePermission,
            isVideo: isVideo,
            diagnosticsArgs: diagnosticsArgs,
            microphoneWasGranted: _microphonePermissionWasGranted,
            cameraWasGranted: _cameraPermissionWasGranted,
          ),
        if (needsPermission) const SizedBox(height: 12),
        _permissionDiagnosticsSection(
          context,
          diagnostics,
          availabilityIssues: availabilityIssues,
          needsMicrophonePermission: needsMicrophonePermission,
          isVideo: isVideo,
          microphoneWasGranted: _microphonePermissionWasGranted,
          cameraWasGranted: _cameraPermissionWasGranted,
        ),
        const SizedBox(height: 12),
        if (frameworkLimitations.isNotEmpty) ...[
          _frameworkLimitationsSection(context, frameworkLimitations),
          const SizedBox(height: 12),
        ],
        _identitySection(context, historyMatch),
        const SizedBox(height: 12),
        if (historyMatch != null && _hasReconnectBaseline(historyMatch)) ...[
          _reconnectDiffSection(context, historyMatch),
          const SizedBox(height: 12),
        ],
        _usbSpecSection(context),
        const SizedBox(height: 12),
        _locationSection(context),
        const SizedBox(height: 12),
        if (topology.isNotEmpty) ...[
          _topologySection(context, topology),
          const SizedBox(height: 12),
        ],
        if (!isInput) ...[
          if (hasAudio) ...[
            _audioSection(context, audio),
            const SizedBox(height: 12),
          ],
          if (hasMidi) ...[
            _midiSection(context, midi),
            const SizedBox(height: 12),
          ],
          _descriptorSection(context),
          const SizedBox(height: 12),
          _powerSection(context),
          const SizedBox(height: 12),
          _configurationsSection(context),
          const SizedBox(height: 12),
          _interfacesSection(context),
          if (classSections.audio.isNotEmpty) ...[
            const SizedBox(height: 12),
            _classDescriptorSection(
              context,
              title: l10n.deviceAudioClassDescriptorsTitle,
              subtitle: l10n.deviceDescriptorsCount(classSections.audio.length),
              icon: Icons.headset_rounded,
              descriptors: classSections.audio,
            ),
          ],
          if (classSections.video.isNotEmpty) ...[
            const SizedBox(height: 12),
            _classDescriptorSection(
              context,
              title: l10n.deviceVideoClassDescriptorsTitle,
              subtitle: l10n.deviceDescriptorsCount(classSections.video.length),
              icon: Icons.videocam_rounded,
              descriptors: classSections.video,
            ),
          ],
          if (classSections.cdc.isNotEmpty) ...[
            const SizedBox(height: 12),
            _classDescriptorSection(
              context,
              title: l10n.deviceCdcSerialDescriptorsTitle,
              subtitle: l10n.deviceDescriptorsCount(classSections.cdc.length),
              icon: Icons.settings_ethernet_rounded,
              descriptors: classSections.cdc,
            ),
          ],
          if (classSections.hub.isNotEmpty) ...[
            const SizedBox(height: 12),
            _classDescriptorSection(
              context,
              title: l10n.deviceHubDescriptorsTitle,
              subtitle: l10n.deviceDescriptorsCount(classSections.hub.length),
              icon: Icons.hub_rounded,
              descriptors: classSections.hub,
            ),
          ],
          if (classSections.bos.isNotEmpty) ...[
            const SizedBox(height: 12),
            _classDescriptorSection(
              context,
              title: l10n.deviceBosCapabilitiesTitle,
              subtitle: l10n.deviceDescriptorsCount(classSections.bos.length),
              icon: Icons.extension_rounded,
              descriptors: classSections.bos,
            ),
          ],
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

  Widget _identitySection(BuildContext context, DeviceHistoryEntry? historyMatch) {
    final l10n = context.l10n;
    final s = view.details.summary;
    final vendor = view.vendorName ?? s.manufacturerName;
    final product = view.productName ?? s.productName;
    final stableIdentityKey = (s.stableIdentityKey ?? '').trim();
    final chipsetFamily = view.chipsetFamily;
    final likelyFunction = view.likelyFunction;
    final knownPaths = <String>[
      ...(historyMatch?.knownDevicePaths ?? const <String>[]),
      s.deviceName,
    ].where((p) => p.trim().isNotEmpty).toSet().toList(growable: false);
    final previousPaths = knownPaths.where((p) => p != s.deviceName).toList(growable: false);
    return SectionCard(
      title: l10n.deviceIdentityTitle,
      subtitle: l10n.deviceIdentitySubtitle,
      leading: const Icon(Icons.badge_outlined),
      child: Column(
        children: [
          KeyValueRow(label: l10n.deviceVendorIdLabel, value: Fmt.decAndHex16(s.vendorId)),
          KeyValueRow(label: l10n.deviceProductIdLabel, value: Fmt.decAndHex16(s.productId)),
          KeyValueRow(label: l10n.deviceVendorLabel, value: Fmt.formatNullable(vendor)),
          KeyValueRow(label: l10n.deviceProductLabel, value: Fmt.formatNullable(product)),
          KeyValueRow(
            label: l10n.deviceChipsetFamilyLabel,
            value: chipsetFamily == null
                ? l10n.unknown
                : '${chipsetFamily.family} (${chipsetFamily.confidence})',
          ),
          if (chipsetFamily != null)
            KeyValueRow(label: l10n.deviceChipsetBasisLabel, value: chipsetFamily.reason),
          KeyValueRow(
            label: l10n.deviceLikelyFunctionLabel,
            value: likelyFunction == null
                ? l10n.unknown
                : '${likelyFunction.label} (${likelyFunction.confidence})',
          ),
          if (likelyFunction != null)
            KeyValueRow(label: l10n.deviceFunctionBasisLabel, value: likelyFunction.reason),
          KeyValueRow(label: l10n.deviceSerialLabel, value: Fmt.formatNullable(s.serialNumber)),
          KeyValueRow(label: l10n.deviceStableIdentityLabel, value: stableIdentityKey.isEmpty ? l10n.unavailable : stableIdentityKey),
          KeyValueRow(label: l10n.deviceIdentityConfidenceLabel, value: _identityConfidenceLabel(context, s.identityConfidence)),
          KeyValueRow(label: l10n.deviceIdentityStrategyLabel, value: _identityStrategyLabel(context, s.identityStrategy)),
          KeyValueRow(label: l10n.devicePhysicalLocationLabel, value: _formatNullableString(context, s.physicalLocationKey)),
          KeyValueRow(label: l10n.deviceInterfaceFingerprintLabel, value: _formatNullableString(context, s.interfaceFingerprint)),
          KeyValueRow(
            label: l10n.devicePathContinuityLabel,
            value: previousPaths.isEmpty
                ? l10n.deviceNoPreviousPathRecorded
                : l10n.deviceReenumeratedAcrossPaths(previousPaths.length + 1),
          ),
          if (previousPaths.isNotEmpty)
            KeyValueRow(
              label: l10n.devicePreviousPathsLabel,
              value: previousPaths.join('\n'),
            ),
        ],
      ),
    );
  }

  Widget _usbSpecSection(BuildContext context) {
    final l10n = context.l10n;
    final s = view.details.summary;
    return SectionCard(
      title: l10n.deviceUsbSpecificationTitle,
      subtitle: l10n.deviceUsbSpecificationSubtitle,
      leading: const Icon(Icons.tune_rounded),
      child: Column(
        children: [
          KeyValueRow(label: l10n.deviceUsbVersionLabel, value: Fmt.formatNullable(s.usbVersion)),
          KeyValueRow(label: l10n.deviceSpeedLabel, value: Fmt.speedLabel(s.speed)),
          KeyValueRow(label: l10n.deviceDeviceClassLabel, value: _joinNameAndIds(context, view.deviceClassName, s.deviceClass)),
          KeyValueRow(label: l10n.deviceSubclassLabel, value: _joinNameAndIds(context, view.deviceSubclassName, s.deviceSubclass)),
          KeyValueRow(label: l10n.deviceProtocolLabel, value: _joinNameAndIds(context, view.deviceProtocolName, s.deviceProtocol)),
          KeyValueRow(label: l10n.deviceInterfacesLabel, value: '${s.interfaceCount}'),
          KeyValueRow(label: l10n.deviceConfigurationsLabel, value: '${s.configurationCount}'),
        ],
      ),
    );
  }

  Widget _locationSection(BuildContext context) {
    final l10n = context.l10n;
    final s = view.details.summary;
    return SectionCard(
      title: l10n.deviceLocationTitle,
      subtitle: l10n.deviceLocationSubtitle,
      leading: const Icon(Icons.pin_drop_outlined),
      child: Column(
        children: [
          KeyValueRow(label: l10n.devicePathLabel, value: s.deviceName),
          KeyValueRow(label: l10n.deviceAndroidDeviceIdLabel, value: s.deviceId == null ? l10n.unknown : '${s.deviceId}'),
          KeyValueRow(label: l10n.devicePortNumberLabel, value: s.portNumber == null ? l10n.unknown : '${s.portNumber}'),
          KeyValueRow(
            label: l10n.deviceTypeLabel,
            value: s.isInputDevice
                ? l10n.deviceTypeInputManager
                : s.isHiddenDevice
                    ? l10n.deviceTypeSysfs
                    : l10n.deviceTypeUsbManager,
            allowCopy: false,
          ),
        ],
      ),
    );
  }

  Widget _topologySection(BuildContext context, Map<String, dynamic> topology) {
    final l10n = context.l10n;
    final children = _asList(topology['children']).whereType<String>().toList(growable: false);
    final siblings = _asList(topology['siblings']).whereType<String>().toList(growable: false);
    final portChain = _asList(topology['portChain']).map(_asInt).whereType<int>().toList(growable: false);
    final busNumber = _asInt(topology['busNumber']);
    final treeDepth = _asInt(topology['treeDepth']);
    final upstreamHub = topology['upstreamHub'] as String?;
    final portChainLabel = portChain.isEmpty ? l10n.unknown : portChain.join(' → ');
    final topologyPath = _buildTopologyPath(busNumber, portChain);
    return SectionCard(
      title: l10n.deviceTopologyTitle,
      subtitle: l10n.deviceTopologySubtitle,
      leading: const Icon(Icons.account_tree_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(label: l10n.deviceSourceLabel, value: _formatNullableString(context, topology['source'] as String?)),
          KeyValueRow(label: l10n.deviceSysfsNameLabel, value: _formatNullableString(context, topology['sysfsName'] as String?)),
          KeyValueRow(label: l10n.deviceSysfsPathLabel, value: _formatNullableString(context, topology['sysfsPath'] as String?)),
          KeyValueRow(label: l10n.deviceDeviceNodeLabel, value: _formatNullableString(context, topology['devPath'] as String?)),
          KeyValueRow(label: l10n.deviceParentLabel, value: _formatNullableString(context, topology['parentSysfsName'] as String?)),
          KeyValueRow(label: l10n.deviceUpstreamHubLabel, value: _formatNullableString(context, upstreamHub)),
          KeyValueRow(label: l10n.deviceBusNumberLabel, value: _asInt(topology['busNumber'])?.toString() ?? l10n.unknown),
          KeyValueRow(label: l10n.deviceDeviceNumberLabel, value: _asInt(topology['deviceNumber'])?.toString() ?? l10n.unknown),
          KeyValueRow(label: l10n.deviceTreeDepthLabel, value: treeDepth?.toString() ?? l10n.unknown),
          KeyValueRow(label: l10n.devicePortChainLabel, value: portChainLabel),
          KeyValueRow(label: l10n.deviceDevpathLabel, value: _formatNullableString(context, topology['devpath'] as String?)),
          KeyValueRow(label: l10n.deviceAuthorizedLabel, value: _asInt(topology['authorized'])?.toString() ?? l10n.unknown),
          KeyValueRow(label: l10n.deviceRemovableLabel, value: _formatNullableString(context, topology['removable'] as String?)),
          KeyValueRow(label: l10n.deviceMaxChildLabel, value: _asInt(topology['maxChild'])?.toString() ?? l10n.unknown),
          if (topologyPath != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.devicePathShortLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            _TopologyPath(path: topologyPath),
          ],
          if (siblings.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TopologyList(title: l10n.deviceSiblingDevicesTitle, values: siblings),
          ],
          if (children.isNotEmpty)
            ...[
              const SizedBox(height: 12),
              _TopologyList(title: l10n.deviceDownstreamChildrenTitle, values: children),
            ],
        ],
      ),
    );
  }

  Widget _descriptorSection(BuildContext context) {
    final l10n = context.l10n;
    final d = view.details.deviceDescriptor;
    final theme = Theme.of(context);
    if (d == null) return const SizedBox.shrink();
    return SectionCard(
      title: l10n.deviceDescriptorTitle,
      subtitle: l10n.deviceDescriptorSubtitle,
      leading: const Icon(Icons.article_outlined),
      child: _ExpandableBlock(
        title: l10n.deviceShowDescriptorFields,
        initiallyExpanded: true,
        child: Column(
          children: [
            KeyValueRow(label: l10n.deviceUsbSpecBcdLabel, value: d.usbVersion ?? l10n.unknown),
            KeyValueRow(label: l10n.deviceReleaseBcdLabel, value: d.deviceRelease ?? l10n.unknown),
            KeyValueRow(label: l10n.deviceEp0MaxPacketLabel, value: d.maxPacketSize0 == null ? l10n.unknown : '${d.maxPacketSize0}'),
            KeyValueRow(label: l10n.deviceNumConfigurationsLabel, value: d.numConfigurations == null ? l10n.unknown : '${d.numConfigurations}'),
            KeyValueRow(label: l10n.deviceIManufacturerLabel, value: d.iManufacturer == null ? l10n.unknown : '${d.iManufacturer}'),
            KeyValueRow(label: l10n.deviceIProductLabel, value: d.iProduct == null ? l10n.unknown : '${d.iProduct}'),
            KeyValueRow(label: l10n.deviceISerialNumberLabel, value: d.iSerialNumber == null ? l10n.unknown : '${d.iSerialNumber}'),
          ],
        ),
      ),
    );
  }

  Widget _audioSection(BuildContext context, Map<String, dynamic> audio) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final matched = _asList(audio['matchedEndpoints']);
    final connectedCount = _asInt(audio['connectedUsbAudioEndpointCount']) ?? matched.length;
    final matchedCount = _asInt(audio['matchedEndpointCount']) ?? matched.length;
    final platformAvailable = audio['platformAvailable'] != false;
    final isUsbAudioClass = audio['isUsbAudioClass'] == true;
    final availabilityNote = (audio['availabilityNote'] as String?)?.trim();
    return SectionCard(
      title: l10n.deviceUsbAudioTitle,
      subtitle: l10n.deviceUsbAudioSubtitle,
      leading: const Icon(Icons.headset_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(label: l10n.deviceUsbAudioClassLabel, value: _yesNoLabel(context, isUsbAudioClass)),
          KeyValueRow(label: l10n.devicePlatformAudioApiLabel, value: platformAvailable ? l10n.deviceAvailable : l10n.unavailable),
          KeyValueRow(label: l10n.deviceConnectedUsbAudioEndpointsLabel, value: '$connectedCount'),
          KeyValueRow(label: l10n.deviceMatchedEndpointsLabel, value: '$matchedCount'),
          if (!platformAvailable) ...[
            const SizedBox(height: 8),
            Text(
              availabilityNote?.isNotEmpty == true
                  ? availabilityNote!
                  : l10n.deviceAudioManagerUnavailableNote,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ] else if (matched.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              availabilityNote?.isNotEmpty == true
                  ? availabilityNote!
                  : isUsbAudioClass
                      ? l10n.deviceNoAudioEndpointMatchedNote
                      : l10n.deviceAndroidNoMatchedAudioEndpointNote,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ] else ...[
            const SizedBox(height: 8),
            for (int i = 0; i < matched.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              _AudioEndpointBlock(endpoint: _asMap(matched[i]), index: i),
            ],
          ],
        ],
      ),
    );
  }

  Widget _midiSection(BuildContext context, Map<String, dynamic> midi) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final matched = _asList(midi['matchedDevices']);
    final connectedCount = _asInt(midi['connectedMidiDeviceCount']) ?? matched.length;
    final matchedCount = _asInt(midi['matchedDeviceCount']) ?? matched.length;
    final probable = midi['probableUsbMidi'] == true;
    final platformAvailable = midi['platformAvailable'] != false;
    final availabilityNote = (midi['availabilityNote'] as String?)?.trim();
    return SectionCard(
      title: l10n.deviceUsbMidiTitle,
      subtitle: l10n.deviceUsbMidiSubtitle,
      leading: const Icon(Icons.piano_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(label: l10n.deviceProbableUsbMidiInterfaceLabel, value: _yesNoLabel(context, probable)),
          KeyValueRow(label: l10n.devicePlatformMidiApiLabel, value: platformAvailable ? l10n.deviceAvailable : l10n.unavailable),
          KeyValueRow(label: l10n.deviceConnectedMidiDevicesLabel, value: '$connectedCount'),
          KeyValueRow(label: l10n.deviceMatchedMidiDevicesLabel, value: '$matchedCount'),
          if (!platformAvailable) ...[
            const SizedBox(height: 8),
            Text(
              availabilityNote?.isNotEmpty == true
                  ? availabilityNote!
                  : l10n.deviceMidiManagerUnavailableNote,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ] else if (matched.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              availabilityNote?.isNotEmpty == true
                  ? availabilityNote!
                  : probable
                      ? l10n.deviceDescriptorsLookLikeMidiNote
                      : l10n.deviceAndroidNoMatchedMidiDeviceNote,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ] else ...[
            const SizedBox(height: 8),
            for (int i = 0; i < matched.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              _MidiDeviceBlock(device: _asMap(matched[i]), index: i),
            ],
          ],
        ],
      ),
    );
  }

  Widget _powerSection(BuildContext context) {
    final l10n = context.l10n;
    final s = view.details.summary;
    if (s.maxPowerMa == null) return const SizedBox.shrink();
    return SectionCard(
      title: l10n.devicePowerTitle,
      subtitle: l10n.devicePowerSubtitle,
      leading: const Icon(Icons.bolt_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(label: l10n.deviceMaxPowerConfig0Label, value: '${s.maxPowerMa} mA'),
        ],
      ),
    );
  }

  Widget _configurationsSection(BuildContext context) {
    final l10n = context.l10n;
    final cfgs = view.details.configurations;
    if (cfgs.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: l10n.deviceConfigurationsTitle,
      subtitle: l10n.deviceConfigurationsSubtitle,
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
    final l10n = context.l10n;
    final ifaces = view.details.interfaces;
    if (ifaces.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: l10n.deviceInterfacesEndpointsTitle,
      subtitle: l10n.deviceInterfacesEndpointsSubtitle,
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final input = view.details.input;
    final s = view.details.summary;
    if (input == null) return const SizedBox.shrink();
    return SectionCard(
      title: l10n.deviceInputDeviceTitle,
      subtitle: l10n.deviceInputDeviceSubtitle,
      leading: const Icon(Icons.keyboard_alt_outlined),
      child: Column(
        children: [
          KeyValueRow(label: l10n.deviceNameLabel, value: Fmt.formatNullable(input.name)),
          KeyValueRow(label: l10n.deviceDescriptorLabel, value: Fmt.formatNullable(input.descriptor)),
          KeyValueRow(label: l10n.deviceExternalLabel, value: _yesNoLabel(context, input.isExternal)),
          KeyValueRow(label: 'VID', value: Fmt.decAndHex16(s.vendorId)),
          KeyValueRow(label: 'PID', value: Fmt.decAndHex16(s.productId)),
          KeyValueRow(label: l10n.deviceSourcesLabel, value: input.sources.isEmpty ? l10n.unknown : input.sources.join(', ')),
          KeyValueRow(label: l10n.deviceKeyboardTypeLabel, value: '${input.keyboardType}'),
          KeyValueRow(label: l10n.deviceMotionRangesLabel, value: '${input.motionRanges.length}'),
          if (input.motionRanges.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ExpandableBlock(
              title: l10n.deviceShowMotionRanges,
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
                          l10n.deviceShowingFirstRanges(16),
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

  Widget _availabilityIssuesSection(BuildContext context, List<Map<String, dynamic>> issues) {
    final l10n = context.l10n;
    return SectionCard(
      title: l10n.deviceWhyDataUnavailableTitle,
      subtitle: l10n.deviceWhyDataUnavailableSubtitle,
      leading: const Icon(Icons.info_outline_rounded),
      child: Column(
        children: [
          for (int i = 0; i < issues.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            _AvailabilityIssueTile(issue: issues[i]),
          ],
        ],
      ),
    );
  }

  Widget _frameworkLimitationsSection(
    BuildContext context,
    List<_FrameworkLimitation> limitations,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectionCard(
      title: l10n.deviceFrameworkLimitationsTitle,
      subtitle: l10n.deviceFrameworkLimitationsSubtitle,
      leading: const Icon(Icons.visibility_off_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deviceFrameworkLimitationsDetected(limitations.length),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < limitations.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            _FrameworkLimitationTile(limitation: limitations[i]),
          ],
        ],
      ),
    );
  }

  Widget _permissionDiagnosticsSection(
    BuildContext context,
    Map<String, dynamic> diagnostics, {
    required List<Map<String, dynamic>> availabilityIssues,
    required bool needsMicrophonePermission,
    required bool isVideo,
    required bool microphoneWasGranted,
    required bool cameraWasGranted,
  }) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (diagnostics.isEmpty) {
      return SectionCard(
        title: l10n.devicePermissionDiagnosticsTitle,
        subtitle: l10n.devicePermissionDiagnosticsSubtitle,
        leading: const Icon(Icons.admin_panel_settings_rounded),
        child: Text(
          l10n.deviceLoadingDiagnostics,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }
    final device = _asMap(diagnostics['device']);
    final usb = _asMap(diagnostics['usb']);
    final android = _asMap(diagnostics['android']);
    final lastFailure = _asMap(diagnostics['lastFailure']);
    final statuses = buildPermissionDiagnosticStatuses(
      diagnostics: diagnostics,
      needsMicrophonePermission: needsMicrophonePermission,
      isVideo: isVideo,
      microphoneWasGranted: microphoneWasGranted,
      cameraWasGranted: cameraWasGranted,
    );
    final behaviorNotes = _stringList(android['behaviorNotes']);
    final lastFailureReason = (lastFailure['reasonCode'] as String?)?.trim();
    final lastFailureMessage = (lastFailure['message'] as String?)?.trim();
    final lastFailureTime = _asInt(lastFailure['timestampMs']);
    final diagnosticsTitle = availabilityIssues.isEmpty
        ? l10n.deviceShowPermissionDiagnostics
        : l10n.deviceShowPermissionDiagnosticsWithUnavailableData(availabilityIssues.length);

    return SectionCard(
      title: l10n.devicePermissionDiagnosticsTitle,
      subtitle: l10n.devicePermissionDiagnosticsSubtitle,
      leading: const Icon(Icons.admin_panel_settings_rounded),
      child: _ExpandableBlock(
        title: diagnosticsTitle,
        initiallyExpanded: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < statuses.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _PermissionStateRow(status: statuses[i]),
            ],
            const SizedBox(height: 12),
            KeyValueRow(
              label: l10n.deviceDeviceClassLabel,
              value: _formatNullableString(context, device['deviceClassLabel'] as String?),
            ),
            KeyValueRow(
              label: l10n.deviceAndroidVersionLabel,
              value: l10n.deviceAndroidVersionValue(
                _asInt(android['sdkInt'])?.toString() ?? '?',
                _formatNullableString(context, android['release'] as String?),
              ),
            ),
            KeyValueRow(
              label: l10n.deviceUsbDetailLabel,
              value: _formatNullableString(context, usb['detail'] as String?),
            ),
            KeyValueRow(
              label: l10n.deviceMicrophoneManifestLabel,
              value: _manifestStatusLabel(context, _asMap(diagnostics['microphone'])['manifestStatus'] as String?),
            ),
            KeyValueRow(
              label: l10n.deviceMicrophoneRuntimeLabel,
              value: _runtimeStatusLabel(context, _asMap(diagnostics['microphone'])['runtimeStatus'] as String?),
            ),
            KeyValueRow(
              label: l10n.deviceCameraManifestLabel,
              value: _manifestStatusLabel(context, _asMap(diagnostics['camera'])['manifestStatus'] as String?),
            ),
            KeyValueRow(
              label: l10n.deviceCameraRuntimeLabel,
              value: _runtimeStatusLabel(context, _asMap(diagnostics['camera'])['runtimeStatus'] as String?),
            ),
            if (behaviorNotes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l10n.deviceAndroidBehaviorLabel,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              for (final note in behaviorNotes) ...[
                Text(
                  '• $note',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
              ],
            ],
            const SizedBox(height: 8),
            KeyValueRow(
              label: l10n.deviceLastFailureReasonLabel,
              value: lastFailureReason?.isNotEmpty == true ? lastFailureReason! : l10n.deviceNoneRecorded,
            ),
            if (lastFailureMessage?.isNotEmpty == true)
              KeyValueRow(
                label: l10n.deviceLastFailureDetailLabel,
                value: lastFailureMessage!,
              ),
            if (lastFailureTime != null && lastFailureTime > 0)
              KeyValueRow(
                label: l10n.deviceLastFailureTimeLabel,
                value: _formatTimestamp(lastFailureTime),
              ),
            if (availabilityIssues.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.deviceWhyDataUnavailableTitle,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < availabilityIssues.length; i++) ...[
                if (i > 0) const Divider(height: 24),
                _AvailabilityIssueTile(issue: availabilityIssues[i]),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _reconnectDiffSection(BuildContext context, DeviceHistoryEntry historyMatch) {
    final baseline = _asMap(historyMatch.previousSnapshot);
    if (baseline.isEmpty) return const SizedBox.shrink();

    final fields = _buildReconnectDiffFields(context, view, baseline);
    final changedFields = fields.where((field) => field.changed).toList(growable: false);
    final baselineTime = DateTime.tryParse((baseline['testedAt'] as String?) ?? '');
    final baselineLabel = _reconnectBaselineLabel(context, baselineTime);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SectionCard(
      title: l10n.deviceReconnectDiffTitle,
      subtitle: l10n.deviceReconnectDiffSubtitle,
      leading: const Icon(Icons.compare_arrows_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            changedFields.isEmpty
                ? l10n.deviceNoDifferencesDetected(baselineLabel)
                : l10n.deviceChangesDetectedCompared(changedFields.length, baselineLabel),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (changedFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (int i = 0; i < changedFields.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              _ReconnectDiffTile(field: changedFields[i]),
            ],
          ],
        ],
      ),
    );
  }

  Widget _classDescriptorSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<_ClassDescriptorView> descriptors,
  }) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return SectionCard(
      title: title,
      subtitle: subtitle,
      leading: Icon(icon),
      child: Column(
        children: [
          for (int i = 0; i < descriptors.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            _ExpandableBlock(
              title: descriptors[i].title,
              initiallyExpanded: i == 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (descriptors[i].summary != null) ...[
                    Text(
                      descriptors[i].summary!,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (descriptors[i].fields.isNotEmpty) ...[
                    for (final entry in descriptors[i].fields.entries.take(12))
                      KeyValueRow(label: entry.key, value: _formatAny(entry.value)),
                    if (descriptors[i].fields.length > 12)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.deviceShowingFirstFields(12),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  _DescriptorNodeTile(node: descriptors[i].node),
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
    final l10n = context.l10n;
    final activeCfg = state['activeConfiguration'];
    final status = _asMap(state['deviceStatus']);
    final ifAlt = _asList(state['interfaceAltSettings']);
    if (activeCfg == null && status.isEmpty && ifAlt.isEmpty) return const SizedBox.shrink();

    final selfPowered = status['selfPowered'];
    final remoteWake = status['remoteWakeup'];
    final rawStatus = status['raw'];

    return SectionCard(
      title: l10n.deviceStateTitle,
      subtitle: l10n.deviceStateSubtitle,
      leading: const Icon(Icons.memory_rounded),
      child: Column(
        children: [
          KeyValueRow(label: l10n.deviceActiveConfigurationLabel, value: activeCfg == null ? l10n.unknown : '$activeCfg'),
          KeyValueRow(
            label: l10n.deviceStatusLabel,
            value: rawStatus == null
                ? l10n.unknown
                : '${Fmt.decAndHex16(rawStatus is int ? rawStatus : int.tryParse('$rawStatus') ?? 0)}',
          ),
          KeyValueRow(label: l10n.deviceSelfPoweredLabel, value: selfPowered == null ? l10n.unknown : _yesNoLabel(context, selfPowered == true)),
          KeyValueRow(label: l10n.deviceRemoteWakeupLabel, value: remoteWake == null ? l10n.unknown : _yesNoLabel(context, remoteWake == true)),
          if (ifAlt.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ExpandableBlock(
              title: l10n.deviceInterfaceAlternateSettingsTitle,
              child: Column(
                children: [
                  for (final it in ifAlt.take(32)) ...[
                    KeyValueRow(
                      label: 'IF ${_asInt(_asMap(it)['interfaceNumber']) ?? '?'}',
                      value: l10n.deviceAltSettingValue(_asInt(_asMap(it)['alternateSetting'])?.toString() ?? l10n.unknown),
                      allowCopy: false,
                    ),
                  ],
                  if (ifAlt.length > 32)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.deviceShowingFirstInterfaces(32),
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
    final l10n = context.l10n;

    final langs = _asList(strings['languageIds']).map((e) => _asInt(e)).whereType<int>().toList(growable: false);
    final preferred = _asInt(strings['preferredLanguageId']);
    final dev = _asMap(strings['device']);
    final ifs = _asList(strings['interfaces']);

    if (langs.isEmpty && dev.isEmpty && ifs.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: l10n.deviceStringDescriptorsTitle,
      subtitle: l10n.deviceStringDescriptorsSubtitle,
      leading: const Icon(Icons.translate_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (langs.isNotEmpty)
            KeyValueRow(
              label: l10n.deviceLanguagesLabel,
              value: langs.map(Fmt.hex16).join(', '),
            ),
          if (preferred != null)
            KeyValueRow(
              label: l10n.devicePreferredLabel,
              value: Fmt.hex16(preferred),
            ),
          if (dev.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(l10n.deviceDeviceStringsTitle, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            KeyValueRow(label: l10n.deviceManufacturerLabel, value: Fmt.formatNullable(dev['manufacturer'] as String?)),
            KeyValueRow(label: l10n.deviceProductLabel, value: Fmt.formatNullable(dev['product'] as String?)),
            KeyValueRow(label: l10n.deviceSerialLabel, value: Fmt.formatNullable(dev['serial'] as String?)),
          ],
          if (ifs.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ExpandableBlock(
              title: l10n.deviceInterfaceStringsTitle,
              child: Column(
                children: [
                  for (final it in ifs.take(48)) ...[
                    KeyValueRow(
                      label: 'IF ${_asInt(_asMap(it)['interfaceNumber']) ?? '?'} (Alt ${_asInt(_asMap(it)['alternateSetting']) ?? 0})',
                      value: (_asMap(it)['value'] as String?)?.trim().isEmpty ?? true ? l10n.unknown : (_asMap(it)['value'] as String),
                    ),
                  ],
                  if (ifs.length > 48)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.deviceShowingFirstInterfaceStrings(48),
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
    final l10n = context.l10n;
    if (tree.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: l10n.deviceDescriptorTreeTitle,
      subtitle: l10n.deviceDescriptorsParsed(tree.length),
      leading: const Icon(Icons.schema_rounded),
      child: _ExpandableBlock(
        title: l10n.deviceShowDescriptors,
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
                  l10n.deviceShowingFirstDescriptors(64),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _advancedHidReportsSection(BuildContext context, List<dynamic> reports) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (reports.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: l10n.deviceHidReportDescriptorsTitle,
      subtitle: l10n.deviceInterfacesCount(reports.length),
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

  String _joinNameAndIds(BuildContext context, String? name, int id) {
    final n = (name == null || name.trim().isEmpty) ? context.l10n.unknown : name;
    return '$n (${Fmt.decAndHex8(id)})';
  }

  static bool _hasUsbClass(UsbDeviceSummary s, List<UsbInterfaceInfo> ifaces, int targetClass) {
    if (s.deviceClass == targetClass) return true;
    for (final iface in ifaces) {
      if (iface.interfaceClass == targetClass) return true;
    }
    return false;
  }
}

class _PermissionBanner extends ConsumerWidget {
  static const EventChannel _events = EventChannel('usbdevinfo/events');
  static const MethodChannel _methods = MethodChannel('usbdevinfo/methods');

  const _PermissionBanner({
    required this.deviceName,
    required this.vendorId,
    required this.productId,
    required this.serialNumber,
    required this.physicalLocationKey,
    required this.interfaceFingerprint,
    required this.stableIdentityKey,
    required this.needsMicrophonePermission,
    required this.isVideo,
    required this.diagnosticsArgs,
    required this.microphoneWasGranted,
    required this.cameraWasGranted,
  });
  final int vendorId;
  final int productId;
  final String? serialNumber;
  final String? physicalLocationKey;
  final String? interfaceFingerprint;
  final String? stableIdentityKey;
  final bool needsMicrophonePermission;
  final bool isVideo;
  final PermissionDiagnosticsArgs diagnosticsArgs;
  final bool microphoneWasGranted;
  final bool cameraWasGranted;

  static Stream<Map<String, dynamic>> _eventStream() => _events.receiveBroadcastStream().map((e) {
        if (e is Map) return e.cast<String, dynamic>();
        return <String, dynamic>{};
      });
  final String deviceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = _eventStream();
    final runtimeAsync = ref.watch(runtimePermissionDiagnosticsProvider(diagnosticsArgs));
    final theme = Theme.of(context);
    final l10n = context.l10n;
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
                    l10n.devicePermissionRequiredTitle,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.devicePermissionRequiredBody,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
            ),
            const SizedBox(height: 12),
            StreamBuilder<Map<String, dynamic>>(
              stream: events,
              builder: (context, snapshot) {
                final data = snapshot.data ?? const {};
                final statuses = buildPermissionBannerStatuses(
                  runtimeDiagnostics: runtimeAsync.asData?.value ?? const {},
                  event: data,
                  needsMicrophonePermission: needsMicrophonePermission,
                  isVideo: isVideo,
                  microphoneWasGranted: microphoneWasGranted,
                  cameraWasGranted: cameraWasGranted,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final status in statuses) ...[
                      _PermissionStateRow(status: status),
                      const SizedBox(height: 10),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (isVideo) {
                            final cameraOk =
                                (await _methods.invokeMethod<bool>('requestCameraPermission', {
                              'deviceName': deviceName,
                              'vendorId': vendorId,
                              'productId': productId,
                              'deviceClass': diagnosticsArgs.deviceClass,
                            })) ??
                                    false;
                            if (!context.mounted) return;
                            if (!cameraOk) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.deviceCameraPermissionRequiredForUsbVideo),
                                ),
                              );
                              ref.invalidate(runtimePermissionDiagnosticsProvider(diagnosticsArgs));
                              return;
                            }
                            ref.invalidate(runtimePermissionDiagnosticsProvider(diagnosticsArgs));
                          }

                          await ref.read(usbIdsDbProvider.future);
                          final repo = ref.read(usbRepositoryProvider);
                          final ok = await repo.requestPermission(
                            deviceName,
                            vendorId: vendorId,
                            productId: productId,
                            serialNumber: serialNumber,
                            physicalLocationKey: physicalLocationKey,
                            interfaceFingerprint: interfaceFingerprint,
                            stableIdentityKey: stableIdentityKey,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? l10n.homePermissionGranted : l10n.devicePermissionNotGranted)),
                          );
                          ref.invalidate(runtimePermissionDiagnosticsProvider(diagnosticsArgs));
                          if (ok) {
                            ref.invalidate(deviceDetailControllerProvider(deviceName));
                            ref.invalidate(deviceDetailRawControllerProvider(deviceName));
                          }
                        },
                        icon: const Icon(Icons.vpn_key_rounded),
                        label: Text(l10n.deviceGrantPermission),
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

Future<void> _showRawDumpExportSheet(
  BuildContext context, {
  required UsbDeviceDetailViewData view,
  required Map<String, dynamic>? raw,
}) async {
  final payload = _buildDeviceExportPayload(view, raw);
  final prettyJson = const JsonEncoder.withIndent('  ').convert(payload);
  final plainText = _buildDevicePlainTextReport(view, raw);
  final rawHex = _buildRawHexDump(view, raw);

  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => FractionallySizedBox(
      heightFactor: 0.92,
      child: _DeviceRawDumpExportSheet(
        prettyJson: prettyJson,
        plainText: plainText,
        rawHex: rawHex,
      ),
    ),
  );
}

Map<String, dynamic> _buildDeviceExportPayload(
  UsbDeviceDetailViewData view,
  Map<String, dynamic>? raw,
) {
  final s = view.details.summary;
  return <String, dynamic>{
    'schema': 'device_raw_dump_export_v1',
    'exportedAt': DateTime.now().toIso8601String(),
    'resolvedNames': <String, dynamic>{
      'vendorName': view.vendorName,
      'productName': view.productName,
      'chipsetFamily': view.chipsetFamily?.family,
      'chipsetConfidence': view.chipsetFamily?.confidence,
      'chipsetReason': view.chipsetFamily?.reason,
      'likelyFunction': view.likelyFunction?.label,
      'likelyFunctionConfidence': view.likelyFunction?.confidence,
      'likelyFunctionReason': view.likelyFunction?.reason,
      'deviceClassName': view.deviceClassName,
      'deviceSubclassName': view.deviceSubclassName,
      'deviceProtocolName': view.deviceProtocolName,
      'interfaceClassNames': [
        for (final item in view.interfaceClassNames)
          <String, dynamic>{
            'className': item.className,
            'subclassName': item.subclassName,
            'protocolName': item.protocolName,
          },
      ],
    },
    'summary': <String, dynamic>{
      'deviceName': s.deviceName,
      'deviceId': s.deviceId,
      'portNumber': s.portNumber,
      'vendorId': s.vendorId,
      'productId': s.productId,
      'deviceClass': s.deviceClass,
      'deviceSubclass': s.deviceSubclass,
      'deviceProtocol': s.deviceProtocol,
      'interfaceCount': s.interfaceCount,
      'configurationCount': s.configurationCount,
      'hasPermission': s.hasPermission,
      'manufacturerName': s.manufacturerName,
      'productName': s.productName,
      'serialNumber': s.serialNumber,
      'usbVersion': s.usbVersion,
      'speed': s.speed,
      'maxPowerMa': s.maxPowerMa,
      'isInputDevice': s.isInputDevice,
      'isHiddenDevice': s.isHiddenDevice,
      'inputSources': s.inputSources,
      'capabilities': s.capabilities,
      'stableIdentityKey': s.stableIdentityKey,
      'identityConfidence': s.identityConfidence,
      'identityStrategy': s.identityStrategy,
      'physicalLocationKey': s.physicalLocationKey,
      'interfaceFingerprint': s.interfaceFingerprint,
      'continuityKeys': s.continuityKeys,
    },
    'interfaces': [
      for (final iface in view.details.interfaces)
        <String, dynamic>{
          'id': iface.id,
          'alternateSetting': iface.alternateSetting,
          'name': iface.name,
          'interfaceClass': iface.interfaceClass,
          'interfaceSubclass': iface.interfaceSubclass,
          'interfaceProtocol': iface.interfaceProtocol,
          'endpointCount': iface.endpointCount,
          'endpoints': [
            for (final ep in iface.endpoints)
              <String, dynamic>{
                'address': ep.address,
                'direction': ep.direction,
                'type': ep.type,
                'maxPacketSize': ep.maxPacketSize,
                'interval': ep.interval,
                'attributes': ep.attributes,
                'number': ep.number,
              },
          ],
        },
    ],
    'configurations': [
      for (final cfg in view.details.configurations)
        <String, dynamic>{
          'id': cfg.id,
          'name': cfg.name,
          'attributes': cfg.attributes,
          'maxPowerMa': cfg.maxPowerMa,
          'interfaceCount': cfg.interfaceCount,
          'interfaces': [
            for (final iface in cfg.interfaces)
              <String, dynamic>{
                'id': iface.id,
                'alternateSetting': iface.alternateSetting,
                'name': iface.name,
                'interfaceClass': iface.interfaceClass,
                'interfaceSubclass': iface.interfaceSubclass,
                'interfaceProtocol': iface.interfaceProtocol,
                'endpointCount': iface.endpointCount,
              },
          ],
        },
    ],
    'deviceDescriptor': view.details.deviceDescriptor == null
        ? null
        : <String, dynamic>{
            'bcdUsb': view.details.deviceDescriptor!.bcdUsb,
            'usbVersion': view.details.deviceDescriptor!.usbVersion,
            'bcdDevice': view.details.deviceDescriptor!.bcdDevice,
            'deviceRelease': view.details.deviceDescriptor!.deviceRelease,
            'maxPacketSize0': view.details.deviceDescriptor!.maxPacketSize0,
            'numConfigurations': view.details.deviceDescriptor!.numConfigurations,
            'iManufacturer': view.details.deviceDescriptor!.iManufacturer,
            'iProduct': view.details.deviceDescriptor!.iProduct,
            'iSerialNumber': view.details.deviceDescriptor!.iSerialNumber,
          },
    'input': view.details.input == null
        ? null
        : <String, dynamic>{
            'id': view.details.input!.id,
            'name': view.details.input!.name,
            'descriptor': view.details.input!.descriptor,
            'isExternal': view.details.input!.isExternal,
            'vendorId': view.details.input!.vendorId,
            'productId': view.details.input!.productId,
            'sources': view.details.input!.sources,
            'keyboardType': view.details.input!.keyboardType,
            'motionRanges': [
              for (final range in view.details.input!.motionRanges)
                <String, dynamic>{
                  'axis': range.axis,
                  'min': range.min,
                  'max': range.max,
                  'flat': range.flat,
                  'fuzz': range.fuzz,
                  'resolution': range.resolution,
                },
            ],
          },
    'raw': raw ?? <String, dynamic>{},
  };
}

String _buildDevicePlainTextReport(
  UsbDeviceDetailViewData view,
  Map<String, dynamic>? raw,
) {
  final s = view.details.summary;
  final buffer = StringBuffer()
    ..writeln('USBDevInfo Device Report')
    ..writeln('Exported: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('Identity')
    ..writeln('  Device path: ${s.deviceName}')
    ..writeln('  Vendor ID: ${Fmt.hex16(s.vendorId)}')
    ..writeln('  Product ID: ${Fmt.hex16(s.productId)}')
    ..writeln('  Vendor: ${view.vendorName ?? s.manufacturerName ?? 'Unknown'}')
    ..writeln('  Product: ${view.productName ?? s.productName ?? 'Unknown'}')
    ..writeln(
      '  Chipset family: ${view.chipsetFamily == null ? 'Unknown' : '${view.chipsetFamily!.family} (${view.chipsetFamily!.confidence})'}',
    )
    ..writeln(
      '  Likely function: ${view.likelyFunction == null ? 'Unknown' : '${view.likelyFunction!.label} (${view.likelyFunction!.confidence})'}',
    )
    ..writeln('  Serial: ${s.serialNumber ?? 'Unknown'}')
    ..writeln()
    ..writeln('USB')
    ..writeln('  Device class: ${view.deviceClassName ?? 'Unknown'} (${Fmt.decAndHex8(s.deviceClass)})')
    ..writeln('  Subclass: ${view.deviceSubclassName ?? 'Unknown'} (${Fmt.decAndHex8(s.deviceSubclass)})')
    ..writeln('  Protocol: ${view.deviceProtocolName ?? 'Unknown'} (${Fmt.decAndHex8(s.deviceProtocol)})')
    ..writeln('  USB version: ${s.usbVersion ?? 'Unknown'}')
    ..writeln('  Speed: ${s.speed ?? 'Unknown'}')
    ..writeln('  Permission granted: ${s.hasPermission ? 'Yes' : 'No'}')
    ..writeln('  Interfaces: ${s.interfaceCount}')
    ..writeln('  Configurations: ${s.configurationCount}');

  if ((s.capabilities ?? const <String>[]).isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Capabilities')
      ..writeln('  ${(s.capabilities ?? const <String>[]).join(', ')}');
  }

  if (view.chipsetFamily != null) {
    buffer
      ..writeln()
      ..writeln('Chipset detection')
      ..writeln('  ${view.chipsetFamily!.reason}');
  }

  if (view.likelyFunction != null) {
    buffer
      ..writeln()
      ..writeln('Likely function')
      ..writeln('  ${view.likelyFunction!.reason}');
  }

  if (view.details.interfaces.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Interfaces');
    for (int i = 0; i < view.details.interfaces.length; i++) {
      final iface = view.details.interfaces[i];
      final resolved = view.interfaceClassNames.length > i ? view.interfaceClassNames[i] : null;
      buffer
        ..writeln(
          '  IF ${iface.id} alt ${iface.alternateSetting}: ${resolved?.className ?? 'Unknown'} / ${resolved?.subclassName ?? 'Unknown'} / ${resolved?.protocolName ?? 'Unknown'}',
        )
        ..writeln('    Endpoints: ${iface.endpointCount}');
      for (final ep in iface.endpoints) {
        buffer.writeln(
          '    - ${ep.type} ${ep.direction} addr ${Fmt.decAndHex8(ep.address)} maxPkt ${ep.maxPacketSize} interval ${ep.interval}',
        );
      }
    }
  }

  final availabilityIssues = _asList(raw?['availabilityIssues']).map(_asMap).where((e) => e.isNotEmpty).toList(growable: false);
  if (availabilityIssues.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Availability issues');
    for (final issue in availabilityIssues) {
      buffer.writeln('  - ${(issue['scope'] as String?) ?? 'availability'}: ${(issue['message'] as String?) ?? 'Unavailable'}');
    }
  }

  final tree = _asList(raw?['descriptorTree']);
  final hidReports = _asList(raw?['hidReports']);
  buffer
    ..writeln()
    ..writeln('Advanced counts')
    ..writeln('  Descriptor tree nodes: ${tree.length}')
    ..writeln('  HID report descriptors: ${hidReports.length}')
    ..writeln('  Strings available: ${_asMap(raw?['strings']).isNotEmpty ? 'Yes' : 'No'}')
    ..writeln('  Device state available: ${_asMap(raw?['deviceState']).isNotEmpty ? 'Yes' : 'No'}');

  return buffer.toString().trimRight();
}

String _buildRawHexDump(
  UsbDeviceDetailViewData view,
  Map<String, dynamic>? raw,
) {
  final buffer = StringBuffer()
    ..writeln('# USBDevInfo raw hex dump')
    ..writeln('# device: ${view.details.summary.deviceName}')
    ..writeln('# exported: ${DateTime.now().toIso8601String()}')
    ..writeln();

  final tree = _asList(raw?['descriptorTree']).map(_asMap).where((e) => e.isNotEmpty).toList(growable: false);
  if (tree.isEmpty) {
    buffer.writeln('Descriptor tree: unavailable');
  } else {
    buffer.writeln('Descriptor tree');
    for (final node in tree) {
      final offset = _asInt(node['offset']);
      final typeName = (node['descriptorTypeName'] as String?) ?? 'Unknown';
      final descriptorType = _asInt(node['descriptorType']);
      final rawHex = (node['rawHex'] as String?)?.trim() ?? '';
      buffer.writeln(
        '[${offset == null ? '?' : '0x${offset.toRadixString(16)}'}] $typeName (${descriptorType == null ? '?' : Fmt.decAndHex8(descriptorType)})',
      );
      buffer.writeln(rawHex.isEmpty ? '<unavailable>' : Fmt.hexWrap(rawHex, group: 2, groupsPerLine: 16));
      buffer.writeln();
    }
  }

  final reports = _asList(raw?['hidReports']).map(_asMap).where((e) => e.isNotEmpty).toList(growable: false);
  if (reports.isEmpty) {
    buffer.writeln('HID report descriptors: unavailable');
  } else {
    buffer.writeln('HID report descriptors');
    for (final report in reports) {
      final ifNum = _asInt(report['interfaceNumber']);
      final hex = (report['reportHex'] as String?)?.trim() ?? '';
      buffer.writeln('Interface ${ifNum ?? '?'}');
      buffer.writeln(hex.isEmpty ? '<unavailable>' : Fmt.hexWrap(hex, group: 2, groupsPerLine: 16));
      buffer.writeln();
    }
  }

  return buffer.toString().trimRight();
}

String _manifestStatusLabel(BuildContext context, String? status) {
  switch (status) {
    case 'declared':
      return context.l10n.deviceManifestStatusDeclared;
    case 'missing':
      return context.l10n.deviceManifestStatusMissing;
    default:
      return context.l10n.unknown;
  }
}

String _runtimeStatusLabel(BuildContext context, String? status) {
  switch (status) {
    case 'granted':
      return context.l10n.deviceRuntimeStatusGranted;
    case 'temporarily_denied':
      return context.l10n.deviceRuntimeStatusTemporarilyDenied;
    case 'permanently_denied':
      return context.l10n.deviceRuntimeStatusPermanentlyDenied;
    case 'not_required':
      return context.l10n.deviceRuntimeStatusNotRequired;
    case 'missing':
      return context.l10n.devicePermissionNotGranted;
    case 'unavailable':
      return context.l10n.unavailable;
    default:
      return context.l10n.unknown;
  }
}

String _formatTimestamp(int timestampMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
}

class _PermissionStateRow extends StatelessWidget {
  const _PermissionStateRow({required this.status});

  final DevicePermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final scheme = theme.colorScheme;
    final tone = _tone(scheme);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: tone.$1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_icon(), size: 18, color: tone.$2),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    status.label,
                    style: theme.textTheme.labelLarge?.copyWith(color: scheme.onErrorContainer),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tone.$1,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _label(context),
                      style: theme.textTheme.labelSmall?.copyWith(color: tone.$2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                status.detail,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _icon() {
    switch (status.state) {
      case DevicePermissionState.granted:
        return Icons.verified_rounded;
      case DevicePermissionState.temporarilyDenied:
        return Icons.schedule_rounded;
      case DevicePermissionState.permanentlyDenied:
        return Icons.block_rounded;
      case DevicePermissionState.reenumerated:
        return Icons.sync_problem_rounded;
      case DevicePermissionState.unavailable:
        return Icons.build_circle_outlined;
      case DevicePermissionState.notApplicable:
        return Icons.remove_circle_outline_rounded;
      case DevicePermissionState.revoked:
        return Icons.restart_alt_rounded;
      case DevicePermissionState.missing:
        return Icons.lock_outline_rounded;
    }
  }

  String _label(BuildContext context) {
    final l10n = context.l10n;
    switch (status.state) {
      case DevicePermissionState.granted:
        return l10n.deviceRuntimeStatusGranted;
      case DevicePermissionState.temporarilyDenied:
        return l10n.devicePermissionStateTemporary;
      case DevicePermissionState.permanentlyDenied:
        return l10n.devicePermissionStatePermanent;
      case DevicePermissionState.reenumerated:
        return l10n.devicePermissionStateReenumerated;
      case DevicePermissionState.unavailable:
        return l10n.devicePermissionStateNotInApp;
      case DevicePermissionState.notApplicable:
        return l10n.deviceRuntimeStatusNotRequired;
      case DevicePermissionState.revoked:
        return l10n.devicePermissionStateRevoked;
      case DevicePermissionState.missing:
        return l10n.deviceManifestStatusMissing;
    }
  }

  (Color, Color) _tone(ColorScheme scheme) {
    switch (status.state) {
      case DevicePermissionState.granted:
        return (scheme.secondaryContainer, scheme.onSecondaryContainer);
      case DevicePermissionState.temporarilyDenied:
        return (scheme.tertiaryContainer, scheme.onTertiaryContainer);
      case DevicePermissionState.permanentlyDenied:
        return (scheme.error, scheme.onError);
      case DevicePermissionState.reenumerated:
        return (scheme.tertiaryContainer, scheme.onTertiaryContainer);
      case DevicePermissionState.unavailable:
        return (scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
      case DevicePermissionState.notApplicable:
        return (scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
      case DevicePermissionState.revoked:
        return (scheme.tertiaryContainer, scheme.onTertiaryContainer);
      case DevicePermissionState.missing:
        return (scheme.error, scheme.onError);
    }
  }
}

class _ConfigBlock extends StatelessWidget {
  const _ConfigBlock({required this.cfg, required this.index});
  final UsbConfigurationInfo cfg;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final attrsHex = Fmt.decAndHex8(cfg.attributes);
    final attrsLabel = Fmt.usbConfigAttributesLabel(cfg.attributes);
    final maxPower = cfg.maxPowerMa == null ? l10n.unknown : '${cfg.maxPowerMa} mA';
    return _ExpandableBlock(
      title: l10n.deviceConfigurationTitle(
        cfg.id.toString(),
        (cfg.name?.trim().isNotEmpty ?? false) ? ' — ${cfg.name}' : '',
      ),
      initiallyExpanded: index == 0,
      child: Column(
        children: [
          KeyValueRow(label: l10n.deviceNameLabel, value: Fmt.formatNullable(cfg.name)),
          KeyValueRow(label: l10n.deviceAttributesLabel, value: '$attrsHex • $attrsLabel'),
          KeyValueRow(label: l10n.deviceMaxPowerShortLabel, value: maxPower),
          KeyValueRow(label: l10n.deviceInterfacesLabel, value: '${cfg.interfaceCount}'),
          if (cfg.interfaces.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.deviceInterfacesSummaryTitle,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            for (final i in cfg.interfaces.take(8)) ...[
              KeyValueRow(
                label: l10n.deviceInterfaceShortLabel(i.id.toString()),
                value: l10n.deviceInterfaceSummaryValue(
                  Fmt.decAndHex8(i.interfaceClass),
                  i.endpointCount.toString(),
                ),
                allowCopy: false,
              ),
            ],
            if (cfg.interfaces.length > 8)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.deviceShowingFirstInterfaces(8),
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
    final l10n = context.l10n;
    final classId = iface.interfaceClass;
    final subclassId = iface.interfaceSubclass;
    final protocolId = iface.interfaceProtocol;
    final className = resolved?.className;
    final subclassName = resolved?.subclassName;
    final protocolName = resolved?.protocolName;

    String join(String? n, int id) => '${(n == null || n.trim().isEmpty) ? l10n.unknown : n} (${Fmt.decAndHex8(id)})';

    return _ExpandableBlock(
      title: l10n.deviceInterfaceTitle('${iface.id}', join(className, classId)),
      initiallyExpanded: index == 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (iface.name != null && iface.name!.trim().isNotEmpty) KeyValueRow(label: l10n.deviceNameLabel, value: iface.name!),
          KeyValueRow(label: l10n.deviceAltSettingLabel, value: '${iface.alternateSetting}'),
          KeyValueRow(label: l10n.deviceClassLabel, value: join(className, classId)),
          KeyValueRow(label: l10n.deviceSubclassLabel, value: join(subclassName, subclassId)),
          KeyValueRow(label: l10n.deviceProtocolLabel, value: join(protocolName, protocolId)),
          const SizedBox(height: 10),
          Text(l10n.deviceEndpointsTitle(iface.endpointCount), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          if (iface.endpoints.isEmpty)
            Text(l10n.deviceNoEndpoints, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))
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
    final l10n = context.l10n;
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
                    l10n.deviceEndpointAddressSummary(Fmt.decAndHex8(ep.address), '${ep.number}', Fmt.decAndHex8(ep.attributes)),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.deviceEndpointMaxPacket('${ep.maxPacketSize}'), style: theme.textTheme.labelMedium),
                Text(l10n.deviceEndpointInterval('${ep.interval}'), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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

class _AdvancedRawViewScreen extends StatelessWidget {
  const _AdvancedRawViewScreen({
    required this.view,
    required this.raw,
  });

  final UsbDeviceDetailViewData view;
  final Map<String, dynamic>? raw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tree = _asList(raw?['descriptorTree']).map(_asMap).where((item) => item.isNotEmpty).toList(growable: false);
    final controlTransfers = _asList(raw?['controlTransfers']).map(_asMap).where((item) => item.isNotEmpty).toList(growable: false);
    final hidReports = _asList(raw?['hidReports']).map(_asMap).where((item) => item.isNotEmpty).toList(growable: false);
    final availabilityIssues = _asList(raw?['availabilityIssues']).map(_asMap).where((item) => item.isNotEmpty).toList(growable: false);
    final title = view.productName ?? view.details.summary.productName ?? l10n.homeUsbDeviceLabel;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deviceAdvancedRawViewTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            SectionCard(
              title: title,
              subtitle: view.details.summary.deviceName,
              leading: const Icon(Icons.developer_mode_rounded),
              child: Column(
                children: [
                  KeyValueRow(label: l10n.deviceDescriptorNodesLabel, value: '${tree.length}'),
                  KeyValueRow(label: l10n.deviceControlTransfersLabel, value: '${controlTransfers.length}'),
                  KeyValueRow(label: l10n.deviceHidReportDumpsLabel, value: '${hidReports.length}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controlTransfers.isNotEmpty) ...[
              SectionCard(
                title: l10n.deviceControlTransfersTitle,
                subtitle: l10n.deviceControlTransfersSubtitle,
                leading: const Icon(Icons.swap_horiz_rounded),
                child: Column(
                  children: [
                    for (int i = 0; i < controlTransfers.length; i++) ...[
                      if (i > 0) const Divider(height: 24),
                      _ControlTransferTile(transfer: controlTransfers[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (tree.isNotEmpty) ...[
              SectionCard(
                title: l10n.deviceDescriptorsSideBySideTitle,
                subtitle: l10n.deviceDescriptorsSideBySideSubtitle,
                leading: const Icon(Icons.view_sidebar_rounded),
                child: Column(
                  children: [
                    for (int i = 0; i < tree.length; i++) ...[
                      if (i > 0) const Divider(height: 24),
                      _AdvancedDescriptorTile(node: tree[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (hidReports.isNotEmpty) ...[
              SectionCard(
                title: l10n.deviceHidReportDumpsTitle,
                subtitle: l10n.deviceHidReportDumpsSubtitle,
                leading: const Icon(Icons.keyboard_command_key_rounded),
                child: Column(
                  children: [
                    for (int i = 0; i < hidReports.length; i++) ...[
                      if (i > 0) const Divider(height: 24),
                      _AdvancedHidReportTile(report: hidReports[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (controlTransfers.isEmpty && tree.isEmpty && hidReports.isEmpty)
              SectionCard(
                title: l10n.deviceAdvancedDataUnavailableTitle,
                subtitle: l10n.deviceAdvancedDataUnavailableSubtitle,
                leading: const Icon(Icons.info_outline_rounded),
                child: Text(
                  availabilityIssues.isNotEmpty
                      ? availabilityIssues.map((issue) => (issue['message'] as String?) ?? l10n.unavailable).join('\n\n')
                      : l10n.deviceGrantPermissionReconnectNote,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ControlTransferTile extends StatelessWidget {
  const _ControlTransferTile({required this.transfer});

  final Map<String, dynamic> transfer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final label = (transfer['label'] as String?)?.trim();
    final responseHex = (transfer['responseHex'] as String?)?.trim();
    final actualLength = _asInt(transfer['actualLength']);
    final success = transfer['success'] != false && (actualLength == null || actualLength >= 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label?.isNotEmpty == true ? label! : l10n.deviceControlTransferDefaultTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        KeyValueRow(label: 'bmRequestType', value: Fmt.decAndHex8(_asInt(transfer['requestType']) ?? 0)),
        KeyValueRow(label: 'bRequest', value: Fmt.decAndHex8(_asInt(transfer['request']) ?? 0)),
        KeyValueRow(label: 'wValue', value: Fmt.decAndHex16(_asInt(transfer['value']) ?? 0)),
        KeyValueRow(label: 'wIndex', value: Fmt.decAndHex16(_asInt(transfer['index']) ?? 0)),
        KeyValueRow(label: l10n.deviceRequestedLengthLabel, value: '${_asInt(transfer['requestedLength']) ?? 0}'),
        KeyValueRow(label: l10n.deviceActualLengthLabel, value: actualLength?.toString() ?? l10n.unknown),
        KeyValueRow(label: l10n.deviceResultLabel, value: success ? l10n.deviceTransferSuccess : l10n.deviceTransferFailed),
        if (responseHex?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          _ExpandableBlock(
            title: l10n.deviceResponseBytesHexTitle,
            child: SelectableText(
              Fmt.hexWrap(responseHex!, group: 2, groupsPerLine: 16),
              style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ],
    );
  }
}

class _AdvancedDescriptorTile extends StatelessWidget {
  const _AdvancedDescriptorTile({required this.node});

  final Map<String, dynamic> node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final off = _asInt(node['offset']);
    final len = _asInt(node['length']);
    final typeName = (node['descriptorTypeName'] as String?) ?? l10n.unknown;
    final type = _asInt(node['descriptorType']);
    final rawHex = (node['rawHex'] as String?)?.trim() ?? '';
    final fields = _asMap(node['fields']);
    final title = '0x${off == null ? '??' : off.toRadixString(16)} • $typeName (${type == null ? '?' : Fmt.decAndHex8(type)}) • ${len ?? '?'} bytes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 720;
            final parsed = _AdvancedRawPane(
              title: l10n.deviceParsedFieldsTitle,
              child: fields.isEmpty
                  ? Text(
                      l10n.deviceNoParsedFieldsAvailable,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  : Column(
                      children: [
                        for (final entry in fields.entries)
                          KeyValueRow(label: entry.key, value: _formatAny(entry.value)),
                      ],
                    ),
            );
            final rawPane = _AdvancedRawPane(
              title: l10n.deviceRawBytesTitle,
              child: SelectableText(
                rawHex.isEmpty ? '<${l10n.unavailable}>' : Fmt.hexWrap(rawHex, group: 2, groupsPerLine: 16),
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            );

            if (stacked) {
              return Column(
                children: [
                  parsed,
                  const SizedBox(height: 12),
                  rawPane,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: parsed),
                const SizedBox(width: 12),
                Expanded(child: rawPane),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AdvancedHidReportTile extends StatelessWidget {
  const _AdvancedHidReportTile({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final ifNum = _asInt(report['interfaceNumber']);
    final reportLen = _asInt(report['reportLength']);
    final summary = _asMap(report['summary']);
    final hex = (report['reportHex'] as String?)?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deviceInterfaceReportTitle('${ifNum ?? '?'}', '${reportLen ?? '?'}'),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 720;
            final parsed = _AdvancedRawPane(
              title: l10n.deviceParsedSummaryTitle,
              child: summary.isEmpty
                  ? Text(
                      l10n.deviceNoParsedHidSummaryAvailable,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  : Column(
                      children: [
                        for (final entry in summary.entries)
                          KeyValueRow(label: entry.key, value: _formatAny(entry.value)),
                      ],
                    ),
            );
            final rawPane = _AdvancedRawPane(
              title: l10n.deviceReportHexTitle,
              child: SelectableText(
                hex.isEmpty ? '<${l10n.unavailable}>' : Fmt.hexWrap(hex, group: 2, groupsPerLine: 16),
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
            );
            if (stacked) {
              return Column(
                children: [
                  parsed,
                  const SizedBox(height: 12),
                  rawPane,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: parsed),
                const SizedBox(width: 12),
                Expanded(child: rawPane),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AdvancedRawPane extends StatelessWidget {
  const _AdvancedRawPane({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          child,
        ],
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
    final l10n = context.l10n;
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
    if (hasKb) chips.add(l10n.deviceKeyboardChip);
    if (hasMouse) chips.add(l10n.deviceMouseChip);
    if (reportIdCount != null) chips.add(l10n.deviceReportIdsChip(reportIdCount.toString()));
    if (collections != null) chips.add(l10n.deviceCollectionsChip(collections.toString()));
    if (usagePages.isNotEmpty) {
      chips.add(l10n.deviceUsagePagesChip(usagePages.map(Fmt.hex16).join(', ')));
    }

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

class _AudioEndpointBlock extends StatelessWidget {
  const _AudioEndpointBlock({required this.endpoint, required this.index});

  final Map<String, dynamic> endpoint;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productName = (endpoint['productName'] as String?)?.trim();
    final typeName = (endpoint['typeName'] as String?) ?? 'Audio endpoint';
    final address = (endpoint['address'] as String?)?.trim();
    final sampleRates = _asList(endpoint['sampleRates']).map(_asInt).whereType<int>().toList(growable: false);
    final channelCounts = _asList(endpoint['channelCounts']).map(_asInt).whereType<int>().toList(growable: false);
    final channelMasks = _asList(endpoint['channelMasks']).map(_asInt).whereType<int>().toList(growable: false);
    final channelIndexMasks = _asList(endpoint['channelIndexMasks']).map(_asInt).whereType<int>().toList(growable: false);
    final encodings = _asList(endpoint['encodings']).whereType<String>().toList(growable: false);
    final profiles = _asList(endpoint['audioProfiles']);
    final descriptors = _asList(endpoint['audioDescriptors']);

    final roleParts = <String>[];
    if (endpoint['isSource'] == true) roleParts.add('Source');
    if (endpoint['isSink'] == true) roleParts.add('Sink');

    return _ExpandableBlock(
      title: 'Endpoint ${index + 1} • ${productName?.isNotEmpty == true ? productName : typeName}',
      initiallyExpanded: index == 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(label: 'Type', value: typeName),
          KeyValueRow(label: 'Role', value: roleParts.isEmpty ? 'Unknown' : roleParts.join(' / ')),
          KeyValueRow(label: 'Product name', value: (productName?.isNotEmpty ?? false) ? productName! : 'Unknown'),
          KeyValueRow(label: 'Address', value: (address?.isNotEmpty ?? false) ? address! : 'Unknown'),
          KeyValueRow(label: 'Sample rates', value: sampleRates.isEmpty ? 'Unknown' : sampleRates.join(', ')),
          KeyValueRow(label: 'Channel counts', value: channelCounts.isEmpty ? 'Unknown' : channelCounts.join(', ')),
          KeyValueRow(
            label: 'Channel masks',
            value: channelMasks.isEmpty ? 'Unknown' : channelMasks.map(Fmt.hex16).join(', '),
          ),
          KeyValueRow(
            label: 'Channel index masks',
            value: channelIndexMasks.isEmpty ? 'Unknown' : channelIndexMasks.map(Fmt.hex16).join(', '),
          ),
          KeyValueRow(label: 'Encodings', value: encodings.isEmpty ? 'Unknown' : encodings.join(', ')),
          if (profiles.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ExpandableBlock(
              title: 'Audio profiles (${profiles.length})',
              child: Column(
                children: [
                  for (final p in profiles.take(12)) ...[
                    _AudioProfileRow(profile: _asMap(p)),
                    const SizedBox(height: 8),
                  ],
                  if (profiles.length > 12)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing first 12 profiles.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (descriptors.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ExpandableBlock(
              title: 'Audio descriptors (${descriptors.length})',
              child: Column(
                children: [
                  for (final d in descriptors.take(8)) ...[
                    _AudioDescriptorRow(descriptor: _asMap(d)),
                    const SizedBox(height: 8),
                  ],
                  if (descriptors.length > 8)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing first 8 descriptors.',
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
}

class _AudioProfileRow extends StatelessWidget {
  const _AudioProfileRow({required this.profile});

  final Map<String, dynamic> profile;

  @override
  Widget build(BuildContext context) {
    final formatName = (profile['formatName'] as String?) ?? 'Unknown';
    final sampleRates = _asList(profile['sampleRates']).map(_asInt).whereType<int>().toList(growable: false);
    final channelMasks = _asList(profile['channelMasks']).map(_asInt).whereType<int>().toList(growable: false);
    final channelIndexMasks = _asList(profile['channelIndexMasks']).map(_asInt).whereType<int>().toList(growable: false);
    final encapsulation = _asInt(profile['encapsulationType']);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            KeyValueRow(label: 'Format', value: formatName),
            KeyValueRow(label: 'Sample rates', value: sampleRates.isEmpty ? 'Unknown' : sampleRates.join(', ')),
            KeyValueRow(
              label: 'Channel masks',
              value: channelMasks.isEmpty ? 'Unknown' : channelMasks.map(Fmt.hex16).join(', '),
            ),
            KeyValueRow(
              label: 'Channel index masks',
              value: channelIndexMasks.isEmpty ? 'Unknown' : channelIndexMasks.map(Fmt.hex16).join(', '),
            ),
            KeyValueRow(
              label: 'Encapsulation',
              value: encapsulation == null ? 'Unknown' : '$encapsulation',
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioDescriptorRow extends StatelessWidget {
  const _AudioDescriptorRow({required this.descriptor});

  final Map<String, dynamic> descriptor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final standard = _asInt(descriptor['standard']);
    final encapsulation = _asInt(descriptor['encapsulationType']);
    final length = _asInt(descriptor['length']);
    final hex = descriptor['descriptorHex'] as String?;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KeyValueRow(label: 'Standard', value: standard == null ? 'Unknown' : '$standard'),
            KeyValueRow(label: 'Encapsulation', value: encapsulation == null ? 'Unknown' : '$encapsulation'),
            KeyValueRow(label: 'Length', value: length == null ? 'Unknown' : '$length bytes'),
            if (hex != null && hex.isNotEmpty) ...[
              const SizedBox(height: 8),
              _ExpandableBlock(
                title: 'Raw descriptor (hex)',
                child: SelectableText(
                  Fmt.hexWrap(hex, group: 2, groupsPerLine: 16),
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

class _MidiDeviceBlock extends StatelessWidget {
  const _MidiDeviceBlock({required this.device, required this.index});

  final Map<String, dynamic> device;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeName = (device['typeName'] as String?) ?? 'MIDI device';
    final transports = _asList(device['transports']).whereType<String>().toList(growable: false);
    final props = _asMap(device['properties']);
    final ports = _asList(device['ports']);
    final name = _pickMidiDisplayName(props) ?? typeName;
    return _ExpandableBlock(
      title: 'Device ${index + 1} • $name',
      initiallyExpanded: index == 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyValueRow(label: 'Type', value: typeName),
          KeyValueRow(label: 'Transports', value: transports.isEmpty ? 'Unknown' : transports.join(', ')),
          KeyValueRow(label: 'Input ports', value: '${_asInt(device['inputPortCount']) ?? 0}'),
          KeyValueRow(label: 'Output ports', value: '${_asInt(device['outputPortCount']) ?? 0}'),
          KeyValueRow(label: 'Private', value: device['isPrivate'] == true ? 'Yes' : 'No'),
          KeyValueRow(
            label: 'Default protocol',
            value: _midiProtocolLabel(_asInt(device['defaultProtocol'])),
          ),
          if (props.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ExpandableBlock(
              title: 'Properties',
              child: Column(
                children: [
                  for (final e in props.entries.take(16)) ...[
                    KeyValueRow(label: e.key, value: _formatAny(e.value)),
                  ],
                  if (props.length > 16)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing first 16 properties.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (ports.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ExpandableBlock(
              title: 'Ports (${ports.length})',
              child: Column(
                children: [
                  for (final p in ports) ...[
                    _MidiPortRow(port: _asMap(p)),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MidiPortRow extends StatelessWidget {
  const _MidiPortRow({required this.port});

  final Map<String, dynamic> port;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            KeyValueRow(label: l10n.deviceTypeLabel, value: (port['typeName'] as String?) ?? l10n.unknown),
            KeyValueRow(label: l10n.devicePortNumberLabel, value: '${_asInt(port['portNumber']) ?? 0}'),
            KeyValueRow(label: l10n.deviceNameLabel, value: _formatNullableString(context, port['name'] as String?)),
          ],
        ),
      ),
    );
  }
}

class _ClassDescriptorSections {
  const _ClassDescriptorSections({
    this.audio = const [],
    this.video = const [],
    this.cdc = const [],
    this.hub = const [],
    this.bos = const [],
  });

  final List<_ClassDescriptorView> audio;
  final List<_ClassDescriptorView> video;
  final List<_ClassDescriptorView> cdc;
  final List<_ClassDescriptorView> hub;
  final List<_ClassDescriptorView> bos;
}

class _ClassDescriptorView {
  const _ClassDescriptorView({
    required this.title,
    required this.node,
    required this.fields,
    this.summary,
  });

  final String title;
  final Map<String, dynamic> node;
  final Map<String, dynamic> fields;
  final String? summary;
}

class _TopologyPath extends StatelessWidget {
  const _TopologyPath({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        path,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _TopologyList extends StatelessWidget {
  const _TopologyList({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(value, style: theme.textTheme.labelMedium),
              ),
          ],
        ),
      ],
    );
  }
}

class _AvailabilityIssueTile extends StatelessWidget {
  const _AvailabilityIssueTile({required this.issue});

  final Map<String, dynamic> issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = (issue['status'] as String?)?.trim().toLowerCase();
    final scope = (issue['scope'] as String?)?.trim();
    final message = (issue['message'] as String?)?.trim();
    final reasonCode = (issue['reasonCode'] as String?)?.trim();
    final isAdvisory = status == 'advisory';
    final bg = isAdvisory
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isAdvisory
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isAdvisory ? Icons.warning_amber_rounded : Icons.block_rounded,
            color: fg,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _availabilityScopeLabel(scope),
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                message?.isNotEmpty == true ? message! : 'Data is unavailable.',
                style: theme.textTheme.bodyMedium,
              ),
              if (reasonCode?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  reasonCode!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

enum _RawDumpExportFormat {
  json,
  report,
  hex,
}

class _DeviceRawDumpExportSheet extends StatefulWidget {
  const _DeviceRawDumpExportSheet({
    required this.prettyJson,
    required this.plainText,
    required this.rawHex,
  });

  final String prettyJson;
  final String plainText;
  final String rawHex;

  @override
  State<_DeviceRawDumpExportSheet> createState() => _DeviceRawDumpExportSheetState();
}

class _DeviceRawDumpExportSheetState extends State<_DeviceRawDumpExportSheet> {
  _RawDumpExportFormat _format = _RawDumpExportFormat.json;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final content = switch (_format) {
      _RawDumpExportFormat.json => widget.prettyJson,
      _RawDumpExportFormat.report => widget.plainText,
      _RawDumpExportFormat.hex => widget.rawHex,
    };
    final title = switch (_format) {
      _RawDumpExportFormat.json => l10n.deviceExportFormatJson,
      _RawDumpExportFormat.report => l10n.deviceExportFormatReport,
      _RawDumpExportFormat.hex => l10n.deviceExportFormatRawHex,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.deviceRawDumpExportTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            l10n.deviceRawDumpExportSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ExportFormatChip(
                label: l10n.deviceExportChipJson,
                selected: _format == _RawDumpExportFormat.json,
                onTap: () => setState(() => _format = _RawDumpExportFormat.json),
              ),
              _ExportFormatChip(
                label: l10n.deviceExportChipReport,
                selected: _format == _RawDumpExportFormat.report,
                onTap: () => setState(() => _format = _RawDumpExportFormat.report),
              ),
              _ExportFormatChip(
                label: l10n.deviceExportChipRawHex,
                selected: _format == _RawDumpExportFormat.hex,
                onTap: () => setState(() => _format = _RawDumpExportFormat.hex),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: content));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.deviceCopiedToClipboard(title))),
                  );
                  HapticFeedback.selectionClick();
                },
                icon: const Icon(Icons.copy_rounded),
                label: Text(l10n.deviceCopyAction),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  content,
                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportFormatChip extends StatelessWidget {
  const _ExportFormatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
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

_ClassDescriptorSections _buildClassDescriptorSections(List<dynamic> tree) {
  final audio = <_ClassDescriptorView>[];
  final video = <_ClassDescriptorView>[];
  final cdc = <_ClassDescriptorView>[];
  final hub = <_ClassDescriptorView>[];
  final bos = <_ClassDescriptorView>[];

  int? currentInterfaceNumber;
  int? currentAltSetting;
  int? currentInterfaceClass;
  int? currentInterfaceSubclass;

  for (final rawNode in tree) {
    final node = _asMap(rawNode);
    final type = _asInt(node['descriptorType']);
    final fields = _asMap(node['fields']);
    final context = _asMap(node['context']);

    if (type == 0x04) {
      currentInterfaceNumber = _asInt(fields['bInterfaceNumber']);
      currentAltSetting = _asInt(fields['bAlternateSetting']);
      currentInterfaceClass = _asInt(fields['bInterfaceClass']);
      currentInterfaceSubclass = _asInt(fields['bInterfaceSubClass']);
      continue;
    }

    if (type == 0x0F || type == 0x10) {
      bos.add(
        _ClassDescriptorView(
          title: _bosTitle(type, fields),
          node: node,
          fields: fields,
          summary: _bosSummary(type, fields),
        ),
      );
      continue;
    }

    if (type == 0x29) {
      hub.add(
        _ClassDescriptorView(
          title: 'Hub descriptor',
          node: node,
          fields: fields,
          summary: _hubSummary(fields),
        ),
      );
      continue;
    }

    if (type != 0x24 && type != 0x25) continue;

    final subtype = _asInt(fields['bDescriptorSubType']);
    final interfaceClass =
        _asInt(fields['interfaceClassContext']) ?? _asInt(context['interfaceClass']) ?? currentInterfaceClass;
    final interfaceSubclass =
        _asInt(fields['interfaceSubclassContext']) ?? _asInt(context['interfaceSubclass']) ?? currentInterfaceSubclass;
    final interfaceNumber =
        _asInt(context['interfaceNumber']) ?? currentInterfaceNumber;
    final altSetting =
        _asInt(context['alternateSetting']) ?? currentAltSetting;
    final target = switch (interfaceClass) {
      1 => audio,
      2 => cdc,
      14 => video,
      _ => null,
    };
    if (target == null) continue;

    final title = _classSpecificTitle(
      interfaceClass: interfaceClass,
      interfaceSubclass: interfaceSubclass,
      subtype: subtype,
      type: type,
      interfaceNumber: interfaceNumber,
      altSetting: altSetting,
      fields: fields,
    );
    final summary = _classSpecificSummary(
      interfaceClass: interfaceClass,
      interfaceSubclass: interfaceSubclass,
      type: type,
      subtype: subtype,
      fields: fields,
    );
    target.add(
      _ClassDescriptorView(
        title: title,
        node: node,
        fields: fields,
        summary: summary,
      ),
    );
  }

  return _ClassDescriptorSections(
    audio: audio,
    video: video,
    cdc: cdc,
    hub: hub,
    bos: bos,
  );
}

String _formatAny(dynamic v) {
  if (v == null) return 'Unknown';
  if (v is Map) {
    final map = v.cast<dynamic, dynamic>();
    return map.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
  if (v is List) return v.join(', ');
  final s = '$v'.trim();
  return s.isEmpty ? 'Unknown' : s;
}

String _formatNullableString(BuildContext context, String? v) {
  final s = (v ?? '').trim();
  return s.isEmpty ? context.l10n.unknown : s;
}

String _yesNoLabel(BuildContext context, bool value) =>
    value ? context.l10n.deviceYes : context.l10n.deviceNo;

String? _buildTopologyPath(int? busNumber, List<int> portChain) {
  if (busNumber == null) return null;
  final parts = <String>['usb$busNumber'];
  if (portChain.isEmpty) return parts.join(' → ');
  for (final port in portChain) {
    parts.add('port $port');
  }
  return parts.join(' → ');
}

String? _pickMidiDisplayName(Map<String, dynamic> props) {
  for (final key in const [
    'name',
    'product',
    'manufacturer',
    'android.media.midi.MidiDeviceInfo.PROPERTY_NAME',
    'android.media.midi.MidiDeviceInfo.PROPERTY_PRODUCT',
  ]) {
    final value = props[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

String _bosTitle(int? type, Map<String, dynamic> fields) {
  if (type == 0x0F) return 'Binary Object Store';
  final capName = (fields['capabilityTypeName'] as String?) ?? _deviceCapabilityName(_asInt(fields['bDevCapabilityType']));
  return capName == null ? 'Device capability' : 'Device capability • $capName';
}

String? _bosSummary(int? type, Map<String, dynamic> fields) {
  if (type == 0x0F) {
    final total = _asInt(fields['wTotalLength']);
    final count = _asInt(fields['bNumDeviceCaps']);
    return 'BOS with ${count ?? '?'} capability descriptor(s) and total length ${total ?? '?'} bytes.';
  }
  final capName = (fields['capabilityTypeName'] as String?) ?? _deviceCapabilityName(_asInt(fields['bDevCapabilityType']));
  if (capName == null) return null;
  final parts = <String>['Capability type: $capName'];
  if (fields['supportsLpm'] == true) parts.add('supports LPM');
  if (fields['supportsLtm'] == true) parts.add('supports LTM');
  final speeds = _stringList(fields['supportedSpeedNames']);
  if (speeds.isNotEmpty) parts.add('speeds ${speeds.join(', ')}');
  final containerId = (fields['containerId'] as String?)?.trim();
  if (containerId?.isNotEmpty == true) parts.add('container ID $containerId');
  final platformUuid = (fields['platformCapabilityUuid'] as String?)?.trim();
  if (platformUuid?.isNotEmpty == true) parts.add('platform UUID $platformUuid');
  return '${parts.join(', ')}.';
}

String? _hubSummary(Map<String, dynamic> fields) {
  final ports = _asInt(fields['bNbrPorts']);
  final powerGood = _asInt(fields['powerGoodMs']);
  final indicators = fields['portIndicatorsSupported'] == true;
  final switchMode = (fields['powerSwitchingModeName'] as String?)?.trim();
  final overCurrent = (fields['overCurrentProtectionModeName'] as String?)?.trim();
  final extras = <String>[];
  if (switchMode?.isNotEmpty == true) extras.add('power switching $switchMode');
  if (overCurrent?.isNotEmpty == true) extras.add('over-current $overCurrent');
  if (indicators) extras.add('indicators supported');
  final extraText = extras.isEmpty ? '' : ', ${extras.join(', ')}';
  return 'Hub with ${ports ?? '?'} downstream port(s), power-good delay ${powerGood ?? '?'} ms$extraText.';
}

String _classSpecificTitle({
  required int? interfaceClass,
  required int? interfaceSubclass,
  required int? subtype,
  required int? type,
  required int? interfaceNumber,
  required int? altSetting,
  required Map<String, dynamic> fields,
}) {
  final base = (fields['descriptorSubtypeName'] as String?)?.trim().isNotEmpty == true
      ? (fields['descriptorSubtypeName'] as String).trim()
      : switch (interfaceClass) {
          1 => _audioSubtypeName(subtype, interfaceSubclass),
          2 => _cdcSubtypeName(subtype),
          14 => _videoSubtypeName(subtype, interfaceSubclass),
          _ => null,
        };
  final typeLabel = type == 0x25 ? 'Endpoint' : 'Interface';
  final ifLabel = interfaceNumber == null ? 'IF ?' : 'IF $interfaceNumber';
  final altLabel = altSetting == null ? '' : ' / Alt $altSetting';
  if (base == null) return '$typeLabel descriptor • $ifLabel$altLabel';
  if (type == 0x25 && !base.toLowerCase().contains('endpoint')) {
    return '$base endpoint • $ifLabel$altLabel';
  }
  return '$base • $ifLabel$altLabel';
}

String? _classSpecificSummary({
  required int? interfaceClass,
  required int? interfaceSubclass,
  required int? type,
  required int? subtype,
  required Map<String, dynamic> fields,
}) {
  switch (interfaceClass) {
    case 1:
      return _audioClassSummary(interfaceSubclass, type, subtype, fields);
    case 2:
      return _cdcClassSummary(subtype, fields);
    case 14:
      return _videoClassSummary(interfaceSubclass, type, subtype, fields);
    default:
      return null;
  }
}

String? _audioSubtypeName(int? subtype, int? interfaceSubclass) {
  if (subtype == null) return null;
  if (interfaceSubclass == 0x02) {
    switch (subtype) {
      case 0x01:
        return 'Audio streaming general';
      case 0x02:
        return 'Format type';
      case 0x03:
        return 'Format specific';
      default:
        return 'Audio subtype ${Fmt.decAndHex8(subtype)}';
    }
  }
  if (interfaceSubclass == 0x03) {
    switch (subtype) {
      case 0x01:
        return 'MIDI streaming header';
      case 0x02:
        return 'MIDI IN jack';
      case 0x03:
        return 'MIDI OUT jack';
      case 0x04:
        return 'MIDI element';
      default:
        return 'Audio subtype ${Fmt.decAndHex8(subtype)}';
    }
  }
  switch (subtype) {
    case 0x01:
      return 'Audio control header';
    case 0x02:
      return 'Input terminal';
    case 0x03:
      return 'Output terminal';
    case 0x04:
      return 'Mixer unit';
    case 0x05:
      return 'Selector unit';
    case 0x06:
      return 'Feature unit';
    case 0x07:
      return 'Processing unit';
    case 0x08:
      return 'Extension unit';
    case 0x0A:
      return 'Clock source';
    case 0x0B:
      return 'Clock selector';
    case 0x0C:
      return 'Clock multiplier';
    case 0x0D:
      return 'Sample rate converter';
    default:
      return 'Audio subtype ${Fmt.decAndHex8(subtype)}';
  }
}

String? _videoSubtypeName(int? subtype, int? interfaceSubclass) {
  if (subtype == null) return null;
  if (interfaceSubclass == 0x02) {
    switch (subtype) {
      case 0x01:
        return 'Video streaming input header';
      case 0x02:
        return 'Video streaming output header';
      case 0x03:
        return 'Still image frame';
      case 0x04:
        return 'Format uncompressed';
      case 0x05:
        return 'Frame uncompressed';
      case 0x06:
        return 'Format MJPEG';
      case 0x07:
        return 'Frame MJPEG';
      case 0x0A:
        return 'Format MPEG-2 TS';
      case 0x0C:
        return 'Format DV';
      case 0x0D:
        return 'Color matching';
      case 0x10:
        return 'Format frame-based';
      case 0x11:
        return 'Frame frame-based';
      case 0x12:
        return 'Format stream-based';
      default:
        return 'Video subtype ${Fmt.decAndHex8(subtype)}';
    }
  }
  switch (subtype) {
    case 0x01:
      return 'Video control header';
    case 0x02:
      return 'Input terminal';
    case 0x03:
      return 'Output terminal';
    case 0x04:
      return 'Selector unit';
    case 0x05:
      return 'Processing unit';
    case 0x06:
      return 'Extension unit';
    case 0x07:
      return 'Encoding unit';
    default:
      return 'Video subtype ${Fmt.decAndHex8(subtype)}';
  }
}

String? _cdcSubtypeName(int? subtype) {
  if (subtype == null) return null;
  switch (subtype) {
    case 0x00:
      return 'CDC header';
    case 0x01:
      return 'Call management';
    case 0x02:
      return 'Abstract control management';
    case 0x03:
      return 'Direct line management';
    case 0x04:
      return 'Telephone ringer';
    case 0x05:
      return 'Telephone call and line state reporting';
    case 0x06:
      return 'Union functional descriptor';
    case 0x07:
      return 'Country selection';
    case 0x08:
      return 'Telephone operational modes';
    case 0x09:
      return 'USB terminal';
    case 0x0A:
      return 'Network channel';
    case 0x0B:
      return 'Protocol unit';
    case 0x0C:
      return 'Extension unit';
    case 0x0D:
      return 'Multi-channel management';
    case 0x0E:
      return 'CAPI control';
    case 0x0F:
      return 'Ethernet networking';
    case 0x10:
      return 'ATM networking';
    default:
      return 'CDC subtype ${Fmt.decAndHex8(subtype)}';
  }
}

String? _deviceCapabilityName(int? type) {
  switch (type) {
    case 0x01:
      return 'Wireless USB';
    case 0x02:
      return 'USB 2.0 extension';
    case 0x03:
      return 'SuperSpeed USB';
    case 0x04:
      return 'Container ID';
    case 0x05:
      return 'Platform';
    case 0x0A:
      return 'SuperSpeed Plus';
    case null:
      return null;
    default:
      return 'Capability ${Fmt.decAndHex8(type)}';
  }
}

String? _audioClassSummary(int? interfaceSubclass, int? type, int? subtype, Map<String, dynamic> fields) {
  final subtypeName =
      (fields['descriptorSubtypeName'] as String?) ?? _audioSubtypeName(subtype, interfaceSubclass) ?? 'Audio descriptor';
  if (type == 0x25) {
    final jackCount = _asInt(fields['bNumEmbMIDIJack']);
    if (jackCount != null) return '$subtypeName with $jackCount embedded jack(s).';
    final lockDelay = _asInt(fields['wLockDelay']);
    return lockDelay == null ? '$subtypeName.' : '$subtypeName, lock delay $lockDelay.';
  }

  final terminalType = (fields['terminalTypeName'] as String?)?.trim();
  final parts = <String>[];
  final terminalId = _asInt(fields['bTerminalID']);
  if (terminalId != null) parts.add('terminal ID $terminalId');
  final unitId = _asInt(fields['bUnitID']);
  if (unitId != null) parts.add('unit ID $unitId');
  final sourceId = _asInt(fields['bSourceID']);
  if (sourceId != null) parts.add('source ID $sourceId');
  final terminalLink = _asInt(fields['bTerminalLink']);
  if (terminalLink != null) parts.add('terminal link $terminalLink');
  if (terminalType?.isNotEmpty == true) parts.add(terminalType!);
  final sampleRates = _asList(fields['sampleRates']).map(_asInt).whereType<int>().toList(growable: false);
  if (sampleRates.isNotEmpty) parts.add('sample rates ${sampleRates.join(', ')} Hz');
  final sourceIds = _asList(fields['baSourceID']).map(_asInt).whereType<int>().toList(growable: false);
  if (sourceIds.isNotEmpty) parts.add('sources ${sourceIds.join(', ')}');
  final jackType = (fields['jackTypeName'] as String?)?.trim();
  if (jackType?.isNotEmpty == true) parts.add('$jackType jack');
  if (parts.isEmpty) return '$subtypeName.';
  return '$subtypeName: ${parts.join(', ')}.';
}

String? _cdcClassSummary(int? subtype, Map<String, dynamic> fields) {
  final subtypeName = (fields['descriptorSubtypeName'] as String?) ?? _cdcSubtypeName(subtype) ?? 'CDC descriptor';
  final capabilityNames = _stringList(fields['capabilityNames']);
  if (capabilityNames.isNotEmpty) {
    return '$subtypeName: ${capabilityNames.join(', ')}.';
  }
  final master = _asInt(fields['bMasterInterface']);
  final slaves = _asList(fields['bSlaveInterfaces']).map(_asInt).whereType<int>().toList(growable: false);
  if (master != null && slaves.isNotEmpty) {
    return '$subtypeName: master interface $master, slave interfaces ${slaves.join(', ')}.';
  }
  final macIndex = _asInt(fields['iMACAddress']);
  if (macIndex != null) {
    return '$subtypeName: MAC string index $macIndex, max segment ${_asInt(fields['wMaxSegmentSize']) ?? '?'} bytes.';
  }
  return '$subtypeName.';
}

String? _videoClassSummary(int? interfaceSubclass, int? type, int? subtype, Map<String, dynamic> fields) {
  final subtypeName =
      (fields['descriptorSubtypeName'] as String?) ?? _videoSubtypeName(subtype, interfaceSubclass) ?? 'Video descriptor';
  if (type == 0x25) {
    final attributes = _asInt(fields['bmAttributes']);
    return attributes == null ? '$subtypeName.' : '$subtypeName, attributes ${Fmt.decAndHex8(attributes)}.';
  }
  final terminalType = (fields['terminalTypeName'] as String?)?.trim();
  final parts = <String>[];
  final terminalId = _asInt(fields['bTerminalID']);
  if (terminalId != null) parts.add('terminal ID $terminalId');
  final unitId = _asInt(fields['bUnitID']);
  if (unitId != null) parts.add('unit ID $unitId');
  final sourceId = _asInt(fields['bSourceID']);
  if (sourceId != null) parts.add('source ID $sourceId');
  if (terminalType?.isNotEmpty == true) parts.add(terminalType!);
  final formatCount = _asInt(fields['bNumFormats']);
  if (formatCount != null) parts.add('$formatCount format(s)');
  final frameWidth = _asInt(fields['wWidth']);
  final frameHeight = _asInt(fields['wHeight']);
  if (frameWidth != null && frameHeight != null) parts.add('${frameWidth}x$frameHeight');
  final guidFormat = (fields['guidFormat'] as String?)?.trim();
  if (guidFormat?.isNotEmpty == true) parts.add('GUID $guidFormat');
  if (parts.isEmpty) return '$subtypeName.';
  return '$subtypeName: ${parts.join(', ')}.';
}

List<String> _stringList(dynamic value) {
  return _asList(value).map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList(growable: false);
}

class _ReconnectDiffField {
  const _ReconnectDiffField({
    required this.label,
    required this.previous,
    required this.current,
    required this.changed,
  });

  final String label;
  final String previous;
  final String current;
  final bool changed;
}

class _FrameworkLimitation {
  const _FrameworkLimitation({
    required this.title,
    required this.summary,
    required this.impact,
    required this.code,
  });

  final String title;
  final String summary;
  final String impact;
  final String code;
}

bool _hasReconnectBaseline(DeviceHistoryEntry entry) {
  return entry.previousSnapshot != null && entry.previousSnapshot!.isNotEmpty;
}

List<_ReconnectDiffField> _buildReconnectDiffFields(
  BuildContext context,
  UsbDeviceDetailViewData view,
  Map<String, dynamic> baseline,
) {
  final s = view.details.summary;
  final fields = <_ReconnectDiffField?>[
    _makeReconnectDiffField(
      label: context.l10n.devicePathLabel,
      previous: _formatNullableString(context, baseline['deviceName'] as String?),
      current: s.deviceName,
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceUsbPermissionLabel,
      previous: _permissionGrantedLabel(context, baseline['hasPermission'] == true),
      current: _permissionGrantedLabel(context, s.hasPermission),
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceUsbVersionLabel,
      previous: _formatNullableString(context, baseline['usbVersion'] as String?),
      current: _formatNullableString(context, s.usbVersion),
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceSpeedLabel,
      previous: Fmt.speedLabel(baseline['speed'] as String?),
      current: Fmt.speedLabel(s.speed),
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceInterfacesLabel,
      previous: _asInt(baseline['interfaceCount'])?.toString() ?? context.l10n.unknown,
      current: '${s.interfaceCount}',
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceConfigurationsLabel,
      previous: _asInt(baseline['configurationCount'])?.toString() ?? context.l10n.unknown,
      current: '${s.configurationCount}',
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceMaxPowerShortLabel,
      previous: _formatMilliampLabel(context, _asInt(baseline['maxPowerMa'])),
      current: _formatMilliampLabel(context, s.maxPowerMa),
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceAndroidDeviceIdLabel,
      previous: _asInt(baseline['deviceId'])?.toString() ?? context.l10n.unknown,
      current: s.deviceId?.toString() ?? context.l10n.unknown,
    ),
    _makeReconnectDiffField(
      label: context.l10n.devicePortNumberLabel,
      previous: _asInt(baseline['portNumber'])?.toString() ?? context.l10n.unknown,
      current: s.portNumber?.toString() ?? context.l10n.unknown,
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceSerialLabel,
      previous: _formatNullableString(context, baseline['serialNumber'] as String?),
      current: _formatNullableString(context, s.serialNumber),
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceStableIdentityLabel,
      previous: _formatNullableString(context, baseline['stableIdentityKey'] as String?),
      current: _formatNullableString(context, s.stableIdentityKey),
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceIdentityConfidenceLabel,
      previous: _identityConfidenceLabel(context, baseline['identityConfidence'] as String?),
      current: _identityConfidenceLabel(context, s.identityConfidence),
    ),
    _makeReconnectDiffField(
      label: context.l10n.devicePhysicalLocationLabel,
      previous: _formatNullableString(context, baseline['physicalLocationKey'] as String?),
      current: _formatNullableString(context, s.physicalLocationKey),
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceInterfaceFingerprintLabel,
      previous: _formatNullableString(context, baseline['interfaceFingerprint'] as String?),
      current: _formatNullableString(context, s.interfaceFingerprint),
    ),
    _makeReconnectDiffField(
      label: context.l10n.deviceInputSourcesLabel,
      previous: _formatStringList(context, baseline['inputSources']),
      current: _formatStringList(context, s.inputSources),
    ),
  ];
  return fields.whereType<_ReconnectDiffField>().where((field) => field.changed).toList(growable: false);
}

_ReconnectDiffField? _makeReconnectDiffField({
  required String label,
  required String previous,
  required String current,
}) {
  final previousNorm = previous.trim().toLowerCase();
  final currentNorm = current.trim().toLowerCase();
  if (previousNorm.isEmpty && currentNorm.isEmpty) return null;
  return _ReconnectDiffField(
    label: label,
    previous: previous,
    current: current,
    changed: previousNorm != currentNorm,
  );
}

String _reconnectBaselineLabel(BuildContext context, DateTime? baselineTime) {
  if (baselineTime == null) return context.l10n.devicePreviousCaptureLabel;
  final local = baselineTime.toLocal();
  final localizations = MaterialLocalizations.of(context);
  final alwaysUse24HourFormat = MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ?? true;
  final date = localizations.formatMediumDate(local);
  final time = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
    alwaysUse24HourFormat: alwaysUse24HourFormat,
  );
  return context.l10n.deviceCaptureFrom(date, time);
}

String _permissionGrantedLabel(BuildContext context, bool granted) =>
    granted ? context.l10n.deviceRuntimeStatusGranted : context.l10n.devicePermissionNotGranted;

String _formatMilliampLabel(BuildContext context, int? value) => value == null ? context.l10n.unknown : '$value mA';

String _formatStringList(BuildContext context, List<String>? values) {
  final list = (values ?? const <String>[]).map((value) => value.trim()).where((value) => value.isNotEmpty).toList(growable: false);
  return list.isEmpty ? context.l10n.unknown : list.join(', ');
}

List<_FrameworkLimitation> _collectFrameworkLimitations({
  required UsbDeviceSummary summary,
  required List<Map<String, dynamic>> availabilityIssues,
  required Map<String, dynamic> audio,
  required Map<String, dynamic> midi,
}) {
  final limitations = <_FrameworkLimitation>[];
  final seen = <String>{};

  void add({
    required String code,
    required String title,
    required String summary,
    required String impact,
  }) {
    if (!seen.add(code)) return;
    limitations.add(
      _FrameworkLimitation(
        code: code,
        title: title,
        summary: summary,
        impact: impact,
      ),
    );
  }

  for (final issue in availabilityIssues) {
    final reasonCode = (issue['reasonCode'] as String?)?.trim();
    switch (reasonCode) {
      case 'framework_hidden_topology_entry':
        add(
          code: reasonCode!,
          title: 'Hidden from UsbManager enumeration',
          summary: 'This device exists in the USB topology, but Android does not expose it as a normal `UsbManager` device.',
          impact: 'You can inspect topology hints, but not request normal framework USB access for this entry.',
        );
      case 'selinux_sysfs_restriction':
        add(
          code: reasonCode!,
          title: 'Blocked by SELinux / sysfs restrictions',
          summary: 'Linux sysfs shows the device path, but Android security policy blocks direct reads from that topology entry.',
          impact: 'Parent/child location can be shown, but raw descriptors and live reads stay unavailable.',
        );
      case 'framework_not_exposed':
        add(
          code: reasonCode!,
          title: 'Raw descriptors not exposed by Android',
          summary: 'Android has the device open, but this build does not expose the raw USB descriptor blob through the framework.',
          impact: 'Descriptor tree, string indexing context, and some class-specific parsing may stay partial or missing.',
        );
      case 'hid_report_unavailable':
        add(
          code: reasonCode!,
          title: 'HID report descriptor hidden',
          summary: 'The HID interface is present, but Android did not return a report descriptor for it.',
          impact: 'The app can show HID presence, but not the full report-byte layout for that interface.',
        );
      case 'device_disconnected_or_framework_error':
        add(
          code: reasonCode!,
          title: 'Direct framework reads failed',
          summary: 'The device is known to Android, but direct framework access failed during advanced USB reads.',
          impact: 'Advanced sections such as descriptor bytes, strings, or live state may be incomplete until the next successful read.',
        );
    }
  }

  final audioNote = (audio['availabilityNote'] as String?)?.trim() ?? '';
  if (audioNote.isNotEmpty && audio['platformAvailable'] == false) {
    add(
      code: 'audio_manager_unavailable',
      title: 'AudioManager USB introspection unavailable',
      summary: audioNote,
      impact: 'Android audio endpoint metadata such as routes, formats, and matched audio endpoints cannot be shown here.',
    );
  } else if (audioNote.isNotEmpty &&
      (audio['isUsbAudioClass'] == true || _asList(audio['matchedEndpoints']).isEmpty) &&
      audioNote.toLowerCase().contains('android framework does not expose')) {
    add(
      code: 'audio_manager_not_exposed',
      title: 'USB audio endpoint not exposed by Android',
      summary: audioNote,
      impact: 'The device may be a USB audio peripheral, but Android is not surfacing a matchable `AudioDeviceInfo` endpoint.',
    );
  }

  final midiNote = (midi['availabilityNote'] as String?)?.trim() ?? '';
  if (midiNote.isNotEmpty && midi['platformAvailable'] == false) {
    add(
      code: 'midi_manager_unavailable',
      title: 'MidiManager introspection unavailable',
      summary: midiNote,
      impact: 'Android MIDI transport, port, and matched-device metadata cannot be shown on this device.',
    );
  } else if (midiNote.isNotEmpty &&
      ((midi['probableUsbMidi'] == true) || _asList(midi['matchedDevices']).isEmpty) &&
      (midiNote.toLowerCase().contains('android framework does not expose') ||
          midiNote.toLowerCase().contains('no matching midimanager device'))) {
    add(
      code: 'midi_manager_not_exposed',
      title: 'USB MIDI endpoint not exposed by Android',
      summary: midiNote,
      impact: 'The app can detect MIDI-like USB descriptors, but Android is not surfacing a matchable `MidiManager` device.',
    );
  }

  if (summary.isHiddenDevice) {
    add(
      code: 'hidden_topology_entry',
      title: 'Topology-only device view',
      summary: 'This entry comes from sysfs topology inspection rather than the normal Android USB framework.',
      impact: 'It helps reveal hidden hubs and downstream nodes, but it will always have less direct framework metadata than a normal `UsbManager` device.',
    );
  }

  return limitations;
}

DeviceHistoryEntry? _findMatchingHistoryEntry(UsbDeviceSummary summary, List<DeviceHistoryEntry> items) {
  final stableKey = (summary.stableIdentityKey ?? '').trim();
  final continuityKeys = (summary.continuityKeys ?? const <String>[]).toSet();
  for (final entry in items) {
    if (stableKey.isNotEmpty && (entry.stableIdentityKey ?? '').trim() == stableKey) {
      return entry;
    }
    final entryKeys = (entry.continuityKeys ?? const <String>[]).toSet();
    if (continuityKeys.intersection(entryKeys).isNotEmpty) {
      return entry;
    }
  }
  return null;
}

String _identityConfidenceLabel(BuildContext context, String? confidence) {
  switch (confidence) {
    case 'high':
      return context.l10n.deviceIdentityConfidenceHigh;
    case 'medium':
      return context.l10n.deviceIdentityConfidenceMedium;
    case 'low':
      return context.l10n.deviceIdentityConfidenceLow;
    default:
      return context.l10n.unknown;
  }
}

String _identityStrategyLabel(BuildContext context, String? strategy) {
  switch (strategy) {
    case 'serial_number':
      return context.l10n.deviceIdentityStrategySerialNumber;
    case 'physical_port':
      return context.l10n.deviceIdentityStrategyPhysicalPort;
    case 'interface_fingerprint':
      return context.l10n.deviceIdentityStrategyInterfaceFingerprint;
    case 'model_fingerprint':
      return context.l10n.deviceIdentityStrategyModelFingerprint;
    default:
      return context.l10n.unknown;
  }
}

String _availabilityScopeLabel(String? scope) {
  switch (scope) {
    case 'device':
      return 'Device presence';
    case 'usb_permission':
      return 'USB permission';
    case 'usb_open':
      return 'USB device open';
    case 'direct_usb_details':
      return 'Raw descriptors and state';
    case 'raw_descriptors':
      return 'Raw descriptors';
    case 'string_descriptors':
      return 'String descriptors';
    case 'hid_reports':
      return 'HID reports';
    case 'usb_access':
      return 'Framework USB access';
    case 'direct_audio_capture':
      return 'Direct audio capture';
    case 'usb_video':
      return 'USB video access';
    default:
      return 'Availability';
  }
}

class _ReconnectDiffTile extends StatelessWidget {
  const _ReconnectDiffTile({required this.field});

  final _ReconnectDiffField field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Text(
          'Previous: ${field.previous}',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          'Current: ${field.current}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: field.changed ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: field.changed ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _FrameworkLimitationTile extends StatelessWidget {
  const _FrameworkLimitationTile({required this.limitation});

  final _FrameworkLimitation limitation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.visibility_off_rounded,
            color: theme.colorScheme.onTertiaryContainer,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(limitation.title, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(limitation.summary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text(
                'Impact: ${limitation.impact}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                limitation.code,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _midiProtocolLabel(int? protocol) {
  switch (protocol) {
    case null:
      return 'Unknown';
    case -1:
      return 'Unknown';
    case 1:
      return 'MIDI 1.0';
    case 2:
      return 'MIDI 2.0';
    case 17:
      return 'UMP MIDI 1.0 up to 64-bit';
    case 18:
      return 'UMP MIDI 1.0 up to 128-bit';
    case 33:
      return 'UMP MIDI 2.0 up to 64-bit';
    case 34:
      return 'UMP MIDI 2.0 up to 128-bit';
    default:
      return '$protocol';
  }
}
