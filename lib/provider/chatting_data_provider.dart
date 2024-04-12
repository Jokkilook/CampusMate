import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChattingDataProvider extends ChangeNotifier {
  QuerySnapshot<Object>? chatListInitData;
  Stream<QuerySnapshot>? chatListStream;
  Map<String, QuerySnapshot<Object>> chattingCache = {};
}