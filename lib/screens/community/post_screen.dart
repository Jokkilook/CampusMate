import 'package:campusmate/app_colors.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:campusmate/widgets/confirm_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/widgets/comment_item.dart';
import '../../provider/user_data_provider.dart';
import 'models/post_data.dart';
import 'modules/format_time_stamp.dart';
import 'widgets/post_controller.dart';

class PostScreen extends StatefulWidget {
  final String postId;
  final bool isAnonymous;

  const PostScreen(
      {super.key, required this.postId, required this.isAnonymous});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late TextEditingController _commentController;
  PostService postService = PostService();
  bool _isReplying = false;
  String? _selectedCommentId;
  late PostData ref;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    String currentUserUid = userData.uid ?? '';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              !widget.isAnonymous ? '일반 게시판' : '익명 게시판',
            ),
            Text(
              userData.school!,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                clipBehavior: Clip.hardEdge,
                elevation: 0,
                shape: const ContinuousRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                context: context,
                builder: (context) {
                  return PostController(
                    currentUserUid: currentUserUid,
                    postData: ref,
                  );
                },
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(
                  "schools/${userData.school}/${(widget.isAnonymous ? 'anonymousPosts' : 'generalPosts')}")
              .doc(widget.postId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircleLoading();
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("게시글을 불러올 수 없습니다."),
                    IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                ),
              );
            }

            if (snapshot.hasData) {
              var data = snapshot.data;

              if (!data!.exists) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("게시글을 불러올 수 없습니다."),
                      IconButton(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh))
                    ],
                  ),
                );
              }

              PostData postData =
                  PostData.fromJson(data.data() as Map<String, dynamic>);
              ref = postData;

              bool userLiked = postData.likers!.contains(currentUserUid);
              bool userDisliked = postData.dislikers!.contains(currentUserUid);

              postService.updateViewCount(
                  postData: postData, userData: userData);

              // 좋아요, 싫어요
              Future<void> voteLikeDislike(bool isLike) async {
                String currentUserUid =
                    context.read<UserDataProvider>().userData.uid ?? '';
                bool userLiked = postData.likers!.contains(currentUserUid);
                bool userDisliked =
                    postData.dislikers!.contains(currentUserUid);

                if (userLiked) {
                  // 이미 좋아요를 누른 경우
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ConfirmDialog(content: '이미 좋아요를 눌렀습니다.'),
                  );
                } else if (userDisliked) {
                  // 이미 싫어요를 누른 경우
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ConfirmDialog(content: '이미 싫어요를 눌렀습니다.'),
                  );
                } else {
                  if (isLike) {
                    await FirebaseFirestore.instance
                        .collection(
                            "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                        .doc(postData.postId)
                        .update({
                      'likers': FieldValue.arrayUnion([currentUserUid]),
                    });
                    setState(() {
                      postData.likers!.add(currentUserUid);
                    });
                  }
                  if (!isLike) {
                    await FirebaseFirestore.instance
                        .collection(
                            "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                        .doc(postData.postId)
                        .update({
                      'dislikers': FieldValue.arrayUnion([currentUserUid]),
                    });
                    setState(() {
                      postData.dislikers!.add(currentUserUid);
                    });
                  }
                }
              }

              // 댓글 가져오기 및 출력
              Widget buildComments() {
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection(
                          "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                      .doc(postData.postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: false)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Text('댓글이 없습니다.');
                    } else {
                      List<PostCommentData> comments = snapshot.data!.docs
                          .map((doc) => PostCommentData.fromJson(
                              doc.data() as Map<String, dynamic>))
                          .toList();
                      List<Widget> visibleComments = [];
                      for (var comment in comments) {
                        // 차단된 사용자의 댓글인지 확인
                        if (!(userData.banUsers?.contains(comment.authorUid) ??
                            false)) {
                          // 차단되지 않은 사용자의 댓글만 출력
                          visibleComments.add(
                            CommentItem(
                              postAuthorUid: postData.authorUid.toString(),
                              postCommentData: comment,
                              refreshCallback: () => setState(() {}),
                              userData: userData,
                              onReplyPressed: (commentId) {
                                setState(() {
                                  // 선택된 댓글의 내용을 저장하고 댓글 입력 창을 업데이트
                                  _selectedCommentId = commentId;
                                  _isReplying = true;
                                });
                              },
                            ),
                          );
                        }
                      }
                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: visibleComments,
                      );
                    }
                  },
                );
              }

              return Scaffold(
                body: RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //제목, 프로필
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              // 제목
                              Text(
                                postData.title ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 14),
                              //작성자 프로필 & 작성 시간 & 조회수
                              Row(
                                children: [
                                  // 작성자 프로필
                                  GestureDetector(
                                    onTap: () {
                                      // boardType이 General일 때만 프로필 조회 가능
                                      if (postData.boardType == 'General') {
                                        context.pushNamed(
                                          Screen.otherProfile,
                                          pathParameters: {
                                            "uid": postData.authorUid ?? "",
                                            "readOnly": "true",
                                          },
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundImage:
                                              postData.boardType == 'General'
                                                  ? NetworkImage(postData
                                                      .profileImageUrl
                                                      .toString())
                                                  : null,
                                          child: postData.boardType != 'General'
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  child: Stack(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/default_image.png',
                                                        fit: BoxFit.cover,
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          // 작성자가 본인일 경우 프로필 이미지 색을 변경
                                                          color: postData
                                                                      .authorUid ==
                                                                  currentUserUid
                                                              ? AppColors.button
                                                                  .withOpacity(
                                                                      0.2)
                                                              : Colors.grey
                                                                  .withOpacity(
                                                                      0.0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              postData.boardType == 'General'
                                                  ? postData.authorName
                                                      .toString()
                                                  : '익명',
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            // 작성일시
                                            Text(
                                              formatTimeStamp(
                                                  postData.timestamp!,
                                                  DateTime.now()),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  // 조회수
                                  const Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    postData.viewers!.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),

                        const Divider(height: 0),

                        //내용, 좋싫버튼
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 글 내용
                              Text(postData.content ?? ''),
                              const SizedBox(height: 10),
                              //사진
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  for (String url in postData.imageUrl!)
                                    url != ""
                                        ? InstaImageViewer(
                                            imageUrl: url,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              child: Image.network(
                                                url,
                                                width: double.infinity,
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          )
                                        : Container()
                                ],
                              ),
                              const SizedBox(height: 20),
                              //좋싫버튼
                              Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        postData.likers!.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      InkWell(
                                        child: Icon(
                                          userLiked
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_alt_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        onTap: () => voteLikeDislike(true),
                                      ),
                                      InkWell(
                                        child: Icon(
                                          userDisliked
                                              ? Icons.thumb_down
                                              : Icons.thumb_down_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        onTap: () => voteLikeDislike(false),
                                      ),
                                      Text(
                                        postData.dislikers!.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 0),

                        //댓글 섹션
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '댓글 ${postData.commentCount}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 0),
                        // 댓글
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: buildComments(),
                        ),
                      ],
                    ),
                  ),
                ), //댓&답글 입력 창
                bottomNavigationBar: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    color: isDark ? AppColors.darkInput : AppColors.lightInput,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        !_isReplying
                            ? const SizedBox(
                                // width: MediaQuery.of(context).size.width * 0.08,
                                )
                            : InkWell(
                                onTap: () {
                                  setState(() {
                                    _isReplying = false;
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        Expanded(
                          child: TextField(
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            controller: _commentController,
                            style: const TextStyle(fontSize: 12),
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                hintText:
                                    _isReplying ? '답글을 입력하세요' : '댓글을 입력하세요',
                                border: InputBorder.none),
                          ),
                        ),
                        // 작성 버튼
                        TextButton(
                          child: const Text(
                            '작성',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            if (_isReplying) {
                              // 답글 작성 중
                              if (_selectedCommentId != null) {
                                String replyContent =
                                    _commentController.text.trim();
                                final postAuthorUid = postData.authorUid;
                                final commentWriters =
                                    postData.commentWriters ??= [];
                                int writerIndex = 0;
                                // 현재 유저가 게시글 작성자가 아니면
                                if (currentUserUid != postAuthorUid) {
                                  // 현재 게시글에서 댓글을 작성한 적이 없는 유저라면
                                  if (!commentWriters
                                      .contains(currentUserUid)) {
                                    await FirebaseFirestore.instance
                                        .collection(
                                            "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                                        .doc(postData.postId)
                                        .update({
                                      'commentWriters': FieldValue.arrayUnion(
                                          [currentUserUid]),
                                    });
                                    writerIndex = commentWriters.length + 1;
                                  } else {
                                    writerIndex =
                                        commentWriters.indexOf(currentUserUid) +
                                            1;
                                  }
                                }

                                if (replyContent.isNotEmpty) {
                                  PostReplyData newReply = PostReplyData(
                                    postId: postData.postId,
                                    commentId: _selectedCommentId,
                                    content: replyContent,
                                    timestamp: Timestamp.now(),
                                    authorUid: currentUserUid,
                                    authorName: userData.name,
                                    school: postData.school,
                                    profileImageUrl: userData.imageUrl,
                                    boardType: postData.boardType,
                                    writerIndex: writerIndex,
                                  );

                                  try {
                                    // 답글 Firestore에 추가
                                    DocumentReference docRef =
                                        await FirebaseFirestore.instance
                                            .collection(
                                                "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                                            .doc(postData.postId)
                                            .collection('comments')
                                            .doc(_selectedCommentId)
                                            .collection('replies')
                                            .add(newReply.data!);
                                    await docRef.update({'replyId': docRef.id});

                                    // 총 댓글 수 업데이트
                                    DocumentReference postDocRef = FirebaseFirestore
                                        .instance
                                        .collection(
                                            "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                                        .doc(postData.postId);
                                    DocumentSnapshot postDoc =
                                        await postDocRef.get();
                                    int currentCommentCount = (postDoc.data()
                                                as Map<String, dynamic>)[
                                            'commentCount'] ??
                                        0;
                                    await postDocRef.update({
                                      'commentCount': currentCommentCount + 1,
                                    });

                                    // 텍스트 필드 내용 지우기
                                    _commentController.clear();
                                    _isReplying = false;

                                    // 화면 새로고침
                                    setState(() {});
                                  } catch (error) {
                                    debugPrint('Error adding reply: $error');
                                  }
                                }
                              }
                            } else {
                              // 댓글 작성 중
                              String commentContent =
                                  _commentController.text.trim();

                              final postAuthorUid = postData.authorUid;
                              final commentWriters =
                                  postData.commentWriters ??= [];
                              int writerIndex = 0;
                              // 현재 유저가 게시글 작성자가 아니면
                              if (currentUserUid != postAuthorUid) {
                                // 현재 게시글에서 댓글을 작성한 적이 없는 유저라면
                                if (!commentWriters.contains(currentUserUid)) {
                                  await FirebaseFirestore.instance
                                      .collection(
                                          "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                                      .doc(postData.postId)
                                      .update({
                                    'commentWriters':
                                        FieldValue.arrayUnion([currentUserUid]),
                                  });
                                  writerIndex = commentWriters.length + 1;
                                } else {
                                  writerIndex =
                                      commentWriters.indexOf(currentUserUid) +
                                          1;
                                }
                              }

                              if (commentContent.isNotEmpty) {
                                PostCommentData newComment = PostCommentData(
                                  postId: postData.postId,
                                  content: commentContent,
                                  timestamp: Timestamp.now(),
                                  authorUid: currentUserUid,
                                  authorName: userData.name,
                                  school: postData.school,
                                  profileImageUrl: userData.imageUrl,
                                  boardType: postData.boardType,
                                  writerIndex: writerIndex,
                                );

                                try {
                                  DocumentReference docRef = await FirebaseFirestore
                                      .instance
                                      .collection(
                                          "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                                      .doc(postData.postId)
                                      .collection('comments')
                                      .add(newComment.data!);
                                  await docRef.update({'commentId': docRef.id});

                                  // 총 댓글 수 업데이트
                                  DocumentReference postDocRef = FirebaseFirestore
                                      .instance
                                      .collection(
                                          "schools/${postData.school}/${postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
                                      .doc(postData.postId);
                                  DocumentSnapshot postDoc =
                                      await postDocRef.get();
                                  int currentCommentCount =
                                      (postDoc.data() as Map<String, dynamic>)[
                                              'commentCount'] ??
                                          0;
                                  await postDocRef.update({
                                    'commentCount': currentCommentCount + 1
                                  });

                                  _commentController.clear();

                                  setState(() {});
                                } catch (error) {
                                  debugPrint('Error adding comment: $error');
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const CircleLoading();
          },
        ),
      ),
    );
  }
}
