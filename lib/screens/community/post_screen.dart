import 'package:campusmate/screens/community/models/post_reply_data.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/widgets/comment_item.dart';

import '../../provider/user_data_provider.dart';
import 'models/post_data.dart';
import 'modules/format_time_stamp.dart';
import 'widgets/post_controller.dart';

//ignore: must_be_immutable
class PostScreen extends StatefulWidget {
  PostData postData;
  final FirebaseFirestore firestore;
  final String school;
  final UserData userData;

  PostScreen({
    Key? key,
    required this.postData,
    required this.firestore,
    required this.school,
    required this.userData,
  }) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _isLoading = false;
  bool _userAlreadyViewed = false;
  late TextEditingController _commentController;
  bool _isReplying = false;
  String? _selectedCommentId;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    checkUserViewedPost();
    _refreshScreen();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> checkUserViewedPost() async {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    setState(() {
      _userAlreadyViewed =
          widget.postData.viewers?.contains(currentUserUid) ?? false;
    });
    if (!_userAlreadyViewed) {
      await updateViewCount(currentUserUid);
    }
  }

  // 조회수
  Future<void> updateViewCount(String currentUserUid) async {
    try {
      if (widget.postData.viewers == null ||
          !widget.postData.viewers!.contains(currentUserUid)) {
        await FirebaseFirestore.instance
            .collection("schools/${widget.school}/" +
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
            .collection("schools/${widget.school}/" +
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
          .collection("schools/${widget.school}/" +
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

  // 닉네임과 프로필 이미지 가져오기
  FutureBuilder<DocumentSnapshot<Object?>> _buildAuthorInforms() {
    return FutureBuilder<DocumentSnapshot>(
      future: widget.firestore
          .collection('schools/${widget.school}/users')
          .doc(widget.postData.authorUid)
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

        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  widget.postData.boardType == 'General' && imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
              child: widget.postData.boardType != 'General' || imageUrl == null
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.postData.boardType == 'General' ? authorName : '익명',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  // 댓글 가져오기 및 출력
  Widget _buildComments() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("schools/${widget.school}/" +
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
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return CommentItem(
                postCommentData: comments[index],
                school: widget.school,
                firestore: FirebaseFirestore.instance,
                refreshCallback: _refreshScreen,
                onReplyPressed: (commentId) {
                  setState(() {
                    // 선택된 댓글의 내용을 저장하고 댓글 입력 창을 업데이트
                    _selectedCommentId = commentId;
                    _isReplying = true;
                  });
                },
              );
            },
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

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
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
                context: context,
                builder: (context) {
                  return PostController(
                    currentUserUid: currentUserUid,
                    postData: widget.postData,
                    school: widget.school,
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
                      Text(
                        widget.postData.title ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildAuthorInforms(),
                          const SizedBox(width: 10),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
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
                      Text(
                        widget.postData.content ?? '',
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
                              Text(
                                widget.postData.likers!.length.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 14),
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
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(fontSize: 12),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: _isReplying ? '답글을 입력하세요' : '댓글을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              // 작성 버튼
              TextButton(
                onPressed: () async {
                  if (_isReplying) {
                    // 답글 작성 중
                    if (_selectedCommentId != null) {
                      String currentUserUid =
                          context.read<UserDataProvider>().userData.uid ?? '';
                      String replyContent = _commentController.text.trim();
                      if (replyContent.isNotEmpty) {
                        PostReplyData newReply = PostReplyData(
                          postId: widget.postData.postId,
                          commentId: _selectedCommentId,
                          content: replyContent,
                          timestamp: Timestamp.now(),
                          authorUid: currentUserUid,
                          boardType: widget.postData.boardType,
                        );

                        try {
                          // 답글 Firestore에 추가
                          DocumentReference docRef = await FirebaseFirestore
                              .instance
                              .collection("schools/${widget.school}/" +
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
                              .collection("schools/${widget.school}/" +
                                  (widget.postData.boardType == 'General'
                                      ? 'generalPosts'
                                      : 'anonymousPosts'))
                              .doc(widget.postData.postId);
                          DocumentSnapshot postDoc = await postDocRef.get();
                          int currentCommentCount = (postDoc.data()
                                  as Map<String, dynamic>)['commentCount'] ??
                              0;
                          await postDocRef.update(
                              {'commentCount': currentCommentCount + 1});

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
                    String currentUserUid =
                        context.read<UserDataProvider>().userData.uid ?? '';
                    String commentContent = _commentController.text.trim();
                    if (commentContent.isNotEmpty) {
                      PostCommentData newComment = PostCommentData(
                        postId: widget.postData.postId,
                        content: commentContent,
                        timestamp: Timestamp.now(),
                        authorUid: currentUserUid,
                        boardType: widget.postData.boardType,
                      );

                      try {
                        DocumentReference docRef = await FirebaseFirestore
                            .instance
                            .collection("schools/${widget.school}/" +
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
                            .collection("schools/${widget.school}/" +
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
                child: const Text(
                  '작성',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
