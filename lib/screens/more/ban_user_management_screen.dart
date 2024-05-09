import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BanUserManagementScreen extends StatelessWidget {
  const BanUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    UserData userData = context.read<UserDataProvider>().userData;
    AuthService auth = AuthService();
    print(userData.banUsers);
    return Scaffold(
      appBar: AppBar(
        title: const Text("차단한 유저 관리"),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return const Divider(height: 0);
        },
        itemCount: userData.banUsers?.length ?? 0,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: FutureBuilder<DocumentSnapshot<Object?>>(
              future: auth.getUserDocumentSnapshot(
                  uid: userData.banUsers?.elementAt(index) ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                print(snapshot);
                var data = snapshot.data;
                UserData targetData =
                    UserData.fromJson(data?.data() as Map<String, dynamic>);
                return Text(targetData.name ?? "알 수 없음");
              },
            ),
          );
        },
      ),
    );
  }
}
