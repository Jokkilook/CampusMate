class SchoolData {
  final String name;
  final List<String> dept;

  SchoolData.fromjson(String schoolName, Map<String, dynamic> json)
      : name = schoolName,
        dept = json["depts"];
}
