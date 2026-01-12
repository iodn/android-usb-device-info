import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/section_card.dart';
import 'controllers/device_history_controller.dart';
import 'history_entry_detail_screen.dart';
import '../home/controllers/device_list_controller.dart';
import 'models/device_history_entry.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  static const routeName = 'history';

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(deviceHistoryControllerProvider);
    final devicesAsync = ref.watch(deviceListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          historyAsync.maybeWhen(
            data: (items) => IconButton(
              tooltip: 'Clear all',
              onPressed: items.isEmpty ? null : () => _confirmClearAll(context),
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
            orElse: () => IconButton(
              tooltip: 'Clear all',
              onPressed: null,
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(error: e.toString()),
          data: (items) {
            final q = _search.text.trim().toLowerCase();
            final filtered = q.isEmpty
                ? items
                : items
                    .where((e) {
                      final title = _titleFor(e).toLowerCase();
                      final subtitle = _subtitleFor(e).toLowerCase();
                      final ids = '${e.vendorId}:${e.productId}'.toLowerCase();
                      return title.contains(q) ||
                          subtitle.contains(q) ||
                          ids.contains(q) ||
                          e.deviceName.toLowerCase().contains(q) ||
                          (e.serialNumber ?? '').toLowerCase().contains(q);
                    })
                    .toList(growable: false);

            final connectedKeys = <String>{};
            final current = devicesAsync.asData?.value;
            if (current != null) {
              for (final it in current) {
                final d = it.device;
                connectedKeys.add(
                  _connectionKey(
                    vendorId: d.vendorId,
                    productId: d.productId,
                    deviceName: d.deviceName,
                    serialNumber: d.serialNumber,
                  ),
                );
              }
            }

            bool isEntryConnected(DeviceHistoryEntry entry) {
              final key = _connectionKey(
                vendorId: entry.vendorId,
                productId: entry.productId,
                deviceName: entry.deviceName,
                serialNumber: entry.serialNumber,
              );
              return connectedKeys.contains(key);
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SectionCard(
                    title: 'Previously inspected devices',
                    subtitle: items.isEmpty ? 'Nothing recorded yet' : '${items.length} item${items.length == 1 ? '' : 's'}',
                    leading: const Icon(Icons.history_rounded),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            items.isEmpty
                                ? 'Open a device info page to record it here.'
                                : 'Swipe left to delete. Use Undo to restore.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.tonalIcon(
                          onPressed: items.isEmpty ? null : () => _confirmClearAll(context),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search name, VID:PID, serial, path…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              onPressed: () {
                                _search.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(hasItems: items.isNotEmpty, query: q)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final entry = filtered[idx];
                            final connected = isEntryConnected(entry);
                            return _HistoryTile(
                              entry: entry,
                              connected: connected,
                              onOpen: () => _openEntry(context, entry),
                              onDelete: () => _deleteOne(context, entry),
                              onDismissed: () => _dismissOne(context, entry, idx),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _titleFor(DeviceHistoryEntry e) {
    return e.productNameResolved ?? e.productNameRaw ?? (e.isInputDevice ? 'Input device' : 'USB device');
  }

  String _subtitleFor(DeviceHistoryEntry e) {
    return e.vendorName ?? e.manufacturerNameRaw ?? 'Unknown vendor';
  }

  void _openEntry(BuildContext context, DeviceHistoryEntry entry) {
    final enc = Uri.encodeComponent(entry.id);
    context.pushNamed(HistoryEntryDetailScreen.routeName, pathParameters: {'id': enc});
  }

  Future<void> _dismissOne(BuildContext context, DeviceHistoryEntry entry, int index) async {
    final removed = await ref.read(deviceHistoryControllerProvider.notifier).removeById(entry.id);
    if (!context.mounted) return;
    if (removed == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from history'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(deviceHistoryControllerProvider.notifier).restore(removed, index: index);
          },
        ),
      ),
    );
  }

  Future<void> _deleteOne(BuildContext context, DeviceHistoryEntry entry) async {
    final removed = await ref.read(deviceHistoryControllerProvider.notifier).removeById(entry.id);
    if (!context.mounted) return;
    if (removed == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from history'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(deviceHistoryControllerProvider.notifier).restore(removed);
          },
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This will remove all recorded devices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(deviceHistoryControllerProvider.notifier).clearAll();
    }
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.connected,
    required this.onOpen,
    required this.onDelete,
    required this.onDismissed,
  });

  final DeviceHistoryEntry entry;
  final bool connected;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = entry.productNameResolved ?? entry.productNameRaw ?? (entry.isInputDevice ? 'Input device' : 'USB device');
    final subtitle = entry.vendorName ?? entry.manufacturerNameRaw ?? 'Unknown vendor';
    final idLine = '${Fmt.hex16(entry.vendorId)} : ${Fmt.hex16(entry.productId)}';
    final dt = DateFormat('MMM d, HH:mm').format(entry.testedAt);

    final connChip = _Chip(
      icon: connected ? Icons.cable_rounded : Icons.cable_outlined,
      label: connected ? 'Connected' : 'Not connected',
      tonal: !connected,
    );

    final permChip = entry.isInputDevice
        ? _Chip(
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
        : (entry.hasPermission
            ? const _Chip(icon: Icons.verified_rounded, label: 'Permission', tonal: false)
            : const _Chip(icon: Icons.lock_outline_rounded, label: 'Needs permission', tonal: true));

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDismissed(),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(entry: entry),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Pill(icon: Icons.fingerprint_rounded, label: idLine),
                          _Pill(icon: Icons.schedule_rounded, label: dt),
                          connChip,
                          permChip,
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        entry.deviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  tooltip: 'Actions',
                  onSelected: (v) {
                    switch (v) {
                      case 'open':
                        onOpen();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'open', child: Text('Open')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.entry});
  final DeviceHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    if (entry.isInputDevice) {
      final src = entry.inputSources ?? const <String>[];
      if (src.contains('mouse')) {
        icon = Icons.mouse_rounded;
      } else if (src.contains('keyboard')) {
        icon = Icons.keyboard_alt_rounded;
      } else {
        icon = Icons.input_rounded;
      }
    } else {
      switch (entry.deviceClass) {
        case 3:
          icon = Icons.mouse_rounded;
          break;
        case 8:
          icon = Icons.storage_rounded;
          break;
        case 9:
          icon = Icons.hub_rounded;
          break;
        case 1:
          icon = Icons.headset_rounded;
          break;
        case 2:
          icon = Icons.router_rounded;
          break;
        case 6:
          icon = Icons.photo_camera_rounded;
          break;
        case 7:
          icon = Icons.print_rounded;
          break;
        case 14:
          icon = Icons.videocam_rounded;
          break;
        default:
          icon = Icons.usb_rounded;
      }
    }
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

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasItems, required this.query});
  final bool hasItems;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = hasItems ? 'No matches' : 'No history yet';
    final body = hasItems ? 'Try a different search term.' : 'Open a device info page to record an entry here.';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      children: [
        Icon(Icons.history_toggle_off_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (hasItems && query.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Query: "$query"',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Failed to load history:\n$error'),
      ),
    );
  }
}
