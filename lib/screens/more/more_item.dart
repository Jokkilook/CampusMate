// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class MoreItem extends StatelessWidget {
  MoreItem({Key? key, this.icon, this.title, this.opTap}) : super(key: key);
  final Icon? icon;
  final String? title;
  Function? opTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        opTap;
      },
      child: ListTile(
        leading: icon ?? const Icon(Icons.close),
        title: Text(title ?? ""),
      ),
    );
  }
}
