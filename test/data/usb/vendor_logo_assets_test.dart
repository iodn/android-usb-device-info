import 'package:USBDevInfo/core/widgets/device_vendor_avatar.dart';
import 'package:USBDevInfo/data/usb/vendor_logo_assets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every mapped vendor logo is bundled and decodes as SVG', () async {
    final paths = vendorLogoAssets.values
        .map((name) => 'assets/vendor_logos/$name.svg')
        .toSet();
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(
      manifest.listAssets().where(
        (path) => path.startsWith('assets/vendor_logos/'),
      ),
      unorderedEquals(paths),
    );
    for (final path in paths) {
      final picture = await vg.loadPicture(SvgAssetLoader(path), null);
      expect(picture.size.isEmpty, isFalse, reason: path);
      picture.picture.dispose();
    }
  });

  testWidgets('shows a known vendor SVG and keeps the unknown device icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            DeviceVendorAvatar(
              vendorId: 0x0781,
              fallbackIcon: Icons.storage_rounded,
            ),
            DeviceVendorAvatar(
              vendorId: 0,
              fallbackIcon: Icons.keyboard_alt_rounded,
            ),
          ],
        ),
      ),
    );
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(
      (svg.bytesLoader as SvgAssetLoader).assetName,
      'assets/vendor_logos/sandisk.svg',
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_alt_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
