import 'package:campusmate/modules/enums.dart';
import 'package:campusmate/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingScreen extends StatefulWidget {
  ThemeSettingScreen({super.key});
  bool isLoading = false;

  @override
  State<ThemeSettingScreen> createState() => _ThemeSettingScreenState();
}

class _ThemeSettingScreenState extends State<ThemeSettingScreen> {
  late SharedPreferences _pref;
  late ThemeType _type = ThemeType.system;

  void initPref() async {
    widget.isLoading = true;
    _pref = await SharedPreferences.getInstance();
    print("Com");
    _type = stringToEnumThemeType(_pref.getString("theme") ?? "system");
    widget.isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    initPref();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text("앱 테마"),
            ),
            body: ListView(
              children: [
                ListTile(
                  onTap: () {
                    _pref.setString("theme", "light");
                    setState(() {
                      _type = ThemeType.light;
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setLightMode();
                    });
                  },
                  leading: const Icon(Icons.light_mode),
                  title: const Text("라이트 모드"),
                  trailing: Radio(
                    value: ThemeType.light,
                    groupValue: _type,
                    onChanged: (value) {
                      _pref.setString("theme", "light");
                      setState(() {
                        _type = ThemeType.light;
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setLightMode();
                      });
                    },
                  ),
                ),
                ListTile(
                  onTap: () {
                    _pref.setString("theme", "dark");
                    setState(() {
                      _type = ThemeType.dark;
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setDarkMode();
                    });
                  },
                  leading: const Icon(Icons.dark_mode),
                  title: const Text("다크 모드"),
                  trailing: Radio(
                    value: ThemeType.dark,
                    groupValue: _type,
                    onChanged: (value) {
                      _pref.setString("theme", "dark");
                      setState(() {
                        _type = ThemeType.dark;
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setDarkMode();
                      });
                    },
                  ),
                ),
                ListTile(
                  onTap: () {
                    _pref.setString("theme", "system");
                    setState(() {
                      _type = ThemeType.system;
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setSystemMode();
                    });
                  },
                  leading: const Icon(Icons.settings_brightness),
                  title: const Text("시스템 테마"),
                  trailing: Radio(
                    value: ThemeType.system,
                    groupValue: _type,
                    onChanged: (value) {
                      _pref.setString("theme", "system");
                      setState(() {
                        _type = ThemeType.system;
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setSystemMode();
                      });
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
