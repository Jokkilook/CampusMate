import 'dart:math';
import 'package:campusmate/models/post_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:random_name_generator/random_name_generator.dart';

class PostGenerator {
  PostData postData = PostData();
  DataBase db = DataBase();
  int index = 0;

  void addDummyPost(int quantity, {bool isGeneral = true}) async {
    AggregateQuerySnapshot query = await db.db
        .collection(isGeneral ? "generalPosts" : "anonymousPosts")
        .count()
        .get();
    index = query.count ?? index;

    for (int i = 0; i < quantity; i++) {
      randomAsign(isGeneral);
      postData.setData();
      db.addPost(postData);
      index++;
    }
  }

  void deleteDummyPost(int quantity, {bool isGeneral = true}) async {
    QuerySnapshot snapshot = await db.db
        .collection(isGeneral ? "generalPosts" : "anonymousPosts")
        .where("uid", isEqualTo: "9UciNePfNfS7KFvbUpgbyMwaSUh1")
        .get();

    for (int i = 0; i < quantity; i++) {
      await db.db
          .collection(isGeneral ? "generalPosts" : "anonymousPosts")
          .doc(snapshot.docs[0].id)
          .delete();
    }
  }

  void randomAsign(bool isGeneral) {
    postData = PostData();
    postData.boardType = isGeneral ? "General" : "Anonymous";
    postData.title = lorem(paragraphs: 1, words: Random().nextInt(2) + 8);
    postData.content = lorem(
        paragraphs: Random().nextInt(2) + 1, words: Random().nextInt(50) + 5);
    postData.timestamp = DateTime.now().toString();
    postData.author = RandomNames(Zone.us).name();
    postData.authorUid = "9UciNePfNfS7KFvbUpgbyMwaSUh1";
  }
}
