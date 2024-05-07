import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:campusmate/screens/community/widgets/comment_reply_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../comment_screen.dart';

class CommentItem extends StatelessWidget {
  final PostCommentData postCommentData;
  final FirebaseFirestore firestore;
  final String school;

  const CommentItem({
    Key? key,
    required this.postCommentData,
    required this.firestore,
    required this.school,
  }) : super(key: key);

  // 닉네임 가져오기
  FutureBuilder<DocumentSnapshot<Object?>> _buildAuthorName() {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore
          .collection('schools/$school/users')
          .doc(postCommentData.authorUid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text(
            'name',
            style: TextStyle(
              fontSize: 12,
            ),
          );
        }

        // 문서에서 사용자 이름 가져오기
        String authorName = snapshot.data!['name'];

        return Text(
          postCommentData.boardType == 'General' ? authorName : '익명',
          style: const TextStyle(
            fontSize: 12,
          ),
        );
      },
    );
  }

  // 답글 리스트
  Widget _buildCommentReplies() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("schools/$school/" +
              (postCommentData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(postCommentData.postId)
          .collection('comments')
          .doc(postCommentData.commentId)
          .collection('replies')
          .orderBy('timestamp', descending: false)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text('답글이 없습니다.');
        } else {
          List<PostReplyData> replies = snapshot.data!.docs
              .map((doc) =>
                  PostReplyData.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: replies.map((reply) {
              return CommentReplyItem(
                postReplyData: reply,
                firestore: firestore,
                school: school,
              );
            }).toList(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = formatTimeStamp(postCommentData.timestamp!, now);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentScreen(
              postCommentData: postCommentData,
            ),
          ),
        );
      },
      child: SizedBox(
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                ),
                const SizedBox(width: 10),
                _buildAuthorName(),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
            // 댓글 내용
            Container(
              padding: const EdgeInsets.only(left: 46, right: 10),
              width: double.infinity,
              child: Text(
                postCommentData.content.toString(),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.only(left: 46, right: 10),
              child: Row(
                children: [
                  // 답글
                  const Row(
                    children: [
                      Icon(
                        Icons.mode_comment_outlined,
                        color: Colors.grey,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // 좋아요
                  GestureDetector(
                    onTap: () {
                      debugPrint('눌림: 좋아요');
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.thumb_up_alt_outlined,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          postCommentData.likers!.length.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 싫어요
                  GestureDetector(
                    onTap: () {
                      debugPrint('눌림: 싫어요');
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.thumb_down_alt_outlined,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          postCommentData.dislikers!.length.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            _buildCommentReplies(),
          ],
        ),
      ),
    );
  }
}
