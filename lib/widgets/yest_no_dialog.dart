import 'package:campusmate/app_colors.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class YesNoDialog extends StatelessWidget {
  final String content;
  Function() onYes;

  YesNoDialog({super.key, required this.content, required this.onYes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
      surfaceTintColor: Colors.transparent,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onYes,
          child: const Text("확인"),
          style: const ButtonStyle(
              overlayColor: MaterialStatePropertyAll(Colors.transparent)),
        ),
        TextButton(
          onPressed: () => router.pop(),
          child: const Text(
            "취소",
            style: TextStyle(color: AppColors.alertText),
          ),
          style: const ButtonStyle(
              overlayColor: MaterialStatePropertyAll(Colors.transparent)),
        )
      ],
    );
  }
}
