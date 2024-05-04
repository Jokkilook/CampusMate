import 'package:campusmate/AppColors.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class InputTextField extends StatefulWidget {
  InputTextField(
      {super.key,
      required this.controller,
      this.checkongController,
      this.minLines = 1,
      this.maxLines = 1,
      this.maxLength,
      this.keyboardType,
      this.hintText,
      this.scrollPadding = const EdgeInsets.all(0),
      this.focusNode,
      this.canOutsideUnfocus = true,
      this.isDark = false,
      this.obscureText = false,
      this.obscrueSee = false,
      this.checkWithOther = false});
  final TextEditingController controller;
  final TextEditingController? checkongController;

  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? hintText;
  final EdgeInsets scrollPadding;
  final FocusNode? focusNode;
  final bool canOutsideUnfocus;
  final bool isDark;
  final bool checkWithOther;
  bool obscureText;
  final bool obscrueSee;

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        setState(() {});
      },
      obscureText: widget.obscureText,
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
          suffixIcon: (widget.obscrueSee && widget.controller.value.text != "")
              ? IconButton(
                  onPressed: () {
                    widget.obscureText = !widget.obscureText;
                    setState(() {});
                  },
                  icon: Icon(
                    widget.obscureText
                        ? Icons.remove_red_eye
                        : Icons.remove_red_eye_outlined,
                    color: widget.isDark
                        ? AppColors.darkHint
                        : AppColors.lightHint,
                  ),
                )
              : const SizedBox(
                  height: 1,
                  width: 1,
                ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: widget.checkWithOther
                    ? ((widget.controller.value.text !=
                                widget.checkongController?.value.text &&
                            widget.controller.value.text != "")
                        ? AppColors.alertText
                        : widget.isDark
                            ? AppColors.darkLine
                            : AppColors.lightLine)
                    : widget.isDark
                        ? AppColors.darkLine
                        : AppColors.lightLine,
                width: 1.5,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: widget.checkWithOther
                    ? ((widget.controller.value.text !=
                                widget.checkongController?.value.text &&
                            widget.controller.value.text != "")
                        ? AppColors.alertText
                        : widget.isDark
                            ? AppColors.darkLine
                            : AppColors.lightLine)
                    : widget.isDark
                        ? AppColors.darkLine
                        : AppColors.lightLine,
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
