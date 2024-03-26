import 'package:campusmate/models/schoolModel.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/school_api.dart';
import 'package:campusmate/screens/regist_screen_b.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 40,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
              onPressed: (/* 로그인 화면으로 돌아가기 */) {},
              icon: const Icon(Icons.close),
            ),
          )
        ],
        title: const Text(
          "회원가입",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C5C5C)),
        ),
        shadowColor: Colors.black,
        elevation: 2,
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
                  color: const Color(0xff2CB66B),
                ),
              ),
              Expanded(
                flex: 90,
                child: Container(
                  height: 10,
                  color: const Color(0xffE4E4E4),
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
                        const Text("  입학연도",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                        const SizedBox(height: 5),
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: SizedBox(
                            height: 50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black45, width: 1.5),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton(
                                underline: Container(),
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: Colors.black45),
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
                        const Text("   학교 선택",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                        const SizedBox(height: 5),
                        DropdownSearch<String>(
                          dropdownButtonProps: const DropdownButtonProps(
                              icon: Icon(
                                Icons.search_outlined,
                                color: Colors.black45,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20)),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                  hintText: "학교를 선택하세요",
                                  hintStyle: const TextStyle(fontSize: 13),
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
                        const Text("   학과 선택",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54)),
                        const SizedBox(height: 5),
                        DropdownSearch<String>(
                          enabled: isReady,
                          dropdownButtonProps: const DropdownButtonProps(
                              icon: Icon(
                                Icons.search_outlined,
                                color: Colors.black45,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20)),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                  hintText: "학과를 선택하세요",
                                  hintStyle: const TextStyle(fontSize: 13),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black38,
                                        width: 1.5,
                                      )),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(40),
        child: ElevatedButton(
          //다음 버튼
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
          child: Text(
            "다음",
            style: TextStyle(
                color: isCompleted ? const Color(0xFF0A351E) : Colors.black45,
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
