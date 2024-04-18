import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/match_card.dart';
import 'package:flutter/material.dart';

class MatchingScreen extends StatelessWidget {
  const MatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text("캠퍼스메이트"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            AdArea(),
            Expanded(child: MatchCard()),
          ],
        ),
      ),
      bottomNavigationBar: Container(height: 70),
    );
  }
}
