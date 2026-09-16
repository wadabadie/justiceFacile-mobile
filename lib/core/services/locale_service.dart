import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final instance = LocaleService._();

  static const _kLocale = 'app_locale';

  Locale _locale = const Locale('fr');
  Locale get locale => _locale;

  bool get isFrench => _locale.languageCode == 'fr';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocale) ?? 'fr';
    _locale = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, locale.languageCode);
    notifyListeners();
  }
}
