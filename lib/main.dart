import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/init_loading_screen.dart';
import 'package:campusmate/provider/theme_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  //플러터 코어 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  //회전 방지 코드(세로화면 고정)
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  ThemeMode currentThemeMode = await loadThemeMode();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserDataProvider(userData: UserData()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ThemeProvider(currentThemeMode: currentThemeMode),
        )
      ],
      child: const MyApp(),
    ),
  );
}

Future<ThemeMode> loadThemeMode() async {
  ThemeMode returnTheme = ThemeMode.system;
  SharedPreferences pref = await SharedPreferences.getInstance();

  switch (pref.getString("theme")) {
    case "light":
      returnTheme = ThemeMode.light;
      break;
    case "dark":
      returnTheme = ThemeMode.dark;
      break;
    case "system":
      returnTheme = ThemeMode.system;
      break;
    default:
      returnTheme = ThemeMode.system;
      break;
  }

  return returnTheme;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const InitLoadingScreen(),
      themeMode: Provider.of<ThemeProvider>(context).currentThemeMode,
      theme: ThemeData(
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
            shape:
                Border(bottom: BorderSide(width: 1, color: Colors.grey[400]!))),
        cardTheme: const CardTheme(color: Colors.white),
        scaffoldBackgroundColor: AppColors.lightBackground,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightBottomNavBar,
        ),
        badgeTheme: const BadgeThemeData(
          backgroundColor: Color.fromARGB(255, 230, 50, 50),
          textColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        dialogTheme: const DialogTheme(
            surfaceTintColor: Colors.transparent, elevation: 0),
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
            shape:
                Border(bottom: BorderSide(width: 1, color: Colors.grey[800]!))),
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
      ),
    );
  }
}
