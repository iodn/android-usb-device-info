import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/dynamic_color_controller.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/usb/usb_event_coordinator.dart';
import 'core/usb/usb_attach_pref_controller.dart';
import 'data/db/usb_ids_update_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: UsbDevInfoApp()));
}

class UsbDevInfoApp extends ConsumerWidget {
  const UsbDevInfoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   ref.watch(usbEventCoordinatorProvider);
   ref.watch(usbIdsAutoCheckCoordinatorProvider);
   // Initialize USB attach behavior preference and sync alias state
   ref.watch(usbOfferAttachControllerProvider);

    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final enabled = ref.watch(dynamicColorsControllerProvider);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'USBDevInfo',
          theme: AppTheme.light(dynamicScheme: enabled ? lightDynamic : null),
          darkTheme: AppTheme.dark(dynamicScheme: enabled ? darkDynamic : null),
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
