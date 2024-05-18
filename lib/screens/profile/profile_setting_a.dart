import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/profile_setting_b.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///프로필 설정 A : 생일, 성별, 자기소개, MBTI 설정
class ProfileSettingA extends StatefulWidget {
  const ProfileSettingA({super.key});

  @override
  State<ProfileSettingA> createState() => _ProfileSettingAState();
}

class _ProfileSettingAState extends State<ProfileSettingA> {
  late int year;
  late int month = 1;
  late int day = 1;
  late List<int> yearList;
  final List<int> monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  late List<int> dayList;
  late String introduce;

  final TextEditingController ageController = TextEditingController();
  final TextEditingController introController = TextEditingController();

  bool isCompleted = false;
  bool gender = true; //true = 남 ,false = 여
  bool ei = true; //true = E, false = I
  bool ns = true; //true = N, false = S
  bool tf = true; //true = T, false = F
  bool pj = true; //true = P, false = J

  @override
  void initState() {
    super.initState();

    introduce = "";
    year = DateTime.now().year - 20;
    yearList = [for (int i = 1990; i < DateTime.now().year; i++) i];
    dayList = [for (int i = 1; i < 32; i++) i];

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
            color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
          ),
        ),
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
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  flex: 67,
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
                            Text("   생년월일",
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
                                "설정이 완료되면 수정할 수 없어요!",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkHint
                                      : AppColors.lightHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //년도
                            SizedBox(
                              width: 110,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isDark
                                          ? AppColors.darkLine
                                          : AppColors.lightLine,
                                      width: 1.5),
                                  color: isDark
                                      ? AppColors.darkInput
                                      : AppColors.lightInput,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton(
                                  underline: Container(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: isDark
                                        ? AppColors.darkLine
                                        : AppColors.lightLine,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(10),
                                  value: year,
                                  items: yearList
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text('$e')))
                                      .toList(),
                                  onChanged: (int? value) {
                                    year = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            //월
                            SizedBox(
                              width: 90,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isDark
                                          ? AppColors.darkLine
                                          : AppColors.lightLine,
                                      width: 1.5),
                                  color: isDark
                                      ? AppColors.darkInput
                                      : AppColors.lightInput,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton(
                                  underline: Container(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: isDark
                                        ? AppColors.darkLine
                                        : AppColors.lightLine,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(10),
                                  value: month,
                                  items: monthList
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text('$e')))
                                      .toList(),
                                  onChanged: (int? value) {
                                    month = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            //일
                            SizedBox(
                              width: 90,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isDark
                                          ? AppColors.darkLine
                                          : AppColors.lightLine,
                                      width: 1.5),
                                  color: isDark
                                      ? AppColors.darkInput
                                      : AppColors.lightInput,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton(
                                  underline: Container(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: isDark
                                        ? AppColors.darkLine
                                        : AppColors.lightLine,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(10),
                                  value: day,
                                  items: dayList
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text('$e')))
                                      .toList(),
                                  onChanged: (int? value) {
                                    day = value!;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("   성별",
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
                                "설정이 완료되면 수정할 수 없어요!",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkHint
                                      : AppColors.lightHint,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: gender
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !gender
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                        Text("   소개",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkHeadText
                                  : AppColors.lightHeadText,
                            )),
                        const SizedBox(height: 5),
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: SizedBox(
                            height: 150,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              controller: introController,
                              maxLines: 20,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.darkLine
                                            : AppColors.lightLine,
                                        width: 1.5,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.darkLine
                                            : AppColors.lightLine,
                                        width: 1.5,
                                      )),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.darkInput
                                      : AppColors.lightInput,
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
                        Text("   MBTI",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkHeadText
                                  : AppColors.lightHeadText,
                            )),
                        const SizedBox(height: 5),
                        //MBTI
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: () {
                                  ei = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "E",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: ei
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: ei
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                                  ei = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "I",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: !ei
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: !ei
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                                  ns = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "N",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: ns
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: ns
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                                  ns = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "S",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: !ns
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: !ns
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                                  tf = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "T",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: tf
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: tf
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                                  tf = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "F",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: !tf
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: !tf
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                                  pj = true;
                                  setState(() {});
                                },
                                child: Text(
                                  "P",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: pj
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: pj
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
                                  pj = false;
                                  setState(() {});
                                },
                                child: Text(
                                  "J",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: !pj
                                          ? AppColors.buttonText
                                          : (isDark
                                              ? AppColors
                                                  .darkUnselectedButtonText
                                              : AppColors
                                                  .lightUnselectedButtonText),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                  backgroundColor: !pj
                                      ? AppColors.button
                                      : (isDark
                                          ? AppColors.darkUnselectedButton
                                          : AppColors.lightUnselectedButton),
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
      bottomNavigationBar: BottomButton(
        text: "다음",
        isCompleted: introController.value.text.isNotEmpty,
        onPressed: introController.value.text.isNotEmpty
            ? () {
                /* 나이 성별 소개 MBTI 데이터베이스에 삽입 */
                userData.birthDate = "$year.$month.$day";
                userData.gender = gender;
                userData.introduce = introController.value.text;
                var mbti = [];
                ei ? mbti.add("E") : mbti.add("I");
                ns ? mbti.add("N") : mbti.add("S");
                tf ? mbti.add("T") : mbti.add("F");
                pj ? mbti.add("P") : mbti.add("J");
                userData.mbti = "${mbti[0]}${mbti[1]}${mbti[2]}${mbti[3]}";

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettingB(),
                    ));
              }
            : null,
      ),
    );
  }
}
