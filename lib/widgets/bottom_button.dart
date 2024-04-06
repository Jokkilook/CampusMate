import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  const BottomButton(
      {super.key,
      required this.text,
      this.isCompleted = true,
      this.onPressed,
      this.isLoading = false});
  final bool isCompleted;
  final Function()? onPressed;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: isCompleted ? onPressed : null,
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                text,
                style: TextStyle(
                    color:
                        isCompleted ? const Color(0xFF0A351E) : Colors.black45,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2BB56B),
          minimumSize: const Size(10000, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
