import 'package:campusmate/router/app_router.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ConfirmDialog extends StatelessWidget {
  final String content;
  Function()? onConfrim;

  ConfirmDialog({super.key, required this.content, this.onConfrim});

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
          onPressed: () {
            onConfrim;
            router.pop();
          },
          style: const ButtonStyle(
              overlayColor: MaterialStatePropertyAll(Colors.transparent)),
          child: const Text("확인"),
        ),
      ],
    );
  }
}
