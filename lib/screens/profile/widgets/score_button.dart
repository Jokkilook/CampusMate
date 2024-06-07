import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/services/profile_service.dart';
import 'package:flutter/material.dart';

///프로필 좋아요, 싫어요 버튼<br>
///required [targetUID] : 평가되는 유저 UID<br>
///required [assessUID] : 평가하는 유저 UID<br>
///[isLike] : 이미 좋아요 누른 유저인지 체크
///[isDislike] : 이미 싫어요 누른 유저인지 체크
// ignore: must_be_immutable
class ScoreButton extends StatefulWidget {
  ScoreButton(
      {super.key,
      required this.targetUID,
      required this.assessUID,
      this.isLike = true,
      this.isDislike = true});
  final String targetUID;
  final String assessUID;
  bool isLike;
  bool isDislike;
  List<bool> origin = [];

  @override
  State<ScoreButton> createState() => _ScoreButtonState();
}

class _ScoreButtonState extends State<ScoreButton> {
  @override
  void initState() {
    super.initState();
    widget.origin = [widget.isLike, widget.isDislike];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        //바뀐게 없으면 아무것도 하지 않음
        if (widget.origin == [widget.isLike, widget.isDislike]) {
          return;
        }
        //이전 평가와 바뀐 게 있으면 파이어스토어에 적용
        else {
          if (widget.isLike) {
            await ProfileService().userLike(
                targetUID: widget.targetUID, likerUID: widget.assessUID);
          }
          if (widget.isDislike) {
            await ProfileService().userDislike(
                targetUID: widget.targetUID, likerUID: widget.assessUID);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            //좋아요 버튼
            Flexible(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (AppColors.likeButton),
                  minimumSize: const Size(1000, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: widget.isLike
                        ? BorderSide(color: Colors.green[900]!, width: 5)
                        : BorderSide.none,
                  ),
                ),
                onPressed: () {
                  if (widget.isLike) {
                    return;
                  } else {
                    widget.isDislike = false;
                    widget.isLike = true;
                    setState(() {});
                  }
                },
                child: const Icon(
                  Icons.thumb_up,
                  color: (AppColors.likeIcon),
                ),
              ),
            ),
            const SizedBox(width: 20),
            //안좋아요 버튼
            Flexible(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (AppColors.dislikeButton),
                  minimumSize: const Size(1000, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: widget.isDislike
                        ? BorderSide(color: Colors.red[900]!, width: 5)
                        : BorderSide.none,
                  ),
                ),
                onPressed: () {
                  if (widget.isDislike) {
                    return;
                  } else {
                    widget.isLike = false;
                    widget.isDislike = true;
                    setState(() {});
                  }
                },
                child: Icon(
                  Icons.thumb_down,
                  color: (AppColors.dislikeIcon),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
