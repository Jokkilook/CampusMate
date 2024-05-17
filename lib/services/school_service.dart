import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SchoolAPI {
  List<String> schoolList = [];
  Map<String, List<String>> deptList = {};
  List<String> test = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //2:학교이름 10:학과이름 13:상태

  //대학, 학과 정보 파이어스토어에 업로드
  Future uploadSchoolInfo() async {
    //대학교 이름 엑셀 로드
    ByteData nameData = await rootBundle.load('assets/SchoolName.xlsx');
    var nameBytes = nameData.buffer
        .asUint8List(nameData.offsetInBytes, nameData.lengthInBytes);
    var nameExcel = Excel.decodeBytes(nameBytes);

    List<String> onlyList = [];

    for (var table in nameExcel.tables.keys) {
      for (var row in nameExcel.tables[table]!.rows) {
        if (row[9]!.value.toString() == "폐교") {
          continue;
        }
        if (row[3]!.value.toString() == "본교" ||
            row[3]!.value.toString() == "분교") {
          onlyList.add(row[2]!.value.toString());
        }
      }
      onlyList.toSet().toList();
      onlyList.removeWhere((element) => element.contains("학원"));
      onlyList.removeAt(0);
      onlyList.sort();
    }

    debugPrint(onlyList.toString());
    debugPrint(onlyList.length.toString());

    //대학교 학과 엑셀 로드
    ByteData deptData = await rootBundle.load('assets/SchoolDept.xlsx');
    var deptBytes = deptData.buffer
        .asUint8List(deptData.offsetInBytes, deptData.lengthInBytes);
    var deptExcel = Excel.decodeBytes(deptBytes);

    //2:학교이름 10:학과이름 13:상태
    Map<String, List<String>> nameDeptMap = {};

    for (var schoolName in onlyList) {
      nameDeptMap[schoolName] = [];
      for (var table in deptExcel.tables.keys) {
        for (var row in deptExcel.tables[table]!.rows) {
          //학과의 학교 이름이 schoolName과 같고, 이미 있는 학과가 아니라면 추가.
          if (row[2]!.value.toString() == schoolName &&
              !nameDeptMap[schoolName]!.contains(row[2]!.value.toString())) {
            nameDeptMap[schoolName]!.add(row[10]!.value.toString());
          }
        }
      }
      nameDeptMap[schoolName]!.toSet().toList();
      nameDeptMap[schoolName]!.removeAt(0);
      nameDeptMap[schoolName]!.sort();
    }

    debugPrint(nameDeptMap.toString());
    debugPrint(nameDeptMap.length.toString());

    nameDeptMap.forEach((key, value) {
      firestore.collection("selection").doc(key).set({"depts": value});
    });
  }

  //회원가입 시 학교 이름 로드
  Future<List<String>> loadSchoolName({bool isTest = false}) async {
    List<String> resultList = [];

    var data = await firestore.collection("selection").get();
    var docs = data.docs;
    for (var element in docs) {
      resultList.add(element.id);
      deptList[element.id] =
          (element.data()["depts"] as List).map((e) => e.toString()).toList();
    }

    if (isTest) {
      resultList.add("테스트대학교");
      deptList["테스트대학교"] = ["테스트학과"];
    }

    return resultList;
  }

  //엑셀에서 학교 이름 가져오기
  void getNameFromExcel() async {
    ByteData data = await rootBundle.load('assets/SchoolName.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        if (row[9]!.value.toString() == "폐교") {
          continue;
        }
        if (row[3]!.value.toString() == "본교" ||
            row[3]!.value.toString() == "분교") {
          schoolList.add(row[2]!.value.toString());
        } else {
          schoolList
              .add("${row[2]!.value.toString()} ${row[3]!.value.toString()}");
        }
      }
      schoolList.toSet().toList();
      schoolList.removeWhere((element) => element.contains("학원"));
      schoolList.removeAt(0);
      schoolList.sort();
    }
  }

  ////엑셀에서 학교 이름으로 학과 가져오기
  void getDeptFromExcel(String schoolName) async {
    ByteData data = await rootBundle.load('assets/SchoolDept.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        if (row[2]!.value.toString() == schoolName &&
            !test.contains(row[2]!.value.toString())) {
          test.add(row[10]!.value.toString());
        }
      }
    }
    test.toSet().toList();
    //deptList.removeWhere((element) => element.contains("학원"));
    test.removeAt(0);
    schoolList.sort();
  }
}
