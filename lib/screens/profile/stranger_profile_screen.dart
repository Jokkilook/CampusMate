import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/chatting_service.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/profile/full_profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StrangerProfilScreen extends StatelessWidget {
  StrangerProfilScreen({super.key, required this.uid, this.readOnly = false});

  final String uid;
  final ChattingService chat = ChattingService();
  final AuthService auth = AuthService();
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text('프로필'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            throw Error();
          } else {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            if (data.isEmpty) {
              return const Center(
                child: Text("데이터 불러오기에 실패했어요..T0T"),
              );
            } else {
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FullProfileCard(
                            userData: UserData.fromJson(data),
                            context: context),
                        readOnly ? Container() : const SizedBox(height: 80)
                      ],
                    ),
                  ),
                  readOnly
                      ? Container()
                      : Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: BottomButton(
                            text: "채팅하기",
                            onPressed: () async {
                              chat.startChatting(context, auth.getUID(), uid);
                            },
                          ),
                        )
                ],
              );
            }
          }
        },
      ),
    );
  }
}
