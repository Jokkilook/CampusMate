import 'package:auto_size_text/auto_size_text.dart';
import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/services/profile_service.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/screens/profile/widgets/schedule_table.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';

///프로필 화면에서 정보를 출력하는 위젯<br>
///required [userData] : 정보를 출력할 유저 데이터
class FullProfileCard extends StatelessWidget {
  final UserData userData;

  const FullProfileCard({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    //점수 계산
    double calculatedScore = ProfileService.getCalculatedScore(userData);
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

    return SingleChildScrollView(
      child: Consumer(
        builder: (context, mediaData, child) => Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const AdArea(),
              const SizedBox(height: 12),
              // 프로필 카드
              Container(
                clipBehavior: Clip.hardEdge,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 0),
                        blurRadius: 2)
                  ],
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    InstaImageViewer(
                      imageUrl: userData.imageUrl.toString(),
                      child: Image.network(
                        userData.imageUrl.toString(),
                        height: MediaQuery.of(context).size.width * 0.9,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    AutoSizeText(
                      "${userData.name}",
                      minFontSize: 12,
                      maxFontSize: 30,
                      style: TextStyle(
                        color:
                            isDark ? AppColors.darkTitle : AppColors.lightTitle,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // 자기소개
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkInnerSection
                                  : AppColors.lightInnerSection,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '자기소개',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTitle
                                        : AppColors.lightTitle,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${userData.introduce}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 정보, 매너학점
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkInnerSection
                                  : AppColors.lightInnerSection,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${userData.name}님의 정보',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkTitle
                                                : AppColors.lightTitle,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '나이  ${DateTime.now().year - int.parse(userData.birthDate!.split(".")[0])}',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                        Text(
                                          '성별  ${userData.gender! ? "남" : "여"}',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                        Text(
                                          '학과  ${userData.dept}',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(
                                    width: 30,
                                    color: isDark
                                        ? AppColors.darkLine
                                        : AppColors.lightLine,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '매너학점 ',
                                                style: TextStyle(
                                                    color: isDark
                                                        ? AppColors.darkTitle
                                                        : AppColors.lightTitle,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                //매너학점이 뭔지 알려주는 안내 카드 출력
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                    shape:
                                                        ContinuousRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 40,
                                                          vertical: 20),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            "매너학점이란?",
                                                            textAlign: TextAlign
                                                                .justify,
                                                            style: TextStyle(
                                                                color: isDark
                                                                    ? AppColors
                                                                        .darkText
                                                                    : AppColors
                                                                        .lightText,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          Text(
                                                            "매너학점은 이용자의 평판을 점수화 시킨 것으로 다른 이용자에게 받은 평가를 기준으로 산정됩니다.\n\n A+부터 F까지 9개의 등급이 있습니다.",
                                                            style: TextStyle(
                                                              color: isDark
                                                                  ? AppColors
                                                                      .darkText
                                                                  : AppColors
                                                                      .lightText,
                                                              fontSize: 20,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.help_outline,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              displayScore,
                                              style: TextStyle(
                                                color: isDark
                                                    ? AppColors.darkText
                                                    : AppColors.lightText,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //성향, 태그
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkInnerSection
                                  : AppColors.lightInnerSection,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '성향',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTitle
                                        : AppColors.lightTitle,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '${userData.mbti}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText,
                                  ),
                                ),
                                Divider(
                                  color: isDark
                                      ? AppColors.darkLine
                                      : AppColors.lightLine,
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (var tag in userData.tags!)
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
                                                : AppColors.lightText,
                                          ),
                                        ),
                                      )
                                  ],
                                )
                              ],
                            ),
                          ),

                          //시간표
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkInnerSection
                                  : AppColors.lightInnerSection,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Text(
                                    '시간표',
                                    style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTitle
                                            : AppColors.lightTitle,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                  child: ScheduleTable(
                                      scheduleData: userData.schedule,
                                      readOnly: true),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
