import 'package:campusmate/app_colors.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  const BottomButton(
      {super.key,
      required this.text,
      this.isCompleted = true,
      this.onPressed,
      this.isLoading = false,
      this.padding = const EdgeInsets.all(20),
      this.height = 50});
  final bool isCompleted;
  final Function()? onPressed;
  final String text;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ElevatedButton(
        onPressed: isCompleted ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircleLoading(color: AppColors.buttonText))
            : Text(
                text,
                style: TextStyle(
                    color: isCompleted ? AppColors.buttonText : Colors.black45,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          minimumSize: Size(10000, height),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
