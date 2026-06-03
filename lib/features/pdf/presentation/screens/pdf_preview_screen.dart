import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/pdf_service_impl.dart';
import '../../../company/presentation/providers/company_provider.dart';
import '../../../invoice/domain/invoice.dart';
import '../../../invoice/presentation/providers/invoice_notifier.dart';

class PdfPreviewScreen extends ConsumerWidget {
  const PdfPreviewScreen({super.key});

  Future<void> _sharePdf(BuildContext context, WidgetRef ref) async {
    final invoice = ref.read(currentInvoiceProvider);
    if (invoice == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final companyInfo = ref.read(companyInfoStateProvider);
      final pdfService = ref.read(pdfServiceProvider);
      final pdfBytes = await pdfService.generateInvoicePdf(invoice, companyInfo);
      
      // Save PDF to temporary folder so other apps like WhatsApp can access the file path provider URI properly
      final tempDir = await getTemporaryDirectory();
      final fileName = 'invoice_${invoice.invoiceNumber}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      final paymentStatusLabel = invoice.paymentStatus == PaymentStatus.paid
          ? 'Paid'
          : (invoice.paymentStatus == PaymentStatus.partiallyPaid ? 'Partially Paid' : 'Unpaid');

      // Share using share_plus package using the written file path
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice ${invoice.invoiceNumber} for ${invoice.customer.name}',
        text: 'Hello *${invoice.customer.name}*,\n\n'
            'Please find attached your invoice *${invoice.invoiceNumber}* from *${companyInfo.name}*.\n\n'
            '• Total Amount: Rs. ${invoice.totalAmount.toStringAsFixed(2)}\n'
            '• Status: *$paymentStatusLabel*',
      );
    } catch (e) {
      if (context.mounted) {
        // Dismiss loading spinner if visible
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = ref.watch(currentInvoiceProvider);
    final companyInfo = ref.watch(companyInfoStateProvider);
    final pdfService = ref.watch(pdfServiceProvider);

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PDF Preview'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text('No invoice data available to generate preview.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${invoice.invoiceNumber}'),
      ),
      body: PdfPreview(
        build: (format) => pdfService.generateInvoicePdf(invoice, companyInfo),
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfFileName: 'invoice_${invoice.invoiceNumber}.pdf',
        loadingWidget: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), // Green color for WhatsApp style
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _sharePdf(context, ref);
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('Send Invoice'),
            ),
          ),
        ),
      ),
    );
  }
}
