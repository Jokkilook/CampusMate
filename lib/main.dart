import 'package:campusmate/app_theme.dart';
import 'package:campusmate/firebase_options.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/provider/theme_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  //플러터 코어 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  //회전 방지 코드(세로화면 고정)
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  //파이어베이스 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //테마 데이터 로드
  ThemeMode currentThemeMode = await loadThemeMode();

  //백그라운드 알림 수신 시
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserDataProvider(userData: UserData()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ThemeProvider(currentThemeMode: currentThemeMode),
        ),
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
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      themeMode: Provider.of<ThemeProvider>(context).currentThemeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
