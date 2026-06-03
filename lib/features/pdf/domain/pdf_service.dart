import 'dart:typed_data';
import '../../invoice/domain/invoice.dart';

abstract class PdfService {
  /// Generates a PDF document for the given invoice and returns the byte array.
  Future<Uint8List> generateInvoicePdf(Invoice invoice);
}
