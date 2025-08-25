// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/main.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  TextEditingController? textEditingController;
  final bool border;
  bool invoiceData = false;
  Function(String)? onChanged;
  Function(String)? onSubmitted;
  bool isEditing = true;
  double? fontSize = 22.sp;
  double? hintFontSize = 22.sp;
  TextAlign textAlign;
  FocusNode? focusNode;

  MyTextField({
    super.key,
    required this.hintText,
    required this.border,
    required this.invoiceData,
    required this.textAlign,
    required this.isEditing,
    this.textEditingController,
    this.onChanged,
    this.hintFontSize,
    this.fontSize,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      onSubmitted: widget.onSubmitted,
      controller: widget.textEditingController,
      onChanged: widget.onChanged,
      readOnly: !widget.isEditing,
      textAlign: widget.textAlign,
      style: TextStyle(fontSize: widget.fontSize),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.hintFontSize,
          color: widget.invoiceData ? textColor : secondaryTextColor,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: widget.border
              ? BorderSide(
                  color: Colors.blueAccent,
                )
              : BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderSide: widget.border ? BorderSide() : BorderSide.none,
        ),
      ),
    );
  }
}
