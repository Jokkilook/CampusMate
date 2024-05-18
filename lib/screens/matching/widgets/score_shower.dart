import 'package:auto_size_text/auto_size_text.dart';
import 'package:campusmate/app_colors.dart';
import 'package:flutter/material.dart';

class ScoreShower extends StatelessWidget {
  const ScoreShower(
      {super.key,
      this.score = "",
      this.percentage = 0,
      this.isLoading = false});

  final String score;
  final int percentage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      decoration: isLoading
          ? BoxDecoration(
              color: isDark ? AppColors.darkTag : AppColors.lightTag,
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: Visibility(
        visible: !isLoading,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: Column(
          children: [
            SizedBox(
              width: 50,
              child: AutoSizeText(
                maxLines: 1,
                "매치율",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 60,
              child: AutoSizeText(
                maxLines: 1,
                "$percentage%",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    width: 6,
                  ),
                ),
                constraints: const BoxConstraints(
                    minHeight: 10, minWidth: 10, maxHeight: 100, maxWidth: 100),
                child: Center(
                  child: AutoSizeText(
                    score,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
