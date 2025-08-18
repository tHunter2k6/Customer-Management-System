// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/main.dart';
import 'package:pos/methods/firestore_meth.dart';
import 'package:pos/pages/new_Invoice.dart';
import 'package:pos/widgets/textfield.dart';

class InvoicePage extends StatefulWidget {
  final int invoice;
  const InvoicePage({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  int total = 0;
  late int balance = total;
  int? payable;

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
          ]);
        }
      }

      setState(() {
        invoiceData = data;

        total = data['total'] ?? 0;
        balance = data['balance'] ?? 0;
        payable = data['payable'] ?? 0;

        discountController = TextEditingController(
          text: data['discount']?.toString() ?? '',
        );
        paidController = TextEditingController(
          text: data['paid']?.toString() ?? '',
        );
      });
    } catch (e) {
      print('Error loading invoice data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText("Invoice Number: ${widget.invoice}"),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 500.w,
                child: MyTextField(
                  textAlign: TextAlign.start,
                  hintText: invoiceData!['owner'] ?? '',
                  invoiceData: true,
                  border: true,
                ),
              ),
              SizedBox(
                width: 500.w,
                child: MyTextField(
                  textAlign: TextAlign.start,
                  hintText: invoiceData!['phone number'] ?? '',
                  invoiceData: true,
                  border: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 500.w,
                child: MyTextField(
                  textAlign: TextAlign.start,
                  invoiceData: true,
                  hintText: invoiceData?['vehicle number'] ?? '',
                  border: true,
                ),
              ),
              SizedBox(
                width: 500.w,
                child: MyTextField(
                  invoiceData: true, textAlign: TextAlign.start,
                  hintText: invoiceData?['vehicle'] ??
                      '', //firestore mein vehicle ka naam hai
                  border: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 500.w,
                child: MyTextField(
                  invoiceData: true,
                  textAlign: TextAlign.start,
                  hintText: invoiceData?['model'] ?? '',
                  border: true,
                ),
              ),
              SizedBox(
                width: 500.w,
                child: MyTextField(
                  invoiceData: true,
                  textAlign: TextAlign.start,
                  hintText: invoiceData?['kilometer'] ?? '',
                  border: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0.w),
            child: Divider(),
          ),
          //title row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: altColumn1,
                width: 200.w,
                height: 50.h,
                child: Center(
                  child: AutoSizeText(
                    "S No.",
                    style: TextStyle(
                      fontSize: 22.sp,
                    ),
                  ),
                ),
              ),
              Container(
                height: 50.h,
                color: altColumn2,
                width: 600.w,
                child: Center(
                  child: AutoSizeText(
                    "Work Details",
                    style: TextStyle(
                      fontSize: 22.sp,
                    ),
                  ),
                ),
              ),
              Container(
                height: 50.h,
                color: altColumn1,
                width: 200.w,
                child: Center(
                  child: AutoSizeText(
                    "Qty",
                    style: TextStyle(
                      fontSize: 22.sp,
                    ),
                  ),
                ),
              ),
              Container(
                color: altColumn2,
                width: 300.w,
                height: 50.h,
                child: Center(
                  child: AutoSizeText(
                    "Amount",
                    style: TextStyle(
                      fontSize: 22.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              //table row ykwim

              StreamBuilder<List<List<TextEditingController>>>(
                stream: _controller.stream,
                initialData: detailsTableControllers,
                builder: (context, snapshot) {
                  controllers = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: detailsTableControllers.length,
                    itemBuilder: (context, index) {
                      return detailsTableControllers.length < 2
                          ? Center(
                              child: SizedBox(
                                width: 100.sp,
                                child: AutoSizeText("Loading..."),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  color: altColumn1,
                                  width: 200.w,
                                  height: 50.h,
                                  child: Center(
                                    child: AutoSizeText(
                                      "${index + 1}",
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 50.h,
                                  color: altColumn2,
                                  width: 600.w,
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
                                  color: altColumn1,
                                  width: 200.w,
                                  child: MyTextField(
                                    textAlign: TextAlign.start,
                                    hintText: '',
                                    textEditingController:
                                        detailsTableControllers[index][1],
                                    invoiceData: false,
                                    border: false,
                                  ),
                                ),
                                Container(
                                  color: altColumn2,
                                  width: 300.w,
                                  height: 50.h,
                                  child: MyTextField(
                                    textAlign: TextAlign.start,
                                    hintText: '',
                                    textEditingController:
                                        detailsTableControllers[index][2],
                                    invoiceData: false,
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
              Divider(),
              //total row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    width: 200.w,
                    height: 50.h,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 600.w,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 200.w,
                  ),
                  Container(
                    color: altColumn2,
                    width: 300.w,
                    height: 50.h,
                    child: AutoSizeText(
                      " Total: $total /=",
                      style: TextStyle(
                        fontSize: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
              //discount row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    width: 200.w,
                    height: 50.h,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 600.w,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 200.w,
                  ),
                  Container(
                    color: altColumn2,
                    width: 300.w,
                    height: 50.h,
                    child: MyTextField(
                      invoiceData: false,
                      textAlign: TextAlign.start,
                      hintText: 'Discount',
                      textEditingController: discountController,
                      border: false,
                      onChanged: (p1) {
                        updateCalculations();
                      },
                    ),
                  ),
                ],
              ),
              //payable row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    width: 200.w,
                    height: 50.h,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 600.w,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 200.w,
                  ),
                  Container(
                    height: 50.h,
                    color: altColumn2,
                    width: 300.w,
                    child: AutoSizeText(
                        style: TextStyle(
                          fontSize: 22.sp,
                        ),
                        " Payable: ${payable == null ? '' : payable}"),
                  ),
                ],
              ),
              //paid row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    width: 200.w,
                    height: 50.h,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 600.w,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 200.w,
                  ),
                  Container(
                    height: 50.h,
                    color: altColumn2,
                    width: 300.w,
                    child: Center(
                      child: MyTextField(
                        invoiceData: false,
                        textAlign: TextAlign.start,
                        hintText: 'Paid',
                        textEditingController: paidController,
                        border: false,
                        onChanged: (p2) {
                          updateCalculations();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              //balance row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.transparent,
                    width: 200.w,
                    height: 50.h,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 600.w,
                  ),
                  Container(
                    height: 50.h,
                    color: Colors.transparent,
                    width: 200.w,
                  ),
                  Container(
                    height: 50.h,
                    color: altColumn2,
                    width: 300.w,
                    child: AutoSizeText(
                        style: TextStyle(
                          fontSize: 22.sp,
                        ),
                        " Balance: ${balance == null ? '' : balance}"),
                  ),
                ],
              ),
              //add remove buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //remove last job button
                  GestureDetector(
                    onTap: () {
                      removeLastJob();
                      updateCalculations();
                    },
                    child: Container(
                      height: 50.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: Colors.purple[600],
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Center(
                        child: AutoSizeText(
                          "Remove Job",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 20.w),
                  //add new job button
                  GestureDetector(
                    onTap: addNewJob,
                    child: Container(
                      height: 50.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: Colors.purple[600],
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Center(
                        child: AutoSizeText(
                          "Add Job",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              //update invoice button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      //update data to firebase

                      try {
                        updateInvoice(
                            detailsTableControllers,
                            total,
                            payable as int,
                            balance,
                            invoiceData!['owner'].toString().toLowerCase(),
                            invoiceData!['phone number']
                                .toString()
                                .toLowerCase(),
                            invoiceData!['vehicle number']
                                .toString()
                                .toLowerCase(),
                            invoiceData!['vehicle'].toString().toLowerCase(),
                            invoiceData!['model'].toString().toLowerCase(),
                            invoiceData!['kilometer'].toString().toLowerCase(),
                            invoiceData!['invoice'] as int,
                            int.tryParse(discountController.text) ?? 0,
                            int.tryParse(paidController.text) ?? 0);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    child: Container(
                      height: 50.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple.shade600,
                        ),
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      child: Center(
                        child: AutoSizeText(
                          " Update Data ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade600,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
