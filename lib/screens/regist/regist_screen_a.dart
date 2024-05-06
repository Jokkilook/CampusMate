import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/school_api.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/regist/regist_screen_b.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistScreenA extends StatefulWidget {
  const RegistScreenA({super.key});

  @override
  State<RegistScreenA> createState() => _RegistScreenAState();
}

class _RegistScreenAState extends State<RegistScreenA> {
  final yearList = [
    for (int i = DateTime.now().year; i > DateTime.now().year - 10; i--) i
  ];

  late List<String> schoolList;
  late List<String> deptList;

  late int selectedYear;
  late String selectedSchool;
  late String selectedDept;
  bool isReady = false;
  bool isCompleted = false;

  UserData newUserData = UserData();

  final schools = SchoolAPI();

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year;
    selectedSchool = "";
    //schoolList = schools.schoolList;
    //deptList = schools.deptList;
    //schools.getNameFromExcel();

    schoolList = ["테스트대학교"];
    deptList = ["테스트학과"];

    FirebaseAuth.instance.signOut();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (/* 로그인 화면으로 돌아가기 */) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false);
            },
            icon: const Icon(Icons.close),
          )
        ],
        title: Text(
          "회원가입",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTitle : AppColors.lightTitle),
        ),
      ),
      body: Column(
        children: [
          Row(
            // 진행상황바
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  height: 10,
                  color: Colors.green,
                ),
              ),
              Expanded(
                flex: 90,
                child: Container(
                  height: 10,
                  color: isDark ? AppColors.darkTag : AppColors.lightTag,
                ),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      // 다음버튼 제외한 UI 섹션
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "  입학연도",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkHeadText
                                : AppColors.lightHeadText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: SizedBox(
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
                                value: selectedYear,
                                items: yearList
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text('$e')))
                                    .toList(),
                                onChanged: (int? value) {
                                  selectedYear = value!;
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "   학교 선택",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkHeadText
                                : AppColors.lightHeadText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        DropdownSearch<String>(
                          dropdownButtonProps: DropdownButtonProps(
                              icon: Icon(
                                Icons.search_outlined,
                                color: isDark
                                    ? AppColors.darkLine
                                    : AppColors.lightLine,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20)),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                  hintText: "학교를 선택하세요",
                                  hintStyle: const TextStyle(fontSize: 13),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10))),
                          popupProps: const PopupProps.menu(
                            showSelectedItems: true,
                            showSearchBox: true,
                          ),
                          items: schoolList,
                          onChanged: (value) {
                            //학교가 선택되면 학과 선택이 활성화됨.
                            selectedSchool = value!;
                            //schools.getDeptFromExcel(selectedSchool);
                            selectedSchool.isEmpty
                                ? isReady = false
                                : isReady = true;

                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "   학과 선택",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkHeadText
                                : AppColors.lightHeadText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        DropdownSearch<String>(
                          enabled: isReady,
                          dropdownButtonProps: DropdownButtonProps(
                              icon: Icon(
                                Icons.search_outlined,
                                color: isDark
                                    ? AppColors.darkLine
                                    : AppColors.lightLine,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20)),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                  hintText: "학과를 선택하세요",
                                  hintStyle: const TextStyle(fontSize: 13),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.darkLine
                                            : AppColors.lightLine,
                                        width: 1.5,
                                      )),
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10))),
                          popupProps: const PopupProps.menu(
                            showSelectedItems: true,
                            showSearchBox: true,
                          ),
                          items: deptList,
                          onChanged: (value) {
                            //학과가 선택되면 다음 버튼 활성화됨.
                            selectedDept = value!;

                            isReady && selectedDept.isNotEmpty
                                ? isCompleted = true
                                : isCompleted = false;
                            setState(() {});
                          },
                        ),
                      ]),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomButton(
        text: "다음",
        isCompleted: isCompleted,
        onPressed: isCompleted
            ? () {
                /* 다음 버튼을 누르면 선택된 연도,학교,학과를 저장 */
                newUserData.enterYear = selectedYear;
                newUserData.school = selectedSchool;
                newUserData.dept = selectedDept;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistScreenB(
                        newUserData: newUserData,
                      ),
                    ));
              }
            : null,
      ),
    );
  }
}
