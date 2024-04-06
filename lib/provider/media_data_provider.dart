import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MediaDataProvider with ChangeNotifier {
  final storage = FirebaseStorage.instance.ref();
}
