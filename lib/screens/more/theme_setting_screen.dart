import 'package:campusmate/modules/enums.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingScreen extends StatefulWidget {
  const ThemeSettingScreen({super.key});

  @override
  State<ThemeSettingScreen> createState() => _ThemeSettingScreenState();
}

class _ThemeSettingScreenState extends State<ThemeSettingScreen> {
  late SharedPreferences pref;
  late ThemeType type;

  void initPref() async {
    pref = await SharedPreferences.getInstance();
    //type = pref.getString("theme");
  }

  @override
  void initState() {
    // TODO: implement initState
    initPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("앱 테마"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text("라이트 모드"),
            trailing: Radio(
              value: ThemeType.light,
              groupValue: ThemeType,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("다크 모드"),
            trailing: Radio(
              value: ThemeType.dark,
              groupValue: ThemeType,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_brightness),
            title: const Text("시스템 테마"),
            trailing: Radio(
              value: ThemeType.system,
              groupValue: ThemeType,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
