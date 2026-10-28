import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class LocalizationService {
  LocalizationService(this.locale);

  final Locale locale;
  Map<String, String> _localizedStrings = {};

  static LocalizationService of(BuildContext context) {
    final localization = Localizations.of<LocalizationService>(context, LocalizationService);
    if (localization == null) {
      throw Exception('LocalizationService not found in context. Make sure it\'s added to localizationsDelegates in MaterialApp.');
    }
    return localization;
  }

  static const LocalizationsDelegate<LocalizationService> delegate = _LocalizationServiceDelegate();

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      print('Error loading localization for ${locale.languageCode}: $e');
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '** $key **';
  }

  String get currentLanguage => locale.languageCode;
}

class _LocalizationServiceDelegate extends LocalizationsDelegate<LocalizationService> {
  const _LocalizationServiceDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationService> load(Locale locale) async {
    LocalizationService localizations = LocalizationService(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_LocalizationServiceDelegate old) => false;
}