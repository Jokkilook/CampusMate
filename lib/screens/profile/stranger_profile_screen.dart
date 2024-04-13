import 'package:campusmate/models/chat_room_data.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/chatting/chat_room_screen.dart';
import 'package:campusmate/screens/profile/full_profile_card.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StrangerProfilScreen extends StatelessWidget {
  StrangerProfilScreen({super.key, required this.uid});

  final db = DataBase();
  final String uid;

  @override
  Widget build(BuildContext context) {
    void startChatting(String targetUid) async {
      //1. 원래 채팅방이 있는지 확인. => 있으면 그 채팅방으로 이동
      //2. 상대방이 나를 차단했는지 확인 (상대방 차단 사용자 리스트에 포함되어있나 확인) 있으면 채팅을 시작할 수 없다는 안내 메세지 출력
      //3. 채팅방 생성 후 이동

      var data = await FirebaseFirestore.instance
          .collection("chats")
          .where("id",
              isEqualTo:
                  "${context.read<UserDataProvider>().userData.uid}$targetUid")
          .get();
      if (data.docs.isNotEmpty) {
        //원래 채팅방 발견하면 그곳으로 이동.
        var room = data.docs[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              chatRoomData: ChatRoomData(
                  roomName: room["roomName"],
                  roomId: room["roomId"],
                  participantsUid: (room["participantsUid"] as List)
                      .map((e) => e.toString())
                      .toList(),
                  lastMessage: room["lastMessage"],
                  lastMessageTime: room["lastMessageTime"]),
            ),
          ),
        );
      }

      if (data.docs.isEmpty) {
        //채팅방이 없으면 생성
        var roomData = ChatRoomData(
          roomId: "${context.read<UserDataProvider>().userData.uid}$targetUid",
          roomName: "테스트 채팅방",
          participantsUid: [
            "${context.read<UserDataProvider>().userData.uid}",
            targetUid
          ],
          lastMessage: "",
        );

        await FirebaseFirestore.instance
            .collection("chats")
            .doc(roomData.roomId)
            .set(roomData.toJson())
            .whenComplete(() => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                    chatRoomData: roomData,
                    isNew: true,
                  ),
                )));
      }
    }

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
                        const SizedBox(height: 80)
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: BottomButton(
                        text: "채팅하기",
                        onPressed: () {
                          startChatting(data["uid"]);
                        },
                      ))
                ],
              );
            }
          }
        },
      ),
    );
  }
}
