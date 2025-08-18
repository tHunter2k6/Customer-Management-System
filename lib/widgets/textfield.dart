// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/main.dart';

class MyTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      onChanged: onChanged,
      textAlign: textAlign,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize,
          color: invoiceData ? textColor : secondaryTextColor,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: border
              ? BorderSide(
                  color: Colors.blueAccent,
                )
              : BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderSide: border ? BorderSide() : BorderSide.none,
        ),
      ),
    );
  }
}
