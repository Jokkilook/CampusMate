import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/input_text_field.dart';
import 'package:flutter/material.dart';

class PasswordUpdateScreen extends StatefulWidget {
  const PasswordUpdateScreen({super.key});

  @override
  State<PasswordUpdateScreen> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends State<PasswordUpdateScreen> {
  late final TextEditingController originController;
  late final TextEditingController updateController;
  late final TextEditingController checkController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    originController = TextEditingController();
    updateController = TextEditingController();
    checkController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      appBar: AppBar(
        title: const Text("비밀번호 변경"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("현재 비밀번호"),
            const SizedBox(height: 10),
            InputTextField(
              obscrueSee: true,
              obscureText: true,
              isDark: isDark,
              controller: originController,
              hintText: "현재 비밀번호를 입력하세요.",
            ),
            const SizedBox(height: 20),
            const Text("변경할 비밀번호"),
            const SizedBox(height: 10),
            InputTextField(
              obscrueSee: true,
              obscureText: true,
              isDark: isDark,
              controller: updateController,
              hintText: "변경할 비밀번호를 입력하세요.",
            ),
            const SizedBox(height: 20),
            const Text("변경할 비밀번호 확인"),
            const SizedBox(height: 10),
            InputTextField(
              obscrueSee: true,
              obscureText: true,
              isDark: isDark,
              controller: checkController,
              hintText: "변경할 비밀번호를 다시 한번 입력하세요.",
            ),
            const SizedBox(height: 20),
            const BottomButton(text: "비밀번호 변경")
          ],
        ),
      ),
    );
  }
}
