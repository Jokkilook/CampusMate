import 'package:campusmate/app_colors.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/screens/community/comment_section.dart';
import 'package:campusmate/screens/community/widgets/like_dislike_panel.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:campusmate/widgets/ad_area.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';
import 'package:campusmate/models/user_data.dart';
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
      resizeToAvoidBottomInset: true,
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
              ).then((value) {
                if (value == "edit") {
                  setState(() {});
                }
              });
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection(
                "schools/${userData.school}/${(widget.isAnonymous ? 'anonymousPosts' : 'generalPosts')}")
            .doc(widget.postId)
            .get(),
        builder: (context, snapshot) {
          //로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleLoading();
          }

          //에러 시
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

          //스냅샷 데이터가 있으면
          if (snapshot.hasData) {
            var data = snapshot.data;

            //스냅샷 데이터에 게시글 데이터가 존재하지 않으면
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
                      icon: const Icon(Icons.refresh),
                    )
                  ],
                ),
              );
            }

            PostData postData =
                PostData.fromJson(data.data() as Map<String, dynamic>);
            ref = postData;
            final GlobalKey<CommentSectionState> key =
                GlobalKey<CommentSectionState>();
            CommentSection commentSection =
                CommentSection(key: key, postData: postData);

            postService.updateViewCount(postData: postData, userData: userData);

            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //게시글 상세 섹션
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                      decoration: BoxDecoration(
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
                                                ? postData.authorName.toString()
                                                : '익명',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          // 작성일시
                                          Text(
                                            formatTimeStamp(postData.timestamp!,
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
                          ],
                        ),
                      ),

                      //내용, 좋싫버튼
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 글 내용
                            Text(
                              postData.content ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 14),
                            //사진
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                for (String url in postData.imageUrl!)
                                  url != ""
                                      ? InstaImageViewer(
                                          imageUrl: url,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
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
                              child: LikeDislikePanel(postData: postData),
                            ),
                          ],
                        ),
                      ),

                      //광고 섹션
                      Container(
                        padding: const EdgeInsets.all(5),
                        width: double.infinity,
                        color: isDark ? AppColors.darkTag : AppColors.lightTag,
                        child: const AdArea(),
                      ),

                      // 댓글 섹션
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: commentSection,
                      ),
                    ],
                  ),
                ),
              ),
              //댓&답글 입력 창
              bottomNavigationBar: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  color: isDark ? AppColors.darkInput : AppColors.lightInput,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      !_isReplying
                          ? const SizedBox()
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  _isReplying = false;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: MediaQuery.of(context).size.width * 0.1,
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
                          if (_commentController.value.text == "") return;

                          String content = _commentController.value.text;

                          //댓글이면
                          if (!_isReplying) {
                            await postService.postComment(
                                userData: userData,
                                postData: postData,
                                content: content);
                          }
                          //답글이면
                          else {
                            await postService.postReply(
                                userData: userData,
                                postData: postData,
                                targetCommentId: _selectedCommentId ?? "",
                                content: content);
                          }

                          key.currentState?.refresh();
                          _commentController.clear();
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
    );
  }
}
