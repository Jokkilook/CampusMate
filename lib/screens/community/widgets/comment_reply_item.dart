import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class CommentReplyItem extends StatefulWidget {
  PostReplyData postReplyData;
  final FirebaseFirestore firestore;
  final String school;

  CommentReplyItem({
    required this.postReplyData,
    required this.firestore,
    required this.school,
    super.key,
  });

  @override
  State<CommentReplyItem> createState() => _CommentReplyItemState();
}

class _CommentReplyItemState extends State<CommentReplyItem> {
  // 닉네임 가져오기
  FutureBuilder<DocumentSnapshot<Object?>> _buildAuthorName() {
    return FutureBuilder<DocumentSnapshot>(
      future: widget.firestore
          .collection('schools/${widget.school}/users')
          .doc(widget.postReplyData.authorUid)
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
          widget.postReplyData.boardType == 'General' ? authorName : '익명',
          style: const TextStyle(
            fontSize: 12,
          ),
        );
      },
    );
  }

  // 좋아요, 싫어요
  Future<void> voteLikeDislike(bool isLike) async {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    bool userLiked = widget.postReplyData.likers!.contains(currentUserUid);
    bool userDisliked =
        widget.postReplyData.dislikers!.contains(currentUserUid);

    if (userLiked) {
      // 이미 좋아요를 누른 경우
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림'),
          content: const Text('이미 좋아요를 눌렀습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else if (userDisliked) {
      // 이미 싫어요를 누른 경우
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림'),
          content: const Text('이미 싫어요를 눌렀습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      if (isLike) {
        await FirebaseFirestore.instance
            .collection("schools/${widget.school}/" +
                (widget.postReplyData.boardType == 'General'
                    ? 'generalPosts'
                    : 'anonymousPosts'))
            .doc(widget.postReplyData.postId)
            .collection('comments')
            .doc(widget.postReplyData.commentId)
            .collection('replies')
            .doc(widget.postReplyData.replyId)
            .update({
          'likers': FieldValue.arrayUnion([currentUserUid]),
        });
        setState(() {
          widget.postReplyData.likers!.add(currentUserUid);
        });
      }
      if (!isLike) {
        await FirebaseFirestore.instance
            .collection("schools/${widget.school}/" +
                (widget.postReplyData.boardType == 'General'
                    ? 'generalPosts'
                    : 'anonymousPosts'))
            .doc(widget.postReplyData.postId)
            .collection('comments')
            .doc(widget.postReplyData.commentId)
            .collection('replies')
            .doc(widget.postReplyData.replyId)
            .update({
          'dislikers': FieldValue.arrayUnion([currentUserUid]),
        });
        setState(() {
          widget.postReplyData.dislikers!.add(currentUserUid);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime =
        formatTimeStamp(widget.postReplyData.timestamp!, now);
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';

    bool userLiked = widget.postReplyData.likers!.contains(currentUserUid);
    bool userDisliked =
        widget.postReplyData.dislikers!.contains(currentUserUid);

    return Container(
      padding: const EdgeInsets.only(left: 46),
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
              widget.postReplyData.content.toString(),
              textAlign: TextAlign.start,
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
                    voteLikeDislike(true);
                  },
                  child: Row(
                    children: [
                      Icon(
                        userLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_alt_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.postReplyData.likers!.length.toString(),
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
                    voteLikeDislike(false);
                  },
                  child: Row(
                    children: [
                      Icon(
                        userDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.postReplyData.dislikers!.length.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // 작성시간
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
