import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/matching/match_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        actions: [
          IconButton(
              onPressed: () async {
                bool containTags;
                bool containMBTI;
                bool containSchdeule;

                var pref = await SharedPreferences.getInstance();
                var tag = pref.getBool("containTags") ?? true;
                var mbti = pref.getBool("containMBTI") ?? true;
                var schedule = pref.getBool("containSchdeule") ?? true;

                tag ? containTags = true : containTags = false;
                mbti ? containMBTI = true : containMBTI = false;
                schedule ? containSchdeule = true : containSchdeule = false;
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Text("매치율 조건 설정"),
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Text("태그 비교"),
                                  Switch(
                                    value: containTags,
                                    onChanged: (value) {
                                      print(value);
                                      containTags = value;
                                    },
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.tune))
        ],
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
