// ignore_for_file: prefer_const_constructors

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos/main.dart';
import 'package:pos/methods/firestore_meth.dart';
import 'package:pos/pages/invoice_page.dart';
import 'package:pos/pages/new_Invoice.dart';
import 'package:pos/pages/user_details_page.dart';
import 'package:pos/widgets/button.dart';
import 'package:pos/widgets/textfield.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchController = TextEditingController();
  String? _selectedFilter;
  List searchDocs = [];
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    getAllClientNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        children: [
          SizedBox(
            height: 150.h,
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 49, 49, 49),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0.w),
                child: Column(
                  children: [
                    Center(
                      child: AutoSizeText(
                        "LR Autos",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 80.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 50.h),
                    //search field wala column
                    SizedBox(
                      child: isSearch
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    // SizedBox(height: 50.h),
                                    SizedBox(
                                      width: 500.w,
                                      child: MyTextField(
                                        textAlign: TextAlign.start,
                                        hintText: 'Search client',
                                        textEditingController: searchController,
                                        border: true,
                                        invoiceData: false,
                                        isEditing: true,
                                        suffixIcon: DropdownButton<String>(
                                          underline: SizedBox.shrink(),
                                          icon: Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.0.w),
                                            child: Icon(
                                              Icons.filter_alt_outlined,
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedFilter = newValue;
                                              if (_selectedFilter ==
                                                  "client name") {
                                                searchDocs.clear();
                                              }
                                            });
                                          },
                                          items: <String>[
                                            'client name',
                                            'invoice',
                                            'phone number',
                                            'vehicle number',
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: _selectedFilter == value
                                                  ? Row(
                                                      children: [
                                                        AutoSizeText(value),
                                                        SizedBox(width: 10),
                                                        Icon(Icons.check,
                                                            color:
                                                                primaryAccent),
                                                      ],
                                                    )
                                                  : AutoSizeText(value),
                                            );
                                          }).toList(),
                                        ),
                                        onSubmitted: (p0) async {
                                          try {
                                            var temp = await searchData(
                                                _selectedFilter as String, p0);
                                            setState(() {
                                              searchDocs.clear();
                                              searchDocs = temp;
                                            });
                                            print(searchDocs);
                                          } catch (e) {
                                            print(e.toString());
                                          }
                                        },
                                        onChanged: (p0) async {
                                          try {
                                            if (p0.isEmpty) {
                                              setState(() {
                                                searchDocs.clear();
                                              });
                                            } else {
                                              if (_selectedFilter ==
                                                  'client name') {
                                                var tempList = await searchData(
                                                    _selectedFilter as String,
                                                    p0);
                                                setState(() {
                                                  searchDocs.clear();
                                                  searchDocs = tempList;
                                                });
                                              }
                                            }
                                          } catch (e) {
                                            print(
                                              e.toString(),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.w),
                                SizedBox(
                                  child: ListView.builder(
                                    itemCount: searchDocs.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return _selectedFilter == 'client name'
                                          ? InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return UserDetailsPage(
                                                        clientName:
                                                            searchDocs[index]
                                                                .toString(),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10.0.w),
                                                    child: Container(
                                                      height: 60.h,
                                                      width: 500.w,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                secondaryTextColor,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.w)),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          searchDocs[index]
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 22.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 190.0.w),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: secondaryTextColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.w)),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          return InvoicePage(
                                                            invoice: searchDocs[
                                                                        index]
                                                                    .data()[
                                                                'invoice'],
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  textColor: textColor,
                                                  title: AutoSizeText(
                                                    '${searchDocs[index].data()['owner']}',
                                                    style: TextStyle(
                                                        fontSize: 22.sp),
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      AutoSizeText(
                                                        '${searchDocs[index].data()['phone number']}',
                                                        style: TextStyle(
                                                            fontSize: 20.sp),
                                                      ),
                                                      SizedBox(width: 20.w),
                                                      AutoSizeText(
                                                        '${searchDocs[index].data()['model']}',
                                                        style: TextStyle(
                                                            fontSize: 22.sp),
                                                      ),
                                                      AutoSizeText(
                                                        ' - ${searchDocs[index].data()['vehicle number']}',
                                                        style: TextStyle(
                                                            fontSize: 22.sp),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: AutoSizeText(
                                                    'Invoice: ${searchDocs[index].data()['invoice'].toString().padLeft(6, '0')}',
                                                    style: TextStyle(
                                                        fontSize: 20.sp),
                                                  ),
                                                ),
                                              ),
                                            );
                                    },
                                  ),
                                ),

                                SizedBox(height: 40.w),
                                //click to search
                                MyButton(
                                    onTap: () async {
                                      try {
                                        var temp = await searchData(
                                          _selectedFilter as String,
                                          searchController.text,
                                        );
                                        setState(() {
                                          searchDocs.clear();
                                          searchDocs = temp;
                                        });
                                        print(searchDocs);
                                      } catch (e) {
                                        print(e.toString());
                                      }
                                    },
                                    containerColor: primaryAccent,
                                    textColor: textColor,
                                    buttonText: "Search",
                                    border: false),
                                //
                                SizedBox(height: 40.w),
                                //back button
                                MyButton(
                                    onTap: () {
                                      setState(() {
                                        isSearch = !isSearch;
                                      });
                                    },
                                    containerColor: Colors.transparent,
                                    textColor: textColor,
                                    buttonText: 'Back',
                                    border: true),
                              ],
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  isSearch = !isSearch;
                                });
                              },
                              child: Container(
                                height: 70.h,
                                width: 350.w,
                                decoration: BoxDecoration(
                                  color: primaryAccent,
                                  borderRadius: BorderRadius.circular(10.w),
                                ),
                                child: Center(
                                  child: AutoSizeText(
                                    "Search ",
                                    style: TextStyle(
                                      fontSize: 25.sp,
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 50.h),
                    isSearch
                        ? Center()
                        :
                        // create new invoice button
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return NewInvoice();
                                  },
                                ),
                              );
                            },
                            child: Container(
                              height: 70.h,
                              width: 350.w,
                              decoration: BoxDecoration(
                                color: primaryAccent,
                                borderRadius: BorderRadius.circular(10.w),
                              ),
                              child: Center(
                                child: AutoSizeText(
                                  "Create Invoice ",
                                  style: TextStyle(
                                    fontSize: 25.sp,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
