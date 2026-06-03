import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../domain/invoice.dart';



final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return InvoiceRepository(prefs);
});

class InvoiceRepository {
  final SharedPreferences _prefs;
  static const String _storageKey = 'saved_invoices';

  InvoiceRepository(this._prefs);

  Future<void> saveInvoice(Invoice invoice) async {
    final invoices = await getInvoices();
    // Check if invoice already exists (by number) and replace or add
    final index = invoices.indexWhere((i) => i.invoiceNumber == invoice.invoiceNumber);
    if (index != -1) {
      invoices[index] = invoice;
    } else {
      invoices.insert(0, invoice); // Add to beginning
    }
    
    final jsonList = invoices.map((i) => jsonEncode(i.toJson())).toList();
    await _prefs.setStringList(_storageKey, jsonList);
  }

  Future<List<Invoice>> getInvoices() async {
    final jsonList = _prefs.getStringList(_storageKey) ?? [];
    return jsonList
        .map((jsonStr) => Invoice.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  Future<void> deleteInvoice(String invoiceNumber) async {
    final invoices = await getInvoices();
    invoices.removeWhere((i) => i.invoiceNumber == invoiceNumber);
    final jsonList = invoices.map((i) => jsonEncode(i.toJson())).toList();
    await _prefs.setStringList(_storageKey, jsonList);
  }
}
