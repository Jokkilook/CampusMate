import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode currentThemeMode = ThemeMode.system;

  ThemeProvider({this.currentThemeMode = ThemeMode.system});

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

  //시스템모드
  setSystemMode() {
    currentThemeMode = ThemeMode.system;
    notifyListeners();
  }
}
