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
          cardTheme: const CardTheme(color: Colors.white),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
              titleLarge: const TextStyle(color: Colors.white),
              titleMedium: const TextStyle(color: Colors.white),
              titleSmall: const TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.grey[300]),
              displayLarge: TextStyle(color: Colors.grey[400])),
          drawerTheme: DrawerThemeData(
            elevation: 0,
            backgroundColor: Colors.grey[850],
            scrimColor: Colors.black.withOpacity(0.4),
          ),
          appBarTheme: AppBarTheme(
              scrolledUnderElevation: 0,
              color: Colors.grey[850],
              shape: Border(bottom: BorderSide(color: Colors.grey[800]!))),
          cardTheme: CardTheme(color: Colors.grey[850]),
          cardColor: Colors.grey[700],
          canvasColor: Colors.grey[600],
          scaffoldBackgroundColor: Colors.grey[900],
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.grey[900],
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashLoadingScreen());
  }
}
