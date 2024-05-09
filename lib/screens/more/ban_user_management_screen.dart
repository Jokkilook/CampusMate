import 'package:campusmate/models/user_data.dart';
import 'package:campusmate/modules/auth_service.dart';
import 'package:campusmate/modules/profile_service.dart';
import 'package:campusmate/provider/user_data_provider.dart';
import 'package:campusmate/screens/profile/stranger_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BanUserManagementScreen extends StatefulWidget {
  const BanUserManagementScreen({super.key});

  @override
  State<BanUserManagementScreen> createState() =>
      _BanUserManagementScreenState();
}

class _BanUserManagementScreenState extends State<BanUserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    UserData userData = context.read<UserDataProvider>().userData;
    AuthService auth = AuthService();
    ProfileService profile = ProfileService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("차단한 유저 관리"),
      ),
      body: userData.banUsers?.isEmpty ?? true
          ? const Center(
              child: Text("차단한 유저가 없어요!"),
            )
          : ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(height: 0);
              },
              itemCount: userData.banUsers?.length ?? 0,
              itemBuilder: (context, index) {
                String targetUid = userData.banUsers?.elementAt(index) ?? "";
                return ListTile(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          clipBehavior: Clip.hardEdge,
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          insetPadding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                      "유저 이름",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StrangerProfilScreen(
                                                    uid: targetUid,
                                                    readOnly: true),
                                          ));
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text("프로필 보기"),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await profile.unbanUser(
                                          targetUID: targetUid,
                                          currentUser: userData);

                                      context
                                              .read<UserDataProvider>()
                                              .userData =
                                          await auth.getUserData(
                                              uid: userData.uid ?? "");
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text("차단 해제"),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  title: FutureBuilder<DocumentSnapshot<Object?>>(
                    future: auth.getUserDocumentSnapshot(uid: targetUid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      var data = snapshot.data;
                      UserData targetData = UserData.fromJson(
                          data?.data() as Map<String, dynamic>);
                      return Text(targetData.name ?? "알 수 없음");
                    },
                  ),
                );
              },
            ),
    );
  }
}
