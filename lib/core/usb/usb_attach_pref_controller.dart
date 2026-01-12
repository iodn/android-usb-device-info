import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_mode_controller.dart' show sharedPreferencesProvider;
import '../../data/usb/providers.dart' show usbPlatformServiceProvider;

const _kUsbOfferAttachKey = 'usb_offer_attach_v1';

final usbOfferAttachControllerProvider =
    NotifierProvider<UsbOfferAttachController, bool>(UsbOfferAttachController.new);

class UsbOfferAttachController extends Notifier<bool> {
  @override
  bool build() {
    // Default to true for fresh installs; users can disable in Settings.
    _loadPersistedAndSync();
    return true;
  }

  Future<void> _loadPersistedAndSync() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final v = prefs.getBool(_kUsbOfferAttachKey);
    final value = v ?? true;
    if (state != value) state = value;
    // Sync component state on load as well
    await _syncPlatform(value);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_kUsbOfferAttachKey, enabled);
    await _syncPlatform(enabled);
  }

  Future<void> _syncPlatform(bool enabled) async {
    try {
      final platform = ref.read(usbPlatformServiceProvider);
      await platform.setUsbAttachComponentEnabled(enabled);
    } catch (_) {
      // ignore errors; not critical for app flow
    }
  }
}
