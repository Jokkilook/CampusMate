import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campusmate/screens/community/widgets/general_board_item.dart';
import 'package:campusmate/screens/community/widgets/anonymous_board_item.dart';
import 'package:provider/provider.dart';
import 'post_screen.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  Future<List<DocumentSnapshot>> _fetchUserPosts(BuildContext context) async {
    try {
      // 사용자 데이터 가져오기
      final UserData userData = context.read<UserDataProvider>().userData;
      String currentUserUid = userData.uid!;
      String school = userData.school!;

      // Firestore 인스턴스 가져오기
      final firestore = FirebaseFirestore.instance;

      // 일반 게시물과 익명 게시물 쿼리
      var generalPostsQuery = firestore
          .collection("schools/$school/generalPosts")
          .where('authorUid', isEqualTo: currentUserUid);
      var anonymousPostsQuery = firestore
          .collection("schools/$school/anonymousPosts")
          .where('authorUid', isEqualTo: currentUserUid);

      // 쿼리 실행
      List<QuerySnapshot> querySnapshots = await Future.wait([
        generalPostsQuery.get(),
        anonymousPostsQuery.get(),
      ]);

      // 결과 병합
      List<DocumentSnapshot> allResults = [
        ...querySnapshots[0].docs,
        ...querySnapshots[1].docs,
      ];

      return allResults;
    } catch (e) {
      // 에러 처리
      debugPrint('Error fetching user posts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 작성한 글'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchUserPosts(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('작성한 글이 없습니다.'));
          }

          final userPosts = snapshot.data!;

          return ListView.separated(
            itemCount: userPosts.length,
            itemBuilder: (context, index) {
              var postData = PostData.fromJson(
                  userPosts[index].data() as Map<String, dynamic>);
              if (userPosts[index].reference.parent.id == 'generalPosts') {
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
              } else if (userPosts[index].reference.parent.id ==
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
          );
        },
      ),
    );
  }
}
