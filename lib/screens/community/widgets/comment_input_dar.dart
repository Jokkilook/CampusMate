import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//ignore: must_be_immutable
class CommentInputBar extends StatefulWidget {
  Function onPost;
  bool isReply = false;

  CommentInputBar({super.key, required this.onPost});

  @override
  State<CommentInputBar> createState() => CommentInputBarState();
}

class CommentInputBarState extends State<CommentInputBar> {
  TextEditingController commentController = TextEditingController();

  void switchType() {
    widget.isReply = !widget.isReply;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isReply = widget.isReply;

    return Container(
      color: Colors.amber,
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          const Padding(padding: EdgeInsets.all(10), child: Text("댓글")),
          Expanded(
              child: TextField(
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            controller: commentController,
            style: const TextStyle(fontSize: 12),
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                hintText: isReply ? '답글을 입력하세요' : '댓글을 입력하세요',
                border: InputBorder.none),
          )),
          TextButton(
            onPressed: () {
              widget.onPost;
            },
            style: const ButtonStyle(
                overlayColor: MaterialStatePropertyAll(Colors.transparent)),
            child: const Text("게시"),
          )
        ],
      ),
    );
  }
}
