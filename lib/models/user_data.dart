import 'package:campusmate/models/schedule_data.dart';

class UserData {
  late String? uid;
  late String? name;
  late String? school;
  late String? dept;
  late String? email;
  late String? password;
  late int? enterYear;
  late int? age;
  late bool? gender;
  late String? introduce;
  late String? mbti;
  late List<String>? tags;
  late ScheduleData schedule = ScheduleData();

  Map<String, dynamic>? data;

  UserData(
      {this.uid,
      this.name,
      this.school,
      this.dept,
      this.email,
      this.password,
      this.enterYear,
      this.age,
      this.gender,
      this.introduce,
      this.mbti,
      this.tags}) {
    data = {
      "uid": uid,
      "name": name,
      "school": school,
      "dept": dept,
      "email": email,
      "password": password,
      "enterYear": enterYear,
      "age": age,
      "gender": gender,
      "introduce": introduce,
      "mbti": mbti,
      "tags": tags,
      "schedule": schedule.schedule
    };
  }
}
