import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

late FirebaseFirestore instance;

List<String> clientNames = [];

//run at startup and make instance

getAllClientNames() async {
  clientNames.clear();
  instance = FirebaseFirestore.instance;

  QuerySnapshot<Map<String, dynamic>> collection =
      await instance.collection('clients').get();
  //
  collection.docs.forEach((doc) {
    clientNames.add(
      doc.id,
    );
    //
    // Map<String, dynamic> docData = doc.data();
    // phoneNumbers.add(docData['phone_number']);
    // //
    // docData.entries.forEach((entry) {
    //   if (entry.key != 'phone_number') {
    //     var temp = entry.value;
    //     print(temp);
    //     regNumbers.add(temp['vehicle_number'].toString());
    //   }
    // });
  });
}

getRemainingOwed(String name) async {
  try {
    QuerySnapshot<Map<String, dynamic>> myDocs = await instance
        .collection('invoices')
        .where('owner', isEqualTo: name)
        .where(
          'balance',
          isGreaterThan: 0,
        )
        .get();

    Map<String, dynamic> allData = {};
    myDocs.docs.forEach((doc) {
      if (doc.data().isNotEmpty) {
        var docData = doc.data();
        allData[docData['invoice']] = docData['balance'];
      }
    });
    return allData;
  } catch (e) {
    print(e.toString());
  }
}

getUserDetails(String name) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await instance.collection('clients').doc(name).get();

    if (userDoc.exists) {
      Map<String, dynamic> userDetails = userDoc.data() as Map<String, dynamic>;
      return userDetails;
    } else {
      return {};
    }
  } catch (e) {
    return {};
  }
}

getUserInvoices(Map<String, dynamic> userDetails, String name //client name
    ) async {
  try {
    var tempList = userDetails.keys.toList();
    List vehicleNames = [];
    Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> allInvoices =
        {};
    for (var i in tempList) {
      if (i != 'phone_number') {
        vehicleNames.add(i); //add all car names
        QuerySnapshot<Map<String, dynamic>> vehicleCollection = await instance
            .collection('clients')
            .doc(name)
            .collection(i)
            .get(); //get vehicle collection
        List<QueryDocumentSnapshot<Map<String, dynamic>>>
            eachVehicleCollection =
            vehicleCollection.docs.toList(); //get all invoices for that vehicle

        allInvoices[i] = eachVehicleCollection;
      }
    }
    return allInvoices;
  } catch (e) {
    return [];
  }
}

searchData(String filter, String value) async {
  String searchVal = removeNonAlphanumeric(value);
  try {
    if (filter == 'client name') {
      //if searching client profile
      List matches = clientNames.where(
        (clientName) {
          String tempName = clientName.toString().toLowerCase().replaceAll(
                  RegExp(r'[^a-zA-Z0-9]'),
                  '') //remove spaces etc and make lower case
              ;
          String tempSearch = searchVal.toLowerCase().replaceAll(
              RegExp(r'[^a-zA-Z0-9]'),
              ''); //remove spaces etc and make lower case

          return tempName.contains(
            tempSearch,
          );
        },
      ) //check the searching value in list ykwim (clients ke naam)
          .toList();

      return matches;
    } else {
      //direct invoice uthaaaaoooooooo

      QuerySnapshot<Map<String, dynamic>> collection = await instance
          .collection('invoices')
          .where(
            filter,
            isEqualTo:
                searchVal.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase(),
          )
          .get();
      var matchingDocs = collection.docs;

      return matchingDocs;
    }
  } catch (e) {
    print(e.toString());
  }
}

//go to searched Invoice

getCurrentInvoice() async {
  try {
    DocumentSnapshot docSnap =
        await instance.collection('invoices').doc('invoice_count').get();

    Map<String, dynamic>? docData = docSnap.data() as Map<String, dynamic>?;

    if (docData == null || docData['current_invoice'] == null) {
      return null;
    }

    String invoiceNumber = docData['current_invoice'].toString();
    return invoiceNumber;
  } catch (e) {
    return e.toString();
  }
}

updateInvoiceCount() async {
  int currentInvoice = int.tryParse(await getCurrentInvoice()) as int;
  int newCount = currentInvoice + 1;
  try {
    await instance.collection('invoices').doc('invoice_count').update({
      'current_invoice': newCount.toString(),
    });
    return true;
  } catch (e) {
    return false;
  }
}

getInvoiceInfo(String invoice) async {
  try {
    DocumentSnapshot docSnap =
        await instance.collection('clients').doc(invoice).get();
    if (!docSnap.exists) {
      return null;
    }

    Map<String, dynamic>? docData = docSnap.data() as Map<String, dynamic>?;
    if (docData == null) {
      return null;
    }

    return docData;
  } catch (e) {
    return e.toString();
  }
}

String removeNonAlphanumeric(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
}

