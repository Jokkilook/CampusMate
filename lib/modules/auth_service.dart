import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;

  String getUID() {
    String uid = auth.currentUser!.uid;
    return uid;
  }
}
