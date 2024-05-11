import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:campusmate/screens/community/widgets/comment_reply_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentItem extends StatefulWidget {
  final PostCommentData postCommentData;
  final FirebaseFirestore firestore;
  final String school;
  final Function(String) onReplyPressed;

  const CommentItem({
    Key? key,
    required this.postCommentData,
    required this.firestore,
    required this.school,
    required this.onReplyPressed,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  // 닉네임 가져오기
  FutureBuilder<DocumentSnapshot<Object?>> _buildAuthorName() {
    return FutureBuilder<DocumentSnapshot>(
      future: widget.firestore
          .collection('schools/${widget.school}/users')
          .doc(widget.postCommentData.authorUid)
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
          widget.postCommentData.boardType == 'General' ? authorName : '익명',
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
          .collection("schools/${widget.school}/" +
              (widget.postCommentData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postCommentData.postId)
          .collection('comments')
          .doc(widget.postCommentData.commentId)
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
                firestore: widget.firestore,
                school: widget.school,
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
    String formattedTime =
        formatTimeStamp(widget.postCommentData.timestamp!, now);

    return SizedBox(
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
              // 답글 작성 버튼
              IconButton(
                onPressed: () {
                  widget.onReplyPressed(
                      widget.postCommentData.commentId.toString());
                },
                icon: const Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
              ),
              // 삭제 or 신고 버튼
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
              widget.postCommentData.content.toString(),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(left: 46, right: 10),
            child: Row(
              children: [
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
                        widget.postCommentData.likers!.length.toString(),
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
                        widget.postCommentData.dislikers!.length.toString(),
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
    );
  }
}
