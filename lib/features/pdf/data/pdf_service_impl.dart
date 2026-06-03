import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/number_to_words.dart';
import '../../company/domain/company_info.dart';
import '../../invoice/domain/invoice.dart';
import '../domain/pdf_service.dart';

part 'pdf_service_impl.g.dart';

@riverpod
PdfService pdfService(Ref ref) {
  return PdfServiceImpl();
}

class PdfServiceImpl implements PdfService {
  // Brand colors
  static final _brandBlue = PdfColor.fromHex('#0277BD');
  static final _darkText = PdfColor.fromHex('#1E293B');
  static final _mutedText = PdfColor.fromHex('#64748B');
  static final _borderColor = PdfColor.fromHex('#E2E8F0');
  static final _bgLight = PdfColor.fromHex('#F8FAFC');

  Future<pw.MemoryImage?> _safeLoadImage(String path) async {
    try {
      final data = await rootBundle.load(path);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      print('Warning: Could not load asset $path: $e');
      return null;
    }
  }

  @override
  Future<Uint8List> generateInvoicePdf(Invoice invoice, CompanyInfo companyInfo) async {
    final pdf = pw.Document();

    // Load assets safely
    final signatureImage = await _safeLoadImage('assets/images/signature.jpg');
    final logoImage = await _safeLoadImage('assets/images/ccs_logo.png');
    final upiLogosImage = await _safeLoadImage('assets/images/upi_logos.jpg');

    final dateFormat = DateFormat('dd-MM-yyyy');
    final rupeeFormat = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 2);

