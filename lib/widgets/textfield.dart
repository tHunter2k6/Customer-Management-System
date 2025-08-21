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
  double? fontSize = 22.sp;
  TextAlign textAlign;

  MyTextField(
      {super.key,
      required this.hintText,
      required this.border,
      required this.invoiceData,
      this.textEditingController,
      this.onChanged,
      this.fontSize,
      required this.textAlign});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textEditingController,
      onChanged: widget.onChanged,
      textAlign: widget.textAlign,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: widget.fontSize,
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
