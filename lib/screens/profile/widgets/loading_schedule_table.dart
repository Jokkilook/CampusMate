import 'package:auto_size_text/auto_size_text.dart';
import 'package:campusmate/Theme/app_colors.dart';
import 'package:flutter/material.dart';

///시간표 로딩 위젯<br>
///매개변수로 유저의 시간표 데이터를 넣어줘야한다.<br>
class LoadingScheduleTable extends StatefulWidget {
  const LoadingScheduleTable({super.key});

  @override
  State<LoadingScheduleTable> createState() => _LoadingScheduleTableState();
}

class _LoadingScheduleTableState extends State<LoadingScheduleTable> {
  var dayData = ["월", "화", "수", "목", "금"];
  var timeData = [
    " ",
    "08:00 ~ 09:00",
    "09:00 ~ 10:00",
    "10:00 ~ 11:00",
    "11:00 ~ 12:00",
    "12:00 ~ 13:00",
    "13:00 ~ 14:00",
    "14:00 ~ 15:00",
    "15:00 ~ 16:00",
    "16:00 ~ 17:00",
    "17:00 ~ 18:00",
    "18:00 ~ 19:00",
    "19:00 ~ 20:00",
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      clipBehavior: Clip.hardEdge,
      foregroundDecoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10)),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Column(
            children: [
              //시간대 표시(세로칸)
              for (var i = 0; i < 13; i++)
                Container(
                    width: 90,
                    height: 35,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkTag : AppColors.lightTag,
                    ),
                    child: const Center(
                        child: AutoSizeText(
                      "",
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )))
            ],
          ),
          for (var i = 0; i < 5; i++)
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  //요일 표시
                  Container(
                      width: 1000,
                      height: 35,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkTag : AppColors.lightTag,
                      ),
                      child: const Center(
                          child: Text(
                        " ",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ))),
                  //나머지 표시
                  for (var i = 0; i < 12; i++)
                    Container(
                      width: 1000,
                      height: 35,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkTag : AppColors.lightTag,
                      ),
                    ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
