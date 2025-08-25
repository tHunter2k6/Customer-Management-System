import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore instance = FirebaseFirestore.instance;

searchUser(String filter, String value) async {
  String searchVal = removeNonAlphanumeric(value.toLowerCase());
  try {
    var collection = await instance
        .collection('clients')
        .where(filter, isEqualTo: searchVal)
        .get();

    return collection.docs.length;
  } catch (e) {}
}

getCurrentInvoice() async {
  try {
    DocumentSnapshot docSnap =
        await instance.collection('invoices').doc('invoice_count').get();

    Map<String, dynamic>? docData = docSnap.data() as Map<String, dynamic>?;

    if (docData == null || docData['current_invoice'] == null) {
      return null;
    }

    return docData['current_invoice'] as int;
  } catch (e) {
    return e.toString();
  }
}

updateInvoiceCount() async {
  int currentInvoice = await getCurrentInvoice();
  try {
    await instance.collection('invoices').doc('invoice_count').update({
      'current_invoice': currentInvoice + 1,
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
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
}

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
  int invoice,
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
      'vehicle': makeController,
      'vehicle number': vehicleController,
      'phone number': phoneController,
      'profit': profit,
    });

    updateInvoiceCount();

    //add invoice under respective client data
    var newUser =
        await instance.collection('clients').doc(nameController).get();

    if (newUser.exists) //check if already a client
    {
      var sth = await instance
          .collection('clients')
          .doc(nameController)
          .collection(makeController)
          .limit(1)
          .get();
      if (sth.docs.isNotEmpty) //check if new car

      {
        await instance
            .collection('clients')
            .doc(nameController)
            .collection(makeController)
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
          makeController: {
            'model': modelController,
            'vehicle': makeController,
            'vehicle_number': vehicleController,
          }
        });
        //add new invoice
        await instance
            .collection('clients')
            .doc(nameController)
            .collection(makeController)
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
      // if new client then make new document and add car details
      await instance.collection('clients').doc(nameController).set({
        makeController: {
          'model': modelController,
          'vehicle': makeController,
          'vehicle_number': vehicleController,
        },
        'phone_number': phoneController,
      });
      //make invoice
      await instance
          .collection('clients')
          .doc(nameController)
          .collection(makeController)
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
  int invoice,
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
      'vehicle': makeController,
      'vehicle number': vehicleController,
      'phone number': phoneController,
    });

    //update invoice under respective client data
    await instance
        .collection('clients')
        .doc(nameController)
        .collection(makeController)
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
