import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScheduleTable extends StatefulWidget {
  const ScheduleTable({super.key});

  @override
  State<ScheduleTable> createState() => _ScheduleTableState();
}

class _ScheduleTableState extends State<ScheduleTable> {
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

  Map<String, bool> monSchedule = {
    "MON08": true,
    "MON09": true,
    "MON10": true,
    "MON11": true,
    "MON12": true,
    "MON13": true,
    "MON14": true,
    "MON15": true,
    "MON16": true,
    "MON17": true,
    "MON18": true,
    "MON19": true,
  };

  Map<String, bool> tueSchedule = {
    "TUE08": true,
    "TUE09": true,
    "TUE10": true,
    "TUE11": true,
    "TUE12": true,
    "TUE13": true,
    "TUE14": true,
    "TUE15": true,
    "TUE16": true,
    "TUE17": true,
    "TUE18": true,
    "TUE19": true,
  };

  Map<String, bool> wedSchedule = {
    "WED08": true,
    "WED09": true,
    "WED10": true,
    "WED11": true,
    "WED12": true,
    "WED13": true,
    "WED14": true,
    "WED15": true,
    "WED16": true,
    "WED17": true,
    "WED18": true,
    "WED19": true,
  };

  Map<String, bool> thuSchedule = {
    "THU08": true,
    "THU09": true,
    "THU10": true,
    "THU11": true,
    "THU12": true,
    "THU13": true,
    "THU14": true,
    "THU15": true,
    "THU16": true,
    "THU17": true,
    "THU18": true,
    "THU19": true,
  };

  Map<String, bool> friSchedule = {
    "FRI08": true,
    "FRI09": true,
    "FRI10": true,
    "FRI11": true,
    "FRI12": true,
    "FRI13": true,
    "FRI14": true,
    "FRI15": true,
    "FRI16": true,
    "FRI17": true,
    "FRI18": true,
    "FRI19": true,
  };

  late List<Map<String, bool>> totalSchedule;

  @override
  Widget build(BuildContext context) {
    totalSchedule = [
      monSchedule,
      tueSchedule,
      wedSchedule,
      thuSchedule,
      friSchedule
    ];

    return Container(
      clipBehavior: Clip.hardEdge,
      foregroundDecoration: BoxDecoration(
          border: Border.all(width: 1.5, color: const Color(0xFFD2D2D2)),
          borderRadius: BorderRadius.circular(10)),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color(0xFFD2D2D2)),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: Column(
              children: [
                for (var time in timeData)
                  Container(
                      width: 1000,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 0.5, color: const Color(0xFFD2D2D2)),
                      ),
                      child: Center(
                          child: Text(
                        time,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w500),
                      )))
              ],
            ),
          ),
          for (var day in totalSchedule)
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  Container(
                      width: 1000,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E9E9),
                        border: Border.all(
                            width: 0.5, color: const Color(0xFFD2D2D2)),
                      ),
                      child: Center(
                          child: Text(
                        day.keys.first.substring(0, 3),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ))),
                  for (var detail in day.entries)
                    GestureDetector(
                      onTap: () {
                        day[detail.key] = !detail.value;

                        print(
                            "${day[detail.key]} ${detail.key} ${detail.value}");
                        setState(() {});
                      },
                      child: Container(
                        width: 1000,
                        height: 35,
                        decoration: BoxDecoration(
                          color: detail.value
                              ? const Color(0xFFFAFAFA)
                              : const Color(0xFF2CB66B),
                          border: Border.all(
                              width: 0.5, color: const Color(0xFFD2D2D2)),
                        ),
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
