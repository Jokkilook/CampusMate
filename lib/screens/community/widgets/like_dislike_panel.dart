import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikeDislikePanel extends StatefulWidget {
  const LikeDislikePanel({super.key, required this.postData});
  final PostData postData;

  @override
  State<LikeDislikePanel> createState() => _LikeDislikePanelState();
}

class _LikeDislikePanelState extends State<LikeDislikePanel> {
  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    String currentUserUid = userData.uid!;
    bool userLiked = widget.postData.likers!.contains(userData.uid!);
    bool userDisliked = widget.postData.dislikers!.contains(userData.uid!);

    // 좋아요, 싫어요
    Future<void> voteLikeDislike(bool isLike) async {
      if (userLiked) {
        // 이미 좋아요를 누른 경우
        ScaffoldMessenger.of(context).clearSnackBars();
        //스낵바 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.black.withOpacity(0.8),
            content: const Text(
              "이미 좋아요를 눌렀습니다.",
              style: TextStyle(color: Colors.white),
            ),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      } else if (userDisliked) {
        // 이미 싫어요를 누른 경우
        ScaffoldMessenger.of(context).clearSnackBars();
        //스낵바 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.black.withOpacity(0.8),
            content: const Text(
              "이미 싫어요를 눌렀습니다.",
              style: TextStyle(color: Colors.white),
            ),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      } else {
        if (isLike) {
          await FirebaseFirestore.instance
              .collection(
                  "schools/${widget.postData.school}/${widget.postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
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
              .collection(
                  "schools/${widget.postData.school}/${widget.postData.boardType == 'General' ? 'generalPosts' : 'anonymousPosts'}")
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

    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.postData.likers!.length.toString(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          InkWell(
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            child: Icon(
              userLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => voteLikeDislike(true),
          ),
          InkWell(
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            child: Icon(
              userDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => voteLikeDislike(false),
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
    );
  }
}
