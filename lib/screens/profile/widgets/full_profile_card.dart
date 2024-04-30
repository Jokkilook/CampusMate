import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/screens/profile/widgets/schedule_table.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';

class FullProfileCard extends StatelessWidget {
  const FullProfileCard(
      {super.key, required this.userData, required this.context});
  final UserData userData;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    late final String score;
    if (userData.score! >= 95) {
      score = "A+";
    } else if (userData.score! >= 90) {
      score = "A";
    } else if (userData.score! >= 85) {
      score = "B+";
    } else if (userData.score! >= 80) {
      score = "B";
    } else if (userData.score! >= 75) {
      score = "C+";
    } else if (userData.score! >= 70) {
      score = "C";
    } else if (userData.score! >= 65) {
      score = "D+";
    } else if (userData.score! >= 60) {
      score = "D";
    } else {
      score = "F";
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
                  color: Theme.of(context).cardTheme.color,
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
                    Text(
                      "${userData.name}",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge!.color,
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
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '자기소개',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .color,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${userData.introduce}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
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
                              color: Theme.of(context).cardColor,
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
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '나이  ${DateTime.now().year - int.parse(userData.birthDate!.split(".")[0])}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                          ),
                                        ),
                                        Text(
                                          '성별  ${userData.gender! ? "남" : "여"}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                          ),
                                        ),
                                        Text(
                                          '학과  ${userData.dept}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const VerticalDivider(width: 30),
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
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge!
                                                        .color,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                //매너학점이 뭔지 알려주는 안내 카드 출력
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      const Dialog(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 40,
                                                              vertical: 40),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            "매너학점이란?",
                                                            textAlign: TextAlign
                                                                .justify,
                                                            style: TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(height: 20),
                                                          Text(
                                                            "매너학점은 이용자의 평판을 점수화 시킨 것으로 다른 이용자에게 받은 평가를 기준으로 산정됩니다.\n\n A+부터 F까지 9개의 등급이 있습니다.",
                                                            style: TextStyle(
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
                                              score,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .color,
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
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '성향',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text('${userData.mbti}'),
                                  Divider(
                                    color: Colors.grey[300],
                                  ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (var tag in userData.tags!)
                                        Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).canvasColor,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          child: Text(tag.toString()),
                                        )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),

                          //시간표
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Text(
                                      '시간표',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .color,
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
