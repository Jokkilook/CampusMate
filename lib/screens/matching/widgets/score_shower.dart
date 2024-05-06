import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ScoreShower extends StatelessWidget {
  const ScoreShower({super.key, this.score = "", this.percentage = 0});

  final String score;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          child: AutoSizeText(
            maxLines: 1,
            "매치율",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge!.color,
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
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(
                    minHeight: 10, minWidth: 10, maxHeight: 100, maxWidth: 100),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: Theme.of(context).textTheme.titleLarge!.color!,
                        width: 5)),
              ),
              Container(
                constraints: const BoxConstraints(
                    minHeight: 10, minWidth: 10, maxHeight: 100, maxWidth: 100),
                child: Center(
                  child: AutoSizeText(
                    score,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
