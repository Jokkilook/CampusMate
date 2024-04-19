import 'dart:io';

import 'package:campusmate/modules/post_generator.dart';
import 'package:campusmate/modules/user_generator.dart';
import 'package:campusmate/provider/chatting_data_provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/test_video_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class MoreScreen extends StatefulWidget {
  MoreScreen({super.key});
  bool isGeneral = true;

  XFile? image;
  File? compImage;
  double? imageSize;
  double? compSize;
  XFile? video;

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 50,
    );

    return File(result!.path);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TestVideoScreen(file: widget.video),
                        ));
                  },
                  child: const Text("비디오 페이지로 이동")),
              TextButton(
                  onPressed: () async {
                    widget.video = await ImagePicker()
                        .pickVideo(source: ImageSource.gallery);
                    setState(() {});
                  },
                  child: const Text("동영상 테스트 갤러리")),
              TextButton(
                  onPressed: () async {
                    widget.video = await ImagePicker()
                        .pickVideo(source: ImageSource.camera);
                    setState(() {});
                  },
                  child: const Text("동영상 테스트 카메라")),
              widget.image != null
                  ? Row(
                      children: [
                        Column(
                          children: [
                            InstaImageViewer(
                              child: Image.file(
                                File(widget.image!.path),
                                width: 200,
                                height: 200,
                              ),
                            ),
                            Text("${widget.imageSize}")
                          ],
                        ),
                        Column(
                          children: [
                            InstaImageViewer(
                              child: Image.file(
                                File(widget.compImage!.path),
                                width: 200,
                                height: 200,
                              ),
                            ),
                            Text("${widget.compSize}")
                          ],
                        )
                      ],
                    )
                  : Container(),
              TextButton(
                  onPressed: () async {
                    widget.image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (widget.image != null) {
                      print(widget.image!.path);
                      var file = await testCompressAndGetFile(
                          File(widget.image!.path),
                          "${widget.image!.path}.jpg");
                      widget.compImage = File(file.path);
                      widget.imageSize =
                          await (widget.image!.length()) / (1024 * 1024);
                      widget.compSize =
                          await (widget.compImage!.length()) / (1024 * 1024);
                      setState(() {});
                    }
                  },
                  child: const Text("이미지 압축 테스트 (좌 원본 우 압축)")),
              Text("${context.read<ChattingDataProvider>().chatListStream}"),
              Text("${userProvider.userData.name}"),
              TextButton(
                  onPressed: () => userProvider.setName("sadsa"),
                  child: const Text("push")),
              const Text("버튼 누르면 10개씩 생성됨"),
              ElevatedButton(
                onPressed: () {
                  UserGenerator().addDummyUser(10);
                },
                child: const Text("더미유저생성"),
              ),
              ElevatedButton(
                onPressed: () {
                  UserGenerator().deleteDummyUser(10);
                },
                child: const Text("더미유저삭제"),
              ),
              ToggleButtons(
                children: const [Text("일반"), Text("익명")],
                isSelected: [widget.isGeneral, !widget.isGeneral],
                onPressed: (index) {
                  switch (index) {
                    case 0:
                      widget.isGeneral = true;
                      break;
                    case 1:
                      widget.isGeneral = false;
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  PostGenerator().addDummyPost(10, isGeneral: widget.isGeneral);
                },
                child: const Text("더미포스트생성"),
              ),
              ElevatedButton(
                onPressed: () {
                  PostGenerator()
                      .deleteDummyPost(10, isGeneral: widget.isGeneral);
                },
                child: const Text("더미포스트삭제"),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut().whenComplete(
                    () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false);
                    },
                  );
                },
                child: const Text("로그아웃"),
              ),
            ],
          ),
        );
      },
    );
  }
}
