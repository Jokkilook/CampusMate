import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/database.dart';
import 'package:campusmate/screens/profile/profile_revise_screen.dart';
import 'package:campusmate/screens/profile/full_profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final db = DataBase();
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
        elevation: 2,
        shadowColor: Colors.black,
        title: const Text('프로필'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            throw Error();
          } else {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            return FullProfileCard(
                userData: UserData.fromJson(data), context: context);
          }
        },
      ),
      bottomNavigationBar: const SizedBox(
        height: 70,
      ),
    );
  }
}
