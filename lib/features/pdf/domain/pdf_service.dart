import 'dart:typed_data';
import '../../company/domain/company_info.dart';
import '../../invoice/domain/invoice.dart';

abstract class PdfService {
  /// Generates a PDF document for the given invoice and company info and returns the byte array.
  Future<Uint8List> generateInvoicePdf(Invoice invoice, CompanyInfo companyInfo);
}
