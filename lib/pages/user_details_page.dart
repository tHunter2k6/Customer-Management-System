import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/main.dart';
import 'package:pos/methods/firestore_meth.dart';
import 'package:pos/pages/invoice_page.dart';

class UserDetailsPage extends StatefulWidget {
  final String clientName;
  const UserDetailsPage({super.key, required this.clientName});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  Map<String, dynamic> userDetails = {};
  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> allInvoices =
      {};
  Map<String, dynamic> remainingBalance = {};
  List<bool> listInvoices = [false];

  getAllData() async {
    var temp1 = await getUserDetails(widget.clientName);
    var temp2 = await getUserInvoices(temp1, widget.clientName);
    var temp3 = await getRemainingOwed(widget.clientName);

    int count = 1;
    setState(() {
      remainingBalance = {};

      userDetails = temp1;
      allInvoices = temp2;
      remainingBalance = temp3;
      while (count != allInvoices.length) {
        listInvoices.add(false);
        count += 1;
      }
    });
  }

  @override
  initState() {
    super.initState();
    getAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 66.0.w),
        child: ListView(
          children: [
            //name and phone number
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        color: secondaryTextColor,
                        size: 80.w,
                      ),
                      AutoSizeText(
                        widget.clientName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 50.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: secondaryTextColor,
                        size: 40.w,
                      ),
                      AutoSizeText(
                        userDetails['phone_number'] == null
                            ? " loading..."
                            : " ${userDetails['phone_number']}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: secondaryTextColor,
            ),
            SizedBox(height: 50.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.0.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 500.w,
                    child: Column(
                      children: [
                        //Vehicles heading
                        Row(
                          children: [
                            Icon(
                              Icons.car_repair,
                              size: 50.w,
                              color: primaryAccent,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            AutoSizeText(
                              "Vehicles ",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 30.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        //Details
                        Padding(
                          padding: EdgeInsets.only(left: 60.0.w),
                          child: ListView.builder(
                            itemCount: allInvoices.length ?? 1,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              List vehicleNames = [];
                              for (var i in userDetails.keys) {
                                if (i != 'phone_number') {
                                  vehicleNames.add(i);
                                }
                              }
                              //All vehicles Details
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    "${index + 1}. ${userDetails[vehicleNames[index]]['model']}",
                                    style: TextStyle(
                                      fontSize: 32.sp,
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      AutoSizeText(
                                        "Make: ",
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 22.sp,
                                        ),
                                      ),
                                      AutoSizeText(
                                        "${userDetails[vehicleNames[index]]['make']}",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 22.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      AutoSizeText(
                                        "Registration number: ",
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 22.sp,
                                        ),
                                      ),
                                      AutoSizeText(
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 22.sp,
                                          ),
                                          "${userDetails[vehicleNames[index]]['vehicle_number']}"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          AutoSizeText(
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 22.sp,
                                              ),
                                              "Invoice(s): "),
                                          AutoSizeText(
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 22.sp,
                                              ),
                                              "${allInvoices[userDetails[vehicleNames[index]]['model']]?.length}"),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            listInvoices[index] =
                                                !listInvoices[index];
                                          });
                                        },
                                        child: listInvoices[index]
                                            ? Icon(
                                                Icons.expand_less,
                                                color: primaryAccent,
                                              )
                                            : Icon(
                                                Icons.expand_more,
                                                color: primaryAccent,
                                              ),
                                      ),
                                    ],
                                  ), //length of all invoices for that vehicle okay
                                  listInvoices[index]
                                      //show all invoices?
                                      ? ListView.builder(
                                          itemCount: allInvoices[userDetails[
                                                  vehicleNames[index]]['model']]
                                              ?.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index1) {
                                            List mewo =
                                                []; //saari invoice ki id stoooore
                                            allInvoices[userDetails[
                                                        vehicleNames[index]]
                                                    ['model']]
                                                ?.forEach((doc) {
                                              mewo.add(doc.id);
                                            });
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20.0.w),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return InvoicePage(
                                                        invoice: mewo[index1]
                                                            .toString());
                                                  }));
                                                },
                                                child: AutoSizeText(
                                                  "- ${mewo[index1].toString().padLeft(6, '0')}",
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 20.sp,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(),
                                  SizedBox(height: 20.h),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  //remaining balance
                  SizedBox(
                    width: 400.w,
                    child: Column(
                      children: [
                        //Vehicles heading
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              size: 50.w,
                              color: primaryAccent,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            AutoSizeText(
                              "Remaining Balance",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 30.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        //list of all
                        Padding(
                          padding: EdgeInsets.only(left: 60.0.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: remainingBalance.entries.map((entry) {
                              return Row(
                                children: [
                                  AutoSizeText(
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 20.sp,
                                      ),
                                      "Invoice ${entry.key.toString().padLeft(6, '0')}:"),
                                  AutoSizeText(
                                    ' Rs ${entry.value}/= ',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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
      ),
    );
  }
}
