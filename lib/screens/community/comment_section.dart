import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/screens/community/widgets/comment_item.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentSection extends StatefulWidget {
  final PostData postData;

  const CommentSection({super.key, required this.postData});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final PostService postService = PostService();

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    return FutureBuilder<QuerySnapshot>(
      future: postService.getPostComment(widget.postData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleLoading();
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Text("댓글을 불러올 수 없습니다."),
                IconButton.filled(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh))
              ],
            ),
          );
        }

        if (snapshot.hasData) {
          var datas = snapshot.data?.docs;

          if (datas != null) {
            List<PostCommentData> comments = datas
                .map((e) => PostCommentData.fromJson(e as Map<String, dynamic>))
                .toList();

            return ListView.separated(
              itemCount: comments.length,
              separatorBuilder: (context, index) {
                return Container();
              },
              itemBuilder: (context, index) {
                PostCommentData comment = comments[index];

                return Text(comment.content!);
                // CommentItem(
                //     postCommentData: comment,
                //     onReplyPressed: (p0) {},
                //     refreshCallback: () {},
                //     postAuthorUid: comment.authorUid ?? "",
                //     userData: userData);
              },
            );
          }

          return Center(
            child: Column(
              children: [
                const Text("댓글을 불러올 수 없습니다."),
                IconButton.filled(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh))
              ],
            ),
          );
        }

        return Center(
          child: Column(
            children: [
              const Text("댓글을 불러올 수 없습니다."),
              IconButton.filled(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh))
            ],
          ),
        );
      },
    );
  }
}
