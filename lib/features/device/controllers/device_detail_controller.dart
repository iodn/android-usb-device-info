import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/usb/providers.dart';
import '../../../data/usb/usb_repository.dart';

const MethodChannel _usbMethods = MethodChannel('usbdevinfo/methods');

final deviceDetailControllerProvider =
    FutureProvider.autoDispose.family<UsbDeviceDetailViewData, String>(
  (ref, deviceName) async {
    await ref.watch(usbIdsDbProvider.future);
    final repo = ref.read(usbRepositoryProvider);
    return repo.getDeviceDetailsEnriched(deviceName);
  },
);

final deviceDetailRawControllerProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, deviceName) async {
    try {
      final res = await _usbMethods.invokeMethod<dynamic>(
        'getDeviceDetails',
        {'deviceName': deviceName},
      );

      if (res is Map<String, dynamic>) return res;
      if (res is Map) return res.cast<String, dynamic>();
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  },
);
