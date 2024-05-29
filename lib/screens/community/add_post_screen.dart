import 'dart:io';
import 'package:campusmate/app_colors.dart';
import 'package:campusmate/services/post_service.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:campusmate/widgets/confirm_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/community/models/post_data.dart';
import 'package:campusmate/models/user_data.dart';
import '../../widgets/bottom_button.dart';

Color primaryColor = const Color(0xFF2BB56B);

//ignore: must_be_immutable
class AddPostScreen extends StatefulWidget {
  final int currentIndex;

  const AddPostScreen({
    super.key,
    required this.currentIndex,
  });

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final PostService postService = PostService();

  late String _selectedBoard;
  bool isLoading = false;

  final PostData postData = PostData();

  List<XFile?> image = [null, null, null, null, null, null];

  @override
  void initState() {
    super.initState();

    _selectedBoard = widget.currentIndex == 0 ? 'General' : 'Anonymous';
    postData.boardType = _selectedBoard;
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserDataProvider>().userData;
    bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('게시글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButtonFormField(
                // 게시판 선택
                value: _selectedBoard,
                items: const [
                  DropdownMenuItem(
                    value: 'General',
                    child: Text(
                      '일반',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Anonymous',
                    child: Text(
                      '익명',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
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
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: const InputDecoration(
                  labelText: '제목',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                // 내용 입력
                controller: _contentController,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                keyboardType: TextInputType.multiline,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
                                                image[i] = await ImagePicker()
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
                                                image[i] = await ImagePicker()
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
                              child: image[i] == null
                                  ? const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                    )
                                  : Image.file(
                                      File(image[i]!.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          image[i] != null
                              ? InkWell(
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.grey[850],
                                  ),
                                  onTap: () {
                                    image[i] = null;
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
      bottomNavigationBar: Hero(
        tag: "addPost",
        child: BottomButton(
          text: '작성',
          isLoading: isLoading,
          isCompleted: true,
          onPressed: isLoading
              ? () {}
              : () async {
                  // 제목, 내용을 입력해야 작성됨
                  if (_titleController.value.text == "") {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ConfirmDialog(content: '제목을 입력해주세요.'),
                    );
                    return;
                  }
                  if (_contentController.value.text == "") {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ConfirmDialog(content: '내용을 입력해주세요.'),
                    );
                    return;
                  }

                  //게시글 업로드 시퀀스
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

                  FirebaseStorage storage = FirebaseStorage.instance;

                  Timestamp time = Timestamp.now();
                  postData.postId =
                      "${userData.uid}_${time.millisecondsSinceEpoch}";

                  postData.boardType = _selectedBoard;
                  postData.authorUid = userData.uid;
                  postData.authorName = userData.name;
                  postData.profileImageUrl = userData.imageUrl;
                  postData.timestamp = time;
                  postData.title = _titleController.value.text;
                  postData.content = _contentController.value.text;
                  postData.school = userData.school;

                  List<String> imageUrls = [];
                  bool isGeneral = _selectedBoard == "General";

                  int index = 0;

                  for (XFile? uploadedImage in image) {
                    if (uploadedImage != null) {
                      //이미지 압축
                      XFile? compPic =
                          await FlutterImageCompress.compressAndGetFile(
                        uploadedImage.path,
                        "${uploadedImage.path}.jpg",
                      );

                      if (compPic != null) {
                        // 이미지 파일 이름 생성
                        String fileName =
                            "${userData.uid}_${time.millisecondsSinceEpoch}_$index.png";

                        // 프로필 이미지 파일 레퍼런스
                        var ref = storage.ref().child(
                            "schools/${userData.school}/postImages/${isGeneral ? "generalPosts" : "anonyPosts"}/${postData.postId}/$fileName");

                        // 파이어스토어에 이미지 파일 업로드
                        await ref.putFile(File(compPic.path));
                        String url = await ref.getDownloadURL();
                        imageUrls.add(url);

                        postData.imageUrl![index] = imageUrls[index];
                      }
                      index++;
                    }
                  }

                  await postService.addPost(
                      postData: postData, userData: userData);

                  context.pop();
                  context.pop();

                  setState(() {
                    isLoading = false;
                  });
                },
        ),
      ),
    );
  }
}
