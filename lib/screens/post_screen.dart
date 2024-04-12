import 'package:campusmate/models/post_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/format_time_stamp.dart';
import '../provider/user_data_provider.dart';

class PostScreen extends StatefulWidget {
  final PostData postData;

  const PostScreen({
    Key? key,
    required this.postData,
  }) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _isLoading = false;
  bool _userAlreadyViewed = false;

  @override
  void initState() {
    super.initState();
    checkUserViewedPost();
  }

  Future<void> checkUserViewedPost() async {
    String currentUserUid = context.read<UserDataProvider>().userData.uid ?? '';
    // 현재 사용자가 게시물을 이미 본 적이 있는지 확인
    _userAlreadyViewed =
        widget.postData.viewers?.contains(currentUserUid) ?? false;
    // 사용자가 아직 게시물을 보지 않은 경우 조회수를 업데이트
    if (!_userAlreadyViewed) {
      await updateViewCount(currentUserUid);
    }
  }

  Future<void> updateViewCount(String currentUserUid) async {
    try {
      // 로컬에서 조회수를 증가
      setState(() {
        widget.postData.viewers?.add(currentUserUid);
        widget.postData.viewCount = (widget.postData.viewCount ?? 0) + 1;
      });
      // Firestore에서 조회수를 업데이트
      String collection = widget.postData.boardType == 'General'
          ? 'generalPosts'
          : 'anonymousPosts';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.postData.postUid)
          .update({
        'viewers': widget.postData.viewers,
        'viewCount': widget.postData.viewCount,
      });
      debugPrint('조회수 업데이트 성공');
    } catch (error) {
      debugPrint('조회수 업데이트 에러: $error');
    }
  }

  Future<void> refreshScreen() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime =
        formatTimeStamp(widget.postData.timestamp ?? '', now);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: Text(
          widget.postData.boardType == 'General' ? '일반 게시판' : '익명 게시판',
        ),
        actions: [
          IconButton(
            onPressed: () {
              refreshScreen();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refreshScreen,
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
                          const CircleAvatar(
                            radius: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.postData.boardType == 'General'
                                ? widget.postData.author ?? 'null'
                                : '익명',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
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
                            widget.postData.viewCount.toString(),
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
                                icon: const Icon(
                                  Icons.thumb_up_alt_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () {},
                              ),
                              Text(
                                widget.postData.likeCount?.toString() ?? '0',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 14),
                              IconButton(
                                icon: const Icon(
                                  Icons.thumb_down_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '댓글 ${widget.postData.commentCount ?? 0}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
