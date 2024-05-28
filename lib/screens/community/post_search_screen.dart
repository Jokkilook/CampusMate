import 'package:campusmate/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campusmate/screens/community/widgets/general_board_item.dart';
import 'package:campusmate/screens/community/widgets/anonymous_board_item.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostSearchScreen extends StatefulWidget {
  const PostSearchScreen({super.key});

  @override
  _PostSearchScreenState createState() => _PostSearchScreenState();
}

class _PostSearchScreenState extends State<PostSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void _searchPosts(String query) async {
    final UserData userData = context.read<UserDataProvider>().userData;

    if (query.isNotEmpty) {
      // generalPosts title 검색
      QuerySnapshot generalPostsTitleSnapshot = await FirebaseFirestore.instance
          .collection("schools/${userData.school!}/generalPosts")
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('title')
          .orderBy('timestamp', descending: true)
          .get();

      // anonymousPosts title 검색
      QuerySnapshot anonymousPostsTitleSnapshot = await FirebaseFirestore
          .instance
          .collection("schools/${userData.school!}/anonymousPosts")
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('title')
          .orderBy('timestamp', descending: true)
          .get();

      // generalPosts content 검색
      QuerySnapshot generalPostsContentSnapshot = await FirebaseFirestore
          .instance
          .collection("schools/${userData.school!}/generalPosts")
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('content')
          .orderBy('timestamp', descending: true)
          .get();

      // anonymousPosts content 검색
      QuerySnapshot anonymousPostsContentSnapshot = await FirebaseFirestore
          .instance
          .collection("schools/${userData.school!}/anonymousPosts")
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('content')
          .orderBy('timestamp', descending: true)
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

      // 시간순으로 정렬
      uniqueResults.sort((a, b) {
        Timestamp timestampA = a['timestamp'] as Timestamp;
        Timestamp timestampB = b['timestamp'] as Timestamp;
        return timestampB.compareTo(timestampA); // 내림차순 정렬
      });

      setState(() {
        _searchResults = uniqueResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  //검색 바
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: const Icon(Icons.arrow_back)),
                      const Divider(),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDark
                                ? AppColors.darkSearchInput
                                : AppColors.lightSearchInput,
                          ),
                          child: TextField(
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            decoration: const InputDecoration(
                                hintText: "게시글 제목을 검색해주세요!",
                                suffixIcon: Icon(Icons.search),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none)),
                            controller: _searchController,
                            onChanged: (value) {
                              _searchPosts(_searchController.text);
                            },
                          ),
                        ),
                      ),
                    ],
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
                            context.pushNamed(Screen.post, pathParameters: {
                              "postId": postData.postId ?? ""
                            });
                          },
                          child: GeneralBoardItem(
                            postData: postData,
                          ),
                        );
                      } else if (_searchResults[index].reference.parent.id ==
                          'anonymousPosts') {
                        return InkWell(
                          onTap: () {
                            context.pushNamed(Screen.anonymousPost,
                                pathParameters: {
                                  "postId": postData.postId ?? ""
                                });
                          },
                          child: AnonymousBoardItem(
                            postData: postData,
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
        ),
      ),
    );
  }
}
