import 'dart:io';

import 'package:campusmate/Theme/app_colors.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:campusmate/widgets/confirm_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'models/post_data.dart';

class EditPostScreen extends StatefulWidget {
  final PostData postData;

  const EditPostScreen({
    super.key,
    required this.postData,
  });

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<String> imageUrls;
  List<String> deleteUrls = [];
  List<XFile?> images = [null, null, null, null, null, null];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageUrls = widget.postData.imageUrl!;
    _titleController = TextEditingController(text: widget.postData.title);
    _contentController = TextEditingController(text: widget.postData.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    PostData editedPost = widget.postData;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('게시글 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: const InputDecoration(labelText: '제목'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '내용',
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                  alignment: WrapAlignment.center,
                  spacing: (MediaQuery.of(context).size.width - 32) * 0.05,
                  runSpacing: (MediaQuery.of(context).size.width - 32) * 0.05,
                  children: [
                    for (var i = 0; i < 6; i++)
                      // 사진 추가
                      Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                barrierColor: Colors.black.withOpacity(0.4),
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    clipBehavior: Clip.hardEdge,
                                    shape: ContinuousRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: IntrinsicHeight(
                                      child: SizedBox(
                                        width: 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                context.pop();
                                                images[i] = await ImagePicker()
                                                    .pickImage(
                                                        source: ImageSource
                                                            .gallery);
                                                setState(() {});
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
                                                context.pop();
                                                images[i] = await ImagePicker()
                                                    .pickImage(
                                                        source:
                                                            ImageSource.camera);
                                                setState(() {});
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
                              width: (MediaQuery.of(context).size.width - 32) *
                                  0.3,
                              height: (MediaQuery.of(context).size.width - 32) *
                                  0.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isDark
                                    ? AppColors.darkInnerSection
                                    : AppColors.lightTag,
                              ),
                              //온라인 업로드 된 이미지가 없고,
                              child: imageUrls[i] == ""
                                  //로컬 업로드 된 이미지가 있으면
                                  ? (images[i] != null
                                      //로컬 이미지 표시
                                      ? Image.file(
                                          File(images[i]!.path),
                                          fit: BoxFit.cover,
                                        )
                                      //빈 이미지 표시
                                      : const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                        ))
                                  //온라인 업로드된 이미지가 있고,
                                  : images[i] != null
                                      //로컬 업로드된 이미지가 있으면 로컬 이미지 표시
                                      ? Image.file(
                                          File(images[i]!.path),
                                          fit: BoxFit.cover,
                                        )
                                      //로컬 업로드된 이미지가 없으면 온라인 이미지 표시
                                      : Image.network(
                                          imageUrls[i],
                                          fit: BoxFit.cover,
                                        ),
                            ),
                          ),
                          (imageUrls[i] != "" || images[i] != null)
                              ? InkWell(
                                  enableFeedback: false,
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.grey[850],
                                  ),
                                  onTap: () {
                                    deleteUrls.add(imageUrls[i]);
                                    imageUrls[i] = "";
                                    images[i] = null;
                                    setState(() {});
                                  },
                                )
                              : const SizedBox(
                                  width: 10,
                                  height: 10,
                                )
                        ],
                      ),
                  ]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomButton(
        isLoading: isLoading,
        text: '수정',
        isCompleted: true,
        onPressed: () async {
          // 제목, 내용을 입력해야 작성됨
          if (_titleController.value.text == "") {
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(content: "제목을 입력해주세요."),
            );
            return;
          }
          if (_contentController.value.text == "") {
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(content: "내용을 입력해주세요."),
            );
            return;
          }

          setState(() {
            isLoading = true;
          });

          //로딩 오버레이 표시
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const Center(
                child: CircleLoading(),
              );
            },
          );

          Timestamp time = Timestamp.now();
          FirebaseStorage storage = FirebaseStorage.instance;

          editedPost.title = _titleController.value.text;
          editedPost.content = _contentController.value.text;
          List<String> editedImageUrls = [];

          // imageUrls : 기존 이미지 url 리스트
          // images : 로컬 업로드된 이미지 XFile 리스트
          // editedImageUrls : 수정된 url 리스트

          int index = 0;
          //로컬 업로드 된 이미지 리스트를 순회한다.
          for (XFile? uploadedImage in images) {
            //로컬 업로드 이미지가 있으면
            if (uploadedImage != null) {
              //기존 이미지를 대체한 이미지면
              if (imageUrls[index] != "") {
                //기존 이미지 url로 연결된 파이어스토리지 이미지 삭제
                String editedImageUrl = imageUrls[index];
                var targetRef = storage.refFromURL(editedImageUrl);
                targetRef.delete();

                //기존 이미지 url 삭제
                imageUrls[index] = "";
              }

              //로컬 업로드 된 이미지 압축
              XFile? compPic = await FlutterImageCompress.compressAndGetFile(
                uploadedImage.path,
                "${uploadedImage.path}.jpg",
              );

              //압축이 성공해서 압축 파일이 존재하면,
              if (compPic != null) {
                // 이미지 파일 이름 생성
                String fileName =
                    "${userData.uid}_${time.millisecondsSinceEpoch}_$index.png";

                // 프로필 이미지 파일 레퍼런스
                var ref = storage.ref().child(
                    "schools/${userData.school}/postImages/${editedPost.postId}/$fileName");

                // 파이어스토어에 이미지 파일 업로드
                await ref.putFile(File(compPic.path));
                String url = await ref.getDownloadURL();
                imageUrls[index] = url;
              }
            }

            //기존 이미지 url이 ""이 아니면
            if (imageUrls[index] != "") {
              //대체할 url 리스트에 url 추가 (중간 공백 삭제)
              editedImageUrls.add(imageUrls[index]);
            }

            //삭제한 이미지 파이어스토리지에서 삭제
            for (var url in deleteUrls) {
              if (url != "") {
                var targetRef = storage.refFromURL(url);
                targetRef.delete();
              }
            }
            index++;
          }

          //이미지 url 정리
          int editedLength = editedImageUrls.length;
          if (editedLength != 6) {
            int targetIndex = 6 - editedLength;
            for (var i = 0; i < targetIndex; i++) {
              editedImageUrls.add("");
            }
          }

          editedPost.imageUrl = editedImageUrls;

          await PostService()
              .updatePost(userData: userData, editedData: editedPost);

          context.pop();
          context.pop();

          setState(() {
            isLoading = false;
          });
        },
      ),
    );
  }
}
