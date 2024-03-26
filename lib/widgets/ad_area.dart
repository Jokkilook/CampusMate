import 'package:flutter/material.dart';

class AdArea extends StatelessWidget {
  const AdArea({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        '광고 영역',
      ),
    );
  }
}
