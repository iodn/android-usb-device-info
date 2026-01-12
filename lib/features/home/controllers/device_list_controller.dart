import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/usb/providers.dart';
import '../../../data/usb/usb_repository.dart';

final deviceSearchQueryProvider =
    NotifierProvider<DeviceSearchQueryController, String>(DeviceSearchQueryController.new);

class DeviceSearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final deviceListControllerProvider =
    AsyncNotifierProvider<DeviceListController, List<UsbDeviceListItem>>(DeviceListController.new);

class DeviceListController extends AsyncNotifier<List<UsbDeviceListItem>> {
  @override
  Future<List<UsbDeviceListItem>> build() async {
    await ref.watch(usbIdsDbProvider.future);
    return _load();
  }

  Future<List<UsbDeviceListItem>> _load() async {
    final repo = ref.read(usbRepositoryProvider);
    final items = await repo.listDevicesEnriched();

    final q = ref.read(deviceSearchQueryProvider).trim().toLowerCase();
    if (q.isEmpty) return items;

    return items.where((it) {
      final s = it.device;
      final vendor = (it.vendorName ?? s.manufacturerName ?? '').toLowerCase();
      final product = (it.productName ?? s.productName ?? '').toLowerCase();
      final id = '${s.vendorId}:${s.productId}'.toLowerCase();
      return vendor.contains(q) || product.contains(q) || id.contains(q) || s.deviceName.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> setQuery(String q) async {
    ref.read(deviceSearchQueryProvider.notifier).setQuery(q);
    final current = state.asData?.value;
    if (current == null) {
      await refresh();
      return;
    }
    state = AsyncValue.data(await _load());
  }
}
