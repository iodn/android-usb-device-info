import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_mode_controller.dart' show sharedPreferencesProvider;
import '../db/usb_ids_db.dart';
import 'models.dart';
import 'platform_usb_service.dart';
import 'usb_repository.dart';

const _kInstalledSha256Pref = 'usbids_artifact_installed_sha256_v3';

final usbPlatformServiceProvider = Provider<UsbPlatformService>((ref) {
  return UsbPlatformService();
});

final usbIdsDbProvider = FutureProvider<UsbIdsDb>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final installedSha = (prefs.getString(_kInstalledSha256Pref) ?? '').trim().toLowerCase();

  final db = await UsbIdsDb.open(
    installedSha256: installedSha.isEmpty ? null : installedSha,
  );
  return db;
});

final usbRepositoryProvider = Provider<UsbRepository>((ref) {
  final platform = ref.read(usbPlatformServiceProvider);
  return UsbRepository(platform, () => ref.read(usbIdsDbProvider.future));
});

final usbEventsProvider = StreamProvider<UsbEvent>((ref) async* {
  await ref.watch(usbIdsDbProvider.future);
  final repo = ref.read(usbRepositoryProvider);
  yield* repo.events();
});
