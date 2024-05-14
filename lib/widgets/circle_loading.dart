import 'package:flutter/material.dart';

class CircleLoading extends StatelessWidget {
  const CircleLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: CircularProgressIndicator(
      strokeCap: StrokeCap.round,
      strokeWidth: 8,
      color: Colors.green,
    ));
  }
}
