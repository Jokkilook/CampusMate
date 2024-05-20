import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/models/user_data.dart';

import '../../widgets/bottom_button.dart';
import 'widgets/show_alert_dialog.dart';

Color primaryColor = const Color(0xFF2BB56B);

//ignore: must_be_immutable
class AddPostScreen extends StatefulWidget {
  final UserData userData;
  final int currentIndex;

  const AddPostScreen({
    super.key,
    required this.currentIndex,
    required this.userData,
  });

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late String _selectedBoard;

  final PostData postData = PostData();

  XFile? image;

  @override
  void initState() {
    super.initState();
    image = null;
    _selectedBoard = widget.currentIndex == 0 ? 'General' : 'Anonymous';
    postData.boardType = _selectedBoard;
  }

  Future<void> _addPost(BuildContext context) async {
    try {
      postData.setData();
      if (_selectedBoard == 'General') {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('schools/${widget.userData.school}/generalPosts')
            .add(postData.data!);
        postData.postId = docRef.id;
        await docRef.update({'postId': postData.postId});
      }
      if (_selectedBoard == 'Anonymous') {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('schools/${widget.userData.school}/anonymousPosts')
            .add(postData.data!);
        postData.postId = docRef.id;
        await docRef.update({'postId': postData.postId});
      }
      Navigator.pop(context);
    } catch (error) {
      debugPrint('에러: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "addpost",
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('게시글 작성'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField(
                // 게시판 선택
                value: _selectedBoard,
                items: const [
                  DropdownMenuItem(child: Text('일반'), value: 'General'),
                  DropdownMenuItem(child: Text('익명'), value: 'Anonymous'),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBoard = value.toString();
                    postData.boardType = _selectedBoard;
                  });
                },
                decoration: const InputDecoration(labelText: '게시판 선택'),
              ),
              TextField(
                // 제목 입력
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                // 내용 입력
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // 사진 추가
              GestureDetector(
                onTap: () {
                  showDialog(
                    barrierColor: Colors.black.withOpacity(0.4),
                    context: context,
                    builder: (context) {
                      return Dialog(
                        clipBehavior: Clip.hardEdge,
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: IntrinsicHeight(
                          child: SizedBox(
                            width: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    image = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {});
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                      "갤러리",
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                const Divider(height: 0),
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    image = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    if (image != null) {
                                      setState(() {});
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                      "카메라",
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  width: MediaQuery.of(context).size.height * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                  child: image == null
                      ? const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                        )
                      : Image.file(
                          File(image!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomButton(
          text: '작성',
          isCompleted: true,
          onPressed: () async {
            final userData = context.read<UserDataProvider>().userData;
            postData.authorUid = userData.uid;
            postData.authorName = userData.name;
            postData.profileImageUrl = userData.imageUrl;
            postData.timestamp = Timestamp.fromDate(DateTime.now());
            // 제목, 내용을 입력해야 작성됨
            if (_titleController.value.text == "") {
              showAlertDialog(context, "제목을 입력해주세요.");
              return;
            }
            if (_contentController.value.text == "") {
              showAlertDialog(context, "내용을 입력해주세요.");
              return;
            }
            postData.title = _titleController.value.text;
            postData.content = _contentController.value.text;

            if (image != null) {
              // 이미지 압축
              XFile? compMedia = await FlutterImageCompress.compressAndGetFile(
                image!.path,
                "${image!.path}.jpg",
              );

              // 원본 이미지 파일 이름 추출
              String fileName = path.basename(image!.path);

              // 프로필 이미지 파일 레퍼런스
              var ref = FirebaseStorage.instance.ref().child(
                  "schools/${widget.userData.school}/postImages/$fileName");

              // 파이어스토어에 이미지 파일 업로드
              await ref.putFile(File(compMedia!.path));

              // 변경할 데이터에 변경된 URL 저장
              postData.imageUrl = await ref.getDownloadURL();
            }

            _addPost(context);
          },
        ),
      ),
    );
  }
}
