import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/profile_revise_screen.dart';
import 'package:campusmate/screens/profile/widgets/full_profile_card.dart';
import 'package:campusmate/widgets/circle_loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//ignore: must_be_immutable
class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final db = DataBase();
  final uid = FirebaseAuth.instance.currentUser?.uid;
  late UserData userData;

  @override
  Widget build(BuildContext context) {
    userData = context.read<UserDataProvider>().userData;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileReviseScreen()),
          );
        },
        child: const Icon(Icons.edit, size: 30),
        backgroundColor: Colors.green,
        foregroundColor: const Color(0xFF0A351E),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      appBar: AppBar(
        title: const Text('내 프로필'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('schools/${userData.school}/users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircleLoading(),
            );
          }
          if (snapshot.hasError) {
            throw Error();
          }

          if (snapshot.hasData) {
            var data = snapshot.data?.data() as Map<String, dynamic>;
            return FullProfileCard(
                userData: UserData.fromJson(data), context: context);
          }

          return const Center(child: Text("데이터를 불러오지 못했어요 T0T"));
        },
      ),
      bottomNavigationBar: const SizedBox(
        height: 70,
      ),
    );
  }
}