    final baseFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        build: (pw.Context context) {
          return [
            // ─── 1. HEADER: Company Info + Logo ───
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo on the left
                if (invoice.showLogo && logoImage != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(right: 16),
                    child: pw.Image(logoImage, width: 70, height: 70, fit: pw.BoxFit.contain),
                  ),
                // Company details
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyInfo.name.toUpperCase(),
                        style: pw.TextStyle(font: boldFont, fontSize: 16, color: _brandBlue, letterSpacing: 1),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(companyInfo.address, style: pw.TextStyle(fontSize: 9, color: _mutedText)),
                      pw.SizedBox(height: 2),
                      pw.Text('Phone: ${companyInfo.phone}', style: pw.TextStyle(fontSize: 9, color: _mutedText)),
                      if (companyInfo.email.isNotEmpty)
                        pw.Text('Email: ${companyInfo.email}', style: pw.TextStyle(fontSize: 9, color: _mutedText)),
                    ],
                  ),
                ),
                // Invoice meta on the right
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(color: _brandBlue, borderRadius: pw.BorderRadius.circular(4)),
                      child: pw.Text(
                        'TAX INVOICE',
                        style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.white, letterSpacing: 1.5),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _metaRow('Invoice No.', invoice.invoiceNumber, baseFont, boldFont),
                    pw.SizedBox(height: 2),
                    _metaRow('Date', dateFormat.format(invoice.invoiceDate), baseFont, boldFont),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Divider(color: _brandBlue, thickness: 2),
            pw.SizedBox(height: 16),

            // ─── 2. BILL TO ───
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: _bgLight,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: _borderColor, width: 0.5),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILL TO', style: pw.TextStyle(font: boldFont, fontSize: 9, color: _mutedText, letterSpacing: 1)),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          invoice.customer.name.toUpperCase(),
                          style: pw.TextStyle(font: boldFont, fontSize: 11, color: _darkText),
                        ),
                        if (invoice.customer.address.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(invoice.customer.address, style: pw.TextStyle(fontSize: 9, color: _mutedText)),
                        ],
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (invoice.customer.phone.isNotEmpty)
                        pw.Text('Phone: ${invoice.customer.phone}', style: pw.TextStyle(fontSize: 9, color: _mutedText)),
                      if (invoice.customer.email.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text('Email: ${invoice.customer.email}', style: pw.TextStyle(fontSize: 9, color: _mutedText)),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // ─── 3. SERVICE ITEMS TABLE ───
            pw.Table(
              border: pw.TableBorder.all(color: _borderColor, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(6),
                2: const pw.FixedColumnWidth(55),
                3: const pw.FixedColumnWidth(90),
                4: const pw.FixedColumnWidth(100),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _brandBlue),
                  children: [
                    _cell('#', align: pw.TextAlign.center, isHeader: true, font: boldFont),
                    _cell('Description', align: pw.TextAlign.left, isHeader: true, font: boldFont),
                    _cell('Qty', align: pw.TextAlign.center, isHeader: true, font: boldFont),
                    _cell('Rate', align: pw.TextAlign.right, isHeader: true, font: boldFont),
                    _cell('Amount', align: pw.TextAlign.right, isHeader: true, font: boldFont),
                  ],
                ),
                // Items
                for (int i = 0; i < invoice.items.length; i++)
                  pw.TableRow(
                    decoration: i.isEven ? null : pw.BoxDecoration(color: _bgLight),
                    children: [
                      _cell('${i + 1}', align: pw.TextAlign.center, font: baseFont),
                      _cell(invoice.items[i].name, align: pw.TextAlign.left, font: baseFont),
                      _cell('${invoice.items[i].quantity}', align: pw.TextAlign.center, font: baseFont),
                      _cell(rupeeFormat.format(invoice.items[i].unitPrice), align: pw.TextAlign.right, font: baseFont),
                      _cell(rupeeFormat.format(invoice.items[i].totalAmount), align: pw.TextAlign.right, font: baseFont),
                    ],
                  ),
                // Total row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E3F2FD')),
                  children: [
                    _cell('', font: boldFont),
                    _cell('TOTAL', align: pw.TextAlign.left, font: boldFont),
                    _cell(
                      '${invoice.items.fold<int>(0, (s, i) => s + i.quantity)}',
                      align: pw.TextAlign.center,
                      font: boldFont,
                    ),
                    _cell('', font: boldFont),
                    _cell(rupeeFormat.format(invoice.totalAmount), align: pw.TextAlign.right, font: boldFont),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 16),

            // ─── 4. SUMMARY + AMOUNT IN WORDS ───
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Amount In Words', style: pw.TextStyle(font: boldFont, fontSize: 9, color: _mutedText)),
                      pw.SizedBox(height: 3),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: _bgLight,
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border.all(color: _borderColor, width: 0.5),
                        ),
                        child: pw.Text(
                          NumberToWordsConverter.convert(invoice.totalAmount),
                          style: pw.TextStyle(font: boldFont, fontSize: 9, color: _darkText),
                        ),
                      ),
                      if (invoice.paymentStatus == PaymentStatus.paid) ...[
                        pw.SizedBox(height: 12),
                        pw.Center(child: _paidStamp()),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _borderColor, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      children: [
                        _summaryRow('Sub Total', rupeeFormat.format(invoice.totalAmount), font: baseFont),
                        pw.Divider(color: _borderColor, thickness: 0.5, height: 0),
                        pw.Container(
                          color: _brandBlue,
                          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Grand Total', style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: PdfColors.white)),
                              pw.Text(rupeeFormat.format(invoice.totalAmount), style: pw.TextStyle(font: boldFont, fontSize: 9.5, color: PdfColors.white)),
                            ],
                          ),
                        ),
                        _summaryRow('Received', rupeeFormat.format(invoice.amountPaid), font: baseFont),
                        pw.Divider(color: _borderColor, thickness: 0.5, height: 0),
                        _summaryRow('Balance Due', rupeeFormat.format(invoice.balance), font: boldFont, highlight: invoice.balance > 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ─── 5. PAYMENT DETAILS (Bank + UPI) ───
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _borderColor, width: 0.5),
                borderRadius: pw.BorderRadius.circular(6),
                color: _bgLight,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('PAYMENT DETAILS', style: pw.TextStyle(font: boldFont, fontSize: 9, color: _brandBlue, letterSpacing: 1)),
                  pw.Divider(color: _borderColor, thickness: 0.5),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Bank Transfer', style: pw.TextStyle(font: boldFont, fontSize: 8.5, color: _darkText)),
                            pw.SizedBox(height: 4),
                            _bankDetailRow('Bank Name', 'South Indian Bank', baseFont, boldFont),
                            _bankDetailRow('Branch', 'KIZHISSERY', baseFont, boldFont),
                            _bankDetailRow('A/C Name', 'SAJITH KUMAR T', baseFont, boldFont),
                            _bankDetailRow('A/C No.', '0620053000003954', baseFont, boldFont),
                            _bankDetailRow('IFSC', 'SIBL0000620', baseFont, boldFont),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: _brandBlue, width: 0.5),
                            borderRadius: pw.BorderRadius.circular(4),
                            color: PdfColors.white,
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [

                                pw.SizedBox(height: 30, child: pw.Center(child: pw.Text('GPay/ PhonePe', style: pw.TextStyle(font: boldFont, color: _brandBlue)))),
                              pw.Text('9567449247', style: pw.TextStyle(font: boldFont, fontSize: 14, color: _darkText)),
                              pw.SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // ─── 6. TERMS & SIGNATURE ───
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Terms & Conditions', style: pw.TextStyle(font: boldFont, fontSize: 9, color: _mutedText)),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        AppConstants.termsAndConditions,
                        style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('For: ${companyInfo.name}', style: pw.TextStyle(font: baseFont, fontSize: 8, color: _mutedText)),
                      pw.SizedBox(height: 6),
                      if (invoice.showSignature && signatureImage != null) ...[
                        pw.Image(signatureImage, width: 80, height: 40, fit: pw.BoxFit.contain),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 120,
                          decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _mutedText, width: 0.5))),
                          padding: const pw.EdgeInsets.only(top: 4),
                          child: pw.Text(
                            'Authorized Signatory',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                        ),
                      ] else ...[
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            '[Electronically Signed]',
                            style: pw.TextStyle(font: baseFont, fontSize: 8, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Computer-generated invoice.\nNo physical signature required.',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: baseFont, fontSize: 7, color: PdfColors.grey500),
                        ),
                      ],
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

  // ─── HELPER WIDGETS ───

  pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.left, bool isHeader = false, required pw.Font font}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: isHeader ? 8.5 : 8, color: isHeader ? PdfColors.white : PdfColors.black),
      ),
    );
  }

  pw.Widget _metaRow(String label, String value, pw.Font baseFont, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text('$label: ', style: pw.TextStyle(font: baseFont, fontSize: 9, color: _mutedText)),
        pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 9, color: _darkText)),
      ],
    );
  }

  pw.Widget _summaryRow(String label, String value, {required pw.Font font, bool highlight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8.5, font: font, color: highlight ? PdfColor.fromHex('#D32F2F') : PdfColors.black)),
          pw.Text(value, style: pw.TextStyle(fontSize: 8.5, font: font, color: highlight ? PdfColor.fromHex('#D32F2F') : PdfColors.black)),
        ],
      ),
    );
  }

  pw.Widget _bankDetailRow(String label, String value, pw.Font baseFont, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text(label, style: pw.TextStyle(font: baseFont, fontSize: 8, color: _mutedText)),
          ),
          pw.Text(':  ', style: pw.TextStyle(font: baseFont, fontSize: 8)),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 8)),
          ),
        ],
      ),
    );
  }

  pw.Widget _paidStamp() {
    return pw.Transform.rotate(
      angle: -0.15,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#4CAF50'), width: 2.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Text(
          'PAID',
          style: pw.TextStyle(
            color: PdfColor.fromHex('#4CAF50'),
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
