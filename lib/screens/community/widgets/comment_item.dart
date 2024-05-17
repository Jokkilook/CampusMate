import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:campusmate/screens/community/widgets/reply_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile/profile_screen.dart';
import '../../profile/stranger_profile_screen.dart';

class CommentItem extends StatefulWidget {
  final PostCommentData postCommentData;
  final FirebaseFirestore firestore;
  final String school;
  final Function(String) onReplyPressed;
  final VoidCallback refreshCallback;

  const CommentItem({
    Key? key,
    required this.postCommentData,
    required this.firestore,
    required this.school,
    required this.onReplyPressed,
    required this.refreshCallback,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  // 닉네임과 프로필 이미지 가져오기
  FutureBuilder<DocumentSnapshot<Object?>> _buildAuthorInforms() {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
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

        // 문서에서 사용자 이름과 이미지 URL 가져오기
        String authorName = snapshot.data!['name'];
        String? imageUrl = snapshot.data!['imageUrl'];

        return GestureDetector(
          onTap: () {
            // boardType이 General일 때만 프로필 조회 가능
            if (widget.postCommentData.boardType == 'General') {
              // 작성자가 현재 유저일 때
              if (widget.postCommentData.authorUid == currentUserUid) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ));
              }
              // 작성자가 다른 유저일 때
              else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StrangerProfilScreen(
                          uid: widget.postCommentData.authorUid.toString()),
                    ));
              }
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    widget.postCommentData.boardType == 'General' &&
                            imageUrl != null
                        ? NetworkImage(imageUrl)
                        : null,
                child: widget.postCommentData.boardType != 'General' ||
                        imageUrl == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                widget.postCommentData.boardType == 'General'
                    ? authorName
                    : '익명',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
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
          return const SizedBox();
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
              return ReplyItem(
                postReplyData: reply,
                firestore: widget.firestore,
                school: widget.school,
                refreshCallback: widget.refreshCallback,
              );
            }).toList(),
          );
        }
      },
    );
  }

  // 좋아요, 싫어요
  Future<void> voteLikeDislike(bool isLike) async {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    bool userLiked = widget.postCommentData.likers!.contains(currentUserUid);
    bool userDisliked =
        widget.postCommentData.dislikers!.contains(currentUserUid);

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
                (widget.postCommentData.boardType == 'General'
                    ? 'generalPosts'
                    : 'anonymousPosts'))
            .doc(widget.postCommentData.postId)
            .collection('comments')
            .doc(widget.postCommentData.commentId)
            .update({
          'likers': FieldValue.arrayUnion([currentUserUid]),
        });
        setState(() {
          widget.postCommentData.likers!.add(currentUserUid);
        });
      }
      if (!isLike) {
        await FirebaseFirestore.instance
            .collection("schools/${widget.school}/" +
                (widget.postCommentData.boardType == 'General'
                    ? 'generalPosts'
                    : 'anonymousPosts'))
            .doc(widget.postCommentData.postId)
            .collection('comments')
            .doc(widget.postCommentData.commentId)
            .update({
          'dislikers': FieldValue.arrayUnion([currentUserUid]),
        });
        setState(() {
          widget.postCommentData.dislikers!.add(currentUserUid);
        });
      }
    }
  }

  // 삭제 or 신고
  void _showAlertDialog(BuildContext context) {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    String authorUid = widget.postCommentData.authorUid.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            currentUserUid == authorUid ? '정말 삭제하시겠습니까?' : '정말 신고하시겠습니까?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "취소",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                currentUserUid == authorUid
                    ? _deleteComment(context)
                    : Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComment(BuildContext context) async {
    try {
      // 댓글의 하위 답글 가져오기
      QuerySnapshot replySnapshot = await FirebaseFirestore.instance
          .collection("schools/${widget.school}/" +
              (widget.postCommentData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postCommentData.postId)
          .collection('comments')
          .doc(widget.postCommentData.commentId)
          .collection('replies')
          .get();

      // 댓글과 답글 삭제
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.delete(FirebaseFirestore.instance
          .collection("schools/${widget.school}/" +
              (widget.postCommentData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postCommentData.postId)
          .collection('comments')
          .doc(widget.postCommentData.commentId));

      for (var doc in replySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // commentCount 업데이트
      int repliesCount = replySnapshot.docs.length;
      DocumentReference postRef = FirebaseFirestore.instance
          .collection("schools/${widget.school}/" +
              (widget.postCommentData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postCommentData.postId);

      batch.update(postRef, {
        'commentCount': FieldValue.increment(-(1 + repliesCount)),
      });

      await batch.commit();

      // 다이얼로그 닫기
      Navigator.pop(context);

      // 화면 새로 고침 콜백 호출
      widget.refreshCallback();
    } catch (e) {
      debugPrint('삭제 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime =
        formatTimeStamp(widget.postCommentData.timestamp!, now);
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';

    bool userLiked = widget.postCommentData.likers!.contains(currentUserUid);
    bool userDisliked =
        widget.postCommentData.dislikers!.contains(currentUserUid);

    return SizedBox(
      child: Column(
        children: [
          Row(
            children: [
              _buildAuthorInforms(),
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
                onPressed: () {
                  _showAlertDialog(context);
                },
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
