import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusmate/screens/profile/profile_revise_screen.dart';
import 'package:campusmate/widgets/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//ignore: must_be_immutable
class ImageUploadScreen extends StatefulWidget {
  ImageUploadScreen({super.key, required this.originUrl, required this.parent});

  final String originUrl;
  ImageViewer parent;

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
      bottomNavigationBar: BottomButton(
        isLoading: isLoading,
        text: "완료",
        isCompleted: !isLoading,
        onPressed: () {
          if (image != null) {
            isLoading = true;
            setState(() {});
            widget.parent.image = image;
            //DataBase().addUser(widget.userData);
          }
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
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
                color: Colors.grey[300],
              ),
              child: image != null
                  ? Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.originUrl,
                      placeholder: (context, url) {
                        return const Center(child: Icon(Icons.error_outline));
                      },
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.9,
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
