import 'package:campusmate/app_colors.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/screens/community/modules/format_time_stamp.dart';
import 'package:campusmate/screens/community/widgets/reply_item.dart';
import 'package:campusmate/services/noti_service.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:campusmate/widgets/confirm_dialog.dart';
import 'package:campusmate/widgets/yest_no_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/user_data.dart';

//ignore: must_be_immutable
class CommentItem extends StatefulWidget {
  final PostCommentData postCommentData;
  final Function() onReplyPressed;
  final VoidCallback postCallback;
  final VoidCallback deleteCallback;
  final String postAuthorUid;
  final UserData userData;
  PostData postData;

  CommentItem(
      {super.key,
      required this.postCommentData,
      required this.onReplyPressed,
      required this.postCallback,
      required this.deleteCallback,
      required this.postAuthorUid,
      required this.userData,
      required this.postData});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  PostService postService = PostService();
  TextEditingController replycontroller = TextEditingController();

  // 답글 리스트
  Widget _buildCommentReplies() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection(
              "schools/${widget.postCommentData.school}/${widget.postCommentData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
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
          List<Widget> visibleReplies = [];
          for (var reply in replies) {
            // 차단된 사용자의 답글인지 확인
            if (!(widget.userData.banUsers?.contains(reply.authorUid) ??
                false)) {
              // 차단되지 않은 사용자의 답글만 출력
              visibleReplies.add(
                ReplyItem(
                  postAuthorUid: widget.postData.authorUid ?? "",
                  postReplyData: reply,
                  postData: widget.postData,
                  postCallback: widget.postCallback,
                  deleteCallback: widget.deleteCallback,
                ),
              );
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: visibleReplies,
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
                "schools/${widget.postCommentData.school}/${widget.postCommentData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
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
            .collection(
                "schools/${widget.postCommentData.school}/${widget.postCommentData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
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

  // 삭제 or 신고 다이얼로그
  void _showAlertDialog(BuildContext context) {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    String authorUid = widget.postCommentData.authorUid.toString();
    String authorName = widget.postCommentData.authorName.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return YesNoDialog(
            content: currentUserUid == authorUid
                ? '댓글을 삭제하시겠습니까?'
                : '$authorName님을 신고하시겠습니까?',
            onYes: () async {
              context.pop();
              if (currentUserUid == authorUid) {
                await postService.deleteCommentAndReply(widget.postCommentData);
                widget.deleteCallback();
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmDialog(
                      content: '신고가 접수되었습니다.',
                    );
                  },
                );
              }
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime now = DateTime.now();
    String formattedTime =
        formatTimeStamp(widget.postCommentData.timestamp!, now);
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';

    bool userLiked = widget.postCommentData.likers!.contains(currentUserUid);
    bool userDisliked =
        widget.postCommentData.dislikers!.contains(currentUserUid);
    //final writerIndex = widget.postCommentData.writerIndex;
    final FocusNode keyboardFocus = FocusNode();

    print(widget.postData.commentWriters);
    print(currentUserUid);
    //?.indexOf(currentUserUid));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // //프로필 사진
              InkWell(
                onTap: () {
                  // boardType이 General일 때만 프로필 조회 가능
                  if (widget.postCommentData.boardType == 'General') {
                    // 작성자가 현재 유저일 때
                    if (widget.postCommentData.authorUid == currentUserUid) {
                      context.pushNamed(Screen.otherProfile, pathParameters: {
                        "uid": widget.postCommentData.authorUid ?? "",
                        "readOnly": "true"
                      });
                    }
                    // 작성자가 다른 유저일 때
                    else {
                      context.pushNamed(Screen.otherProfile, pathParameters: {
                        "uid": widget.postCommentData.authorUid ?? "",
                        "readOnly": "true"
                      });
                    }
                  }
                },
                overlayColor:
                    const MaterialStatePropertyAll(Colors.transparent),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.postCommentData.boardType == 'General'
                      ? NetworkImage(
                          widget.postCommentData.profileImageUrl.toString())
                      : null,
                  child: widget.postCommentData.boardType != 'General'
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/default_image.png',
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  // 작성자가 본인일 경우 프로필 이미지 색을 변경
                                  color: widget.postCommentData.authorUid ==
                                          currentUserUid
                                      ? AppColors.button.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.0),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    //작성자 닉네임, 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 작성자 프로필
                        GestureDetector(
                          onTap: () {
                            // boardType이 General일 때만 프로필 조회 가능
                            if (widget.postCommentData.boardType == 'General') {
                              // 작성자가 현재 유저일 때
                              if (widget.postCommentData.authorUid ==
                                  currentUserUid) {
                                context.pushNamed(Screen.otherProfile,
                                    pathParameters: {
                                      "uid": widget.postCommentData.authorUid ??
                                          "",
                                      "readOnly": "true"
                                    });
                              }
                              // 작성자가 다른 유저일 때
                              else {
                                context.pushNamed(Screen.otherProfile,
                                    pathParameters: {
                                      "uid": widget.postCommentData.authorUid ??
                                          "",
                                      "readOnly": "true"
                                    });
                              }
                            }
                          },
                          //작성자 표시
                          child: Row(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.2),
                                child: Text(
                                  //일반 게시판이면
                                  widget.postCommentData.boardType == 'General'
                                      ?
                                      //댓글 작성자 닉네임 표시
                                      widget.postCommentData.authorName
                                          .toString()
                                      //아니면 익명(댓글 단 순서)표시
                                      : '익명 ${widget.postCommentData.authorUid == widget.postData.authorUid ? "" : (widget.postData.commentWriters?.indexOf(widget.postCommentData.authorUid) ?? 0) + 1}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              widget.postCommentData.boardType != 'General'
                                  ?
                                  // 익명 게시판에서 댓글 작성자가 글 작성자라면 표시
                                  (widget.postCommentData.authorUid ==
                                          widget.postData.authorUid
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3, vertical: 1),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: const Text(
                                            '작성자',
                                            style: TextStyle(
                                                fontSize: 8,
                                                color: Colors.grey),
                                          ),
                                        )
                                      : const SizedBox())
                                  : const SizedBox(),
                              const SizedBox(
                                width: 8,
                              ),
                              //작성 시간
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
                        //답글, 관리 버튼
                        Row(
                          children: [
                            // 답글 작성 버튼
                            InkWell(
                              borderRadius: BorderRadius.circular(100),
                              child: const Icon(
                                Icons.mode_comment_outlined,
                                color: Colors.grey,
                                size: 16,
                              ),
                              onTap: () {
                                //스낵바로 답글 입력창 출력
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    padding: const EdgeInsets.all(0),
                                    elevation: 0,
                                    backgroundColor: isDark
                                        ? AppColors.darkInput
                                        : AppColors.lightInput,
                                    content: Container(
                                      padding: const EdgeInsets.all(0),
                                      height: 50,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context)
                                                    .clearSnackBars();
                                              },
                                              child: Icon(
                                                Icons.close,
                                                color: isDark
                                                    ? AppColors.darkHint
                                                    : AppColors.lightHint,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: TextField(
                                            focusNode: keyboardFocus,
                                            onTapOutside: (event) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            controller: replycontroller,
                                            style:
                                                const TextStyle(fontSize: 12),
                                            minLines: 1,
                                            maxLines: 4,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                hintText:
                                                    '${widget.postCommentData.authorName}님에게 답글을 작성합니다.',
                                                border: InputBorder.none),
                                          )),
                                          TextButton(
                                            onPressed: () async {
                                              //답글 입력 시퀀스
                                              if (replycontroller.value.text ==
                                                  "") return;

                                              String content =
                                                  replycontroller.value.text;

                                              await postService.postReply(
                                                  targetCommentId: widget
                                                          .postCommentData
                                                          .commentId ??
                                                      "",
                                                  userData: widget.userData,
                                                  postData: widget.postData,
                                                  content: content);

                                              widget.postData.commentWriters
                                                  ?.add(currentUserUid);

                                              widget.postCallback();
                                              replycontroller.clear();

                                              //답글 대상 댓글 작성자에게 알림 보내기 (댓글 작성자가 본인이 아니면 알림을 보냄)
                                              if ((widget.userData.uid ?? "") !=
                                                  (widget.postCommentData
                                                          .authorUid ??
                                                      "")) {
                                                NotiService.sendNotiToUser(
                                                  targetUID: widget
                                                          .postCommentData
                                                          .authorUid ??
                                                      "",
                                                  title: widget.postData
                                                              .boardType ==
                                                          "General"
                                                      ? "${widget.userData.name ?? ""}님의 답글"
                                                      : "답글이 달렸습니다.",
                                                  content: content,
                                                  data: {
                                                    "type": widget.postData
                                                                .boardType ==
                                                            "General"
                                                        ? "generalPost"
                                                        : "anonyPost",
                                                    "id":
                                                        widget.postData.postId,
                                                    "school": widget
                                                            .userData.school ??
                                                        ""
                                                  },
                                                );
                                              }

                                              ScaffoldMessenger.of(context)
                                                  .clearSnackBars();

                                              setState(() {});
                                            },
                                            style: const ButtonStyle(
                                                overlayColor:
                                                    MaterialStatePropertyAll(
                                                        Colors.transparent)),
                                            child: const Text("등록"),
                                          )
                                        ],
                                      ),
                                    ),
                                    duration: const Duration(days: 1),
                                  ),
                                );
                                keyboardFocus.requestFocus();
                              },
                            ),
                            const SizedBox(width: 20),
                            // 삭제 or 신고 버튼
                            InkWell(
                              borderRadius: BorderRadius.circular(100),
                              child: const Icon(
                                Icons.more_horiz,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onTap: () => _showAlertDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 댓글 내용
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        widget.postCommentData.content.toString(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    //좋,싫, 작성시간
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
                              Icon(
                                userLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_alt_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.postCommentData.likers!.length
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.postCommentData.dislikers!.length
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
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
              ),
            ],
          ),
          _buildCommentReplies(),
        ],
      ),
    );
  }
}
