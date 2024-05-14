import 'package:flutter/material.dart';

class CircleLoading extends StatelessWidget {
  const CircleLoading({
    super.key,
    this.color = Colors.green,
  });
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      strokeCap: StrokeCap.round,
      strokeWidth: 8,
      color: color,
    ));
  }
}
