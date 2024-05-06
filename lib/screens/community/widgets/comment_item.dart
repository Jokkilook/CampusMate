import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = formatTimeStamp(postCommentData.timestamp!, now);

    return Container(
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
                // 답글 수
                const Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  child: Row(
                    children: [
                      // 좋아요
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

                GestureDetector(
                  child: Row(
                    children: [
                      // 싫어요
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
        ],
      ),
    );
  }
}
