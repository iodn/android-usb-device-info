import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/device/permission_state_logic.dart';

void main() {
  group('deviceNeedsMicrophonePermission', () {
    test('returns false for non-audio USB devices', () {
      expect(
        deviceNeedsMicrophonePermission(
          isAudioClass: false,
          audio: const {},
        ),
        isFalse,
      );
    });

    test('returns false for audio output-only devices', () {
      expect(
        deviceNeedsMicrophonePermission(
          isAudioClass: true,
          audio: const {
            'matchedEndpoints': [
              {'isSink': true, 'isSource': false}
            ],
          },
        ),
        isFalse,
      );
    });

    test('returns true for audio input-capable devices', () {
      expect(
        deviceNeedsMicrophonePermission(
          isAudioClass: true,
          audio: const {
            'matchedEndpoints': [
              {'isSink': true, 'isSource': true}
            ],
          },
        ),
        isTrue,
      );
    });
  });

  group('buildPermissionDiagnosticStatuses', () {
    Map<String, dynamic> baseDiagnostics({
      Map<String, dynamic>? microphone,
      Map<String, dynamic>? camera,
      Map<String, dynamic>? usb,
    }) {
      return <String, dynamic>{
        'usb': usb ??
            const {
              'status': 'missing',
              'detail': 'Android still blocks direct access to this USB device.',
            },
        'microphone': microphone ??
            const {
              'declared': true,
              'granted': false,
              'manifestStatus': 'declared',
              'runtimeStatus': 'missing',
            },
        'camera': camera ??
            const {
              'declared': true,
              'granted': false,
              'manifestStatus': 'declared',
              'runtimeStatus': 'missing',
            },
      };
    }

    test('marks microphone as not applicable for non-audio devices', () {
      final statuses = buildPermissionDiagnosticStatuses(
        diagnostics: baseDiagnostics(),
        needsMicrophonePermission: false,
        isVideo: false,
      );

      expect(statuses[1].label, 'Microphone');
      expect(statuses[1].state, DevicePermissionState.notApplicable);
    });

    test('marks microphone as missing for audio capture devices before grant', () {
      final statuses = buildPermissionDiagnosticStatuses(
        diagnostics: baseDiagnostics(),
        needsMicrophonePermission: true,
        isVideo: false,
      );

      expect(statuses[1].state, DevicePermissionState.missing);
      expect(statuses[1].detail, 'Permission has not been granted yet.');
    });

    test('marks microphone as temporarily denied after user denial', () {
      final statuses = buildPermissionDiagnosticStatuses(
        diagnostics: baseDiagnostics(
          microphone: const {
            'declared': true,
            'granted': false,
            'manifestStatus': 'declared',
            'runtimeStatus': 'temporarily_denied',
          },
        ),
        needsMicrophonePermission: true,
        isVideo: false,
      );

      expect(statuses[1].state, DevicePermissionState.temporarilyDenied);
    });

    test('marks microphone as granted after user approval', () {
      final statuses = buildPermissionDiagnosticStatuses(
        diagnostics: baseDiagnostics(
          microphone: const {
            'declared': true,
            'granted': true,
            'manifestStatus': 'declared',
            'runtimeStatus': 'granted',
          },
        ),
        needsMicrophonePermission: true,
        isVideo: false,
      );

      expect(statuses[1].state, DevicePermissionState.granted);
    });

    test('marks runtime permission as revoked after one-time grant expires', () {
      final statuses = buildPermissionDiagnosticStatuses(
        diagnostics: baseDiagnostics(
          microphone: const {
            'declared': true,
            'granted': false,
            'manifestStatus': 'declared',
            'runtimeStatus': 'missing',
          },
        ),
        needsMicrophonePermission: true,
        isVideo: false,
        microphoneWasGranted: true,
      );

      expect(statuses[1].state, DevicePermissionState.revoked);
      expect(statuses[1].detail, contains('revoked'));
    });
  });

  group('buildPermissionBannerStatuses', () {
    const runtimeDiagnostics = {
      'device': {'deviceName': '/dev/bus/usb/001/002'},
      'usb': {
        'status': 'missing',
        'detail': 'Android still blocks direct access to this USB device.',
      },
      'microphone': {
        'declared': true,
        'granted': false,
        'manifestStatus': 'declared',
        'runtimeStatus': 'missing',
      },
      'camera': {
        'declared': true,
        'granted': false,
        'manifestStatus': 'declared',
        'runtimeStatus': 'missing',
      },
    };

    test('marks USB state as re-enumerated when instance changes', () {
      final statuses = buildPermissionBannerStatuses(
        runtimeDiagnostics: runtimeDiagnostics,
        event: const {
          'type': 'permission_instance_changed',
          'originalName': '/dev/bus/usb/001/002',
          'newName': '/dev/bus/usb/001/003',
        },
        needsMicrophonePermission: false,
        isVideo: false,
      );

      expect(statuses.first.state, DevicePermissionState.reenumerated);
    });

    test('marks USB state as temporarily denied on broadcast timeout', () {
      final statuses = buildPermissionBannerStatuses(
        runtimeDiagnostics: runtimeDiagnostics,
        event: const {
          'type': 'permission_timeout_failed',
          'originalName': '/dev/bus/usb/001/002',
        },
        needsMicrophonePermission: false,
        isVideo: false,
      );

      expect(statuses.first.state, DevicePermissionState.temporarilyDenied);
    });
  });
}
