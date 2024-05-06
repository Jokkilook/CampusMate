import 'dart:convert';
import 'package:campusmate/models/school_model.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SchoolAPI {
  static const String baseUrl = "https://api.odcloud.kr/api";
  static const String id =
      "/15014632/v1/uddi:6939f45b-1283-4462-b394-820c26e1445d?page=";
  static const String tail = "&perPage=1000";
  static const String key =
      "&serviceKey=YXCUlt2omoo9wIHweuRa2AwH00oXWywq3Up%2F6DVims6C8XED7Xcyn4SR3WaU83G73CP3%2FupnkVWkJnbDvVa%2B%2Bg%3D%3D";

  List<String> schoolList = [];
  List<String> deptList = [];

  Future<void> getSchools() async {
    List<SchoolModel> schoolInstance = [];
    for (int i = 1; i < 61; i++) {
      final url = Uri.parse('$baseUrl$id$i$tail$key');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> schools = jsonDecode(response.body)["data"];
        for (var school in schools) {
          schoolInstance.add(SchoolModel.fromjson(school));
        }

        for (var school in schoolInstance) {
          schoolList.add(school.name);
        }
        debugPrint(response.statusCode.toString());
      } else {
        debugPrint(response.statusCode.toString());
      }
    }
    // schoolList = schoolList.toSet().toList();
    // schoolList.removeWhere((item) => item.contains("학원"));
  }

  static Future<void> getSchoolList() async {
    List<SchoolModel> schoolInstance = [];
    final url = Uri.parse('$baseUrl$id$key');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> schools = jsonDecode(response.body)["data"];
      for (var school in schools) {
        schoolInstance.add(SchoolModel.fromjson(school));
      }
    } else {}
    throw Error();
  }

  static Future<List<SchoolModel>> getDeptName() async {
    List<SchoolModel> schoolInstance = [];
    final url = Uri.parse('$baseUrl$id$key');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> schools = jsonDecode(response.body)["data"];
      for (var school in schools) {
        schoolInstance.add(SchoolModel.fromjson(school));
      }

      return schoolInstance;
    } else {}
    throw Error();
  }

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

  void getDeptFromExcel(String schoolName) async {
    ByteData data = await rootBundle.load('assets/SchoolDept.xlsx');
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        if (row[2]!.value.toString() == schoolName) {
          deptList.add(row[10]!.value.toString());
        }
      }
    }
    deptList.toSet().toList();
    //deptList.removeWhere((element) => element.contains("학원"));
    deptList.removeAt(0);
    schoolList.sort();
  }
  //2:학교이름 10:학과이름 13:상태
}
