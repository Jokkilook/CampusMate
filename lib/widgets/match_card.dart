import 'package:auto_size_text/auto_size_text.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:campusmate/widgets/score_shower.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where("school", isEqualTo: "테스트대학교")
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Text("아직 사용자가 없어요 o_o");
        }
        if (snapshot.hasError) {
          throw Error();
        } else {
          var data = snapshot.data?.docs ?? [];
          return Center(child: SwipableCard(data, context));
        }
      },
    );
  }

  CardSwiper SwipableCard(final data, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.height;

    return CardSwiper(
        threshold: 100,
        cardsCount: data.length,
        cardBuilder: (context, index, horizontalOffsetPercentage,
            verticalOffsetPercentage) {
          final doc = data[index];
          late final String score;
          if (doc.get("score") >= 95) {
            score = "A+";
          } else if (doc.get("score") >= 90) {
            score = "A";
          } else if (doc.get("score") >= 85) {
            score = "B+";
          } else if (doc.get("score") >= 80) {
            score = "B";
          } else if (doc.get("score") >= 75) {
            score = "C+";
          } else if (doc.get("score") >= 70) {
            score = "C";
          } else if (doc.get("score") >= 65) {
            score = "D+";
          } else if (doc.get("score") >= 60) {
            score = "D";
          } else {
            score = "F";
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StrangerProfilScreen(uid: doc.get("uid")),
                  ));
            },
            child: Container(
              clipBehavior: Clip.hardEdge,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 0),
                      blurRadius: 2)
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //사진부분
                  Flexible(
                    child: Container(
                      color: Colors.amber,
                    ),
                  ),
                  //정보부분
                  Container(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 20, left: 20, right: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 220,
                                  child: AutoSizeText(
                                    "${doc.get("name")}, ${doc.get("age")}",
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Flexible(child: SizedBox())
                              ],
                            ),
                            Text(
                              '${doc.get("mbti")}',
                              style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 10),
                            ExtendedWrap(
                              maxLines: 2,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (var tag in doc.get("tags"))
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: Text(
                                      tag.toString(),
                                      style: TextStyle(color: Colors.grey[850]),
                                    ),
                                  )
                              ],
                              overflowWidget: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                child: Text(
                                  "+",
                                  style: TextStyle(color: Colors.grey[850]),
                                ),
                              ),
                            )
                          ],
                        ),
                        //매너학점
                        Positioned(right: 0, child: Score(score: score)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
