import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/router/app_router.dart';
import 'package:campusmate/screens/community/comment_section.dart';
import 'package:campusmate/screens/community/widgets/comment_input_bar.dart';
import 'package:campusmate/screens/community/widgets/like_dislike_panel.dart';
import 'package:campusmate/services/noti_service.dart';
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

    return PopScope(
      onPopInvoked: (didPop) {
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      child: Scaffold(
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
                setState(() {
                  ScaffoldMessenger.of(context).clearSnackBars();
                });
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
                        BorderRadius.vertical(top: Radius.circular(20)),
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

              postService.updateViewCount(
                  postData: postData, userData: userData);

              print("AUTHOR: ${postData.authorUid}");
              print("CURRENT: $currentUserUid");

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
                                    fontSize: 24,
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
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: postData.boardType !=
                                                    'General'
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
                                                        decoration:
                                                            BoxDecoration(
                                                          // 작성자가 본인일 경우 프로필 이미지 색을 변경
                                                          color: postData
                                                                      .authorUid ==
                                                                  currentUserUid
                                                              ? Colors
                                                                  .blueAccent
                                                                  .withOpacity(
                                                                      0.4)
                                                              : Colors
                                                                  .transparent,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: postData
                                                            .profileImageUrl ??
                                                        "",
                                                    fit: BoxFit.cover,
                                                    width: 38,
                                                    height: 38,
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/default_image.png',
                                                      fit: BoxFit.cover,
                                                      width: 38,
                                                      height: 38,
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Image.asset(
                                                      'assets/images/default_image.png',
                                                      fit: BoxFit.cover,
                                                      width: 38,
                                                      height: 38,
                                                    ),
                                                  ),
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
                                                  fontSize: 14,
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
                                  child: LikeDislikePanel(postData: postData),
                                ),
                              ],
                            ),
                          ),

                          //광고 섹션
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: double.infinity,
                            color:
                                isDark ? AppColors.darkTag : AppColors.lightTag,
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
                  bottomNavigationBar: CommentInputBar(
                    commentController: _commentController,
                    onPost: () async {
                      if (_commentController.value.text == "") return;

                      String content = _commentController.value.text;

                      await postService.postComment(
                          userData: userData,
                          postData: postData,
                          content: content);

                      postData.commentWriters?.add(currentUserUid);

                      _commentController.clear();
                      key.currentState?.refresh();

                      //게시글 작성자에게 댓글 알림 (내가 작성자면 보내지 않음)
                      if (userData.uid != postData.authorUid) {
                        NotiService.sendNotiToUser(
                          targetUID: postData.authorUid ?? "",
                          title: widget.isAnonymous
                              ? "댓글이 달렸습니다."
                              : "${userData.name}님의 댓글",
                          content: content,
                          data: {
                            "type": widget.isAnonymous
                                ? "anonyPost"
                                : "generalPost",
                            "id": postData.postId,
                            "school": userData.school ?? ""
                          },
                        );
                      }
                    },
                  ));
            }

            return const CircleLoading();
          },
        ),
      ),
    );
  }
}
