enum DevicePermissionState {
  missing,
  granted,
  temporarilyDenied,
  permanentlyDenied,
  reenumerated,
  unavailable,
  notApplicable,
  revoked,
}

class DevicePermissionStatus {
  const DevicePermissionStatus({
    required this.label,
    required this.state,
    required this.detail,
  });

  final String label;
  final DevicePermissionState state;
  final String detail;
}

bool deviceNeedsMicrophonePermission({
  required bool isAudioClass,
  required Map<String, dynamic> audio,
}) {
  if (!isAudioClass) return false;
  final matchedEndpoints = _asList(audio['matchedEndpoints']);
  if (matchedEndpoints.isEmpty) {
    return true;
  }
  for (final endpoint in matchedEndpoints) {
    final map = _asMap(endpoint);
    if (map['isSource'] == true) return true;
  }
  return false;
}

bool runtimePermissionIsGranted(Map<String, dynamic> runtime) {
  return runtime['granted'] == true || runtime['runtimeStatus'] == 'granted';
}

List<DevicePermissionStatus> buildPermissionBannerStatuses({
  required Map<String, dynamic> runtimeDiagnostics,
  required Map<String, dynamic> event,
  required bool needsMicrophonePermission,
  required bool isVideo,
  bool microphoneWasGranted = false,
  bool cameraWasGranted = false,
}) {
  final usb = _asMap(runtimeDiagnostics['usb']);
  final usbEventStatus = _usbStatusFromEvent(
    deviceName: runtimeDiagnostics['device'] is Map
        ? (_asMap(runtimeDiagnostics['device'])['deviceName'] as String?)
        : null,
    event: event,
    fallbackState: usbPermissionStateFromDiagnostics(usb['status'] as String?),
    fallbackDetail: _nullableString(usb['detail']) ?? 'Android still blocks direct access to this USB device.',
  );
  return [
    usbEventStatus,
    runtimePermissionStatus(
      label: 'Microphone',
      applicable: needsMicrophonePermission,
      runtime: _asMap(runtimeDiagnostics['microphone']),
      unavailableDetail: 'This build does not request microphone permission.',
      missingDetail: 'Needed only if you later add direct USB audio capture.',
      wasPreviouslyGranted: microphoneWasGranted,
    ),
    runtimePermissionStatus(
      label: 'Camera',
      applicable: isVideo,
      runtime: _asMap(runtimeDiagnostics['camera']),
      unavailableDetail: 'This build is missing the camera permission declaration.',
      missingDetail: 'Required before Android will grant USB access to video-class devices.',
      wasPreviouslyGranted: cameraWasGranted,
    ),
  ];
}

List<DevicePermissionStatus> buildPermissionDiagnosticStatuses({
  required Map<String, dynamic> diagnostics,
  required bool needsMicrophonePermission,
  required bool isVideo,
  bool microphoneWasGranted = false,
  bool cameraWasGranted = false,
}) {
  final usb = _asMap(diagnostics['usb']);
  return [
    DevicePermissionStatus(
      label: 'USB device access',
      state: usbPermissionStateFromDiagnostics(usb['status'] as String?),
      detail: _nullableString(usb['detail']) ?? 'Unknown',
    ),
    runtimePermissionStatus(
      label: 'Microphone',
      applicable: needsMicrophonePermission,
      runtime: _asMap(diagnostics['microphone']),
      unavailableDetail: 'This build does not request microphone permission.',
      missingDetail: 'Permission has not been granted yet.',
      wasPreviouslyGranted: microphoneWasGranted,
    ),
    runtimePermissionStatus(
      label: 'Camera',
      applicable: isVideo,
      runtime: _asMap(diagnostics['camera']),
      unavailableDetail: 'This build is missing the camera permission declaration.',
      missingDetail: 'Permission has not been granted yet.',
      wasPreviouslyGranted: cameraWasGranted,
    ),
  ];
}

DevicePermissionState usbPermissionStateFromDiagnostics(String? status) {
  switch (status) {
    case 'granted':
      return DevicePermissionState.granted;
    case 'temporarily_denied':
      return DevicePermissionState.temporarilyDenied;
    case 'reenumerated':
      return DevicePermissionState.reenumerated;
    case 'unavailable':
      return DevicePermissionState.unavailable;
    case 'not_applicable':
      return DevicePermissionState.notApplicable;
    case 'device_disconnected':
      return DevicePermissionState.temporarilyDenied;
    case 'missing':
    default:
      return DevicePermissionState.missing;
  }
}

