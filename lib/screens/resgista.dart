import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
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
  final schoolList = ["대림대학교", "안양대학교", "한세대학교"];
  final deptList = ["컴퓨터공학과", "물리학과", "생명공학과"];

  late int selectedYear;
  late String selectedSchool;
  late String selectedDept;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    selectedYear = DateTime.now().year;
    selectedSchool = "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (/* 로그인 화면으로 돌아가기 */) {},
              icon: const Icon(Icons.close))
        ],
        title: const Text("회원가입"),
        shadowColor: Colors.black,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("  입학연도",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            FractionallySizedBox(
              widthFactor: 1,
              child: SizedBox(
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45, width: 1.5),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton(
                    underline: Container(),
                    icon: const Icon(Icons.keyboard_arrow_down_outlined,
                        color: Colors.black45),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(10),
                    value: selectedYear,
                    items: yearList
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text('$e')))
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
                selectedSchool = value!;
                isReady = !isReady;
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            const Text("   학과 선택",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
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
                selectedDept = value!;
                setState(() {});
              },
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text(
                "로그인",
                style: TextStyle(color: Color(0xFF0A351E), fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BB56B),
                minimumSize: const Size(100, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
