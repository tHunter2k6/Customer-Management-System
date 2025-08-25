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

  bool isEditing = false;
  int profit = 0;
  int total = 0;
  late int balance = total;
  int payable = 0;
  List<List<TextEditingController>> detailsTableControllers = [
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
    [
      TextEditingController(),
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
    int newProfit = 0;

    for (var controllers in detailsTableControllers) {
      newTotal += int.tryParse(removeNonAlphanumeric(controllers[2].text)) ?? 0;
      newProfit +=
          int.tryParse(removeNonAlphanumeric(controllers[3].text)) ?? 0;
    }

    int discount =
        int.tryParse(removeNonAlphanumeric(discountController.text)) ?? 0;

    int paid = int.tryParse(removeNonAlphanumeric(paidController.text)) ?? 0;

    // Calculate payable and balance and profit
    int newPayable = newTotal - discount;
    if (newPayable < 0) newPayable = 0;

    int newBalance = newPayable - paid;
    if (newBalance < 0) newBalance = 0;

    newProfit = newTotal - newProfit;
    if (newProfit < 0) newProfit = 0;

    setState(() {
      total = newTotal;
      payable = newPayable;
      balance = newBalance;
      profit = newProfit;
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
      payable = 0;
      profit = 0;
      isEditing = false;
      detailsTableControllers = [
        [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ],
        [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ],
        [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ],
        [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ],
      ];
    });
  }

  final FocusScopeNode _localScopeNode = FocusScopeNode();
  final FocusNode _focusNode = FocusNode();
  FocusNode? _newRowFocusNode;
  @override
  Widget build(BuildContext context) {
    getInvoice();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
      ),
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
                      fontSize: 50.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  invoice == null
                      ? AutoSizeText("Loading ...")
                      : AutoSizeText(
                          "Invoice: $invoice ",
                          style: TextStyle(
                            fontSize: 25.sp,
                          ),
                        ),
                ],
              ),
            ),
          ),
          //details container
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 66.0.w),
            child: Container(
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12.w),
                // border: Border.all(
                //   color: textColor,
                // ),
              ),
              child: Column(
                children: [
                  //name and date
                  Padding(
                    padding: EdgeInsets.only(right: 20.0.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 1000.w,
                          child: MyTextField(
                            isEditing: true,
                            hintText: 'Enter Name',
                            invoiceData: false,
                            textEditingController: nameController,
                            border: false,
                            hintFontSize: 25.sp,
                            fontSize: 28.sp,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        AutoSizeText(
                          "${DateFormat("MMMM d, y").format(DateTime.now())}",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 1300.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: primaryAccent,
                                  ),
                                  Container(
                                    width: 250.w,
                                    child: MyTextField(
                                      isEditing: true,
                                      hintText: 'Phone No. ',
                                      invoiceData: false,
                                      textEditingController: phoneController,
                                      border: false,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.car_repair,
                                  ),
                                  SizedBox(
                                    width: 250.w,
                                    child: MyTextField(
                                      isEditing: true,
                                      hintText: 'Vehicle No. ',
                                      invoiceData: false,
                                      textEditingController: vehicleController,
                                      border: false,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.miscellaneous_services_rounded,
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                    child: MyTextField(
                                      hintText: 'Make',
                                      isEditing: true,
                                      textAlign: TextAlign.start,
                                      invoiceData: false,
                                      textEditingController: makeController,
                                      border: false,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                    child: MyTextField(
                                      isEditing: true,
                                      invoiceData: false,
                                      hintText: 'Model ',
                                      textEditingController: modelController,
                                      border: false,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0.w),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.gas_meter_outlined,
                                  ),
                                  SizedBox(
                                    width: 250.w,
                                    child: MyTextField(
                                      invoiceData: false,
                                      isEditing: true,
                                      textAlign: TextAlign.start,
                                      hintText: 'km',
                                      textEditingController:
                                          kilometerController,
                                      border: false,
                                      onSubmitted: (p0) {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 66.0.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //invoice table
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isEditing ? 1000.w : 850.w,
                      decoration: BoxDecoration(
                        color: containerColor,
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
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 50.h,
                                  // color: altColumn2,
                                  width: 400.w,
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
                                  width: 150.w,
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
                                  width: 150.w,
                                  child: AutoSizeText(
                                    "Cost",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                    ),
                                  ),
                                ),
                                isEditing
                                    ? Container(
                                        // color: altColumn2,
                                        height: 50.h,
                                        width: 170.w,
                                        child: AutoSizeText(
                                          "Purchase",
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 22.sp,
                                          ),
                                        ),
                                      )
                                    : Center(),
                              ],
                            ),
                            //details row ykwim
                            FocusScope(
                              node: _localScopeNode,
                              child: RawKeyboardListener(
                                focusNode: _focusNode,
                                onKey: (RawKeyEvent event) {
                                  // if (event is RawKeyDownEvent &&
                                  //     event.logicalKey ==
                                  //         LogicalKeyboardKey.enter) {
                                  // _localScopeNode
                                  //     .nextFocus(); // Moves focus only within this scope
                                  // }
                                },
                                child: StreamBuilder<
                                    List<List<TextEditingController>>>(
                                  stream: _controller.stream,
                                  initialData: detailsTableControllers,
                                  builder: (context, snapshot) {
                                    controllers = snapshot.data ?? [];
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: detailsTableControllers.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 70.w,
                                                  height: 50.h,
                                                  child: AutoSizeText(
                                                    textAlign: TextAlign.center,
                                                    "${index + 1}",
                                                    style: TextStyle(
                                                      fontSize: 22.sp,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: 50.h,
                                                  // color: altColumn2,
                                                  width: 400.w,
                                                  child: MyTextField(
                                                    textAlign: TextAlign.start,
                                                    invoiceData: false,
                                                    hintText: '',
                                                    textEditingController:
                                                        detailsTableControllers[
                                                            index][0],
                                                    border: false,
                                                    isEditing: true,
                                                    focusNode: index ==
                                                            detailsTableControllers
                                                                    .length -
                                                                1
                                                        ? _newRowFocusNode
                                                        : null,
                                                  ),
                                                ),
                                                Container(
                                                  height: 50.h,
                                                  // color: altColumn1,
                                                  width: 160.w,
                                                  child: MyTextField(
                                                    isEditing: true,
                                                    textAlign: TextAlign.end,
                                                    invoiceData: false,
                                                    hintText: '',
                                                    textEditingController:
                                                        detailsTableControllers[
                                                            index][1],
                                                    border: false,
                                                  ),
                                                ),
                                                Container(
                                                  // color: altColumn2,
                                                  width: 160.w,
                                                  height: 50.h,
                                                  child: MyTextField(
                                                    isEditing: true,
                                                    textAlign: TextAlign.end,
                                                    invoiceData: false,
                                                    hintText: '',
                                                    textEditingController:
                                                        detailsTableControllers[
                                                            index][2],
                                                    border: false,
                                                    onChanged: (p0) {
                                                      updateCalculations();
                                                    },
                                                    onSubmitted: (p0) {
                                                      if (index ==
                                                          detailsTableControllers
                                                                  .length -
                                                              1) {
                                                        _newRowFocusNode =
                                                            FocusNode();
                                                        addNewJob();
                                                        Future.delayed(
                                                            Duration.zero, () {
                                                          if (_newRowFocusNode !=
                                                              null) {
                                                            _newRowFocusNode!
                                                                .requestFocus();
                                                          }
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                                isEditing
                                                    ? Container(
                                                        // color: altColumn2,
                                                        width: 170.w,
                                                        height: 50.h,
                                                        child: MyTextField(
                                                          isEditing: true,
                                                          textAlign:
                                                              TextAlign.end,
                                                          invoiceData: false,
                                                          hintText: '',
                                                          textEditingController:
                                                              detailsTableControllers[
                                                                  index][3],
                                                          border: false,
                                                          onChanged: (p0) {
                                                            updateCalculations();
                                                          },
                                                        ),
                                                      )
                                                    : Center(),
                                              ],
                                            ),
                                            Divider(
                                              color: secondaryTextColor,
                                              thickness: 0.1,
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            // add remove buttons
                            Column(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                        color:
                                                            secondaryTextColor,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                        color:
                                                            secondaryTextColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20.w),

                                          //edit job button
                                          GestureDetector(
                                            onTap: () {
                                              TextEditingController controller =
                                                  TextEditingController();
                                              isEditing == false
                                                  ? {
                                                      showDialog(
                                                        barrierDismissible:
                                                            true,
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Container(
                                                              height: 50.h,
                                                              width: 200.w,
                                                              child: AutoSizeText(
                                                                  "Enter Password"),
                                                            ),
                                                            content: TextField(
                                                              controller:
                                                                  controller,
                                                              onSubmitted:
                                                                  (value) {
                                                                if (controller
                                                                        .text ==
                                                                    '1234') {
                                                                  setState(() {
                                                                    isEditing =
                                                                        true;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                } else {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                }
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    }
                                                  : setState(() {
                                                      isEditing = false;
                                                    });
                                            },
                                            child: SizedBox(
                                              height: 50.h,
                                              width: 150.w,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isEditing
                                                        ? Icons.done
                                                        : Icons.edit,
                                                    color: secondaryTextColor,
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  AutoSizeText(
                                                    isEditing ? "Done" : "Edit",
                                                    style: TextStyle(
                                                        color:
                                                            secondaryTextColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      isEditing
                                          ? AutoSizeText(
                                              "Gross Profit: Rs $profit",
                                              style: TextStyle(fontSize: 22.sp),
                                            )
                                          : Center(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),
                    //generate invoice button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            //put data to firebase

                            try {
                              addToFirebase(
                                detailsTableControllers,
                                total,
                                payable,
                                balance,
                                nameController.text.toLowerCase(),
                                phoneController.text.toLowerCase(),
                                vehicleController.text.toLowerCase(),
                                makeController.text.toLowerCase(),
                                modelController.text.toLowerCase(),
                                kilometerController.text.toLowerCase(),
                                invoice as int,
                                int.tryParse(discountController.text) ?? 0,
                                int.tryParse(paidController.text) ?? 0,
                                profit,
                              );
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
                                    color: textColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 20.w),
                //total and shi
                Column(
                  children: [
                    SizedBox(height: 50.h),
                    Row(
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
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
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
                              // alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: AutoSizeText(
                                NumberFormat.currency(
                                        locale: 'en_PK',
                                        symbol: 'Rs ',
                                        decimalDigits: 0)
                                    .format(total as num),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  color: textColor,
                                ),
                              ),
                            ),
                            // discount row
                            Container(
                              width: 180.w,
                              height: 50.h,
                              // alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: MyTextField(
                                isEditing: true,
                                textAlign: TextAlign.end,
                                invoiceData: true,
                                hintText: '0',
                                hintFontSize: 22.sp,
                                textEditingController: discountController,
                                border: false,
                                onChanged: (p1) {
                                  updateCalculations();
                                },
                              ),
                            ),
                            // payable row
                            Container(
                              height: 50.h,
                              width: 150.w,
                              // alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: AutoSizeText(
                                NumberFormat.currency(
                                        locale: 'en_PK',
                                        symbol: 'Rs ',
                                        decimalDigits: 0)
                                    .format(payable),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  color: textColor,
                                ),
                              ),
                            ),
                            // paid row
                            Container(
                              height: 50.h,
                              width: 180.w,
                              // alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: MyTextField(
                                isEditing: true,
                                textAlign: TextAlign.end,
                                hintText: '0',
                                hintFontSize: 22.sp,
                                invoiceData: true,
                                textEditingController: paidController,
                                border: false,
                                onChanged: (p2) {
                                  updateCalculations();
                                },
                              ),
                            ),
                            // balance row
                            Container(
                              height: 50.h,
                              width: 150.w,
                              // alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: AutoSizeText(
                                NumberFormat.currency(
                                        locale: 'en_PK',
                                        symbol: 'Rs ',
                                        decimalDigits: 0)
                                    .format(balance),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
