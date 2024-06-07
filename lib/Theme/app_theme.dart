import 'package:campusmate/Theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorSchemeSeed: Colors.green,
    dialogTheme: const DialogTheme(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    indicatorColor: Colors.green,
    drawerTheme: DrawerThemeData(
      elevation: 0,
      backgroundColor: Colors.grey[100],
      scrimColor: Colors.black.withOpacity(0.4),
    ),
    appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
        color: AppColors.lightAppbar,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(width: 1, color: Colors.grey[400]!))),
    cardTheme: const CardTheme(color: Colors.white),
    scaffoldBackgroundColor: AppColors.lightBackground,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBottomNavBar,
    ),
    badgeTheme: const BadgeThemeData(
      backgroundColor: Color.fromARGB(255, 230, 50, 50),
      textColor: Colors.white,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.green,
    dialogTheme:
        const DialogTheme(surfaceTintColor: Colors.transparent, elevation: 0),
    indicatorColor: Colors.green,
    drawerTheme: DrawerThemeData(
      elevation: 0,
      backgroundColor: Colors.grey[850],
      scrimColor: Colors.black.withOpacity(0.4),
    ),
    appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
        color: AppColors.darkAppbar,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(width: 1, color: Colors.grey[800]!))),
    cardTheme: CardTheme(color: AppColors.darkCard),
    cardColor: Colors.grey[700],
    canvasColor: Colors.grey[600],
    scaffoldBackgroundColor: AppColors.darkBackground,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBottomNavBar,
    ),
    badgeTheme: const BadgeThemeData(
      backgroundColor: Color.fromARGB(255, 230, 50, 50),
      textColor: Colors.white,
    ),
  );
}
