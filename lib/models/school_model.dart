class SchoolModel {
  final String name;
  final String dept;

  SchoolModel.fromjson(Map<String, dynamic> json)
      : name = json["학교명"],
        dept = json["학부_과(전공)명"];
}
