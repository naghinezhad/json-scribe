import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  DarkThemeStatus darkThemeStatus = DarkThemeStatus();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemeStatus.setDarkTheme(value);
    notifyListeners();
  }

  ThemeProvider() {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    _darkTheme = await darkThemeStatus.getTheme();
    notifyListeners();
  }
}

class DarkThemeStatus {
  static const themeStatus = "THEME_STATUS";
  final _storage = const FlutterSecureStorage();

  Future<void> setDarkTheme(bool value) async {
    await _storage.write(key: themeStatus, value: value.toString());
  }

  Future<bool> getTheme() async {
    String? value = await _storage.read(key: themeStatus);
    return value == 'true';
  }
}
