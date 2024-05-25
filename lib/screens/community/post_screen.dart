import 'package:campusmate/app_colors.dart';
import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';

import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/widgets/comment_item.dart';

import '../../provider/user_data_provider.dart';
import '../profile/stranger_profile_screen.dart';
import 'models/post_data.dart';
import 'modules/format_time_stamp.dart';
import 'widgets/post_controller.dart';

//ignore: must_be_immutable
class PostScreen extends StatefulWidget {
  PostData postData;
  final FirebaseFirestore firestore;
  final UserData userData;

  PostScreen({
    Key? key,
    required this.postData,
    required this.firestore,
    required this.userData,
  }) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _isLoading = false;
  late TextEditingController _commentController;
  bool _isReplying = false;
  String? _selectedCommentId;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    updateViewCount();
    _refreshScreen();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 조회수
  Future<void> updateViewCount() async {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    bool userAlreadyViewed =
        widget.postData.viewers?.contains(currentUserUid) ?? false;

    try {
      if (!userAlreadyViewed) {
        await FirebaseFirestore.instance
            .collection("schools/${widget.postData.school}/" +
                (widget.postData.boardType == 'General'
                    ? 'generalPosts'
                    : 'anonymousPosts'))
            .doc(widget.postData.postId)
            .update({
          'viewers': FieldValue.arrayUnion([currentUserUid]),
        });

        debugPrint('조회수 업데이트 성공');

        setState(() {
          widget.postData.viewers ??= [];
          widget.postData.viewers!.add(currentUserUid);
        });
      } else {
        debugPrint('이미 조회한 사용자입니다.');
      }
    } catch (error) {
      debugPrint('조회수 업데이트 에러: $error');
    }
  }

