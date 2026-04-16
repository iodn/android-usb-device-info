import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_mode_controller.dart' show sharedPreferencesProvider;

const _kAppLocaleOverrideKey = 'app_locale_override_v1';

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, Locale?>(AppLocaleController.new);

class AppLocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadPersisted();
    return null;
  }

  Future<void> _loadPersisted() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final parsed = decodeLocaleCode(prefs.getString(_kAppLocaleOverrideKey));
    if (!_sameLocale(parsed, state)) {
      state = parsed;
    }
  }

  Future<void> setOverrideLocale(Locale? locale) async {
    if (_sameLocale(locale, state)) return;
    state = locale;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (locale == null) {
      await prefs.remove(_kAppLocaleOverrideKey);
    } else {
      await prefs.setString(_kAppLocaleOverrideKey, encodeLocaleCode(locale));
    }
  }

  static Locale resolveActiveLocale({
    required List<Locale> supportedLocales,
    required Locale? systemLocale,
    required Locale? overrideLocale,
  }) {
    final fallbackLocale = englishFallback(supportedLocales);
    final wanted = overrideLocale ?? systemLocale;
    if (wanted == null) return fallbackLocale;
    return matchSupportedLocale(wanted, supportedLocales) ?? fallbackLocale;
  }

  static Locale englishFallback(List<Locale> supportedLocales) {
    return matchSupportedLocale(const Locale('en'), supportedLocales) ??
        supportedLocales.first;
  }

  static Locale? matchSupportedLocale(
    Locale wanted,
    List<Locale> supportedLocales,
  ) {
    for (final locale in supportedLocales) {
      if (_sameLocale(locale, wanted)) return locale;
    }
    for (final locale in supportedLocales) {
      if (locale.languageCode == wanted.languageCode) return locale;
    }
    return null;
  }

  static String encodeLocaleCode(Locale locale) {
    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return locale.languageCode;
    }
    return '${locale.languageCode}_$countryCode';
  }

  static Locale? decodeLocaleCode(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    final parts = value.split(RegExp('[-_]'));
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  static bool _sameLocale(Locale? a, Locale? b) {
    if (a == null || b == null) return a == b;
    return a.languageCode == b.languageCode &&
        (a.countryCode ?? '') == (b.countryCode ?? '');
  }
}
