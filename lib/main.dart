import 'package:campusmate/AppColors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/chatting_data_provider.dart';
import 'package:campusmate/provider/media_data_provider.dart';
import 'package:campusmate/provider/theme_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/splash_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  //회전 방지 코드(세로화면 고정)
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserDataProvider(userData: UserData())),
        ChangeNotifierProvider(
          create: (context) => MediaDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChattingDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashLoadingScreen(),
      themeMode: Provider.of<ThemeProvider>(context).currentThemeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
        dialogTheme: const DialogTheme(surfaceTintColor: Colors.transparent),
        indicatorColor: Colors.green,
        drawerTheme: DrawerThemeData(
          elevation: 0,
          backgroundColor: Colors.grey[100],
          scrimColor: Colors.black.withOpacity(0.4),
        ),
        appBarTheme: AppBarTheme(
            scrolledUnderElevation: 0,
            color: Colors.white,
            shape: Border(bottom: BorderSide(color: Colors.grey[400]!))),
        cardTheme: const CardTheme(color: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        badgeTheme: const BadgeThemeData(
          backgroundColor: Color.fromARGB(255, 230, 50, 50),
          textColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        dialogTheme: const DialogTheme(surfaceTintColor: Colors.transparent),
        indicatorColor: Colors.green,
        drawerTheme: DrawerThemeData(
          elevation: 0,
          backgroundColor: Colors.grey[850],
          scrimColor: Colors.black.withOpacity(0.4),
        ),
        appBarTheme: AppBarTheme(
            elevation: 0,
            scrolledUnderElevation: 0,
            color: AppColors.darkAppbar,
            shape: Border(bottom: BorderSide(color: Colors.grey[800]!))),
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
