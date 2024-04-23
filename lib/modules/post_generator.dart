import 'dart:math';
import 'package:campusmate/models/post_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:provider/provider.dart';

class PostGenerator {
  PostData postData = PostData();
  DataBase db = DataBase();
  int index = 0;

  void addDummyPost(BuildContext context, int quantity,
      {bool isGeneral = true}) async {
    UserData userData = context.read<UserDataProvider>().userData;
    AggregateQuerySnapshot query = await db.db
        .collection(
            "schools/${userData.school}/${isGeneral ? "generalPosts" : "anonymousPosts"}")
        .count()
        .get();
    index = query.count ?? index;

    for (int i = 0; i < quantity; i++) {
      randomAsign(context, isGeneral);
      postData.setData();
      db.addPost(userData, postData);
      index++;
    }
  }

  void deleteDummyPost(BuildContext context, int quantity,
      {bool isGeneral = true}) async {
    UserData userData = context.read<UserDataProvider>().userData;
    QuerySnapshot snapshot = await db.db
        .collection(
            "schools/${userData.school}/${isGeneral ? "generalPosts" : "anonymousPosts"}")
        .where("uid", isEqualTo: userData.uid)
        .get();

    for (int i = 0; i < quantity; i++) {
      await db.db
          .collection(
              "schools/${userData.school}/${isGeneral ? "generalPosts" : "anonymousPosts"}")
          .doc(snapshot.docs[i].id)
          .delete();
    }
  }

  void randomAsign(BuildContext context, bool isGeneral) {
    UserData userData = context.read<UserDataProvider>().userData;
    postData = PostData();
    postData.boardType = isGeneral ? "General" : "Anonymous";
    postData.title = lorem(paragraphs: 1, words: Random().nextInt(2) + 8);
    postData.content = lorem(
        paragraphs: Random().nextInt(2) + 1, words: Random().nextInt(50) + 5);
    postData.timestamp = Timestamp.fromDate(DateTime.now());
    postData.authorUid = userData.uid;
  }
}
