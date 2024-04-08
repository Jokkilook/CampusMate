import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/media_data_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/splash_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserDataProvider(userData: UserData())),
        ChangeNotifierProvider(
          create: (context) => MediaDataProvider(),
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
        theme: ThemeData(
            textSelectionTheme: const TextSelectionThemeData(
                selectionHandleColor: Colors.green)),
        debugShowCheckedModeBanner: false,
        home: const SplashLoadingScreen()
        // ScreenList(),
        );
  }
}
