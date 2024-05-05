import 'package:campusmate/AppColors.dart';
import 'package:campusmate/modules/profile_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    // TODO: implement initState
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
      child: Row(
        children: [
          //좋아요 버튼
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (widget.isLike
                      ? AppColors.inactivelikeButton
                      : AppColors.likeButton),
                  minimumSize: const Size(1000, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
                child: Icon(
                  Icons.thumb_up,
                  color: (widget.isLike
                      ? AppColors.inactivelikeIcon
                      : AppColors.likeIcon),
                ),
              ),
            ),
          ),
          //안좋아요 버튼
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (widget.isDislike
                      ? AppColors.inactivedislikeButton
                      : AppColors.dislikeButton),
                  minimumSize: const Size(1000, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
                  Icons.thumb_up,
                  color: (widget.isDislike
                      ? AppColors.inactivedislikeIcon
                      : AppColors.dislikeIcon),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
