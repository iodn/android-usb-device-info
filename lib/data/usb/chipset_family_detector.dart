import 'models.dart';

class ChipsetFamilyMatch {
  const ChipsetFamilyMatch({
    required this.family,
    required this.confidence,
    required this.reason,
  });

  final String family;
  final String confidence;
  final String reason;
}

ChipsetFamilyMatch? detectChipsetFamily({
  required UsbDeviceSummary summary,
  required List<UsbInterfaceInfo> interfaces,
  String? vendorName,
  String? productName,
}) {
  final vid = summary.vendorId & 0xffff;
  final pid = summary.productId & 0xffff;
  final productText = _norm(productName ?? summary.productName);
  final vendorText = _norm(vendorName ?? summary.manufacturerName);
  final caps = (summary.capabilities ?? const <String>[])
      .map((value) => value.toLowerCase())
      .toSet();
  final sig = interfaces
      .map((iface) =>
          '${iface.interfaceClass}:${iface.interfaceSubclass}:${iface.interfaceProtocol}')
      .toSet();

  bool hasSig(int cls, int sub, int proto) =>
      sig.contains('$cls:$sub:$proto');
  bool hasClass(int cls) =>
      summary.deviceClass == cls ||
      interfaces.any((iface) => iface.interfaceClass == cls);

  switch (vid) {
    case 0x0403:
      return const ChipsetFamilyMatch(
        family: 'FTDI FT232/FT2232 family',
        confidence: 'high',
        reason: 'VID 0403 is assigned to FTDI and commonly identifies FT232/FT2232/FT4232 USB bridge devices.',
      );
    case 0x10C4:
      return const ChipsetFamilyMatch(
        family: 'Silicon Labs CP210x family',
        confidence: 'high',
        reason: 'VID 10C4 is strongly associated with Silicon Labs CP210x USB UART bridges.',
      );
    case 0x1A86:
      return const ChipsetFamilyMatch(
        family: 'QinHeng CH34x/CH91xx family',
        confidence: 'high',
        reason: 'VID 1A86 is commonly used by QinHeng/WCH serial bridge controllers such as CH340 and related families.',
      );
    case 0x067B:
      return const ChipsetFamilyMatch(
        family: 'Prolific PL2303 family',
        confidence: 'high',
        reason: 'VID 067B is widely used by Prolific PL2303 USB serial bridge variants.',
      );
    case 0x0B95:
      return ChipsetFamilyMatch(
        family: 'ASIX AX88xxx family',
        confidence: hasClass(2) || caps.contains('cdc') ? 'high' : 'medium',
        reason: hasClass(2) || caps.contains('cdc')
            ? 'VID 0B95 plus communications/network-style interfaces strongly suggests an ASIX USB Ethernet controller.'
            : 'VID 0B95 maps to ASIX, often used for AX88179/AX88772 USB Ethernet chipsets.',
      );
    case 0x0BDA:
      if (productText.contains('rtl815') || productText.contains('815')) {
        return const ChipsetFamilyMatch(
          family: 'Realtek RTL815x family',
          confidence: 'high',
          reason: 'Realtek VID 0BDA with RTL815x-style product naming indicates a USB Ethernet controller from the RTL8152/RTL8153 family.',
        );
      }
      return ChipsetFamilyMatch(
        family: 'Realtek USB peripheral family',
        confidence: hasClass(2) ? 'medium' : 'low',
        reason: hasClass(2)
            ? 'VID 0BDA with communications interfaces likely indicates a Realtek USB network controller family.'
            : 'VID 0BDA belongs to Realtek, but the exact controller family is ambiguous from current descriptors.',
      );
    case 0x0424:
      return ChipsetFamilyMatch(
        family: caps.contains('hub')
            ? 'Microchip/SMSC USB hub family'
            : 'Microchip/SMSC USB controller family',
        confidence: caps.contains('hub') ? 'high' : 'medium',
        reason: caps.contains('hub')
            ? 'VID 0424 with hub capability commonly points to Microchip/SMSC USB hub silicon.'
            : 'VID 0424 is used by SMSC/Microchip USB networking and hub controller families.',
      );
    case 0x05E3:
      return ChipsetFamilyMatch(
        family: caps.contains('hub')
            ? 'Genesys Logic hub family'
            : 'Genesys Logic USB controller family',
        confidence: caps.contains('hub') ? 'high' : 'medium',
        reason: caps.contains('hub')
            ? 'VID 05E3 with hub capability strongly suggests a Genesys Logic USB hub controller.'
            : 'VID 05E3 belongs to Genesys Logic, commonly used for hubs and storage-related USB bridge silicon.',
      );
    case 0x152D:
      return ChipsetFamilyMatch(
        family: 'JMicron JMS57x/JMS58x family',
        confidence: caps.contains('storage') ? 'high' : 'medium',
        reason: caps.contains('storage')
            ? 'VID 152D with mass-storage behavior strongly suggests a JMicron SATA/NVMe USB bridge controller.'
            : 'VID 152D belongs to JMicron USB bridge silicon, often from the JMS57x/JMS58x family.',
      );
    case 0x04B4:
      return ChipsetFamilyMatch(
        family: 'Cypress/Infineon EZ-USB family',
        confidence: hasClass(255) ? 'high' : 'medium',
        reason: hasClass(255)
            ? 'VID 04B4 with vendor-specific interfaces strongly suggests Cypress/Infineon EZ-USB FX2/FX3 family silicon.'
            : 'VID 04B4 belongs to Cypress/Infineon and is commonly used by EZ-USB controller families.',
      );
    case 0x0D8C:
      return const ChipsetFamilyMatch(
        family: 'C-Media USB audio family',
        confidence: 'high',
        reason: 'VID 0D8C is widely associated with C-Media USB audio codec/controller families.',
      );
    case 0x20B1:
      return ChipsetFamilyMatch(
        family: 'XMOS USB audio family',
        confidence: hasClass(1) ? 'high' : 'medium',
        reason: hasClass(1)
            ? 'VID 20B1 with USB audio interfaces strongly suggests an XMOS-based USB audio controller.'
            : 'VID 20B1 is commonly associated with XMOS USB interface silicon.',
      );
    case 0x534D:
      if (hasClass(14) || caps.contains('video')) {
        return const ChipsetFamilyMatch(
          family: 'MacroSilicon video capture family',
          confidence: 'medium',
          reason: 'VID 534D with UVC/video interfaces often indicates a MacroSilicon capture bridge family.',
        );
      }
      break;
    case 0x0C45:
      if (hasClass(14) || caps.contains('video')) {
        return const ChipsetFamilyMatch(
          family: 'Sonix webcam family',
          confidence: 'medium',
          reason: 'VID 0C45 with USB video interfaces often maps to Sonix webcam controller families.',
        );
      }
      break;
  }

  if ((hasSig(2, 2, 1) || hasSig(2, 2, 0)) &&
      (productText.contains('cp210') ||
          productText.contains('ch340') ||
          productText.contains('pl2303') ||
          productText.contains('ft232'))) {
    return ChipsetFamilyMatch(
      family: 'USB serial bridge family',
      confidence: 'medium',
      reason:
          'CDC/serial-style interfaces plus product naming suggest a USB UART bridge chipset family.',
    );
  }

  if (hasClass(14) &&
      (productText.contains('uvc') ||
          productText.contains('camera') ||
          productText.contains('capture'))) {
    return const ChipsetFamilyMatch(
      family: 'USB video/UVC controller family',
      confidence: 'low',
      reason:
          'USB video interfaces plus product naming suggest a UVC controller family, but the exact chipset is not identifiable from current metadata.',
    );
  }

  if (hasClass(1) &&
      (vendorText.contains('c-media') ||
          vendorText.contains('xmos') ||
          productText.contains('dac') ||
          productText.contains('audio'))) {
    return const ChipsetFamilyMatch(
      family: 'USB audio controller family',
      confidence: 'low',
      reason:
          'USB audio interfaces plus vendor/product naming suggest an identifiable USB audio controller family, but not a single exact chipset line.',
    );
  }

  return null;
}

String _norm(String? value) =>
    (value ?? '').trim().toLowerCase();
