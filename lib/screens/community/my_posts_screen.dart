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

  static const String generalPostsCollection = 'generalPosts';
  static const String anonymousPostsCollection = 'anonymousPosts';

  Future<List<DocumentSnapshot>> _fetchUserPosts(BuildContext context) async {
    try {
      final UserData userData = context.read<UserDataProvider>().userData;
      String currentUserUid = userData.uid!;
      String school = userData.school!;

      final firestore = FirebaseFirestore.instance;

      var generalPostsQuery = firestore
          .collection("schools/$school/$generalPostsCollection")
          .where('authorUid', isEqualTo: currentUserUid)
          .orderBy('timestamp', descending: true);
      var anonymousPostsQuery = firestore
          .collection("schools/$school/$anonymousPostsCollection")
          .where('authorUid', isEqualTo: currentUserUid)
          .orderBy('timestamp', descending: true);

      List<QuerySnapshot> querySnapshots = await Future.wait([
        generalPostsQuery.get(),
        anonymousPostsQuery.get(),
      ]);

      List<DocumentSnapshot> allResults = [
        ...querySnapshots[0].docs,
        ...querySnapshots[1].docs,
      ];

      // 디버깅 로그 출력
      for (var doc in allResults) {
        debugPrint('Fetched post: ${doc.data()}');
      }

      return allResults;
    } catch (e) {
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
            return const Center(child: Text('오류가 발생했습니다. 나중에 다시 시도해주세요.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('작성한 글이 없습니다.'));
          }

          final userPosts = snapshot.data!;

          return ListView.separated(
            itemCount: userPosts.length,
            itemBuilder: (context, index) {
              var postData = PostData.fromJson(
                  userPosts[index].data() as Map<String, dynamic>);
              return _buildPostItem(context, postData,
                  userPosts[index].reference.parent.id, userData);
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

  Widget _buildPostItem(BuildContext context, PostData postData,
      String parentCollectionId, UserData userData) {
    if (parentCollectionId == generalPostsCollection) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(
                postData: postData,
                firestore: FirebaseFirestore.instance,
                userData: userData,
              ),
            ),
          );
        },
        child: GeneralBoardItem(
          postData: postData,
          firestore: FirebaseFirestore.instance,
        ),
      );
    } else if (parentCollectionId == anonymousPostsCollection) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(
                postData: postData,
                firestore: FirebaseFirestore.instance,
                userData: userData,
              ),
            ),
          );
        },
        child: AnonymousBoardItem(
          postData: postData,
        ),
      );
    } else {
      return Container();
    }
  }
}
