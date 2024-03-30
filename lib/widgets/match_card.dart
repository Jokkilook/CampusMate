import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  MatchCard({super.key});

  var tags = ["냥", "테스트", "싫어요"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
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
        children: [
          const CircleAvatar(
            radius: 60,
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            "닉네임",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          // 자기소개
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '자기소개',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '자기소개',
                ),
              ],
            ),
          ),
          // 정보, 매너학점
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            height: 105,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '정보',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('나이  22'),
                      Text('성별  남'),
                      Text('학과  테스트학과'),
                    ],
                  ),
                ),
                VerticalDivider(
                  width: 30,
                  color: Colors.grey[400],
                  thickness: 1.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            '매너학점 ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              //매너학점이 뭔지 알려주는 안내 카드 출력
                              print("test");
                            },
                            child: const Icon(Icons.help_outline,
                                size: 16, color: Colors.black45),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'B+',
                            style: TextStyle(
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
          //성향, 태그
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '성향',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('MBTI  ENTJ'),
                  const Text(
                    '태그',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var tag in tags)
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(15)),
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
        ],
      ),
    );
  }
}
