import 'dart:io';

import 'package:campusmate/widgets/bottom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'models/post_data.dart';
import 'widgets/show_alert_dialog.dart';
import 'package:path/path.dart' as path;

class EditPostScreen extends StatefulWidget {
  final PostData postData;
  final String school;

  const EditPostScreen({
    Key? key,
    required this.postData,
    required this.school,
  }) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  XFile? image;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.postData.title);
    _contentController = TextEditingController(text: widget.postData.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updatePost(BuildContext context, String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection("schools/${widget.school}/" +
              (widget.postData.boardType == 'General'
                  ? 'generalPosts'
                  : 'anonymousPosts'))
          .doc(widget.postData.postId)
          .update({
        'title': _titleController.text,
        'content': _contentController.text,
        'imageUrl': imageUrl,
      });
      Navigator.pop(context);
    } catch (error) {
      debugPrint('게시글 수정 에러: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('게시글 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _contentController,
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '내용',
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
          // 제목, 내용을 입력해야 작성됨
          if (_titleController.value.text == "") {
            showAlertDialog(context, "제목을 입력해주세요.");
            return;
          }
          if (_contentController.value.text == "") {
            showAlertDialog(context, "내용을 입력해주세요.");
            return;
          }
          if (image != null) {
            // 이미지 압축
            XFile? compMedia = await FlutterImageCompress.compressAndGetFile(
              image!.path,
              "${image!.path}.jpg",
            );

            // 원본 이미지 파일 이름 추출
            String fileName = path.basename(image!.path);

            // 프로필 이미지 파일 레퍼런스
            var ref = FirebaseStorage.instance
                .ref()
                .child("schools/${widget.school}/postImages/$fileName");

            // 파이어스토어에 이미지 파일 업로드
            await ref.putFile(File(compMedia!.path));

            // 변경할 데이터에 변경된 URL 저장
            widget.postData.imageUrl = await ref.getDownloadURL();
          }
          _updatePost(context, widget.postData.imageUrl.toString());
        },
      ),
    );
  }
}
