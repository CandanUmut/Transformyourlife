import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._translations);

  final Locale locale;
  final Map<String, dynamic> _translations;

  String t(String key) => _translations[key] as String? ?? key;

  static Future<AppLocalizations> load(Locale locale) async {
    final data = await rootBundle
        .loadString('assets/lang/${locale.languageCode}.json');
    final Map<String, dynamic> translations = json.decode(data);
    return AppLocalizations(locale, translations);
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'tr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
