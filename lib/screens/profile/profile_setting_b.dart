import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

///프로필 설정 B : 태그 설정
class ProfileSettingB extends StatefulWidget {
  const ProfileSettingB({super.key});

  @override
  State<ProfileSettingB> createState() => _ProfileSettingBState();
}

class _ProfileSettingBState extends State<ProfileSettingB> {
  late int age;
  late String introduce;
  late List<String> userTag = [];

  //테스트 태그 리스트
  var tagList = [
    "공부",
    "동네",
    "취미",
    "식사",
    "카풀",
    "술",
    "등하교",
    "시간 떼우기",
    "연애",
    "편입",
    "취업",
    "토익",
    "친분",
    "연상",
    "동갑",
    "연하",
    "선배",
    "동기",
    "후배"
  ];

  bool isCompleted = false;

  @override
  void initState() {
    super.initState();

    introduce = "";
    age = 0;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "프로필 설정",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTitle : AppColors.lightTitle),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              //상태 진행바
              children: [
                Expanded(
                  flex: 66,
                  child: Container(
                    height: 10,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  flex: 37,
                  child: Container(
                    height: 10,
                    color: isDark ? AppColors.darkTag : AppColors.lightTag,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("   선호 태그 선택",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkHeadText
                                      : AppColors.lightHeadText,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                              child: Text(
                                "최대 8가지 선택",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkHint
                                        : AppColors.lightHint),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          direction: Axis.horizontal,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (var tag in tagList)
                              OutlinedButton(
                                onPressed: () {
                                  if (userTag.contains(tag)) {
                                    //유저 태그 리스트에 태그가 있으면 삭제
                                    userTag.remove(tag);
                                  } else if (userTag.length < 8) {
                                    //유저 태그 리스트에 태그가 없고 리스트가 8개를 넘지 않으면 추가
                                    userTag.add(tag);
                                  }

                                  setState(() {});
                                },
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        width: 0,
                                        color: Colors.white.withOpacity(0)),
                                    backgroundColor: userTag.contains(tag)
                                        ? Colors.green
                                        : (isDark
                                            ? AppColors.darkTag
                                            : AppColors.lightTag),
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10)),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                      color: userTag.contains(tag)
                                          ? const Color(0xff0B351E)
                                          : (isDark
                                              ? AppColors.darkTitle
                                              : AppColors.lightTitle)),
                                ),
                              ),
                          ],
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomButton(
        text: "다음",
        isCompleted: userTag.isNotEmpty,
        onPressed: userTag.isNotEmpty
            ? () {
                //선택된 태그가 없으면 아무 것도 안함(혹시 모를 유저의 이상행동 방지)
                if (userTag.isEmpty) return;
                /* 태그 리스트 데이터베이스에 삽입 */
                userData.tags = userTag;

                context.pushNamed(Screen.profileC);
              }
            : null,
      ),
    );
  }
}
