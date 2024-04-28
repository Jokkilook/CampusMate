import 'package:auto_size_text/auto_size_text.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:campusmate/widgets/profile/score_shower.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//ignore: must_be_immutable
class MatchCard extends StatefulWidget {
  MatchCard({super.key});
  bool containTags = true;
  bool containMBTI = true;
  bool containSchedule = true;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  late SharedPreferences pref;

  Future getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    widget.containTags = pref.getBool("containTags") ?? true;
    widget.containMBTI = pref.getBool("containMBTI") ?? true;
    widget.containSchedule = pref.getBool("containSchedule") ?? true;
  }

  void refresh() {
    getPref();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  int matchFilter(
      {required UserData myData,
      required UserData otherData,
      bool containTags = true,
      bool containMBTI = true,
      bool containSchedule = true}) {
    int matchPercent = 0;
    List<bool> conditionList = [];
    containTags ? conditionList.add(containTags) : null;
    containMBTI ? conditionList.add(containMBTI) : null;
    containSchedule ? conditionList.add(containSchedule) : null;

    matchPercent = ((containSchedule ? compareSchedule(myData, otherData) : 0) +
            (containTags ? compareTags(myData, otherData) : 0) +
            (containMBTI ? compareMBTI(myData, otherData) : 0)) ~/
        conditionList.length;

    return matchPercent;
  }

  int compareMBTI(UserData myData, UserData otherData) {
    int matchPercent = 0;
    int count = 0;
    String myMBTI = myData.mbti!;
    String otherMBTI = otherData.mbti!;
    for (int i = 0; i < 4; i++) {
      if (myMBTI[i] == otherMBTI[i]) count++;
    }
    matchPercent = (count / 4 * 100).toInt();
    return matchPercent;
  }

  int compareSchedule(UserData myData, UserData otherData) {
    int matchPercent = 0;
    int index = 0;
    int count = 0;
    for (var day in myData.schedule.schedule) {
      day.forEach((key, value) {
        if (value == otherData.schedule.schedule[index][key]) {
          count++;
        }
      });
      index++;
    }
    matchPercent = (count / 60 * 100).toInt();
    return matchPercent;
  }

  int compareTags(UserData myData, UserData otherData) {
    List myTags = myData.tags!;
    List otherTags = otherData.tags!;
    int matchPercent = 0;
    int count = 0;

    if (myTags.length >= otherTags.length) {
      for (var element in otherTags) {
        myTags.contains(element) ? count++ : null;
      }
    } else {
      for (var element in myTags) {
        otherTags.contains(element) ? count++ : null;
      }
    }

    matchPercent =
        (count * 2 / (myTags.length + otherTags.length) * 100).toInt();
    return matchPercent;
  }

  @override
  Widget build(BuildContext context) {
    refresh();
    UserData userData = context.read<UserDataProvider>().userData;
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('schools/${userData.school}/users')
          .where("school", isEqualTo: userData.school)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("아직 사용자가 없어요 o_o"));
        }
        if (snapshot.hasError) {
          return const Center(child: Text("오류가 발생했어요!"));
        }
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> data = snapshot.data?.docs ?? [];
          if (data.length < 2) {
            return Center(
                child: IconButton.filled(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              color: Colors.green,
              iconSize: MediaQuery.of(context).size.width * 0.1,
            ));
          }

          return Center(child: swipableCard(data, context));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  CardSwiper swipableCard(
      List<QueryDocumentSnapshot> data, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.height;
    final UserData userData = context.read<UserDataProvider>().userData;

    for (var info in data) {
      var doc = UserData.fromJson(info.data() as Map<String, dynamic>);
      if (doc.uid == userData.uid) {
        data.remove(info);
        break;
      }
    }

    //Map<점수(int), 유저데이처(UserData)> 를 생성한다.
    Map<int, UserData> totalData = {};

    for (var element in data) {
      UserData strangerData =
          UserData.fromJson(element.data() as Map<String, dynamic>);
      totalData[matchFilter(
        myData: userData,
        otherData: strangerData,
        containTags: widget.containTags,
        containMBTI: widget.containMBTI,
        containSchedule: widget.containSchedule,
      )] = strangerData;
    }

    //위에 점수를 도출한 맵을 Key(점수)가 높은 순으로 정렬해서 할당한다.
    Map<int, UserData> finalData = {};

    finalData = Map.fromEntries(
        totalData.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));

    //점수별로 정렬된 카드를 순서대로 출력
    return CardSwiper(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
        threshold: 100,
        cardsCount: finalData.length,
        cardBuilder: (context, index, horizontalOffsetPercentage,
            verticalOffsetPercentage) {
          final UserData doc = finalData.values.elementAt(index);
          late final String score;

          if (doc.score! >= 95) {
            score = "A+";
          } else if (doc.score! >= 90) {
            score = "A";
          } else if (doc.score! >= 85) {
            score = "B+";
          } else if (doc.score! >= 80) {
            score = "B";
          } else if (doc.score! >= 75) {
            score = "C+";
          } else if (doc.score! >= 70) {
            score = "C";
          } else if (doc.score! >= 65) {
            score = "D+";
          } else if (doc.score! >= 60) {
            score = "D";
          } else {
            score = "F";
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StrangerProfilScreen(uid: doc.uid!),
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
                      width: double.infinity,
                      color: Colors.grey,
                      child: Image.network(
                        doc.imageUrl!,
                        height: double.maxFinite,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  //정보부분
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              flex: 8,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 15,
                                  bottom: 20,
                                  left: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //이름, 나이
                                    SizedBox(
                                      width: 220,
                                      child: AutoSizeText(
                                        "${doc.name!}, ${DateTime.now().year - int.parse(doc.birthDate!.split(".")[0])}",
                                        maxLines: 1,
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    //MBTI
                                    Text(
                                      '${doc.mbti}',
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54),
                                    ),
                                    const SizedBox(height: 10),
                                    ExtendedWrap(
                                      maxLines: 2,
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        for (var tag in doc.tags!)
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            child: Text(
                                              tag.toString(),
                                              style: TextStyle(
                                                  color: Colors.grey[850]),
                                            ),
                                          )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: ScoreShower(
                                    score: score,
                                    percentage: finalData.keys.elementAt(index),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
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
