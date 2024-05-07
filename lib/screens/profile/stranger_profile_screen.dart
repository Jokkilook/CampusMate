import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/widgets/score_button.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/screens/profile/widgets/full_profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    UserData currenUser = context.read<UserDataProvider>().userData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: auth.getUserDocumentSnapshot(uid: widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                  IconButton(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh))
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
                    IconButton(
                        onPressed: () {
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                ),
              );
            } else {
              UserData strangerData = UserData.fromJson(data);
              bool isLike =
                  strangerData.likers?.contains(currenUser.uid) ?? false;
              bool isDislike =
                  strangerData.dislikers?.contains(currenUser.uid) ?? false;
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FullProfileCard(
                            userData: strangerData, context: context),
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
                          widget.uid != currenUser.uid
                              ? Flexible(
                                  flex: 1,
                                  child: ScoreButton(
                                    assessUID: currenUser.uid!,
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
