import 'package:campusmate/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userData, child) {
        return Center(
          child:
              Text("${Provider.of<UserDataProvider>(context).userData.name}"),
        );
      },
    );
  }
}
