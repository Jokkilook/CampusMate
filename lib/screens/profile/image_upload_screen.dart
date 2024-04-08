import 'dart:io';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key, required this.userData});
  final UserData userData;

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  ImagePicker imagePicker = ImagePicker();

  var image;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: BottomButton(
        isLoading: isLoading,
        text: "완료",
        isCompleted: !isLoading,
        onPressed: () async {
          if (image != null) {
            isLoading = true;
            setState(() {});
            var ref = FirebaseStorage.instance
                .ref()
                .child("images/${widget.userData.uid}.png");

            await ref.putFile(File(image!.path));
            widget.userData.imageUrl = await ref.getDownloadURL();
            DataBase().addUser(widget.userData);
          }

          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text('프로필 이미지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.amber,
              ),
              child: image != null
                  ? Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      widget.userData.imageUrl.toString(),
                      fit: BoxFit.cover,
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () async {
                      image = await imagePicker.pickImage(
                          source: ImageSource.gallery);

                      setState(() {});
                    },
                    child: const Text("갤러리")),
                TextButton(
                    onPressed: () async {
                      image = await imagePicker.pickImage(
                          source: ImageSource.camera);

                      setState(() {});
                    },
                    child: const Text("카메라"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
