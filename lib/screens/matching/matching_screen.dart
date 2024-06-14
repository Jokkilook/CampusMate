import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/screens/matching/widgets/match_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(userData.school!),
        actions: [
          IconButton(
            onPressed: () async {
              var pref = await SharedPreferences.getInstance();
              showDialog(
                context: context,
                builder: (_) {
                  return FilterDialog(pref: pref);
                },
              ).then((value) => value ? null : setState(() {}));
            },
            icon: const Icon(Icons.tune),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            const AdArea(),
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
  late bool containSchedule;
  bool showWarning = false;
  List<bool> initSetting = [];

  @override
  void initState() {
    super.initState();

    widget.pref.getBool("containTags") ?? true
        ? containTags = true
        : containTags = false;
    widget.pref.getBool("containMBTI") ?? true
        ? containMBTI = true
        : containMBTI = false;
    widget.pref.getBool("containSchedule") ?? true
        ? containSchedule = true
        : containSchedule = false;

    initSetting = [containTags, containMBTI, containSchedule];
  }

  void showWaring() async {
    setState(() {
      showWarning = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    try {
      setState(() {
        showWarning = false;
      });
    } catch (e) {
      //
    }
  }

  void setConditions() {
    widget.pref.setBool("containTags", containTags);
    widget.pref.setBool("containMBTI", containMBTI);
    widget.pref.setBool("containSchedule", containSchedule);
  }

  @override
  Widget build(BuildContext context) {
    var list = [containTags, containMBTI, containSchedule];

    return PopScope(
      onPopInvoked: (didPop) {
        if (const ListEquality()
            .equals(initSetting, [containTags, containMBTI, containSchedule])) {
          return;
        }

        setConditions();
      },
      child: Dialog(
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: IntrinsicHeight(
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
                        const Text(
                          "태그 비교",
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: containTags,
                          onChanged: (value) async {
                            if (!value &&
                                list
                                        .where((element) => element == true)
                                        .length ==
                                    1) {
                              showWaring();
                            } else {
                              containTags = value;
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "MBTI 비교",
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: containMBTI,
                          onChanged: (value) {
                            if (!value &&
                                list
                                        .where((element) => element == true)
                                        .length ==
                                    1) {
                              showWaring();
                            } else {
                              containMBTI = value;
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "시간표 비교",
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: containSchedule,
                          onChanged: (value) {
                            if (!value &&
                                list
                                        .where((element) => element == true)
                                        .length ==
                                    1) {
                              showWaring();
                            } else {
                              containSchedule = value;
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    showWarning
                        ? const Text(
                            "조건을 1개 이상 선택해야합니다.",
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.alertText,
                                fontWeight: FontWeight.bold),
                          )
                        : Container()
                  ],
                ),
                TextButton(
                    onPressed: () {
                      bool result = false;
                      if (const ListEquality().equals(initSetting,
                          [containTags, containMBTI, containSchedule])) {
                        result = true;
                      }
                      Navigator.pop(context, result);
                    },
                    child: const Text(
                      "확인",
                      style: TextStyle(fontSize: 16),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
