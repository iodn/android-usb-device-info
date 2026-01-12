import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/formatters.dart';
import '../../data/usb/usb_repository.dart';
import '../device/device_detail_screen.dart';
import '../history/controllers/device_history_controller.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import 'controllers/device_list_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const routeName = 'home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(deviceListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('USBDevInfo'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () => context.goNamed(HistoryScreen.routeName),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.goNamed(SettingsScreen.routeName),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _searchController,
              onChanged: (q) => ref.read(deviceListControllerProvider.notifier).setQuery(q),
              onClear: () {
                _searchController.clear();
                ref.read(deviceListControllerProvider.notifier).setQuery('');
              },
            ),
            Expanded(
              child: devicesAsync.when(
                data: (items) => _DeviceList(items: items),
                loading: () => const _LoadingState(),
                error: (e, st) => _ErrorState(error: e.toString()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(deviceListControllerProvider.notifier).refresh(),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Refresh'),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final isEmpty = value.text.isEmpty;
          return TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search vendor, product, VID:PID, device path…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
      ),
    );
  }
}

class _DeviceList extends ConsumerWidget {
  const _DeviceList({required this.items});
  final List<UsbDeviceListItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const _EmptyState();
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(deviceListControllerProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, idx) => _DeviceTile(item: items[idx]),
      ),
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  const _DeviceTile({required this.item});
  final UsbDeviceListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = item.device;
    final title = item.productName ?? d.productName ?? (d.isInputDevice ? 'Input device' : 'USB Device');
    final subtitle = item.vendorName ?? d.manufacturerName ?? item.deviceClassName ?? 'Unknown vendor';
    final idLine = '${Fmt.hex16(d.vendorId)} : ${Fmt.hex16(d.productId)}';

    final isInput = d.isInputDevice;
    final sources = d.inputSources ?? const <String>[];

    final permissionChip = isInput
        ? _StatusChip(
            label: sources.isEmpty ? 'Input device' : 'Input: ${sources.join(', ')}',
            icon: sources.contains('mouse')
                ? Icons.mouse_rounded
                : sources.contains('keyboard')
                    ? Icons.keyboard_rounded
                    : Icons.input_rounded,
            tonal: true,
          )
        : (d.hasPermission
            ? const _StatusChip(label: 'Permission granted', icon: Icons.verified_rounded)
            : const _StatusChip(label: 'Needs permission', icon: Icons.lock_outline_rounded, tonal: true));

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        await ref.read(deviceHistoryControllerProvider.notifier).recordFromListItem(item);
        if (!context.mounted) return;
        final enc = Uri.encodeComponent(d.deviceName);
        context.goNamed(DeviceDetailScreen.routeName, pathParameters: {'id': enc});
      },
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DeviceAvatar(
                deviceClass: d.deviceClass,
                isInput: isInput,
                sources: sources,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _InfoPill(icon: Icons.fingerprint_rounded, label: idLine),
                        _InfoPill(
                          icon: Icons.usb_rounded,
                          label: isInput ? 'Input path' : '${d.interfaceCount} interfaces',
                        ),
                        permissionChip,
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      d.deviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceAvatar extends StatelessWidget {
  const _DeviceAvatar({
    required this.deviceClass,
    required this.isInput,
    required this.sources,
  });

  final int deviceClass;
  final bool isInput;
  final List<String> sources;

  IconData _iconForClass() {
    if (isInput) {
      if (sources.contains('mouse')) return Icons.mouse_rounded;
      if (sources.contains('keyboard')) return Icons.keyboard_alt_rounded;
      return Icons.input_rounded;
    }
    switch (deviceClass) {
      case 3:
        return Icons.mouse_rounded;
      case 8:
        return Icons.storage_rounded;
      case 9:
        return Icons.hub_rounded;
      case 1:
        return Icons.headset_rounded;
      case 2:
        return Icons.router_rounded;
      case 6:
        return Icons.photo_camera_rounded;
      case 7:
        return Icons.print_rounded;
      case 14:
        return Icons.videocam_rounded;
      default:
        return Icons.usb_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconForClass();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    this.tonal = false,
  });

  final String label;
  final IconData icon;
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      children: [
        Icon(Icons.usb_off_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(
          'No USB devices detected',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Connect a USB device (OTG) or a USB accessory, then pull to refresh.\n\n'
          'Tip: grant permission per device to read strings, parse raw descriptors, '
          'and enumerate full configurations/interfaces/endpoints.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Failed to load devices:\n$error'),
      ),
    );
  }
}
