// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

//create and print pdf

void createPdf(
  String name,
  String phone,
  String vehicleNumber,
  String model,
  String discount,
  String paid,
  String invoice,
  String total,
  String payable,
  String balance,
  List<List<TextEditingController>> detailsTableControllers,
) async {
  final doc = pw.Document();

  final currencyFormatter = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'Rs ',
    decimalDigits: 0,
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(250, 600),
      margin: const pw.EdgeInsets.all(16),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'LR Autos',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Invoice #: $invoice'),
            pw.Text('Date: ${DateFormat('dd/MM/yy').format(DateTime.now())}'),
            pw.SizedBox(height: 4),
            pw.Text('Name: $name'),
            pw.Text('Phone: $phone'),
            pw.Text('Vehicle No.: $vehicleNumber'),
            pw.Text('Model: $model'),
            pw.SizedBox(height: 12),

            // Table
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: pw.FlexColumnWidth(3), // Description
                1: pw.FlexColumnWidth(1), // Qty
                2: pw.FlexColumnWidth(2), // Cost
              },
              children: [
                // Table header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Description',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Cost',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),

                // Table rows from controllers
                ...detailsTableControllers.map((row) {
                  final description = row[0].text;
                  final qty = row[1].text;
                  final cost = int.tryParse(row[2].text) ?? 0;

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(description),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(qty),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          currencyFormatter.format(cost),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Divider(),

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                        'Total: ${currencyFormatter.format(int.tryParse(total) ?? 0)}/='),
                    pw.Text(
                        'Discount: ${currencyFormatter.format(int.tryParse(discount) ?? 0)}/='),
                    pw.Text(
                        'Payable: ${currencyFormatter.format(int.tryParse(payable) ?? 0)}/='),
                    pw.Text(
                        'Paid: ${currencyFormatter.format(int.tryParse(paid) ?? 0)}/='),
                    pw.Text(
                        'Balance: ${currencyFormatter.format(int.tryParse(balance) ?? 0)}/='),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save());
}
