import 'package:USBDevInfo/data/usb/models.dart';
import 'package:USBDevInfo/data/usb/usb_repository.dart';
import 'package:USBDevInfo/features/home/controllers/device_list_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'device search accepts the displayed USB IDs and combinations of words',
    () {
      final camera = UsbDeviceListItem(
        device: UsbDeviceSummary.fromMap({
          'deviceName': '/dev/bus/usb/001/002',
          'vendorId': 0x046d,
          'productId': 0x0825,
          'capabilities': ['Video'],
        }),
        vendorName: 'Logitech',
        productName: 'Webcam',
        deviceClassName: 'Video',
      );
      final devices = [camera];

      for (final query in [
        '046D:0825',
        '0x046d:0x0825',
        '  logitech  video ',
      ]) {
        expect(filterUsbDeviceList(devices, query), devices, reason: query);
      }
      expect(filterUsbDeviceList(devices, 'storage'), isEmpty);
    },
  );
}
