import 'dart:async';
import 'dart:convert';

import 'package:USBDevInfo/data/usb/models.dart';
import 'package:USBDevInfo/data/usb/providers.dart';
import 'package:USBDevInfo/data/usb/usb_repository.dart';
import 'package:USBDevInfo/features/device/controllers/device_detail_controller.dart';
import 'package:USBDevInfo/features/device/device_detail_screen.dart';
import 'package:USBDevInfo/features/history/controllers/device_history_controller.dart';
import 'package:USBDevInfo/features/history/models/device_history_entry.dart';
import 'package:USBDevInfo/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _cameraPath = '/dev/bus/usb/001/002';
const _methods = MethodChannel('usbdevinfo/methods');

class _TestHistory extends DeviceHistoryController {
  @override
  Future<List<DeviceHistoryEntry>> build() async => [];

  @override
  Future<void> recordFromView(
    UsbDeviceDetailViewData view, {
    Map<String, dynamic>? raw,
  }) async {}
}

enum _AccessScenario {
  denyUsb,
  settings,
  unplugDuringCamera,
  unplugDuringUsb,
  accessory,
  inputController,
  audioFormats,
  compositeFunctions,
}

void main() {
  for (final scenario in _AccessScenario.values) {
    final useSettings = scenario == _AccessScenario.settings;
    final accessory = scenario == _AccessScenario.accessory;
    final inputController = scenario == _AccessScenario.inputController;
    final audioFormats = scenario == _AccessScenario.audioFormats;
    final compositeFunctions = scenario == _AccessScenario.compositeFunctions;
    final path = accessory
        ? 'accessory:example'
        : inputController
        ? 'input:4'
        : _cameraPath;
    final description = switch (scenario) {
      _AccessScenario.denyUsb =>
        'camera resumes before USB request and blocks duplicate taps',
      _AccessScenario.settings =>
        'returns from Android settings and retries access in landscape',
      _AccessScenario.unplugDuringCamera => 'unplugging during the camera prompt stops before asking for USB access',
      _AccessScenario.unplugDuringUsb =>
        'unplugging during the USB prompt shows the disconnect',
      _AccessScenario.accessory => 'accessory metadata is visible before permission and serial appears after approval',
      _AccessScenario.inputController =>
        'controller buttons and named axes appear without a USB prompt',
      _AccessScenario.audioFormats =>
        'advertised audio formats show channels, bit depth, and rate ranges',
      _AccessScenario.compositeFunctions =>
        'composite functions show and export the supplied name and interface range',
    };
    testWidgets(description, (tester) async {
      await tester.binding.setSurfaceSize(
        useSettings ? const Size(812, 375) : const Size(375, 812),
      );
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final camera = Completer<bool>();
      final usb = Completer<bool>();
      final calls = <String>[];
      var disconnected = false;
      var granted = false;
      var cameraStatus = useSettings ? 'permanently_denied' : 'missing';
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(_methods, (call) async {
        calls.add(call.method);
        return switch (call.method) {
          'openAppSettings' => null,
          'requestCameraPermission' => camera.future,
          'requestPermission' => usb.future,
          _ => throw MissingPluginException(call.method),
        };
      });
      addTearDown(() => messenger.setMockMethodCallHandler(_methods, null));

      Map<String, dynamic> snapshot() => {
        'summary': {
          'deviceName': path,
          if (accessory) ...{
            'manufacturerName': 'Example',
            'productName': 'Test accessory',
            'deviceRelease': '2.1',
            if (granted) 'serialNumber': 'A-42',
          } else if (inputController) ...{
            'productName': 'Test controller',
            'isInputDevice': true,
            'deviceClass': 3,
            'inputSources': ['gamepad', 'joystick'],
          } else ...{
            'vendorId': 0x046d,
            'productId': 0x0825,
            'deviceClass': audioFormats ? 1 : 14,
          },
          'hasPermission': granted || inputController || audioFormats || compositeFunctions,
        },
        if (compositeFunctions)
          'descriptorTree': [
            {
              'descriptorType': 0x02,
              'fields': {'bConfigurationValue': 2},
            },
            {
              'descriptorType': 0x0B,
              'fields': {
                'bFirstInterface': 0,
                'bInterfaceCount': 2,
                'bFunctionClass': 0x0E,
                'bFunctionSubClass': 3,
                'bFunctionProtocol': 0,
                'iFunction': 4,
                'functionName': 'Video capture',
              },
            },
          ],
        if (audioFormats)
          'descriptorTree': [
            {
              'descriptorType': 0x24,
              'context': {
                'interfaceClass': 1,
                'interfaceSubclass': 2,
                'interfaceNumber': 1,
                'alternateSetting': 1,
              },
              'fields': {
                'bDescriptorSubType': 2,
                'audioSubclassName': 'AudioStreaming',
                'bNrChannels': 2,
                'bBitResolution': 24,
                'sampleRateMinHz': 44100,
                'sampleRateMaxHz': 96000,
              },
            },
          ],
        if (inputController)
          'input': {
            'name': 'Test controller',
            'sources': ['gamepad', 'joystick'],
            'supportedButtons': ['A', 'R1'],
            'motionRanges': [
              {
                'axis': 15,
                'axisName': 'HAT X',
                'source': 'joystick',
                'min': -1,
                'max': 1,
              },
            ],
          },
        if (accessory)
          'accessory': {
            'description': 'Accessory description',
            'uri': 'https://example.com/doc',
          },
        if (disconnected)
          'availabilityIssues': [
            {'scope': 'device', 'reasonCode': 'device_disconnected'},
          ],
      };
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceDetailControllerProvider(path).overrideWith((ref) async {
              final raw = await ref.watch(
                deviceDetailRawControllerProvider(path).future,
              );
              return UsbDeviceDetailViewData(
                details: UsbDeviceDetails.fromMap(raw),
                vendorName: 'Example',
                productName: accessory
                    ? 'Test accessory'
                    : inputController
                    ? 'Test controller'
                    : 'USB camera',
                deviceClassName: accessory ? null : 'Video',
                deviceSubclassName: null,
                deviceProtocolName: null,
                interfaceClassNames: [],
              );
            }),
            deviceDetailRawControllerProvider(path)
                .overrideWith((ref) => snapshot()),
            deviceHistoryControllerProvider.overrideWith(_TestHistory.new),
            usbEventsProvider.overrideWith((ref) => const Stream.empty()),
            runtimePermissionDiagnosticsProvider.overrideWith(
              (ref, args) => {
                'camera': {'runtimeStatus': cameraStatus},
              },
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: useSettings ? ThemeData.light() : ThemeData.dark(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.4)),
              child: child!,
            ),
            home: DeviceDetailScreen(deviceName: path),
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (scenario == _AccessScenario.denyUsb) {
        final logo = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(
          (logo.bytesLoader as SvgAssetLoader).assetName,
          'assets/vendor_logos/logitech.svg',
        );
      }

      if (compositeFunctions) {
        final details = find.text('Technical details');
        await tester.scrollUntilVisible(details, 180);
        await tester.pumpAndSettle();
        await tester.tap(details);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text('USB functions'), 180);
        await tester.pumpAndSettle();
        expect(find.text('Configuration 2'), findsOneWidget);
        expect(find.text('Video capture'), findsOneWidget);
        expect(find.text('0–1'), findsOneWidget);
        await tester.tap(find.byTooltip('Export raw dump'));
        await tester.pumpAndSettle();
        final preview = tester.widget<SelectableText>(
          find.byWidgetPredicate(
            (widget) =>
                widget is SelectableText &&
                (widget.data?.contains('"interfaceAssociations"') ?? false),
          ),
        );
        final payload = jsonDecode(preview.data!) as Map<String, dynamic>;
        expect(payload['interfaceAssociations'], [
          {
            'configuration': 2,
            'firstInterface': 0,
            'interfaceCount': 2,
            'functionClass': 0x0E,
            'functionSubclass': 3,
            'functionProtocol': 0,
            'stringIndex': 4,
            'name': 'Video capture',
          },
        ]);
        expect(calls, isEmpty);
        return;
      }

      if (audioFormats) {
        final formatTitle = find.text('Audio stream formats');
        await tester.scrollUntilVisible(formatTitle, 180);
        await tester.pumpAndSettle();
        final descriptors = find.text('1 descriptor(s)');
        await tester.scrollUntilVisible(descriptors, 100);
        await tester.pumpAndSettle();
        await tester.tap(descriptors);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('2 ch, 24-bit, 44100–96000 Hz'),
          findsOneWidget,
        );
        expect(calls, isEmpty);
        return;
      }

      if (inputController) {
        final details = find.text('Technical details');
        await tester.scrollUntilVisible(details, 180);
        await tester.pumpAndSettle();
        await tester.tap(details);
        await tester.pumpAndSettle();
        final ranges = find.text('Show motion ranges');
        await tester.scrollUntilVisible(ranges, 180);
        await tester.pumpAndSettle();
        expect(find.text('Supported buttons'), findsOneWidget);
        expect(find.text('A, R1'), findsOneWidget);
        await tester.tap(ranges);
        await tester.pumpAndSettle();
        expect(find.text('HAT X · joystick'), findsOneWidget);
        expect(find.text('Grant permission'), findsNothing);
        expect(calls, isEmpty);
        return;
      }

      if (useSettings) {
        final settings = find.widgetWithText(FilledButton, 'Settings');
        await tester.scrollUntilVisible(settings, 100);
        await tester.pumpAndSettle();
        await tester.tap(settings);
        await tester.pumpAndSettle();
        expect(calls, ['openAppSettings']);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        cameraStatus = 'granted';
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        calls.clear();
      }

      final button = find.widgetWithText(FilledButton, 'Grant permission');
      await tester.scrollUntilVisible(button, 100);
      await tester.pumpAndSettle();
      expect(button, findsOneWidget);
      if (accessory) {
        expect(find.text('Test accessory'), findsOneWidget);
        expect(find.text('Accessory description'), findsOneWidget);
        expect(find.text('A-42'), findsNothing);
        expect(find.text('Vendor ID'), findsNothing);
        await tester.tap(button);
        await tester.pump();
        expect(calls, ['requestPermission']);
        granted = true;
        usb.complete(true);
        await tester.pumpAndSettle();
        expect(find.text('A-42'), findsOneWidget);
        expect(button, findsNothing);
        return;
      }
      await tester.tap(button);
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(calls, ['requestCameraPermission']);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final unplugged = PlatformException(code: 'device_disconnected');
      if (scenario == _AccessScenario.unplugDuringCamera) {
        disconnected = true;
        camera.completeError(unplugged);
        await tester.pumpAndSettle();
        expect(calls, ['requestCameraPermission']);
      } else {
        camera.complete(true);
        await tester.pump();
        expect(calls, ['requestCameraPermission', 'requestPermission']);
        if (scenario == _AccessScenario.unplugDuringUsb) {
          disconnected = true;
          usb.completeError(unplugged);
        } else {
          usb.complete(false);
        }
        await tester.pumpAndSettle();
      }
      if (disconnected) {
        expect(
          find.widgetWithText(SnackBar, 'Device disconnected'),
          findsOneWidget,
        );
        expect(button, findsNothing);
      } else {
        expect(find.text('Permission not granted'), findsOneWidget);
        expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      }
    });
  }
}
