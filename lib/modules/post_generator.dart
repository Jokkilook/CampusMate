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

  void addDummyPost(int quantity) async {
    AggregateQuerySnapshot query =
        await db.db.collection("generalPosts").count().get();
    index = query.count ?? index;

    for (int i = 0; i < quantity; i++) {
      randomAsign();
      postData.setData();
      db.addPost(postData);
      index++;
    }
  }

  void deleteDummyPost(int quantity) async {
    QuerySnapshot snapshot = await db.db
        .collection("generalPosts")
        .where("uid", isEqualTo: "9UciNePfNfS7KFvbUpgbyMwaSUh1")
        .get();

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      await db.db.collection('generalPosts').doc(doc.id).delete();
    }
  }

  void randomAsign() {
    postData = PostData();
    postData.title = lorem(paragraphs: 1, words: Random().nextInt(2) + 8);
    postData.content = lorem(
        paragraphs: Random().nextInt(2) + 1, words: Random().nextInt(50) + 5);
    postData.timestamp = DateTime.now()
        .add(Duration(days: Random().nextInt(10), hours: Random().nextInt(10)))
        .toString();
    postData.author = RandomNames(Zone.us).name();
    postData.uid = "9UciNePfNfS7KFvbUpgbyMwaSUh1";
  }
}
