// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pos/main.dart';
import 'package:pos/methods/firestore_meth.dart';
import 'package:pos/methods/printing.dart';
import 'package:pos/widgets/button.dart';
import 'package:pos/widgets/textfield.dart';

class InvoicePage extends StatefulWidget {
  final String invoice;
  const InvoicePage({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool isEditing = false;
  int total = 0;
  int profit = 0;
  late int balance = total;
  int? payable;
  DateTime? date;

  List<List<TextEditingController>> detailsTableControllers = [[]];
  Map<String, dynamic>? invoiceData = {};
  TextEditingController discountController = TextEditingController();
  TextEditingController paidController = TextEditingController();

  final StreamController<List<List<TextEditingController>>> _controller =
      StreamController.broadcast();

  var controllers;

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

  Future<void> _loadData() async {
    try {
      DocumentSnapshot docSnap = await instance
          .collection('invoices')
          .doc(widget.invoice.toString())
          .get();

      if (!docSnap.exists) {
        setState(() {
          invoiceData = {};
        });
        return;
      }

      Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
      if (data == null) {
        setState(() {
          invoiceData = {};
        });
        return;
      }

      // clear previous controllers to avoid duplicates on reload
      detailsTableControllers.clear();

      if (data['details'] != null) {
        Map<String, dynamic> detailsMap =
            data['details'] as Map<String, dynamic>;
        for (var entry in detailsMap.entries) {
          var i = entry.value as Map<String, dynamic>;
          detailsTableControllers.add([
            TextEditingController(text: i['Description']?.toString() ?? ''),
            TextEditingController(text: i['Quantity']?.toString() ?? ''),
            TextEditingController(text: i['Cost']?.toString() ?? ''),
            TextEditingController(text: i['Purchase']?.toString() ?? ''),
          ]);
        }
      }

      // set minimum 4 rows
      if (detailsTableControllers.length < 4) {
        int count = detailsTableControllers.length;
        while (count != 4) {
          detailsTableControllers.add([
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
            TextEditingController(),
          ]);
          count += 1;
        }
      }

      setState(() {
        invoiceData = data;

        total = data['total'] ?? 0;
        balance = data['balance'] ?? 0;
        payable = data['payable'] ?? 0;
        profit = data['profit'] ?? 0;

        discountController = TextEditingController(
          text: data['discount']?.toString() ?? '',
        );
        paidController = TextEditingController(
          text: data['paid']?.toString() ?? '',
        );
        Timestamp ts = invoiceData!['date'];
        date = ts.toDate();
      });
      print(invoiceData!['date']);
    } catch (e) {
      print('Error loading invoice data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  final FocusScopeNode _localScopeNode = FocusScopeNode();
  final FocusNode _focusNode = FocusNode();
  FocusNode? _newRowFocusNode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                    "LR AUTOS ",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 50.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  widget.invoice == null
                      ? AutoSizeText("Loading ...")
                      : AutoSizeText(
                          "Invoice: ${widget.invoice.padLeft(6, '0')} ",
                          style: TextStyle(
                            fontSize: 25.sp,
                          ),
                        ),
                ],
              ),
            ),
          ),
          //client details container
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
                            hintText: invoiceData!['owner'] ?? '',
                            invoiceData: false,
                            border: false,
                            isEditing: isEditing,
                            hintFontSize: 25.sp,
                            fontSize: 28.sp,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        AutoSizeText(
                          date == null
                              ? "loading..."
                              : DateFormat("MMMM d, y")
                                  .format(date as DateTime),
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
                                      hintText:
                                          invoiceData!['phone number'] ?? '',
                                      invoiceData: false,
                                      border: false,
                                      isEditing: isEditing,
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
                                      hintText:
                                          invoiceData?['vehicle number'] ?? '',
                                      invoiceData: false,
                                      border: false,
                                      isEditing: isEditing,
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
                                      hintText: invoiceData?['make'] ?? '',
                                      textAlign: TextAlign.start,
                                      invoiceData: false,
                                      border: false,
                                      isEditing: isEditing,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                    child: MyTextField(
                                      invoiceData: false,
                                      isEditing: isEditing,
                                      hintText: invoiceData?['model'] ?? '',
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
                                      isEditing: isEditing,
                                      textAlign: TextAlign.start,
                                      hintText: invoiceData?['kilometer'] ?? '',
                                      border: false,
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
                        child: Container(
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
                                      // color: altColumn2,
                                      height: 50.h,
                                      width: 142.w,
                                      child: AutoSizeText(
                                        "Price",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 50.h,
                                      // color: altColumn1,
                                      width: 162.w,
                                      child: AutoSizeText(
                                        "Quantity",
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
                                StreamBuilder<
                                    List<List<TextEditingController>>>(
                                  stream: _controller.stream,
                                  initialData: detailsTableControllers,
                                  builder: (context, snapshot) {
                                    controllers = snapshot.data ?? [];
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: detailsTableControllers.length,
                                      itemBuilder: (context, index) {
                                        return detailsTableControllers.isEmpty
                                            ? Center(
                                                child: SizedBox(
                                                  width: 100.sp,
                                                  child: AutoSizeText(
                                                      "Loading..."),
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        width: 70.w,
                                                        height: 50.h,
                                                        child: AutoSizeText(
                                                          textAlign:
                                                              TextAlign.center,
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
                                                          textAlign:
                                                              TextAlign.start,
                                                          isEditing: isEditing,
                                                          invoiceData: false,
                                                          hintText: '',
                                                          textEditingController:
                                                              detailsTableControllers[
                                                                  index][0],
                                                          border: false,
                                                          focusNode: index ==
                                                                  detailsTableControllers
                                                                          .length -
                                                                      1
                                                              ? _newRowFocusNode
                                                              : null,
                                                        ),
                                                      ),
                                                      Container(
                                                        // color: altColumn2,
                                                        width: 160.w,
                                                        height: 50.h,
                                                        child: MyTextField(
                                                          isEditing: isEditing,
                                                          textAlign:
                                                              TextAlign.end,
                                                          invoiceData: false,
                                                          hintText: '',
                                                          textEditingController:
                                                              detailsTableControllers[
                                                                  index][2],
                                                          border: false,
                                                          onChanged: (p0) {
                                                            updateCalculations();
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 50.h,
                                                        // color: altColumn1,
                                                        width: 160.w,
                                                        child: MyTextField(
                                                          isEditing: isEditing,
                                                          textAlign:
                                                              TextAlign.end,
                                                          invoiceData: false,
                                                          hintText: '',
                                                          textEditingController:
                                                              detailsTableControllers[
                                                                  index][1],
                                                          border: false,
                                                          onSubmitted: (p0) {
                                                            if (index ==
                                                                detailsTableControllers
                                                                        .length -
                                                                    1) {
                                                              _newRowFocusNode =
                                                                  FocusNode();
                                                              addNewJob();
                                                              Future.delayed(
                                                                  Duration.zero,
                                                                  () {
                                                                if (_newRowFocusNode !=
                                                                    null) {
                                                                  _newRowFocusNode!
                                                                      .requestFocus();
                                                                }
                                                              });
                                                            }
                                                          },
                                                          onChanged: (p0) {
                                                            int cost = 0;
                                                            int qty = 1;
                                                            if (p0.isEmpty) {
                                                              cost = 1;
                                                            } else {
                                                              qty = int.tryParse(removeNonAlphanumeric(
                                                                      detailsTableControllers[index]
                                                                              [
                                                                              1]
                                                                          .text)) ??
                                                                  1 as int;
                                                              cost = int.tryParse(
                                                                  removeNonAlphanumeric(
                                                                      detailsTableControllers[index]
                                                                              [
                                                                              2]
                                                                          .text)) as int;
                                                            }
                                                            setState(() {
                                                              detailsTableControllers[
                                                                      index][2]
                                                                  .text = (qty *
                                                                      cost)
                                                                  .toString();
                                                            });
                                                            updateCalculations();
                                                          },
                                                        ),
                                                      ),
                                                      isEditing
                                                          ? Container(
                                                              // color: altColumn2,
                                                              width: 170.w,
                                                              height: 50.h,
                                                              child:
                                                                  MyTextField(
                                                                isEditing:
                                                                    isEditing,
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                invoiceData:
                                                                    false,
                                                                hintText: '',
                                                                textEditingController:
                                                                    detailsTableControllers[
                                                                        index][3],
                                                                border: false,
                                                                onSubmitted:
                                                                    (p0) {
                                                                  if (index ==
                                                                      detailsTableControllers
                                                                              .length -
                                                                          1) {
                                                                    _newRowFocusNode =
                                                                        FocusNode();
                                                                    addNewJob();
                                                                    Future.delayed(
                                                                        Duration
                                                                            .zero,
                                                                        () {
                                                                      if (_newRowFocusNode !=
                                                                          null) {
                                                                        _newRowFocusNode!
                                                                            .requestFocus();
                                                                      }
                                                                    });
                                                                  }
                                                                },
                                                                onChanged:
                                                                    (p0) {
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
                                // add remove buttons
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              //add new job button
                                              InkWell(
                                                onTap: isEditing
                                                    ? addNewJob
                                                    : () {},
                                                child: SizedBox(
                                                  height: 50.h,
                                                  width: 150.w,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.add_circle,
                                                        color:
                                                            secondaryTextColor,
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      AutoSizeText(
                                                        "Add Item",
                                                        style: TextStyle(
                                                            color:
                                                                secondaryTextColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 20.w),

                                              //remove last job button
                                              InkWell(
                                                onTap: isEditing
                                                    ? () {
                                                        removeLastJob();
                                                        updateCalculations();
                                                      }
                                                    : () {},
                                                child: SizedBox(
                                                  height: 50.h,
                                                  width: 150.w,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.remove_circle,
                                                        color:
                                                            secondaryTextColor,
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      AutoSizeText(
                                                        "Remove Item",
                                                        style: TextStyle(
                                                            color:
                                                                secondaryTextColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 20.w),

                                              //edit job button
                                              InkWell(
                                                onTap: () {
                                                  TextEditingController
                                                      controller =
                                                      TextEditingController();
                                                  isEditing == false
                                                      ? {
                                                          showDialog(
                                                            barrierDismissible:
                                                                true,
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title:
                                                                    Container(
                                                                  height: 50.h,
                                                                  width: 200.w,
                                                                  child: AutoSizeText(
                                                                      "Enter Password"),
                                                                ),
                                                                content:
                                                                    TextField(
                                                                  controller:
                                                                      controller,
                                                                  onSubmitted:
                                                                      (value) {
                                                                    if (controller
                                                                            .text ==
                                                                        '1234') {
                                                                      setState(
                                                                          () {
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
                                                        color:
                                                            secondaryTextColor,
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      AutoSizeText(
                                                        isEditing
                                                            ? "Done"
                                                            : "Edit",
                                                        style: TextStyle(
                                                            color:
                                                                secondaryTextColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                  style: TextStyle(
                                                      fontSize: 22.sp),
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
                      ),
                    ),

                    SizedBox(height: 30.h),
                    //update invoice button
                    Row(
                      children: [
                        MyButton(
                          onTap: () {
                            //put data to firebase

                            try {
                              updateInvoice(
                                detailsTableControllers,
                                total,
                                payable as int,
                                balance,
                                invoiceData!['owner'].toString(),
                                invoiceData!['phone number'].toString(),
                                invoiceData!['vehicle number']
                                    .toString()
                                    .toUpperCase(),
                                invoiceData!['make'].toString(),
                                invoiceData!['model'].toString(),
                                invoiceData!['kilometer'].toString(),
                                invoiceData!['invoice'],
                                int.tryParse(discountController.text) ?? 0,
                                int.tryParse(paidController.text) ?? 0,
                                profit,
                              );
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                          containerColor: primaryAccent,
                          textColor: textColor,
                          buttonText: "Update Invoice",
                          border: false,
                        ),
                        SizedBox(width: 20.w),

                        //PRINT ALL DATA
                        MyButton(
                          onTap: () {
                            createPdf(
                              invoiceData!['owner'].toString(),
                              invoiceData!['phone number'].toString(),
                              invoiceData!['vehicle number']
                                  .toString()
                                  .toUpperCase(),
                              invoiceData!['model'].toString(),
                              discountController.text,
                              paidController.text,
                              invoiceData!['invoice']
                                  .toString()
                                  .padLeft(6, '0'),
                              total.toString(),
                              payable.toString(),
                              balance.toString(),
                              detailsTableControllers,
                            );
                          },
                          containerColor: Colors.transparent,
                          textColor: textColor,
                          buttonText: "Print",
                          border: true,
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
                                isEditing: isEditing,
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
                                    .format(payable ?? 0),
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
                                isEditing: isEditing,
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
