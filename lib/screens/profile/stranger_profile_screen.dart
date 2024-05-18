import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/screens/profile/widgets/loading_profile_card.dart';
import 'package:campusmate/services/auth_service.dart';
import 'package:campusmate/services/chatting_service.dart';
import 'package:campusmate/services/profile_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/widgets/score_button.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/screens/profile/widgets/full_profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

///프로필을 표시하는 스크린<br>
///required [uid] : 표시할 유저의 uid, 로그인한 유저의 uid면 자동으로 내 프로필로 표시<br>
///[readOnly] : true면 채팅하기 버튼은 표시 안 함. 좋아요 싫어요 버튼은 표시
class StrangerProfilScreen extends StatefulWidget {
  const StrangerProfilScreen(
      {super.key, required this.uid, this.readOnly = false});

  final String uid;
  final bool readOnly;

  @override
  State<StrangerProfilScreen> createState() => _StrangerProfilScreenState();
}

class _StrangerProfilScreenState extends State<StrangerProfilScreen> {
  final ChattingService chat = ChattingService();
  final AuthService auth = AuthService();
  final ProfileService profile = ProfileService();
  bool canBan = false;
  late String targetUID;
  late String name;

  @override
  Widget build(BuildContext context) {
    UserData currentUser = context.read<UserDataProvider>().userData;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.uid == currentUser.uid ? "내 " : ""}프로필'),
        actions: [
          widget.uid == currentUser.uid
              ? Container()
              : IconButton(
                  onPressed: () {
                    canBan
                        ? showDialog(
                            context: context,
                            builder: (_) {
                              return Dialog(
                                clipBehavior: Clip.hardEdge,
                                shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                insetPadding: const EdgeInsets.all(20),
                                child: SizedBox(
                                  width: MediaQuery.of(_).size.width * 0.8,
                                  child: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Text(
                                            "$name 님을 차단하시겠어요?",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () async {
                                                  profile.banUser(
                                                      targetUID: targetUID,
                                                      currentUser: currentUser);
                                                  context
                                                          .read<UserDataProvider>()
                                                          .userData =
                                                      await auth.getUserData(
                                                          uid:
                                                              currentUser.uid ??
                                                                  "");

                                                  Navigator.pop(_);
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(15),
                                                  child: Text(
                                                    "네",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(_);
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(15),
                                                  child: Text(
                                                    "아니요",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : null;
                  },
                  icon: const Icon(Icons.block))
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: auth.getUserDocumentSnapshot(uid: widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingProfileCard();
          }
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("존재하지 않는 사용자입니다."),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel))
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("오류가 발생했어요!"),
                  const SizedBox(height: 20),
                  IconButton.filled(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    color: Colors.green,
                    iconSize: MediaQuery.of(context).size.width * 0.08,
                  )
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            Map<String, dynamic> data;
            try {
              data = snapshot.data?.data() as Map<String, dynamic>;
            } catch (e) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("존재하지 않는 사용자입니다."),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.cancel))
                  ],
                ),
              );
            }

            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("데이터를 불러오지 못했어요!"),
                    const SizedBox(height: 20),
                    IconButton.filled(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      color: Colors.green,
                      iconSize: MediaQuery.of(context).size.width * 0.08,
                    )
                  ],
                ),
              );
            } else {
              canBan = true;
              UserData strangerData = UserData.fromJson(data);
              targetUID = strangerData.uid ?? "";
              name = strangerData.name ?? "";
              bool isLike =
                  strangerData.likers?.contains(currentUser.uid) ?? false;
              bool isDislike =
                  strangerData.dislikers?.contains(currentUser.uid) ?? false;

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FullProfileCard(
                          userData: strangerData,
                        ),
                        widget.readOnly
                            ? Container()
                            : const SizedBox(height: 80)
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.readOnly
                              ? Container()
                              : Flexible(
                                  flex: 1,
                                  child: BottomButton(
                                    padding: EdgeInsets.fromLTRB(
                                        20, 20, widget.readOnly ? 20 : 0, 20),
                                    text: "채팅하기",
                                    onPressed: () async {
                                      chat.startChatting(
                                          context, auth.getUID(), widget.uid);
                                    },
                                  ),
                                ),
                          widget.uid != currentUser.uid
                              ? Flexible(
                                  flex: 1,
                                  child: ScoreButton(
                                    assessUID: currentUser.uid!,
                                    targetUID: widget.uid,
                                    isLike: isLike,
                                    isDislike: isDislike,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("존재하지 않는 사용자입니다."),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel))
              ],
            ),
          );
        },
      ),
    );
  }
}
