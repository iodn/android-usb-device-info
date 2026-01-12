import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/app_router.dart';
import '../../data/usb/models.dart';
import '../../data/usb/providers.dart';
import '../../data/usb/usb_repository.dart';
import '../../features/device/device_detail_screen.dart';
import '../../features/history/controllers/device_history_controller.dart';
import '../../features/home/controllers/device_list_controller.dart';
import '../../features/home/home_screen.dart';

final usbEventCoordinatorProvider = Provider<void>((ref) {
  bool disposed = false;
  ref.onDispose(() => disposed = true);

  String? autoOpenedDeviceName;
  Future<void> chain = Future.value();

  ref.listen<AsyncValue<UsbEvent>>(usbEventsProvider, (prev, next) {
    final event = next.asData?.value;
    if (event == null || disposed) return;

    chain = chain.then((_) async {
      if (disposed) return;

      await ref.read(usbIdsDbProvider.future);

      final type = event.type.toLowerCase().trim();
      final isAttach = type.contains('attach') || type.contains('connect') || type == 'added';
      final isDetach = type.contains('detach') || type.contains('disconnect') || type == 'removed';

      await ref.read(deviceListControllerProvider.notifier).refresh();

      final dn = (event.deviceName ?? '').trim();
      if (dn.isEmpty) return;

      final router = ref.read(appRouterProvider);

      if (isAttach) {
        try {
          final repo = ref.read(usbRepositoryProvider);
          final items = await repo.listDevicesEnriched();
          final match = items.where((it) => it.device.deviceName == dn).toList();
          if (match.isNotEmpty) {
            await ref.read(deviceHistoryControllerProvider.notifier).recordFromListItem(match.first);
          }
        } catch (_) {}

        autoOpenedDeviceName = dn;
        final enc = Uri.encodeComponent(dn);
        scheduleMicrotask(() {
          router.goNamed(DeviceDetailScreen.routeName, pathParameters: {'id': enc});
        });
        return;
      }

      if (isDetach) {
        if (autoOpenedDeviceName == dn) {
          autoOpenedDeviceName = null;
          scheduleMicrotask(() {
            router.goNamed(HomeScreen.routeName);
          });
        }
      }
    });
  });
});
