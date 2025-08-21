// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pos/main.dart';
import 'package:pos/methods/firestore_meth.dart';
import 'package:pos/pages/invoice_page.dart';
import 'package:pos/widgets/amount.dart';
import 'package:pos/widgets/textfield.dart';

class NewInvoice extends StatefulWidget {
  const NewInvoice({super.key});

  @override
  State<NewInvoice> createState() => _NewInvoiceState();
}

int? invoice;

class _NewInvoiceState extends State<NewInvoice> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController vehicleController = TextEditingController();
  TextEditingController makeController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController kilometerController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController paidController = TextEditingController();

  int total = 0;
  late int balance = total;
  int? payable;
  List<List<TextEditingController>> detailsTableControllers = [
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
  ];

  final StreamController<List<List<TextEditingController>>> _controller =
      StreamController.broadcast();
  var controllers;

  getInvoice() async {
    int temp = await getCurrentInvoice();
    setState(() {
      invoice = temp;
    });
  }

  //add new row
  addNewJob() {
    setState(() {
      detailsTableControllers.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
    _controller.add(detailsTableControllers);
  }

// remove last row
  removeLastJob() {
    setState(() {
      detailsTableControllers.removeLast();
    });
    _controller.add(detailsTableControllers);
  }

  void updateCalculations() {
    int newTotal = 0;
    for (var controllers in detailsTableControllers) {
      newTotal += int.tryParse(controllers[2].text) ?? 0;
    }

    int discount = int.tryParse(discountController.text) ?? 0;

    int paid = int.tryParse(paidController.text) ?? 0;

    // Calculate payable and balance
    int newPayable = newTotal - discount;
    if (newPayable < 0) newPayable = 0;

    int newBalance = newPayable - paid;
    if (newBalance < 0) newBalance = 0;

    setState(() {
      total = newTotal;
      payable = newPayable;
      balance = newBalance;
    });
  }

// clear all data
  clearData() {
    setState(() {
      nameController.clear();
      phoneController.clear();
      vehicleController.clear();
      makeController.clear();
      modelController.clear();
      kilometerController.clear();
      discountController.clear();
      paidController.clear();
      total = 0;
      balance = total;
      payable;
      detailsTableControllers = [
        [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]
      ];
    });
    // invoice = getCurrentInvoice();
  }

  final FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    getInvoice();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(),
      body: ListView(
        children: [
          //heading Lr autos
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 66.0),
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    "LR Autos ",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  invoice == null
                      ? AutoSizeText("Loading...")
                      : AutoSizeText("Invoice: $invoice "),
                ],
              ),
            ),
          ),
          //details container
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 66.0.w),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(
                  color: textColor,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 300.w,
                        child: MyTextField(
                          hintText: 'Enter Name',
                          invoiceData: false,
                          textEditingController: nameController,
                          border: false,
                          fontSize: 25.sp,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      AutoSizeText(
                        "${DateTime.now().day} - ${DateTime.now().month} - ${DateTime.now().year}        ",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.phone,
                                  color: primaryAccent,
                                ),
                              ),
                              SizedBox(
                                width: 300.w,
                                child: MyTextField(
                                  hintText: 'Phone No. ',
                                  invoiceData: false,
                                  textEditingController: phoneController,
                                  border: false,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.car_repair,
                                ),
                              ),
                              SizedBox(
                                width: 300.w,
                                child: MyTextField(
                                  hintText: 'Vehicle No. ',
                                  invoiceData: false,
                                  textEditingController: vehicleController,
                                  border: false,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.miscellaneous_services_rounded,
                                ),
                              ),
                              SizedBox(
                                width: 100.w,
                                child: MyTextField(
                                  hintText: 'Make',
                                  textAlign: TextAlign.start,
                                  invoiceData: false,
                                  textEditingController: makeController,
                                  border: false,
                                ),
                              ),
                              SizedBox(
                                width: 300.w,
                                child: MyTextField(
                                  invoiceData: false,
                                  hintText: 'Model ',
                                  textEditingController: modelController,
                                  border: false,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.gas_meter_outlined,
                                ),
                              ),
                              SizedBox(
                                width: 300.w,
                                child: MyTextField(
                                  invoiceData: false,
                                  textAlign: TextAlign.start,
                                  hintText: 'km',
                                  textEditingController: kilometerController,
                                  border: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Amount(
                          updateCalculations: updateCalculations,
                          total: total,
                          balance: balance,
                          payable: payable),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30.h),

          RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter) {
                addNewJob();
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 66.0.w),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: secondaryTextColor,
                  ),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Column(
                    children: [
                      //title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 50.h,
                            width: 70.w,
                            child: AutoSizeText(
                              "S No.",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 22.sp,
                              ),
                            ),
                          ),
                          Container(
                            height: 50.h,
                            // color: altColumn2,
                            width: 500.w,
                            child: AutoSizeText(
                              "  Description",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 22.sp,
                              ),
                            ),
                          ),
                          Container(
                            height: 50.h,
                            // color: altColumn1,
                            width: 140.w,
                            child: AutoSizeText(
                              "Quantity",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 22.sp,
                              ),
                            ),
                          ),
                          Container(
                            // color: altColumn2,
                            height: 50.h,
                            width: 140.w,
                            child: AutoSizeText(
                              "Cost",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 22.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      //details row ykwim
                      SizedBox(
                        child: StreamBuilder<List<List<TextEditingController>>>(
                          stream: _controller.stream,
                          initialData: detailsTableControllers,
                          builder: (context, snapshot) {
                            controllers = snapshot.data ?? [];
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: detailsTableControllers.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      // color: altColumn1,
                                      width: 70.w,
                                      height: 50.h,
                                      child: Center(
                                        child: AutoSizeText(
                                          textAlign: TextAlign.start,
                                          "${index + 1}",
                                          style: TextStyle(
                                            fontSize: 22.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 50.h,
                                      // color: altColumn2,
                                      width: 500.w,
                                      child: MyTextField(
                                        textAlign: TextAlign.start,
                                        invoiceData: false,
                                        hintText: '',
                                        textEditingController:
                                            detailsTableControllers[index][0],
                                        border: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50.h,
                                      // color: altColumn1,
                                      width: 150.w,
                                      child: MyTextField(
                                        textAlign: TextAlign.end,
                                        invoiceData: false,
                                        hintText: '',
                                        textEditingController:
                                            detailsTableControllers[index][1],
                                        border: false,
                                      ),
                                    ),
                                    Container(
                                      // color: altColumn2,
                                      width: 150.w,
                                      height: 50.h,
                                      child: MyTextField(
                                        textAlign: TextAlign.end,
                                        invoiceData: false,
                                        hintText: '',
                                        textEditingController:
                                            detailsTableControllers[index][2],
                                        border: false,
                                        onChanged: (p0) {
                                          updateCalculations();
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // SizedBox(height: 30.h),

                      Padding(
                        padding: EdgeInsets.only(right: 400.0.w),
                        child: Divider(
                          color: secondaryTextColor,
                        ),
                      ),
                      // add remove buttons
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //add new job button
                              GestureDetector(
                                onTap: addNewJob,
                                child: SizedBox(
                                  height: 50.h,
                                  width: 150.w,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add_circle,
                                        color: secondaryTextColor,
                                      ),
                                      SizedBox(width: 10.w),
                                      AutoSizeText(
                                        "Add Item",
                                        style: TextStyle(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.w),

                              //remove last job button
                              GestureDetector(
                                onTap: () {
                                  removeLastJob();
                                  updateCalculations();
                                },
                                child: SizedBox(
                                  height: 50.h,
                                  width: 150.w,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.remove_circle,
                                        color: secondaryTextColor,
                                      ),
                                      SizedBox(width: 10.w),
                                      AutoSizeText(
                                        "Remove Item",
                                        style: TextStyle(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30.h),
          //generate invoice button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 66.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    //put data to firebase

                    try {
                      addToFirebase(
                          detailsTableControllers,
                          total,
                          payable as int,
                          balance,
                          nameController.text.toLowerCase(),
                          phoneController.text.toLowerCase(),
                          vehicleController.text.toLowerCase(),
                          makeController.text.toLowerCase(),
                          modelController.text.toLowerCase(),
                          kilometerController.text.toLowerCase(),
                          invoice as int,
                          int.tryParse(discountController.text) ?? 0,
                          int.tryParse(paidController.text) ?? 0);
                      //
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return InvoicePage(
                            invoice: invoice!,
                          );
                        }),
                      );
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Container(
                    height: 50.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: primaryAccent,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Center(
                      child: AutoSizeText(
                        "Save Invoice",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),

                //CLEAR ALL DATA
                GestureDetector(
                  onTap: clearData,
                  child: Container(
                    height: 50.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Center(
                      child: AutoSizeText(
                        "Reset Invoice",
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
