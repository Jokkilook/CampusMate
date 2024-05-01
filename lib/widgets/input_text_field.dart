import 'package:campusmate/AppColors.dart';
import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  const InputTextField(
      {super.key,
      required this.controller,
      this.minLines,
      this.maxLines,
      this.maxLength,
      this.keyboardType,
      this.hintText,
      this.scrollPadding = const EdgeInsets.all(0),
      this.focusNode,
      this.canOutsideUnfocus = true,
      this.isDark = false});
  final TextEditingController controller;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? hintText;
  final EdgeInsets scrollPadding;
  final FocusNode? focusNode;
  final bool canOutsideUnfocus;
  final bool isDark;

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      onTapOutside: widget.canOutsideUnfocus
          ? (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          : null,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      scrollPadding: widget.scrollPadding,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: widget.isDark ? AppColors.darkLine : AppColors.lightLine,
                width: 1.5,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: widget.isDark ? AppColors.darkLine : AppColors.lightLine,
                width: 1.5,
              )),
          filled: true,
          fillColor: widget.isDark ? AppColors.darkInput : AppColors.lightInput,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          hintText: widget.hintText,
          hintStyle: const TextStyle(fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
    );
  }
}
