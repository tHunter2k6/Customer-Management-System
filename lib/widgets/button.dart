import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/main.dart';

class MyButton extends StatefulWidget {
  final void Function()? onTap;
  final Color containerColor;
  final Color textColor;
  final String buttonText;
  final bool border;
  const MyButton({
    super.key,
    required this.onTap,
    required this.containerColor,
    required this.textColor,
    required this.buttonText,
    required this.border,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: 50.h,
        width: 150.w,
        decoration: BoxDecoration(
          color: widget.containerColor,
          border: widget.border
              ? Border.all(
                  color: secondaryTextColor,
                )
              : Border.all(
                  width: 0,
                ),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Center(
          child: AutoSizeText(
            widget.buttonText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
