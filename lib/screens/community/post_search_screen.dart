import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campusmate/screens/community/widgets/general_board_item.dart';
import 'package:campusmate/screens/community/widgets/anonymous_board_item.dart';
import 'package:provider/provider.dart';

import 'post_screen.dart'; // 추가된 import

class PostSearchScreen extends StatefulWidget {
  const PostSearchScreen({super.key});

  @override
  _PostSearchScreenState createState() => _PostSearchScreenState();
}

class _PostSearchScreenState extends State<PostSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void _searchPosts() async {
    String query = _searchController.text;
    final UserData userData = context.read<UserDataProvider>().userData;

    if (query.isNotEmpty) {
      // generalPosts title 검색
      QuerySnapshot generalPostsTitleSnapshot = await FirebaseFirestore.instance
          .collection("schools/${userData.school!}/generalPosts")
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // anonymousPosts title 검색
      QuerySnapshot anonymousPostsTitleSnapshot = await FirebaseFirestore
          .instance
          .collection("schools/${userData.school!}/anonymousPosts")
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // generalPosts content 검색
      QuerySnapshot generalPostsContentSnapshot = await FirebaseFirestore
          .instance
          .collection("schools/${userData.school!}/generalPosts")
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // anonymousPosts content 검색
      QuerySnapshot anonymousPostsContentSnapshot = await FirebaseFirestore
          .instance
          .collection("schools/${userData.school!}/anonymousPosts")
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // 검색 결과 병합 및 중복 제거
      List<DocumentSnapshot> allResults = [
        ...generalPostsTitleSnapshot.docs,
        ...anonymousPostsTitleSnapshot.docs,
        ...generalPostsContentSnapshot.docs,
        ...anonymousPostsContentSnapshot.docs
      ];

      // 중복 제거
      final uniqueResults =
          {for (var doc in allResults) doc.id: doc}.values.toList();

      setState(() {
        _searchResults = uniqueResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 검색'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '검색어를 입력하세요',
                suffixIcon: IconButton(
                  onPressed: _searchPosts,
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var postData = PostData.fromJson(
                      _searchResults[index].data() as Map<String, dynamic>);
                  if (_searchResults[index].reference.parent.id ==
                      'generalPosts') {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostScreen(
                              postData: postData,
                              firestore: FirebaseFirestore.instance,
                              school: userData.school!,
                              userData: userData,
                            ),
                          ),
                        );
                      },
                      child: GeneralBoardItem(
                        postData: postData,
                        firestore: FirebaseFirestore.instance,
                        school: userData.school!,
                      ),
                    );
                  } else if (_searchResults[index].reference.parent.id ==
                      'anonymousPosts') {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostScreen(
                              postData: postData,
                              firestore: FirebaseFirestore.instance,
                              school: userData.school!,
                              userData: userData,
                            ),
                          ),
                        );
                      },
                      child: AnonymousBoardItem(
                        postData: postData,
                        school: userData.school!,
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
