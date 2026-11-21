import 'package:USBDevInfo/core/theme/theme_mode_controller.dart';
import 'package:USBDevInfo/data/usb/models.dart';
import 'package:USBDevInfo/data/usb/usb_repository.dart';
import 'package:USBDevInfo/features/history/controllers/device_history_controller.dart';
import 'package:USBDevInfo/features/history/models/device_history_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('accessory history preserves metadata without carrying serials between grants', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWith(
          (ref) => SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(deviceHistoryControllerProvider.future);
    final history = container.read(deviceHistoryControllerProvider.notifier);

    const path = 'accessory:example';
    final summary = {
      'deviceName': path,
      'manufacturerName': 'Example',
      'productName': 'Test accessory',
      'deviceRelease': '2.1',
    };
    final publicItem = UsbDeviceListItem(
      device: UsbDeviceSummary.fromMap(summary),
      vendorName: 'Example',
      productName: 'Test accessory',
      deviceClassName: null,
    );
    final raw = <String, dynamic>{
      'summary': {...summary, 'hasPermission': true, 'serialNumber': 'A-42'},
      'accessory': {'description': 'Dock', 'uri': 'https://example.com/dock'},
    };

    await history.recordFromListItem(publicItem);
    await history.recordFromView(
      UsbDeviceDetailViewData(
        details: UsbDeviceDetails.fromMap(raw),
        vendorName: 'Example',
        productName: 'Test accessory',
        deviceClassName: null,
        deviceSubclassName: null,
        deviceProtocolName: null,
        interfaceClassNames: const [],
      ),
      raw: raw,
    );
    await history.recordFromListItem(publicItem);

    final entries = container
        .read(deviceHistoryControllerProvider)
        .requireValue;
    final publicEntry = entries.singleWhere((entry) => entry.id == path);
    final authorized = entries.singleWhere(
      (entry) => entry.serialNumber == 'A-42',
    );
    expect(publicEntry.serialNumber, isNull);
    expect(publicEntry.hasPermission, isFalse);
    expect(authorized.accessory, {
      'version': '2.1',
      'description': 'Dock',
      'uri': 'https://example.com/dock',
    });
    expect(
      DeviceHistoryEntry.fromMap(authorized.copyWith().toMap()).accessory,
      authorized.accessory,
    );
  });
}
