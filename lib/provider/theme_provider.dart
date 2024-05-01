import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode currentThemeMode = ThemeMode.light;

  //라이트모드
  setLightMode() {
    currentThemeMode = ThemeMode.light;
    notifyListeners();
  }

  //다크모드
  setDarkMode() {
    currentThemeMode = ThemeMode.dark;
    notifyListeners();
  }
}
