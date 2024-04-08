import 'package:campusmate/firebase_options.dart';
import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/login_screen.dart';
import 'package:campusmate/screens/screen_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class SplashLoadingScreen extends StatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void initialize() async {
    String uid;
    await MobileAds.instance.initialize();
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).whenComplete(() async {
      try {
        uid = FirebaseAuth.instance.currentUser!.uid;
        var snapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        var data = snapshot.data() as Map<String, dynamic>;
        var userData = UserData.fromJson(data);
        context.read<UserDataProvider>().userData = userData;
        Future.delayed(const Duration(seconds: 2));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ScreenList()),
            (route) => false);
      } catch (e) {
        print("xxxxxxx>>>>>>>$e");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      }
    });
  }
}