//add new invoice
addToFirebase(
  List<List<TextEditingController>> detailsTableControllers,
  int total,
  int payable,
  int balance,
  String nameController,
  String phoneController,
  String vehicleController,
  String makeController,
  String modelController,
  String kilometerController,
  String invoice,
  int discountController,
  int paidController,
  int profit,
) async {
  nameController = removeNonAlphanumeric(nameController);
  phoneController = phoneController.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  vehicleController = vehicleController
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
      .toUpperCase(); //make it caps
  makeController = removeNonAlphanumeric(makeController);
  modelController = removeNonAlphanumeric(modelController);
  kilometerController = removeNonAlphanumeric(kilometerController);

  Map<String, dynamic> detailsMap = {};
  int index = 1;
  for (List<TextEditingController> job in detailsTableControllers) {
    if (job[0].text != '') {
      detailsMap["Job $index"] = {
        'Description': job[0].text,
        'Quantity': int.tryParse(job[1].text) ?? 0,
        'Cost': int.tryParse(job[2].text) ?? 0,
        'Purchase': int.tryParse(job[3].text) ?? 0,
      };
      index += 1; //increment job count
    }
  }
  final date = DateTime.now();
  try {
    //add new invoice to invoice collection
    await instance.collection('invoices').doc(invoice.toString()).set({
      'details': detailsMap,
      'date': date,
      'invoice': invoice,
      'kilometer': kilometerController,
      'total': total,
      'discount': discountController,
      'payable': payable,
      'paid': paidController,
      'balance': balance,
      'owner': nameController,
      'model': modelController,
      'make': makeController,
      'vehicle number': vehicleController,
      'phone number': phoneController,
      'profit': profit,
    });

    updateInvoiceCount();

    //add invoice under respective client data

    if (clientNames.contains(nameController)) //check if already a client
    {
      var sth = await instance
          .collection('clients')
          .doc(nameController)
          .collection(modelController)
          .limit(1)
          .get();
      if (sth.docs.isNotEmpty) //check if new car

      {
        await instance
            .collection('clients')
            .doc(nameController)
            .collection(modelController)
            .doc(invoice.toString())
            .set({
          'details': detailsMap,
          'date': date,
          'invoice': invoice,
          'kilometer': kilometerController,
          'total': total,
          'discount': discountController,
          'payable': payable,
          'paid': paidController,
          'profit': profit,
          'balance': balance,
        });
      } else
      //if new car then add car details under client
      {
        await instance.collection('clients').doc(nameController).update({
          modelController: {
            //car name as key
            'model': modelController,
            'make': makeController,
            'vehicle_number': vehicleController,
          }
        });
        //add new invoice
        await instance
            .collection('clients')
            .doc(nameController)
            .collection(modelController) //car name
            .doc(invoice.toString())
            .set({
          'details': detailsMap,
          'date': date,
          'invoice': invoice,
          'kilometer': kilometerController,
          'total': total,
          'discount': discountController,
          'payable': payable,
          'paid': paidController,
          'profit': profit,
          'balance': balance,
        });
      }
    } else {
      //locally add NEW client name to local list ykwim
      clientNames.add(nameController);
      // make NEW document of client and add car details
      await instance.collection('clients').doc(nameController).set({
        modelController: {
          'model': modelController,
          'make': makeController,
          'vehicle_number': vehicleController,
        },
        'phone_number': phoneController,
      });
      //make invoice
      await instance
          .collection('clients')
          .doc(nameController)
          .collection(modelController)
          .doc(invoice.toString())
          .set({
        'details': detailsMap,
        'date': date,
        'invoice': invoice,
        'kilometer': kilometerController,
        'total': total,
        'discount': discountController,
        'payable': payable,
        'paid': paidController,
        'profit': profit,
        'balance': balance,
      });
    }
  } catch (e) {
    print(e.toString());
  }
}

//update old invoice
updateInvoice(
  List<List<TextEditingController>> detailsTableControllers,
  int total,
  int payable,
  int balance,
  String nameController,
  String phoneController,
  String vehicleController,
  String makeController,
  String modelController,
  String kilometerController,
  String invoice,
  int discountController,
  int paidController,
  int profit,
) async {
  nameController = removeNonAlphanumeric(nameController);
  phoneController = removeNonAlphanumeric(phoneController);
  vehicleController = removeNonAlphanumeric(vehicleController);
  makeController = removeNonAlphanumeric(makeController);
  modelController = removeNonAlphanumeric(modelController);
  kilometerController = removeNonAlphanumeric(kilometerController);

  Map<String, dynamic> detailsMap = {};
  int index = 1;
  for (List<TextEditingController> job in detailsTableControllers) {
    if (job[0].text != '') {
      detailsMap["Job $index"] = {
        'Description': job[0].text,
        'Quantity': int.tryParse(job[1].text) ?? 0,
        'Cost': int.tryParse(job[2].text) ?? 0,
        'Purchase': int.tryParse(job[3].text) ?? 0,
      };
      index += 1; //increment job count
    }
  }
  final date = DateTime.now();
  try {
    //add new invoice to invoice collection
    await instance.collection('invoices').doc(invoice.toString()).update({
      'details': detailsMap,
      'date': date,
      'invoice': invoice,
      'kilometer': kilometerController,
      'total': total,
      'discount': discountController,
      'payable': payable,
      'paid': paidController,
      'balance': balance,
      'profit': profit,
      'owner': nameController,
      'model': modelController,
      'make': makeController,
      'vehicle number': vehicleController,
      'phone number': phoneController,
    });

    //update invoice under respective client data
    await instance
        .collection('clients')
        .doc(nameController)
        .collection(modelController)
        .doc(invoice.toString())
        .update({
      'details': detailsMap,
      'date': date,
      'invoice': invoice,
      'kilometer': kilometerController,
      'total': total,
      'discount': discountController,
      'payable': payable,
      'profit': profit,
      'paid': paidController,
      'balance': balance,
    });
  } catch (e) {
    print(e.toString());
  }
}