  // 좋아요, 싫어요
  Future<void> voteLikeDislike(bool isLike) async {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    bool userLiked = widget.postData.likers!.contains(currentUserUid);
    bool userDisliked = widget.postData.dislikers!.contains(currentUserUid);

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
            .collection("schools/${widget.postData.school}/" +
                (widget.postData.boardType == 'General'
                    ? 'generalPosts'
                    : 'anonymousPosts'))
            .doc(widget.postData.postId)
            .update({
          'likers': FieldValue.arrayUnion([currentUserUid]),
        });
        setState(() {
          widget.postData.likers!.add(currentUserUid);
        });
      }
      if (!isLike) {
        await FirebaseFirestore.instance
            .collection("schools/${widget.postData.school}/" +
                (widget.postData.boardType == 'General'
                    ? 'generalPosts'
                    : 'anonymousPosts'))
            .doc(widget.postData.postId)
            .update({
          'dislikers': FieldValue.arrayUnion([currentUserUid]),
        });
        setState(() {
          widget.postData.dislikers!.add(currentUserUid);
        });
      }
    }
  }

  // 새로고침
  Future<void> _refreshScreen() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 데이터 다시 가져오기
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection("schools/${widget.postData.school}/" +
              (widget.postData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postData.postId)
          .get();

      // 새로운 postData로 상태 업데이트
      setState(() {
        widget.postData =
            PostData.fromJson(postSnapshot.data() as Map<String, dynamic>);
        _isLoading = false;
        _isReplying = false;
      });
    } catch (error) {
      debugPrint('데이터 가져오기 에러: $error');
      setState(() {
        _isLoading = false;
        _isReplying = false;
      });
    }
  }

  // 댓글 가져오기 및 출력
  Widget _buildComments() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("schools/${widget.postData.school}/" +
              (widget.postData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postData.postId)
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
              .map((doc) =>
                  PostCommentData.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          List<Widget> visibleComments = [];
          for (var comment in comments) {
            // 차단된 사용자의 댓글인지 확인
            if (!(widget.userData.banUsers?.contains(comment.authorUid) ??
                false)) {
              // 차단되지 않은 사용자의 댓글만 출력
              visibleComments.add(
                CommentItem(
                  postAuthorUid: widget.postData.authorUid.toString(),
                  postCommentData: comment,
                  firestore: FirebaseFirestore.instance,
                  refreshCallback: _refreshScreen,
                  userData: widget.userData,
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

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = formatTimeStamp(widget.postData.timestamp!, now);
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';

    bool userLiked = widget.postData.likers!.contains(currentUserUid);
    bool userDisliked = widget.postData.dislikers!.contains(currentUserUid);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.postData.boardType == 'General' ? '일반 게시판' : '익명 게시판',
            ),
            Text(
              widget.userData.school!,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _refreshScreen();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                clipBehavior: Clip.hardEdge,
                elevation: 0,
                shape: const ContinuousRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                context: context,
                builder: (context) {
                  return PostController(
                    currentUserUid: currentUserUid,
                    postData: widget.postData,
                  );
                },
              ).then((_) {
                _refreshScreen();
              });
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircleLoading(),
            )
          : RefreshIndicator(
              onRefresh: _refreshScreen,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        widget.postData.title ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          // 작성자 프로필
                          GestureDetector(
                            onTap: () {
                              // boardType이 General일 때만 프로필 조회 가능
                              if (widget.postData.boardType == 'General') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StrangerProfilScreen(
                                        uid: widget.postData.authorUid ?? "",
                                      ),
                                    ));
                              }
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage:
                                      widget.postData.boardType == 'General'
                                          ? NetworkImage(widget
                                              .postData.profileImageUrl
                                              .toString())
                                          : null,
                                  child: widget.postData.boardType != 'General'
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
                                                decoration: BoxDecoration(
                                                  // 작성자가 본인일 경우 프로필 이미지 색을 변경
                                                  color: widget.postData
                                                              .authorUid ==
                                                          currentUserUid
                                                      ? AppColors.button
                                                          .withOpacity(0.2)
                                                      : Colors.grey
                                                          .withOpacity(0.0),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  widget.postData.boardType == 'General'
                                      ? widget.postData.authorName.toString()
                                      : '익명',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // 작성일시
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 조회수
                          const Icon(
                            Icons.account_circle_outlined,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.postData.viewers!.length.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 글 내용
                      Text(widget.postData.content ?? ''),
                      const SizedBox(height: 10),
                      // 사진
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.postData.imageUrl != null
                                ? InstaImageViewer(
                                    imageUrl:
                                        widget.postData.imageUrl.toString(),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      child: Image.network(
                                        widget.postData.imageUrl.toString(),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 14),
                              Text(
                                widget.postData.likers!.length.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  userLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  voteLikeDislike(true);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  userDisliked
                                      ? Icons.thumb_down
                                      : Icons.thumb_down_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  voteLikeDislike(false);
                                },
                              ),
                              Text(
                                widget.postData.dislikers!.length.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '댓글 ${widget.postData.commentCount}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      // 댓글
                      _buildComments(),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: const Icon(
                          Icons.cancel_outlined,
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      hintText: _isReplying ? '답글을 입력하세요' : '댓글을 입력하세요',
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
                      String replyContent = _commentController.text.trim();

                      final postAuthorUid = widget.postData.authorUid;
                      final commentWriters =
                          widget.postData.commentWriters ??= [];
                      int _writerIndex = 0;
                      // 현재 유저가 게시글 작성자가 아니면
                      if (currentUserUid != postAuthorUid) {
                        // 현재 게시글에서 댓글을 작성한 적이 없는 유저라면
                        if (!commentWriters.contains(currentUserUid)) {
                          await FirebaseFirestore.instance
                              .collection("schools/${widget.postData.school}/" +
                                  (widget.postData.boardType == 'General'
                                      ? 'generalPosts'
                                      : 'anonymousPosts'))
                              .doc(widget.postData.postId)
                              .update({
                            'commentWriters':
                                FieldValue.arrayUnion([currentUserUid]),
                          });
                          _writerIndex = commentWriters.length + 1;
                        } else {
                          _writerIndex =
                              commentWriters.indexOf(currentUserUid) + 1;
                        }
                      }

                      if (replyContent.isNotEmpty) {
                        PostReplyData newReply = PostReplyData(
                          postId: widget.postData.postId,
                          commentId: _selectedCommentId,
                          content: replyContent,
                          timestamp: Timestamp.now(),
                          authorUid: currentUserUid,
                          authorName: widget.userData.name,
                          school: widget.postData.school,
                          profileImageUrl: widget.userData.imageUrl,
                          boardType: widget.postData.boardType,
                          writerIndex: _writerIndex,
                        );

                        try {
                          // 답글 Firestore에 추가
                          DocumentReference docRef = await FirebaseFirestore
                              .instance
                              .collection("schools/${widget.postData.school}/" +
                                  (widget.postData.boardType == 'General'
                                      ? 'generalPosts'
                                      : 'anonymousPosts'))
                              .doc(widget.postData.postId)
                              .collection('comments')
                              .doc(_selectedCommentId)
                              .collection('replies')
                              .add(newReply.data!);
                          await docRef.update({'replyId': docRef.id});

                          // 총 댓글 수 업데이트
                          DocumentReference postDocRef = FirebaseFirestore
                              .instance
                              .collection("schools/${widget.postData.school}/" +
                                  (widget.postData.boardType == 'General'
                                      ? 'generalPosts'
                                      : 'anonymousPosts'))
                              .doc(widget.postData.postId);
                          DocumentSnapshot postDoc = await postDocRef.get();
                          int currentCommentCount = (postDoc.data()
                                  as Map<String, dynamic>)['commentCount'] ??
                              0;
                          await postDocRef.update({
                            'commentCount': currentCommentCount + 1,
                          });

                          // 텍스트 필드 내용 지우기
                          _commentController.clear();
                          _isReplying = false;

                          // 화면 새로고침
                          _refreshScreen();
                        } catch (error) {
                          debugPrint('Error adding reply: $error');
                        }
                      }
                    }
                  } else {
                    // 댓글 작성 중
                    String commentContent = _commentController.text.trim();

                    final postAuthorUid = widget.postData.authorUid;
                    final commentWriters =
                        widget.postData.commentWriters ??= [];
                    int _writerIndex = 0;
                    // 현재 유저가 게시글 작성자가 아니면
                    if (currentUserUid != postAuthorUid) {
                      // 현재 게시글에서 댓글을 작성한 적이 없는 유저라면
                      if (!commentWriters.contains(currentUserUid)) {
                        await FirebaseFirestore.instance
                            .collection("schools/${widget.postData.school}/" +
                                (widget.postData.boardType == 'General'
                                    ? 'generalPosts'
                                    : 'anonymousPosts'))
                            .doc(widget.postData.postId)
                            .update({
                          'commentWriters':
                              FieldValue.arrayUnion([currentUserUid]),
                        });
                        _writerIndex = commentWriters.length + 1;
                      } else {
                        _writerIndex =
                            commentWriters.indexOf(currentUserUid) + 1;
                      }
                    }

                    if (commentContent.isNotEmpty) {
                      PostCommentData newComment = PostCommentData(
                        postId: widget.postData.postId,
                        content: commentContent,
                        timestamp: Timestamp.now(),
                        authorUid: currentUserUid,
                        authorName: widget.userData.name,
                        school: widget.postData.school,
                        profileImageUrl: widget.userData.imageUrl,
                        boardType: widget.postData.boardType,
                        writerIndex: _writerIndex,
                      );

                      try {
                        DocumentReference docRef = await FirebaseFirestore
                            .instance
                            .collection("schools/${widget.postData.school}/" +
                                (widget.postData.boardType == 'General'
                                    ? 'generalPosts'
                                    : 'anonymousPosts'))
                            .doc(widget.postData.postId)
                            .collection('comments')
                            .add(newComment.data!);
                        await docRef.update({'commentId': docRef.id});

                        // 총 댓글 수 업데이트
                        DocumentReference postDocRef = FirebaseFirestore
                            .instance
                            .collection("schools/${widget.postData.school}/" +
                                (widget.postData.boardType == 'General'
                                    ? 'generalPosts'
                                    : 'anonymousPosts'))
                            .doc(widget.postData.postId);
                        DocumentSnapshot postDoc = await postDocRef.get();
                        int currentCommentCount = (postDoc.data()
                                as Map<String, dynamic>)['commentCount'] ??
                            0;
                        await postDocRef
                            .update({'commentCount': currentCommentCount + 1});

                        _commentController.clear();

                        _refreshScreen();
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
}
