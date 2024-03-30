import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/match_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text("캠퍼스메이트"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          children: [
            const AdArea(),
            const SizedBox(height: 20),
            Expanded(
                child: MatchCard(
              uid: "asd",
            )),
          ],
        ),
      ),
      bottomNavigationBar: Container(height: 70),
    );
  }
}
