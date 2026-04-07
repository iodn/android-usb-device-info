import 'models.dart';

class LikelyFunctionMatch {
  const LikelyFunctionMatch({
    required this.label,
    required this.confidence,
    required this.reason,
  });

  final String label;
  final String confidence;
  final String reason;
}

LikelyFunctionMatch? detectLikelyFunction({
  required UsbDeviceSummary summary,
  required List<UsbInterfaceInfo> interfaces,
  String? vendorName,
  String? productName,
}) {
  final caps = (summary.capabilities ?? const <String>[])
      .map((value) => value.toLowerCase())
      .toSet();
  final product = _norm(productName ?? summary.productName);
  final vendor = _norm(vendorName ?? summary.manufacturerName);

  bool hasCap(String value) => caps.contains(value.toLowerCase());
  bool hasClass(int cls) =>
      summary.deviceClass == cls ||
      interfaces.any((iface) => iface.interfaceClass == cls);
  bool hasAudioControl = interfaces.any(
    (iface) => iface.interfaceClass == 1 && iface.interfaceSubclass == 1,
  );
  bool hasAudioStreaming = interfaces.any(
    (iface) => iface.interfaceClass == 1 && iface.interfaceSubclass == 2,
  );
  bool hasMidiStreaming = interfaces.any(
    (iface) => iface.interfaceClass == 1 && iface.interfaceSubclass == 3,
  );
  bool hasCdcAcm = interfaces.any(
    (iface) => iface.interfaceClass == 2 && iface.interfaceSubclass == 2,
  );
  bool hasMassStorage = hasCap('Storage') || hasClass(8);
  bool hasVideo = hasCap('Video') || hasClass(14);
  bool hasAudio = hasCap('Audio') || hasClass(1);
  bool hasMidi = hasCap('MIDI') || hasMidiStreaming;
  bool hasHid = hasCap('HID') || hasClass(3) || summary.isInputDevice;
  bool hasCdc = hasCap('CDC') || hasClass(2) || hasClass(10) || hasCdcAcm;
  bool hasHub = hasCap('Hub') || summary.deviceClass == 9;
  bool composite = hasCap('Composite') || interfaces.length > 1 || summary.deviceClass == 0;

  if (summary.isInputDevice) {
    return const LikelyFunctionMatch(
      label: 'External input peripheral',
      confidence: 'high',
      reason: 'Android exposes this device through the input stack, which strongly suggests a keyboard, mouse, gamepad, or similar HID input peripheral.',
    );
  }

  if (hasHub) {
    return LikelyFunctionMatch(
      label: 'USB hub',
      confidence: composite ? 'high' : 'medium',
      reason: composite
          ? 'Hub capability dominates the topology role even if the device also exposes additional management interfaces.'
          : 'The device advertises hub-class behavior.',
    );
  }

  if (hasVideo && hasAudio) {
    return const LikelyFunctionMatch(
      label: 'AV capture / webcam device',
      confidence: 'high',
      reason: 'Combined USB video and audio interfaces are typical of webcams, HDMI capture dongles, and other AV capture devices.',
    );
  }

  if (hasMidi && hasAudio) {
    return const LikelyFunctionMatch(
      label: 'USB audio + MIDI interface',
      confidence: 'high',
      reason: 'Audio-class streaming plus MIDI streaming interfaces usually indicate a USB audio interface, mixer, or music-production device.',
    );
  }

  if (hasMassStorage && hasHid) {
    return const LikelyFunctionMatch(
      label: 'Storage device with control/input interface',
      confidence: 'medium',
      reason: 'Mass-storage plus HID/control interfaces often indicate card readers, docking stations, encrypted drives, or devices with buttons/management channels.',
    );
  }

  if (hasCdc && hasMassStorage) {
    return const LikelyFunctionMatch(
      label: 'Dock / adapter with storage and communications',
      confidence: 'medium',
      reason: 'Communications plus storage interfaces often show up in docks, combo adapters, and multifunction bridge devices.',
    );
  }

  if (hasCdcAcm ||
      product.contains('serial') ||
      product.contains('uart') ||
      product.contains('console')) {
    return const LikelyFunctionMatch(
      label: 'USB serial / UART adapter',
      confidence: 'high',
      reason: 'CDC ACM or serial-oriented product naming strongly suggests a USB serial bridge or console adapter.',
    );
  }

  if (hasMassStorage &&
      (product.contains('sata') ||
          product.contains('nvme') ||
          product.contains('ssd') ||
          product.contains('enclosure') ||
          vendor.contains('jmicron'))) {
    return const LikelyFunctionMatch(
      label: 'Storage bridge / enclosure',
      confidence: 'high',
      reason: 'Mass-storage behavior plus bridge/enclosure naming strongly suggests a USB-to-SATA or USB-to-NVMe storage bridge.',
    );
  }

  if (hasMassStorage) {
    return const LikelyFunctionMatch(
      label: 'Mass-storage device',
      confidence: 'medium',
      reason: 'Mass-storage is the dominant exposed function.',
    );
  }

  if (hasVideo) {
    return const LikelyFunctionMatch(
      label: 'USB video device',
      confidence: 'medium',
      reason: 'Video-class interfaces dominate the exposed USB function.',
    );
  }

  if (hasAudio && hasAudioStreaming && hasAudioControl) {
    return const LikelyFunctionMatch(
      label: 'USB audio device',
      confidence: 'high',
      reason: 'Audio control plus audio streaming interfaces are the typical signature of a USB sound card, headset, DAC, or speakerphone.',
    );
  }

  if (hasAudio) {
    return const LikelyFunctionMatch(
      label: 'USB audio peripheral',
      confidence: 'medium',
      reason: 'Audio-class capability is the dominant exposed function.',
    );
  }

  if (hasMidi) {
    return const LikelyFunctionMatch(
      label: 'USB MIDI device',
      confidence: 'medium',
      reason: 'MIDI streaming interfaces are the dominant exposed function.',
    );
  }

  if (hasHid && composite) {
    return const LikelyFunctionMatch(
      label: 'Composite HID peripheral',
      confidence: 'medium',
      reason: 'The device exposes multiple interfaces, with HID being the most obvious end-user function.',
    );
  }

  if (hasHid) {
    return const LikelyFunctionMatch(
      label: 'HID peripheral',
      confidence: 'medium',
      reason: 'HID is the dominant exposed function.',
    );
  }

  if (hasCdc) {
    return const LikelyFunctionMatch(
      label: 'Communications / networking adapter',
      confidence: 'medium',
      reason: 'CDC-style communications interfaces dominate the exposed function.',
    );
  }

  if (composite) {
    return const LikelyFunctionMatch(
      label: 'Multifunction composite USB device',
      confidence: 'low',
      reason: 'The device exposes multiple interface families, but none is dominant enough to classify more specifically from current metadata.',
    );
  }

  return null;
}

String _norm(String? value) => (value ?? '').trim().toLowerCase();
