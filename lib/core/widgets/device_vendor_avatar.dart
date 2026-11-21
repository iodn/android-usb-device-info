import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/usb/vendor_logo_assets.dart';

class DeviceVendorAvatar extends StatelessWidget {
  const DeviceVendorAvatar({
    super.key,
    required this.vendorId,
    required this.fallbackIcon,
    this.size = 48,
  });

  final int vendorId;
  final IconData fallbackIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final logo = vendorLogoAssets[vendorId];
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Center(
        child: Icon(fallbackIcon, color: colors.onPrimaryContainer),
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: logo == null
          ? fallback
          : DecoratedBox(
              decoration: BoxDecoration(
                color: vendorLogosForDarkBackground.contains(logo)
                    ? const Color(0xff212121)
                    : Colors.white,
                borderRadius: BorderRadius.circular(size / 3),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  'assets/vendor_logos/$logo.svg',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => fallback,
                ),
              ),
            ),
    );
  }
}
