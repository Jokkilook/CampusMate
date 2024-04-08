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
      this.scrollPadding = const EdgeInsets.all(0)});
  final TextEditingController controller;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? hintText;
  final EdgeInsets scrollPadding;

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      scrollPadding: widget.scrollPadding,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.6),
                width: 1.5,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.6),
                width: 1.5,
              )),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          hintText: widget.hintText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
    );
  }
}
