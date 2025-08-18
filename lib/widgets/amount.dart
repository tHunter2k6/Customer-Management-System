// ignore_for_file: unnecessary_string_interpolations

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pos/main.dart';
import 'package:pos/widgets/textfield.dart';

class Amount extends StatefulWidget {
  final discountController;
  final paidController;
  final Function updateCalculations;
  final int total;
  final int balance;
  final int? payable;
  const Amount(
      {super.key,
      this.discountController,
      this.paidController,
      required this.updateCalculations,
      required this.total,
      required this.balance,
      required this.payable});

  @override
  State<Amount> createState() => _AmountState();
}

class _AmountState extends State<Amount> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //first column
        Column(
          children: [
            Container(
              height: 50.h,
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                "Total",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: secondaryTextColor,
                ),
              ),
            ),
            Container(
              height: 50.h,
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                "Discount",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: secondaryTextColor,
                ),
              ),
            ),
            Container(
              height: 50.h,
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                "Payable",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: secondaryTextColor,
                ),
              ),
            ),
            Container(
              height: 50.h,
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                "Paid",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: secondaryTextColor,
                ),
              ),
            ),
            Container(
              height: 50.h,
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                "Balance",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
        //values column
        Column(
          children: [
            Container(
              width: 150.w,
              height: 50.h,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: AutoSizeText(
                "${NumberFormat.currency(locale: 'en_PK', symbol: '', decimalDigits: 0).format(widget.total as num)}",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: textColor,
                ),
              ),
            ),
            // discount row
            Container(
              width: 150.w,
              height: 50.h,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: MyTextField(
                textAlign: TextAlign.start,
                invoiceData: true,
                hintText: '',
                textEditingController: widget.discountController,
                border: false,
                onChanged: (p1) {
                  widget.updateCalculations();
                },
              ),
            ),
            // payable row
            Container(
              height: 50.h,
              width: 150.w,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: AutoSizeText(
                "${widget.payable == null ? NumberFormat.currency(locale: 'en_PK', symbol: '', decimalDigits: 0).format(0) : NumberFormat.currency(locale: 'en_PK', symbol: 'Rs ', decimalDigits: 0).format(widget.payable)}",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: textColor,
                ),
              ),
            ),
            // paid row
            Container(
              height: 50.h,
              width: 150.w,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: MyTextField(
                textAlign: TextAlign.start,
                hintText: '',
                invoiceData: true,
                textEditingController: widget.paidController,
                border: false,
                onChanged: (p2) {
                  widget.updateCalculations();
                },
              ),
            ),
            // balance row
            Container(
              height: 50.h,
              width: 150.w,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: AutoSizeText(
                "${widget.balance == null ? NumberFormat.currency(locale: 'en_PK', symbol: 'Rs ', decimalDigits: 0).format(0) : NumberFormat.currency(locale: 'en_PK', symbol: 'Rs ', decimalDigits: 0).format(widget.balance)}",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: textColor,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
