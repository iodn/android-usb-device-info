import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/usb/providers.dart';
import '../../../data/usb/usb_repository.dart';

final deviceSearchQueryProvider =
    NotifierProvider<DeviceSearchQueryController, String>(
      DeviceSearchQueryController.new,
    );

class DeviceSearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
}

final deviceListControllerProvider =
    AsyncNotifierProvider<DeviceListController, List<UsbDeviceListItem>>(
      DeviceListController.new,
    );

class DeviceListController extends AsyncNotifier<List<UsbDeviceListItem>> {
  @override
  Future<List<UsbDeviceListItem>> build() async {
    final repo = ref.watch(usbRepositoryProvider);
    await ref.watch(usbIdsDbProvider.future);
    return repo.listDevicesEnriched();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await AsyncValue.guard(() => future);
  }
}

List<UsbDeviceListItem> filterUsbDeviceList(
  List<UsbDeviceListItem> items,
  String query,
) {
  final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
  if (terms.singleOrNull == '') return items;
  return items
      .where((item) {
        final device = item.device;
        final vid = device.vendorId.toRadixString(16).padLeft(4, '0');
        final pid = device.productId.toRadixString(16).padLeft(4, '0');
        final searchable = [
          item.vendorName,
          device.manufacturerName,
          item.productName,
          device.productName,
          item.deviceClassName,
          item.likelyFunction?.label,
          device.deviceName,
          ...?device.capabilities,
          ...?device.inputSources,
          if (!device.isAccessory) ...[
            '$vid:$pid',
            '0x$vid:0x$pid',
            '${device.vendorId}:${device.productId}',
          ],
        ].whereType<String>().join(' ').toLowerCase();
        return terms.every(searchable.contains);
      })
      .toList(growable: false);
}
