import 'package:flutter/material.dart';

class SupportedAppLocale {
  const SupportedAppLocale({
    required this.locale,
    required this.englishName,
    required this.nativeName,
  });

  final Locale locale;
  final String englishName;
  final String nativeName;
}

const supportedAppLocales = <SupportedAppLocale>[
  SupportedAppLocale(
    locale: Locale('ar'),
    englishName: 'Arabic',
    nativeName: 'العربية',
  ),
  SupportedAppLocale(
    locale: Locale('ar', 'EG'),
    englishName: 'Arabic (Egypt)',
    nativeName: 'العربية (مصر)',
  ),
  SupportedAppLocale(
    locale: Locale('de'),
    englishName: 'German',
    nativeName: 'Deutsch',
  ),
  SupportedAppLocale(
    locale: Locale('en'),
    englishName: 'English',
    nativeName: 'English',
  ),
  SupportedAppLocale(
    locale: Locale('es'),
    englishName: 'Spanish',
    nativeName: 'Español',
  ),
  SupportedAppLocale(
    locale: Locale('fil'),
    englishName: 'Filipino',
    nativeName: 'Filipino',
  ),
  SupportedAppLocale(
    locale: Locale('fr'),
    englishName: 'French',
    nativeName: 'Français',
  ),
  SupportedAppLocale(
    locale: Locale('hi'),
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
  ),
  SupportedAppLocale(
    locale: Locale('id'),
    englishName: 'Indonesian',
    nativeName: 'Indonesia',
  ),
  SupportedAppLocale(
    locale: Locale('it'),
    englishName: 'Italian',
    nativeName: 'Italiano',
  ),
  SupportedAppLocale(
    locale: Locale('ja'),
    englishName: 'Japanese',
    nativeName: '日本語',
  ),
  SupportedAppLocale(
    locale: Locale('ko'),
    englishName: 'Korean',
    nativeName: '한국어',
  ),
  SupportedAppLocale(
    locale: Locale('ms'),
    englishName: 'Malay',
    nativeName: 'Bahasa Melayu',
  ),
  SupportedAppLocale(
    locale: Locale('nl'),
    englishName: 'Dutch',
    nativeName: 'Nederlands',
  ),
  SupportedAppLocale(
    locale: Locale('pl'),
    englishName: 'Polish',
    nativeName: 'Polski',
  ),
  SupportedAppLocale(
    locale: Locale('pt'),
    englishName: 'Portuguese',
    nativeName: 'Português',
  ),
  SupportedAppLocale(
    locale: Locale('pt', 'BR'),
    englishName: 'Portuguese (Brazil)',
    nativeName: 'Português (Brasil)',
  ),
  SupportedAppLocale(
    locale: Locale('ru'),
    englishName: 'Russian',
    nativeName: 'Русский',
  ),
  SupportedAppLocale(
    locale: Locale('th'),
    englishName: 'Thai',
    nativeName: 'ไทย',
  ),
  SupportedAppLocale(
    locale: Locale('tr'),
    englishName: 'Turkish',
    nativeName: 'Türkçe',
  ),
  SupportedAppLocale(
    locale: Locale('uk'),
    englishName: 'Ukrainian',
    nativeName: 'Українська',
  ),
  SupportedAppLocale(
    locale: Locale('vi'),
    englishName: 'Vietnamese',
    nativeName: 'Tiếng Việt',
  ),
  SupportedAppLocale(
    locale: Locale('zh'),
    englishName: 'Chinese',
    nativeName: '中文',
  ),
];

SupportedAppLocale? supportedAppLocaleFor(Locale locale) {
  for (final item in supportedAppLocales) {
    if (_sameLocale(item.locale, locale)) return item;
  }
  for (final item in supportedAppLocales) {
    if (item.locale.languageCode == locale.languageCode) return item;
  }
  return null;
}

String supportedLocaleLabel(Locale locale) {
  final match = supportedAppLocaleFor(locale);
  if (match == null) return locale.toLanguageTag();
  if (match.englishName == match.nativeName) return match.nativeName;
  return '${match.nativeName} (${match.englishName})';
}

bool _sameLocale(Locale a, Locale b) {
  return a.languageCode == b.languageCode &&
      (a.countryCode ?? '') == (b.countryCode ?? '');
}
