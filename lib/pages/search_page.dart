// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:pos/main.dart';
// import 'package:pos/methods/firestore_meth.dart';
// import 'package:pos/pages/invoice_page.dart';
// import 'package:pos/widgets/textfield.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   QuerySnapshot<Map<String, dynamic>>? matchedDocs;
//   DocumentSnapshot<Map<String, dynamic>>? invoiceSearch; //search  by invoice
//   bool search = false;
//   String? _selectedFilter;
//   TextEditingController searchController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(),
//       body: Column(
//         children: [
//           SizedBox(height: 50.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: 500.w,
//                 child: MyTextField(
//                   textAlign: TextAlign.start,
//                   hintText: 'Search client',
//                   textEditingController: searchController,
//                   border: true,
//                   invoiceData: false,
//                 ),
//               ),
//               // ),
//               SizedBox(width: 20.w),
//               DropdownButton<String>(
//                 value: _selectedFilter,
//                 hint: AutoSizeText("  select filter"),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedFilter = newValue;
//                   });
//                 },
//                 items: <String>[
//                   'invoice',
//                   'phone number',
//                   'vehicle number',
//                   'vehicle'
//                 ].map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               SizedBox(width: 20.w),
//               IconButton(
//                 onPressed: () async {
//                   if (_selectedFilter == 'invoice') {
//                     invoiceSearch = await instance
//                         .collection('invoices')
//                         .doc(searchController.text.toLowerCase())
//                         .get();
//                     setState(() {
//                       search = true;
//                     });
//                   } else {
//                     matchedDocs = await instance
//                         .collection('invoices')
//                         .where(_selectedFilter as String,
//                             isEqualTo: searchController.text.toLowerCase())
//                         .get();
//                     setState(() {
//                       search = true;
//                     });
//                   }
//                 },
//                 icon: Icon(Icons.search),
//               ),
//             ],
//           ),
//           SizedBox(width: 20.w),
//           !search
//               ? Center()
//               : Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 300.0.sp),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: _selectedFilter != "invoice"
//                           ? matchedDocs!.docs.map((doc) {
//                               return ListTile(
//                                 title: AutoSizeText("Invoice: ${doc.id}"),
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(builder: (context) {
//                                       return InvoicePage(
//                                         invoice: int.tryParse(doc.id) as int,
//                                       );
//                                     }),
//                                   );
//                                   setState(() {
//                                     search = false;
//                                   });
//                                 },
//                               );
//                             }).toList()
//                           : [
//                               ListTile(
//                                 title: AutoSizeText(
//                                     "Invoice: ${invoiceSearch!.id}"),
//                                 onTap: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(builder: (context) {
//                                       return InvoicePage(
//                                         invoice: int.tryParse(invoiceSearch!.id)
//                                             as int,
//                                       );
//                                     }),
//                                   );

//                                   setState(() {
//                                     search = false;
//                                   });
//                                 },
//                               )
//                             ]),
//                 )
//         ],
//       ),
//     );
//   }
// }
