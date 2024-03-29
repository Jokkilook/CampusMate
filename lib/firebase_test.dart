//아래 두줄은 파이어베이스 쓰려면 추가해야한다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FirebaseTest {
  void initFirebase() async {
    //파이어베이스 초기화 하는것.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAuth.instance.signOut();
  }
}
