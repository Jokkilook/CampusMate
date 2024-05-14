import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/profile_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:campusmate/screens/matching/widgets/score_shower.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  Center refreshMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          IconButton.filled(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
            ),
            color: Colors.green,
            iconSize: MediaQuery.of(context).size.width * 0.08,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    refresh();
    UserData userData = context.read<UserDataProvider>().userData;
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('schools/${userData.school}/users')
          .get(),
      builder: (context, snapshot) {
        //로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleLoading();
        }
        //유저 데이터가 없으면
        if (!snapshot.hasData) {
          return refreshMessage("아직 사용자가 없어요 😳");
        }
        //에러가 발생했으면
        if (snapshot.hasError) {
          return refreshMessage("오류가 발생했어요!");
        }
        //데이터가 있을 때
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> data = snapshot.data?.docs ?? [];

          //데이터가 있는데 2개 미만일때,
          if (data.length < 2) {
            return refreshMessage("아직 사용자가 없어요 😳");
          }
          //2개 이상 데이터가 들어왔을 때 스와이프 카드 출력 시도
          try {
            return Center(child: swipableCard(data, context));
          } catch (e) {
            return refreshMessage("추천할 유저가 없어요 😢");
          }
        }
        //그 이 외의 상황
        else {
          return refreshMessage("오류가 발생했어요!");
        }
      },
    );
  }

  CardSwiper swipableCard(
      List<QueryDocumentSnapshot> datas, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.height;
    final UserData userData = context.read<UserDataProvider>().userData;
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    List<QueryDocumentSnapshot> data = datas;
    List<QueryDocumentSnapshot> removeItems = [];

    for (var info in datas) {
      var doc = UserData.fromJson(info.data() as Map<String, dynamic>);
      //불러온 유저 데이터에서 밴한 유저 삭제
      if (userData.banUsers?.contains(doc.uid) ?? false) {
        removeItems.add(info);
        continue;
      }
      //불러온 유저 데이터에서 나를 밴한 유저 데이터 삭제
      if (userData.blockers?.contains(doc.uid) ?? false) {
        removeItems.add(info);
        continue;
      }
      //불러온 유저 데이터에서 내 데이터 삭제
      if (doc.uid == userData.uid) {
        removeItems.add(info);
        continue;
      }
    }

    data.removeWhere((element) => removeItems.contains(element));

    //Map<점수(int), 유저데이터(UserData)> 를 생성한다.
    Map<double, UserData> totalData = {};

    for (var element in data) {
      UserData strangerData =
          UserData.fromJson(element.data() as Map<String, dynamic>);

      //점수가 같으면 데이터가 덮어씌워져 랜덤더블값을 더해 중복 확률 제거
      totalData[matchFilter(
            myData: userData,
            otherData: strangerData,
            containTags: widget.containTags,
            containMBTI: widget.containMBTI,
            containSchedule: widget.containSchedule,
          ) +
          Random().nextDouble()] = strangerData;
    }

    //위에 점수를 도출한 맵을 Key(점수)가 높은 순으로 정렬해서 할당한다.
    Map<double, UserData> finalData = {};
    finalData = Map.fromEntries(
        totalData.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));

    //점수별로 정렬된 카드를 순서대로 출력
    return CardSwiper(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
        threshold: 100,
        cardsCount: finalData.length,
        numberOfCardsDisplayed: finalData.length <= 1 ? finalData.length : 2,
        isLoop: true,
        cardBuilder: (context, index, horizontalOffsetPercentage,
            verticalOffsetPercentage) {
          final UserData doc = finalData.values.elementAt(index);

          //점수 계산
          double calculatedScore = ProfileService.getCalculatedScore(doc);
          String displayScore = "";

          if (calculatedScore > 95) {
            displayScore = "A+";
          } else if (calculatedScore >= 90) {
            displayScore = "A";
          } else if (calculatedScore >= 85) {
            displayScore = "B+";
          } else if (calculatedScore >= 80) {
            displayScore = "B";
          } else if (calculatedScore >= 75) {
            displayScore = "C+";
          } else if (calculatedScore >= 70) {
            displayScore = "C";
          } else if (calculatedScore >= 65) {
            displayScore = "D+";
          } else if (calculatedScore > 60) {
            displayScore = "D";
          } else {
            displayScore = "F";
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StrangerProfilScreen(uid: doc.uid!),
                  )).then((value) => value ? setState(() {}) : null);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //사진부분
                  Expanded(
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
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //이름,나이 / MBTI / 태그 표시
                        Flexible(
                          flex: 8,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              bottom: 20,
                              left: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //이름, 나이
                                SizedBox(
                                  width: 220,
                                  child: AutoSizeText(
                                    "${doc.name!}, ${DateTime.now().year - int.parse(doc.birthDate!.split(".")[0])}",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTitle
                                            : AppColors.lightTitle,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                //MBTI
                                Text(
                                  '${doc.mbti}',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkHint
                                          : AppColors.lightHint),
                                ),
                                const SizedBox(height: 10),
                                //태그
                                ExtendedWrap(
                                  maxLines: 2,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (var tag in doc.tags!)
                                      Container(
                                        decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.darkTag
                                                : AppColors.lightTag,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        child: Text(
                                          tag.toString(),
                                          style: TextStyle(
                                              color: isDark
                                                  ? AppColors.darkText
                                                  : AppColors.lightText),
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
                                score: displayScore,
                                percentage:
                                    finalData.keys.elementAt(index).toInt(),
                              ),
                            ),
                          ),
                        )
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
