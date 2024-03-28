import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/screens/profile_setting_b.dart';
import 'package:flutter/material.dart';

class ProfileSettingA extends StatefulWidget {
  ProfileSettingA({super.key, required this.userData});
  UserData userData;

  @override
  State<ProfileSettingA> createState() => _ProfileSettingAState();
}

class _ProfileSettingAState extends State<ProfileSettingA> {
  late int age;
  late String introduce;

  final TextEditingController ageController = TextEditingController();
  final TextEditingController introController = TextEditingController();
  final db = DataBase();

  bool isCompleted = false;

  bool gender = true; //true = 남 ,false = 여
  bool EI = true; //true = E, false = I
  bool NS = true; //true = N, false = S
  bool TF = true; //true = T, false = F
  bool PJ = true; //true = P, false = J

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
        titleSpacing: 40,
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
                  flex: 33,
                  child: Container(
                    height: 10,
                    color: const Color(0xff2CB66B),
                  ),
                ),
                Expanded(
                  flex: 67,
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
                        const Text("   나이",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 5),
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              controller: ageController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                try {
                                  age = int.parse(ageController.text);
                                } catch (e) {
                                  ageController.text = "";
                                }
                              },
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black45,
                                        width: 1.5,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black45,
                                        width: 1.5,
                                      )),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  labelStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("   성별",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  gender = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "남",
                                  style: TextStyle(
                                      color: gender
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gender
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(10000, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10))),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  gender = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "여",
                                  style: TextStyle(
                                      color: !gender
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !gender
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(10000, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text("   소개",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 5),
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: SizedBox(
                            height: 150,
                            child: TextField(
                              controller: introController,
                              maxLines: 20,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black45,
                                        width: 1.5,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black45,
                                        width: 1.5,
                                      )),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  hintText: "프로필에 표시될 소개를 적어보세요!",
                                  labelStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("   MBTI",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Column(
                              children: [],
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  EI = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "E",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: EI
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: EI
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(50, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10))),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  EI = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "I",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: !EI
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: !EI
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(50, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  NS = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "N",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: NS
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: NS
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(50, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10))),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  NS = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "S",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: !NS
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: !NS
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(50, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  TF = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "T",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TF
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: TF
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(50, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10))),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  TF = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "F",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: !TF
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: !TF
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(50, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  PJ = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "P",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: PJ
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: PJ
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(50, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10))),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  PJ = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "J",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: !PJ
                                          ? const Color(0xFF0A351E)
                                          : Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: !PJ
                                      ? const Color(0xFF2BB56B)
                                      : const Color(0xFFE3DFE3),
                                  minimumSize: const Size(50, 60),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                ),
                              ),
                            ),
                          ],
                        )
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
          onPressed: age > 0 && introController.value.text.isNotEmpty
              ? () {
                  /* 나이 성별 소개 MBTI 데이터베이스에 삽입 */
                  widget.userData.age = int.parse(ageController.value.text);
                  widget.userData.gender = gender;
                  widget.userData.introduce = introController.value.text;
                  var mbti = [];
                  EI ? mbti.add("E") : mbti.add("I");
                  NS ? mbti.add("N") : mbti.add("S");
                  TF ? mbti.add("T") : mbti.add("F");
                  PJ ? mbti.add("P") : mbti.add("J");
                  widget.userData.mbti =
                      "${mbti[0]}${mbti[1]}${mbti[2]}${mbti[3]}";
                  print("${mbti[0]}${mbti[1]}${mbti[2]}${mbti[3]}");

                  db.addUser(widget.userData);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileSettingB(userData: widget.userData),
                      ));
                }
              : null,
          child: Text(
            "다음",
            style: TextStyle(
                color: age > 0 && introduce.isNotEmpty
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
