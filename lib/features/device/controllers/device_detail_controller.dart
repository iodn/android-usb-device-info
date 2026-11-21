import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/usb/models.dart';
import '../../../data/usb/providers.dart';
import '../../../data/usb/usb_repository.dart';

const MethodChannel _usbMethods = MethodChannel('usbdevinfo/methods');

final deviceDetailControllerProvider =
    FutureProvider.autoDispose.family<UsbDeviceDetailViewData, String>(
  (ref, deviceName) async {
    final raw = ref.watch(deviceDetailRawControllerProvider(deviceName).future);
    final repo = ref.watch(usbRepositoryProvider);
    return repo.enrichDeviceDetails(UsbDeviceDetails.fromMap(await raw));
  },
);

final deviceDetailRawControllerProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, deviceName) => ref.watch(usbPlatformServiceProvider).getDeviceDetails(deviceName),
);

typedef PermissionDiagnosticsArgs = ({
  String deviceName,
  int vendorId,
  int productId,
  bool isAudioClass,
  bool needsMicrophonePermission,
  bool isVideo,
  bool isInputDevice,
  bool isHiddenDevice,
  int deviceClass,
  bool hasUsbPermission,
});

final runtimePermissionDiagnosticsProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, PermissionDiagnosticsArgs>((ref, args) async {
  try {
    final res = await _usbMethods.invokeMethod<dynamic>(
      'getRuntimePermissionDiagnostics',
      {
        'deviceName': args.deviceName,
        'vendorId': args.vendorId,
        'productId': args.productId,
        'isAudio': args.isAudioClass,
        'needsMicrophonePermission': args.needsMicrophonePermission,
        'isVideo': args.isVideo,
        'isInputDevice': args.isInputDevice,
        'isHiddenDevice': args.isHiddenDevice,
        'deviceClass': args.deviceClass,
        'hasUsbPermission': args.hasUsbPermission,
      },
    );
    if (res is Map<String, dynamic>) return res;
    if (res is Map) return res.cast<String, dynamic>();
    return <String, dynamic>{};
  } catch (_) {
    return <String, dynamic>{};
  }
});
