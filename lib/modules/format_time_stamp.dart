import 'package:cloud_firestore/cloud_firestore.dart';

String formatTimeStamp(Timestamp timeStamp, DateTime now) {
  DateTime postTime = DateTime.parse(timeStamp.toDate().toString());

  Duration difference = now.difference(postTime);

  if (difference.inSeconds < 60) {
    return "방금";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes}분 전";
  } else if (difference.inHours < 24) {
    return "${difference.inHours}시간 전";
  } else if (difference.inDays < 30) {
    return "${difference.inDays}일 전";
  } else if (difference.inDays < 365) {
    int months = difference.inDays ~/ 30;
    return "$months달 전";
  } else {
    int years = difference.inDays ~/ 365;
    return "$years년 전";
  }
}
