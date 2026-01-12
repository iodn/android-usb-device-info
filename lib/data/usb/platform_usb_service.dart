import 'dart:async';
import 'package:flutter/services.dart';

import 'models.dart';

class UsbPlatformService {
 static const MethodChannel _method = MethodChannel('usbdevinfo/methods');
 static const EventChannel _events = EventChannel('usbdevinfo/events');

 Stream<UsbEvent>? _cachedEventStream;

  Stream<UsbEvent> events() {
    _cachedEventStream ??= _events.receiveBroadcastStream().map((dynamic e) {
      final map = (e as Map<Object?, Object?>?) ?? const {};
      return UsbEvent.fromMap(map);
    });
    return _cachedEventStream!;
  }

  Future<List<UsbDeviceSummary>> listDevices() async {
    final raw = await _method.invokeMethod<List<dynamic>>('listDevices');
    final list = raw ?? const <dynamic>[];
    return list
        .whereType<Map<Object?, Object?>>()
        .map(UsbDeviceSummary.fromMap)
        .toList();
  }

  Future<bool> requestPermission(String deviceName) async {
    final ok = await _method.invokeMethod<bool>('requestPermission', {
      'deviceName': deviceName,
    });
    return ok ?? false;
  }

  Future<UsbDeviceDetails> getDeviceDetails(String deviceName) async {
   final raw = await _method.invokeMethod<Map<dynamic, dynamic>>('getDeviceDetails', {
     'deviceName': deviceName,
   });
   return UsbDeviceDetails.fromMap((raw ?? const <dynamic, dynamic>{}).cast<Object?, Object?>());
 }

 Future<void> setUsbAttachComponentEnabled(bool enabled) async {
   try {
     await _method.invokeMethod('setUsbAttachComponentEnabled', {
       'enabled': enabled,
     });
   } catch (_) {}
 }
}
