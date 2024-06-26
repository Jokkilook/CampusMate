import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:campusmate/widgets/confirm_dialog.dart';
import 'package:campusmate/widgets/yest_no_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ReplyItem extends StatefulWidget {
  final PostData postData;
  PostReplyData postReplyData;
  final VoidCallback postCallback;
  final VoidCallback deleteCallback;
  final String postAuthorUid;

  ReplyItem({
    required this.postData,
    required this.postReplyData,
    required this.postCallback,
    required this.deleteCallback,
    required this.postAuthorUid,
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
          builder: (context) => ConfirmDialog(content: "이미 좋아요를 눌렀습니다."));
    } else if (userDisliked) {
      // 이미 싫어요를 누른 경우
      showDialog(
          context: context,
          builder: (context) => ConfirmDialog(content: "이미 싫어요를 눌렀습니다."));
    } else {
      if (isLike) {
        await FirebaseFirestore.instance
            .collection(
                "schools/${widget.postReplyData.school}/${widget.postReplyData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
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
            .collection(
                "schools/${widget.postReplyData.school}/${widget.postReplyData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
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
    String authorName = widget.postReplyData.authorName.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return YesNoDialog(
          content: currentUserUid == authorUid
              ? '답글을 삭제하시겠습니까?'
              : '$authorName님을 신고하시겠습니까?',
          onYes: () async {
            context.pop();
            if (currentUserUid == authorUid) {
              await PostService().deleteReply(widget.postReplyData);
              widget.deleteCallback();
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  context.pop();
                  return ConfirmDialog(content: '신고가 접수되었습니다.');
                },
              );
            }
          },
        );
      },
    );
  }

  void openProfile(String userUID) {}

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime =
        formatTimeStamp(widget.postReplyData.timestamp!, now);
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';

    bool userLiked = widget.postReplyData.likers!.contains(currentUserUid);
    bool userDisliked =
        widget.postReplyData.dislikers!.contains(currentUserUid);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //프로필 사진
          GestureDetector(
            onTap: () {
              // boardType이 General일 때만 프로필 조회 가능
              if (widget.postReplyData.boardType == 'General') {
                // 작성자가 현재 유저일 때
                if (widget.postReplyData.authorUid == currentUserUid) {
                  context.pushNamed(Screen.otherProfile, pathParameters: {
                    "uid": widget.postReplyData.authorUid ?? "",
                    "readOnly": "true"
                  });
                }
                // 작성자가 다른 유저일 때
                else {
                  context.pushNamed(Screen.otherProfile, pathParameters: {
                    "uid": widget.postReplyData.authorUid ?? "",
                    "readOnly": "true"
                  });
                }
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.postReplyData.boardType != 'General'
                  ? Stack(
                      children: [
                        Image.asset(
                          'assets/images/default_image.png',
                          fit: BoxFit.cover,
                          width: 36,
                          height: 36,
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            // 작성자가 본인일 경우 프로필 이미지 색을 변경
                            color:
                                widget.postReplyData.authorUid == currentUserUid
                                    ? Colors.blueAccent.withOpacity(0.4)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.postReplyData.profileImageUrl ?? "",
                      fit: BoxFit.cover,
                      width: 36,
                      height: 36,
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/default_image.png',
                        fit: BoxFit.cover,
                        width: 36,
                        height: 36,
                      ),
                      placeholder: (context, url) => Image.asset(
                        'assets/images/default_image.png',
                        fit: BoxFit.cover,
                        width: 36,
                        height: 36,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //작성자 닉네임, 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //작성자 닉네임, 작성 시간
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // boardType이 General일 때만 프로필 조회 가능
                            if (widget.postReplyData.boardType == 'General') {
                              // 작성자가 현재 유저일 때
                              if (widget.postReplyData.authorUid ==
                                  currentUserUid) {
                                context.pushNamed(Screen.otherProfile,
                                    pathParameters: {
                                      "uid":
                                          widget.postReplyData.authorUid ?? "",
                                      "readOnly": "true"
                                    });
                              }
                              // 작성자가 다른 유저일 때
                              else {
                                context.pushNamed(Screen.otherProfile,
                                    pathParameters: {
                                      "uid":
                                          widget.postReplyData.authorUid ?? "",
                                      "readOnly": "true"
                                    });
                              }
                            }
                          },
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.2),
                            child: Text(
                              //일반 게시판이면
                              widget.postReplyData.boardType == 'General'
                                  ?
                                  //댓글 작성자 닉네임 표시
                                  widget.postReplyData.authorName.toString()
                                  //아니면 익명(댓글 단 순서)표시
                                  : '익명 ${widget.postReplyData.authorUid == widget.postData.authorUid ? "" : (widget.postData.commentWriters?.indexOf(widget.postReplyData.authorUid) ?? 0) + 1}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        widget.postReplyData.boardType != 'General'
                            ?
                            // 익명 게시판에서 댓글 작성자가 글 작성자라면 표시
                            (widget.postReplyData.authorUid ==
                                    widget.postAuthorUid
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.8,
                                        color: isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      '작성자',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText,
                                      ),
                                    ),
                                  )
                                : const SizedBox())
                            : const SizedBox(),
                        const SizedBox(width: 8),
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

                    // 삭제 or 신고 버튼
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _showAlertDialog(context),
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                //내용
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.postReplyData.content.toString(),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 6),
                //좋,싫
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 좋아요
                    GestureDetector(
                      onTap: () {
                        voteLikeDislike(true);
                      },
                      child: Row(
                        children: [
                          Row(
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
                                  widget.postReplyData.dislikers!.length
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
