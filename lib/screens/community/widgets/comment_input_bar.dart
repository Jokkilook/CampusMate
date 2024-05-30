import 'package:campusmate/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//ignore: must_be_immutable
class CommentInputBar extends StatefulWidget {
  Function onPost;

  final TextEditingController commentController;

  CommentInputBar(
      {super.key, required this.commentController, required this.onPost});

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Container(
      color: isDark ? AppColors.darkInput : AppColors.lightInput,
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TextField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: widget.commentController,
              style: const TextStyle(fontSize: 12),
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  hintText: '댓글을 입력하세요',
                  border: InputBorder.none),
            ),
          )),
          TextButton(
            onPressed: () async {
              await widget.onPost();
              setState(() {});
            },
            style: const ButtonStyle(
                overlayColor: MaterialStatePropertyAll(Colors.transparent)),
            child: const Text("등록"),
          )
        ],
      ),
    );
  }
}
