// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

// import 'dart:async';

// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:pos/methods/firestore_meth.dart';

// class VehicleDetails extends StatefulWidget {
//   final String clientName;
//   final String vehicleName;
//   final FirebaseFirestore instance;
//   const VehicleDetails(
//       {super.key,
//       required this.clientName,
//       required this.vehicleName,
//       required this.instance});

//   @override
//   State<VehicleDetails> createState() => _VehicleDetailsState();
// }

// class _VehicleDetailsState extends State<VehicleDetails> {
// //
//   addNewField() {
//     setState(() {
//       textFieldControllers
//           .add([TextEditingController(), TextEditingController()]);
//     });
//     _controller.add(textFieldControllers);
//   }

//   final StreamController<List<List<TextEditingController>>> _controller =
//       StreamController.broadcast();
//   List<List<TextEditingController>> textFieldControllers = [];
//   var controllers;
//   //
//   @override
//   void initState() {
//     addNewField();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade800,
//       appBar: AppBar(
//         backgroundColor: Colors.grey.shade900,
//         centerTitle: true,
//         title: AutoSizeText(widget.clientName),
//       ),
//       body: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: ScreenUtil().setHeight(50)),
//             AutoSizeText(
//               "VEHICLE NAME: ${widget.vehicleName}",
//             ),
//             SizedBox(height: ScreenUtil().setHeight(30)),
//             GestureDetector(
//               onTap: () {
//                 showDialog(
//                   barrierDismissible: true,
//                   builder: (context) {
//                     return Dialog(
//                       backgroundColor: Colors.transparent,
//                       insetPadding: EdgeInsets.zero,
//                       child: Align(
//                         alignment: Alignment.center,
//                         child: Container(
//                           height: 600,
//                           width: 500,
//                           margin: EdgeInsets.only(top: 50), // Spacing from top
//                           padding: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[800],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Container(
//                                 height: 400,
//                                 width: 400,
//                                 child: StreamBuilder<
//                                         List<List<TextEditingController>>>(
//                                     stream: _controller.stream,
//                                     initialData: textFieldControllers,
//                                     builder: (context, snapshot) {
//                                       controllers = snapshot.data ?? [];

//                                       return ListView.builder(
//                                         itemCount: textFieldControllers.length,
//                                         itemBuilder: (context, index) {
//                                           return Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Container(
//                                                 width: 200,
//                                                 child: TextField(
//                                                   controller: controllers[index]
//                                                       [0],
//                                                   decoration: InputDecoration(
//                                                     hintText: "service name",
//                                                     hintStyle: TextStyle(
//                                                       color: Colors.grey,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               Container(
//                                                 width: 200,
//                                                 child: TextField(
//                                                   controller: controllers[index]
//                                                       [1],
//                                                   decoration: InputDecoration(
//                                                     hintText: "cost",
//                                                     hintStyle: TextStyle(
//                                                       color: Colors.grey,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       );
//                                     }),
//                               ),
//                               GestureDetector(
//                                 onTap: addNewField,
//                                 child: Container(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(20),
//                                     child: AutoSizeText("add"),
//                                   ),
//                                 ),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () async {
//                                       // await updateFirebase(
//                                       //   controllers,
//                                       //   widget.clientName,
//                                       //   widget.vehicleName,
//                                       //   widget.instance,
//                                       // );
//                                       textFieldControllers.clear();
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: Container(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(20),
//                                         child: AutoSizeText("save"),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: 10),
//                                   GestureDetector(
//                                     onTap: () => Navigator.pop(context),
//                                     child: Container(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(20),
//                                         child: AutoSizeText("back"),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   context: context,
//                 );
//               },
//               child: AutoSizeText(
//                 'A D D  N E W',
//               ),
//             ),
//             SizedBox(height: ScreenUtil().setHeight(20)),
//             Container(
//               child: AutoSizeText(
//                 'H I S T O R Y :',
//               ),
//             ),
//             SizedBox(height: 10),
//             StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('clients')
//                   .doc(widget.clientName)
//                   .collection(widget.vehicleName)
//                   .snapshots(),
//               builder: (context, snapshots) {
//                 if (snapshots.hasData) {
//                   return Center(
//                     child: Container(
//                       width: ScreenUtil().setWidth(600),
//                       color: Colors.red,
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: snapshots.data!.docs.length,
//                         itemBuilder: (context, index) {
//                           if (snapshots.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           } else {
//                             var orders = snapshots.data!.docs
//                                 .map((doc) => doc.id)
//                                 .toList();

//                             return ListTile(
//                               onTap: () async {
//                                 // final details = await getOrderInfo(
//                                 //   orders[index],
//                                 //   widget.clientName,
//                                 //   widget.vehicleName,
//                                 //   widget.instance,
//                                 // ) as Map<String, dynamic>?;

//                                 // if (details != null) {
//                                 //   showDialog(
//                                 //     barrierDismissible: true,
//                                 //     builder: (context) {
//                                 //       return Dialog(
//                                 //         backgroundColor: Colors.transparent,
//                                 //         insetPadding: EdgeInsets.zero,
//                                 //         child: Align(
//                                 //           alignment: Alignment.center,
//                                 //           child: Container(
//                                 //             height: 350,
//                                 //             width: 400,
//                                 //             margin: EdgeInsets.only(
//                                 //                 top: 50), // Spacing from top
//                                 //             padding: EdgeInsets.all(16),
//                                 //             decoration: BoxDecoration(
//                                 //               color: Colors.grey[800],
//                                 //               borderRadius:
//                                 //                   BorderRadius.circular(10),
//                                 //             ),
//                                 //             child: Column(
//                                 //               mainAxisAlignment:
//                                 //                   MainAxisAlignment
//                                 //                       .spaceBetween,
//                                 //               children: [
//                                 //                 Column(
//                                 //                   crossAxisAlignment:
//                                 //                       CrossAxisAlignment.start,
//                                 //                   children: details.entries
//                                 //                       .map((entry) {
//                                 //                     return Padding(
//                                 //                       padding: const EdgeInsets
//                                 //                           .symmetric(
//                                 //                           vertical: 4.0),
//                                 //                       child: AutoSizeText(
//                                 //                         '${entry.key}: Rs ${entry.value}/=',
//                                 //                         style: TextStyle(
//                                 //                             fontSize: 16),
//                                 //                       ),
//                                 //                     );
//                                 //                   }).toList(),
//                                 //                 ),
//                                 //                 GestureDetector(
//                                 //                   onTap: () =>
//                                 //                       Navigator.pop(context),
//                                 //                   child: Container(
//                                 //                     child: Padding(
//                                 //                       padding:
//                                 //                           const EdgeInsets.all(
//                                 //                               20),
//                                 //                       child:
//                                 //                           AutoSizeText("back"),
//                                 //                     ),
//                                 //                   ),
//                                 //                 )
//                                 //               ],
//                                 //             ),
//                                 //           ),
//                                 //         ),
//                                 //       );
//                                 //     },
//                                 //     context: context,
//                                 //   );
//                                 // } else {
//                                 //   print("error");
//                                 // }
//                               },
//                               titleAlignment: ListTileTitleAlignment.center,
//                               title: AutoSizeText(orders.isNotEmpty
//                                   ? orders[index]
//                                   : "NO PREIVOUS ORDERS FOR THIS VEHICLE"),
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                   );
//                 } else {
//                   return CircularProgressIndicator();
//                 }
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
