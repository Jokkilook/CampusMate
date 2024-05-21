import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile/profile_screen.dart';
import '../../profile/stranger_profile_screen.dart';

//ignore: must_be_immutable
class ReplyItem extends StatefulWidget {
  PostReplyData postReplyData;
  final FirebaseFirestore firestore;
  final VoidCallback refreshCallback;

  ReplyItem({
    required this.postReplyData,
    required this.firestore,
    required this.refreshCallback,
    super.key,
  });

  @override
  State<ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
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
          elevation: 0,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
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
          elevation: 0,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
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
            .collection("schools/${widget.postReplyData.school}/" +
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
            .collection("schools/${widget.postReplyData.school}/" +
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

  // 삭제 or 신고
  void _showAlertDialog(BuildContext context) {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    String authorUid = widget.postReplyData.authorUid.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
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
                    ? _deleteReply(context)
                    : Navigator.pop(context);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReply(BuildContext context) async {
    try {
      // Firestore batch 초기화
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 댓글 컬렉션 참조
      CollectionReference commentsCollection = FirebaseFirestore.instance
          .collection("schools/${widget.postReplyData.school}/" +
              (widget.postReplyData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postReplyData.postId)
          .collection('comments');

      // 답글 문서 참조
      DocumentReference replyDocRef = commentsCollection
          .doc(widget.postReplyData.commentId)
          .collection('replies')
          .doc(widget.postReplyData.replyId);

      // 답글 삭제를 배치에 추가
      batch.delete(replyDocRef);

      // 게시글의 commentCount 감소를 배치에 추가
      DocumentReference postDocRef = FirebaseFirestore.instance
          .collection("schools/${widget.postReplyData.school}/" +
              (widget.postReplyData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postReplyData.postId);

      batch.update(postDocRef, {
        'commentCount': FieldValue.increment(-1),
      });

      // 배치 커밋
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
              // 작성자 프로필
              GestureDetector(
                onTap: () {
                  // boardType이 General일 때만 프로필 조회 가능
                  if (widget.postReplyData.boardType == 'General') {
                    // 작성자가 현재 유저일 때
                    if (widget.postReplyData.authorUid == currentUserUid) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ));
                    }
                    // 작성자가 다른 유저일 때
                    else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StrangerProfilScreen(
                                uid: widget.postReplyData.authorUid.toString()),
                          ));
                    }
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: widget.postReplyData.boardType ==
                              'General'
                          ? NetworkImage(
                              widget.postReplyData.profileImageUrl.toString())
                          : null,
                      child: widget.postReplyData.boardType != 'General'
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                  'assets/images/default_image.png'),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.postReplyData.boardType == 'General'
                          ? widget.postReplyData.authorName.toString()
                          : '익명',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
