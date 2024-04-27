import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/matching/match_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text("캠퍼스메이트"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                var pref = await SharedPreferences.getInstance();
                showDialog(
                  context: context,
                  builder: (_) {
                    return FilterDialog(pref: pref);
                  },
                ).then((value) {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.tune))
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            AdArea(),
            Expanded(child: MatchCard()),
          ],
        ),
      ),
      bottomNavigationBar: Container(height: 70),
    );
  }
}

//필터 다이얼로그
class FilterDialog extends StatefulWidget {
  final SharedPreferences pref;

  const FilterDialog({super.key, required this.pref});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late bool containTags;
  late bool containMBTI;
  late bool containSchdeule;
  bool showWarning = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.pref.getBool("containTags") ?? true
        ? containTags = true
        : containTags = false;
    widget.pref.getBool("containMBTI") ?? true
        ? containMBTI = true
        : containMBTI = false;
    widget.pref.getBool("containSchdeule") ?? true
        ? containSchdeule = true
        : containSchdeule = false;
  }

  void showWaring() async {
    showWarning = true;
    Future.delayed(const Duration(minutes: 2));
    showWarning = false;
  }

  @override
  Widget build(BuildContext context) {
    var list = [containTags, containMBTI, containSchdeule];

    return PopScope(
      onPopInvoked: (didPop) {
        widget.pref.setBool("containTags", containTags);
        widget.pref.setBool("containMBTI", containMBTI);
        widget.pref.setBool("containSchdeule", containSchdeule);
      },
      child: Dialog(
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "매치율 조건 설정",
                style: TextStyle(fontSize: 20),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("태그 비교"),
                      Switch(
                        value: containTags,
                        onChanged: (value) async {
                          list.where((element) => element == true).length <= 1
                              ? setState(() {
                                  showWaring();
                                })
                              : containTags = value;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("MBTI 비교"),
                      Switch(
                        value: containMBTI,
                        onChanged: (value) {
                          containMBTI = value;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("시간표 비교"),
                      Switch(
                        value: containSchdeule,
                        onChanged: (value) {
                          containSchdeule = value;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  showWarning ? const Text("조건을 1개 이상 선택해야합니다.") : Container()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
