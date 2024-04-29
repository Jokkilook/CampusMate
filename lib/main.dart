import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/chatting_data_provider.dart';
import 'package:campusmate/provider/media_data_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/splash_loading_screen.dart';
import 'package:flutter/foundation.dart';
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
        themeMode: Brightness.dark == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: AppBarTheme(
              scrolledUnderElevation: 0,
              color: Colors.white,
              shape: Border(bottom: BorderSide(color: Colors.grey[400]!))),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme(
              brightness: Brightness.dark,
              primary: Colors.white,
              onPrimary: Colors.red,
              secondary: Colors.white,
              onSecondary: Colors.yellow,
              error: Colors.red,
              onError: Colors.red,
              background: Colors.green,
              onBackground: Colors.grey[700]!,
              surface: Colors.green,
              onSurface: Colors.white),
          appBarTheme: AppBarTheme(
              color: Colors.grey[850],
              shape: Border(bottom: BorderSide(color: Colors.grey[800]!))),
          scaffoldBackgroundColor: Colors.grey[900],
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.grey[900],
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashLoadingScreen());
  }
}
