import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    "토익"
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "프로필 설정",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C5C5C)),
        ),
        shadowColor: Colors.black,
        elevation: 2,
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
                    color: const Color(0xff2CB66B),
                  ),
                ),
                Expanded(
                  flex: 37,
                  child: Container(
                    height: 10,
                    color: const Color(0xffE4E4E4),
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
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("   선호 태그 선택",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                              child: Text(
                                "최대 8가지 선택",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black45),
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
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                      color: userTag.contains(tag)
                                          ? const Color(0xff0B351E)
                                          : Colors.black54),
                                ),
                                style: OutlinedButton.styleFrom(
                                    side: userTag.contains(tag)
                                        ? BorderSide(
                                            width: 2,
                                            color: Colors.green.shade700)
                                        : BorderSide(
                                            width: 0,
                                            color: Colors.white.withOpacity(0)),
                                    backgroundColor: userTag.contains(tag)
                                        ? Colors.green
                                        : Colors.black12,
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10)),
                              ),
                          ],
                        ),
                        //Text("디버그용 출력 리스트 / $userTag / ${userTag.length}")
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(40),
        child: ElevatedButton(
          onPressed: userTag.isNotEmpty ? () {/* 태그 리스트 데이터베이스에 삽입 */} : null,
          child: Text(
            "다음",
            style: TextStyle(
                color: userTag.isNotEmpty
                    ? const Color(0xFF0A351E)
                    : Colors.black45,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2BB56B),
            minimumSize: const Size(10000, 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
