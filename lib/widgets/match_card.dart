import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Tapped");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
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
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where("school", isEqualTo: "테스트대학교")
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Text("사용자가 없어요 o_o");
            }
            if (snapshot.hasError) {
              throw Error();
            } else {
              var data = snapshot.data?.docs ?? [];
              return CardContent(data);
            }
          },
        ),
      ),
    );
  }

  ListView CardContent(final data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
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
          child: Hero(
            tag: doc.get("uid"),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  doc.get("name"),
                  style: const TextStyle(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '자기소개',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        doc.get("introduce"),
                      ),
                    ],
                  ),
                ),
                // 정보, 매너학점
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  height: 105,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '정보',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('나이  ${doc.get("age")}'),
                            Text('성별  ${doc.get("gender") ? "남" : "여"}'),
                            Text('학과  ${doc.get("dept")}'),
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
                            Expanded(
                              child: Center(
                                child: Text(
                                  score,
                                  style: const TextStyle(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                        Text('MBTI  ${doc.get("mbti")}'),
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
                            for (var tag in doc.get("tags"))
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
          ),
        );
      },
    );
  }
}
