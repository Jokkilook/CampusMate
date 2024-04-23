import 'package:campusmate/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firesotre = FirebaseFirestore.instance;

  String getUID() {
    String uid = auth.currentUser!.uid;
    return uid;
  }

  Future registUser(UserData userData) async {
    userData.setData();
    firesotre
        .collection("schools/${userData.school}/users")
        .doc(userData.uid)
        .set(userData.toJson())
        .whenComplete(() {
      firesotre
          .collection("userSchoolInfo")
          .doc(userData.uid)
          .set({"userSchoolData": userData.school});
    });
  }

  Future setUserData(UserData userData) async {
    userData.setData();
    firesotre
        .collection("schools/${userData.school}/users")
        .doc(userData.uid)
        .set(userData.toJson());
  }

  Future deleteUser(String uid) async {
    var list = await getUserSchoolInfo(uid);
    await firesotre.collection("schools/${list[1]}/users").doc(uid).delete();
    await firesotre.collection("userSchoolInfo").doc(uid).delete();
  }

  Future<List<String>> getUserSchoolInfo(String uid) async {
    List<String> infoList = [];

    var data = await firesotre.collection("userSchoolInfo").doc(uid).get();
    infoList.add(uid);
    infoList.add(
        (data.data() as Map<String, dynamic>)["userSchoolData"].toString());

    return infoList;
  }

  Future<UserData> getUserData(
      {String uid = "", Source? options = Source.serverAndCache}) async {
    List<String> list = await getUserSchoolInfo(uid);
    String school = list[1];
    DocumentSnapshot doc = await firesotre
        .collection("schools/$school/users")
        .doc(uid)
        .get(GetOptions(source: options!));
    return UserData.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<DocumentSnapshot> getUserDocumentSnapshot(
      {String uid = "", Source? options = Source.serverAndCache}) async {
    var list = await getUserSchoolInfo(uid);
    return firesotre
        .collection('schools/${list[1]}/users')
        .doc(uid)
        .get(GetOptions(source: options!));
  }
}
