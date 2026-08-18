import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  
  LanguageProvider() {
    _loadFromPrefs();
  }

  Locale get currentLocale => _currentLocale;
  bool get isBangla => _currentLocale.languageCode == 'bn';

  void toggleLanguage() async {
    if (_currentLocale.languageCode == 'en') {
      _currentLocale = const Locale('bn');
    } else {
      _currentLocale = const Locale('en');
    }
    notifyListeners();
    _saveToPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    _currentLocale = Locale(langCode);
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', _currentLocale.languageCode);
  }

  T translate<T>(T en, T bn) {
    return isBangla ? bn : en;
  }
}
