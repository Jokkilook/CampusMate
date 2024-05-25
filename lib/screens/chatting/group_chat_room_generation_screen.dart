import 'package:campusmate/app_colors.dart';
import 'package:campusmate/services/chatting_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupChatRoomGenerationScreen extends StatefulWidget {
  const GroupChatRoomGenerationScreen({super.key});

  @override
  State<GroupChatRoomGenerationScreen> createState() =>
      _GroupChatRoomGenerationScreenState();
}

class _GroupChatRoomGenerationScreenState
    extends State<GroupChatRoomGenerationScreen> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController descController = TextEditingController();

  bool onCreating = false;

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      appBar: AppBar(
        title: const Text("그룹 채팅방 생성"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "방 이름",
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkHeadText
                          : AppColors.lightHeadText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  maxLength: 20,
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "방 이름을 입력해주세요.",
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  "방 설명",
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkHeadText
                          : AppColors.lightHeadText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  maxLength: 100,
                  maxLines: 4,
                  minLines: 1,
                  controller: descController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "방 설명을 입력해주세요.",
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            TextButton(
                onPressed: titleController.value.text == "" ||
                        descController.value.text == ""
                    ? null
                    : () async {
                        if (!onCreating) {
                          onCreating = true;
                          context.pop();
                          await ChattingService().createGroupRoom(
                              context: context,
                              roomName: titleController.value.text,
                              desc: descController.value.text,
                              limit: 30);

                          onCreating = false;
                        }
                      },
                child: const Text("방 만들기"))
          ],
        ),
      ),
    );
  }
}