DevicePermissionStatus runtimePermissionStatus({
  required String label,
  required bool applicable,
  required Map<String, dynamic> runtime,
  required String unavailableDetail,
  required String missingDetail,
  bool wasPreviouslyGranted = false,
}) {
  if (!applicable) {
    return DevicePermissionStatus(
      label: label,
      state: DevicePermissionState.notApplicable,
      detail: 'Not relevant for this device class.',
    );
  }
  final state = runtimePermissionStateForDiagnostics(
    runtime,
    wasPreviouslyGranted: wasPreviouslyGranted,
  );
  return DevicePermissionStatus(
    label: label,
    state: state,
    detail: runtimePermissionDetail(
      runtime,
      unavailableDetail: unavailableDetail,
      missingDetail: missingDetail,
      wasPreviouslyGranted: wasPreviouslyGranted,
    ),
  );
}

DevicePermissionState runtimePermissionStateForDiagnostics(
  Map<String, dynamic> runtime, {
  bool wasPreviouslyGranted = false,
}) {
  final status = runtime['runtimeStatus'] as String?;
  if (wasPreviouslyGranted && status != 'granted' && status != 'unavailable' && status != 'not_required') {
    return DevicePermissionState.revoked;
  }
  switch (status) {
    case 'granted':
      return DevicePermissionState.granted;
    case 'temporarily_denied':
      return DevicePermissionState.temporarilyDenied;
    case 'permanently_denied':
      return DevicePermissionState.permanentlyDenied;
    case 'unavailable':
      return DevicePermissionState.unavailable;
    case 'not_required':
      return DevicePermissionState.notApplicable;
    case 'missing':
    default:
      return (runtime['declared'] == true)
          ? DevicePermissionState.missing
          : DevicePermissionState.unavailable;
  }
}

String runtimePermissionDetail(
  Map<String, dynamic> runtime, {
  required String unavailableDetail,
  required String missingDetail,
  bool wasPreviouslyGranted = false,
}) {
  final manifestStatus = runtime['manifestStatus'] as String?;
  final runtimeStatus = runtime['runtimeStatus'] as String?;
  if (manifestStatus == 'missing') return unavailableDetail;
  if (wasPreviouslyGranted && runtimeStatus != 'granted' && runtimeStatus != 'unavailable' && runtimeStatus != 'not_required') {
    return 'Permission was previously granted, but Android revoked it. Request it again.';
  }
  switch (runtimeStatus) {
    case 'granted':
      return 'Runtime permission is granted.';
    case 'temporarily_denied':
      return 'Previously denied, but Android still allows another request.';
    case 'permanently_denied':
      return 'Denied with “Don’t ask again” or blocked by system policy.';
    case 'not_required':
      return 'This Android version does not require a runtime grant for this permission.';
    case 'missing':
    default:
      return missingDetail;
  }
}

DevicePermissionStatus _usbStatusFromEvent({
  required String? deviceName,
  required Map<String, dynamic> event,
  required DevicePermissionState fallbackState,
  required String fallbackDetail,
}) {
  final type = (event['type'] as String?) ?? '';
  final sameDeviceResult = type == 'permission_result' && event['deviceName'] == deviceName;
  final instanceChanged = type == 'permission_instance_changed' && event['originalName'] == deviceName;
  final timeoutFailed = type == 'permission_timeout_failed' && event['originalName'] == deviceName;

  if (instanceChanged) {
    return const DevicePermissionStatus(
      label: 'USB device access',
      state: DevicePermissionState.reenumerated,
      detail: 'The device reconnected under a new Android path. Request access again for the new instance.',
    );
  }
  if (timeoutFailed) {
    return const DevicePermissionStatus(
      label: 'USB device access',
      state: DevicePermissionState.temporarilyDenied,
      detail: 'Android did not deliver a stable USB permission result. Retry after the device settles.',
    );
  }
  if (sameDeviceResult && event['granted'] == false) {
    return const DevicePermissionStatus(
      label: 'USB device access',
      state: DevicePermissionState.temporarilyDenied,
      detail: 'The last USB access request was denied or interrupted.',
    );
  }
  if (sameDeviceResult && event['granted'] == true) {
    return const DevicePermissionStatus(
      label: 'USB device access',
      state: DevicePermissionState.granted,
      detail: 'UsbManager permission is currently granted for this device.',
    );
  }
  return DevicePermissionStatus(
    label: 'USB device access',
    state: fallbackState,
    detail: fallbackDetail,
  );
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const <dynamic>[];
}

String? _nullableString(dynamic value) {
  final out = value as String?;
  if (out == null || out.trim().isEmpty) return null;
  return out;
}
