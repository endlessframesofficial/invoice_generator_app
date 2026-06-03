import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/number_to_words.dart';
import '../../invoice/domain/invoice.dart';
import '../domain/pdf_service.dart';

part 'pdf_service_impl.g.dart';

@riverpod
PdfService pdfService(Ref ref) {
  return PdfServiceImpl();
}

class PdfServiceImpl implements PdfService {
  @override
  Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    // Load signature image from assets
    final signatureByteData = await rootBundle.load('assets/images/signature.jpg');
    final signatureBytes = signatureByteData.buffer.asUint8List();
    final signatureImage = pw.MemoryImage(signatureBytes);

    final dateFormat = DateFormat('dd-MM-yyyy');
    
    // Custom NumberFormat for Indian Rupees formatting (₹ 1,200.00)
    final indianRupeesFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs. ',
      decimalDigits: 2,
    );

    // Let's load a standard font if needed, or rely on pdf's built-in Helvetica.
    // Helvetica is built-in and safe to use.
    final baseFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: baseFont,
          bold: boldFont,
        ),
        build: (pw.Context context) {
          return [
            // 1. HEADER SECTION
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      AppConstants.companyName,
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 18,
                        color: PdfColor.fromHex('#000000'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      AppConstants.companyAddress,
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Phone no.: ${AppConstants.companyPhone}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Email: ${AppConstants.companyEmail}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
                // Logo box matching Cochin Cool Service logo look
                pw.Container(
                  width: 50,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#0D1B2A'),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.RichText(
                    textAlign: pw.TextAlign.center,
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'c',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                            color: PdfColor.fromHex('#00B4D8'),
                          ),
                        ),
                        pw.TextSpan(
                          text: 'c',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                            color: PdfColor.fromHex('#FF4D6D'),
                          ),
                        ),
                        pw.TextSpan(
                          text: 's',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 16,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColor.fromHex('#0277BD'), thickness: 1.5),

            // 2. TAX INVOICE TITLE
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(
                'Tax Invoice',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  color: PdfColor.fromHex('#0277BD'),
                ),
              ),
            ),
            pw.Divider(color: PdfColor.fromHex('#0277BD'), thickness: 1.5),
            pw.SizedBox(height: 12),

            // 3. BILL TO & INVOICE DETAILS ROW
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Bill To Section
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.customer.name.toUpperCase(),
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 11,
                        ),
                      ),
                      if (invoice.customer.phone.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Phone: ${invoice.customer.phone}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                      if (invoice.customer.email.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Email: ${invoice.customer.email}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                      if (invoice.customer.address.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Address: ${invoice.customer.address}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ],
                  ),
                ),
                // Invoice Details Section
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Invoice Details',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('Invoice No.: ', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text(invoice.invoiceNumber, style: pw.TextStyle(font: boldFont, fontSize: 9)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('Date: ', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text(dateFormat.format(invoice.invoiceDate), style: pw.TextStyle(font: boldFont, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            // 4. SERVICE TABLE
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E2E8F0'),
                width: 1,
              ),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),  // #
                1: const pw.FlexColumnWidth(6),   // Service Name
                2: const pw.FixedColumnWidth(60),  // Qty (slightly wider for better fit)
                3: const pw.FixedColumnWidth(90),  // Unit Price
                4: const pw.FixedColumnWidth(100), // Amount
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#0277BD'),
                  ),
                  children: [
                    _cell('#', align: pw.TextAlign.center, isHeader: true, font: boldFont),
                    _cell('Item name', align: pw.TextAlign.left, isHeader: true, font: boldFont),
                    _cell('Quantity', align: pw.TextAlign.center, isHeader: true, font: boldFont),
                    _cell('Price/ unit', align: pw.TextAlign.right, isHeader: true, font: boldFont),
                    _cell('Amount', align: pw.TextAlign.right, isHeader: true, font: boldFont),
                  ],
                ),
                // Table Items
                for (int i = 0; i < invoice.items.length; i++)
                  pw.TableRow(
                    children: [
                      _cell((i + 1).toString(), align: pw.TextAlign.center, font: baseFont),
                      _cell(invoice.items[i].name, align: pw.TextAlign.left, font: baseFont),
                      _cell(invoice.items[i].quantity.toString(), align: pw.TextAlign.center, font: baseFont),
                      _cell(indianRupeesFormat.format(invoice.items[i].unitPrice), align: pw.TextAlign.right, font: baseFont),
                      _cell(indianRupeesFormat.format(invoice.items[i].totalAmount), align: pw.TextAlign.right, font: baseFont),
                    ],
                  ),
                // Total Summary Row inside Table
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8FAFC'),
                  ),
                  children: [
                    _cell('', font: boldFont),
                    _cell('Total', align: pw.TextAlign.left, font: boldFont),
                    _cell(
                      invoice.items.fold<int>(0, (sum, item) => sum + item.quantity).toString(),
                      align: pw.TextAlign.center,
                      font: boldFont,
                    ),
                    _cell('', font: boldFont),
                    _cell(indianRupeesFormat.format(invoice.totalAmount), align: pw.TextAlign.right, font: boldFont),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // 5. BOTTOM DETAILS SECTION
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Left hand side info (Words & Terms & Seal)
                pw.Expanded(
                  flex: 3,
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Invoice Amount In Words',
                              style: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfColors.grey700),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              NumberToWordsConverter.convert(invoice.totalAmount),
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                            pw.SizedBox(height: 12),
                            pw.Text(
                              'Terms And Conditions',
                              style: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfColors.grey700),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              AppConstants.termsAndConditions,
                              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                            ),
                          ],
                        ),
                      ),
                      if (invoice.paymentStatus == PaymentStatus.paid) ...[
                        pw.SizedBox(width: 12),
                        _paidStamp(),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                // Right hand side info (Subtotal, Total, Received, Balance)
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    children: [
                      _summaryRow('Sub Total', indianRupeesFormat.format(invoice.totalAmount), font: baseFont),
                      // Grand Total highlighted row
                      pw.Container(
                        color: PdfColor.fromHex('#0277BD'),
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total',
                              style: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfColors.white),
                            ),
                            pw.Text(
                              indianRupeesFormat.format(invoice.totalAmount),
                              style: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfColors.white),
                            ),
                          ],
                        ),
                      ),
                      _summaryRow('Received', indianRupeesFormat.format(invoice.amountPaid), font: baseFont),
                      _summaryRow('Balance', indianRupeesFormat.format(invoice.balance), font: baseFont),
                      
                      pw.SizedBox(height: 24),
                      
                      // Authorized Signatory section with stamp representation
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'For: ${AppConstants.companyName}',
                            style: pw.TextStyle(font: baseFont, fontSize: 8),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 10),
                            child: pw.Image(
                              signatureImage,
                              width: 80,
                              height: 40,
                              fit: pw.BoxFit.contain,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Authorized Signatory',
                            style: pw.TextStyle(font: boldFont, fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool isHeader = false,
    required pw.Font font,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 8.5 : 8,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _summaryRow(String label, String value, {required pw.Font font}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 8.5, font: font, color: PdfColors.black),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 8.5, font: font, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  pw.Widget _paidStamp() {
    return pw.Transform.rotate(
      angle: -0.15,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#D32F2F'), width: 2),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          'PAID',
          style: pw.TextStyle(
            color: PdfColor.fromHex('#D32F2F'),
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
