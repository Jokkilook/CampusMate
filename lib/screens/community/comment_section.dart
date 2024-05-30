import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_comment_data.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/screens/community/widgets/comment_item.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentSection extends StatefulWidget {
  final PostData postData;

  const CommentSection({super.key, required this.postData});

  @override
  State<CommentSection> createState() => CommentSectionState();
}

class CommentSectionState extends State<CommentSection> {
  final PostService postService = PostService();
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    commentCount = widget.postData.commentCount ?? 0;
  }

  void refresh() {
    commentCount++;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;

    return Column(
      children: [
        //댓글 수
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  '댓글 $commentCount',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        //댓글&답글 표시
        FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: postService.getPostComment(widget.postData),
          builder: (context, snapshot) {
            //불러오는 중
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircleLoading();
            }

            //에러 발생 시
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    const Text("댓글을 불러올 수 없습니다."),
                    IconButton.filled(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh),
                    )
                  ],
                ),
              );
            }

            //스냅샷 데이터가 존재할때,
            if (snapshot.hasData) {
              var datas = snapshot.data?.docs;

              //스냅샷에 댓글 데이터가 있으면
              if (datas != null) {
                List<PostCommentData> comments = datas
                    .map((e) => PostCommentData.fromJson(e.data()))
                    .toList();

                //댓글 리스트뷰 출력
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) {
                    return Container();
                  },
                  itemBuilder: (context, index) {
                    PostCommentData comment = comments[index];

                    return CommentItem(
                      postCommentData: comment,
                      onReplyPressed: () {},
                      postCallback: () {
                        commentCount++;
                        setState(() {});
                      },
                      deleteCallback: () {
                        commentCount =
                            commentCount - (1 + (comment.replyCount ?? 0));
                        setState(() {});
                      },
                      postAuthorUid: comment.authorUid ?? "",
                      userData: userData,
                      postData: widget.postData,
                    );
                  },
                );
              }

              //스냅샷에 댓글 데이터가 없으면
              return const Center(
                child: Text("댓글이 없습니다."),
              );
            }

            //이도저도 아니면
            return Center(
              child: Column(
                children: [
                  const Text("댓글을 불러올 수 없습니다."),
                  IconButton.filled(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh))
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
