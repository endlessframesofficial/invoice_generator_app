import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/company/domain/company_info.dart';
import '../../features/customer/domain/customer.dart';
import '../../features/invoice/domain/invoice.dart';

final firestoreSyncServiceProvider = Provider<FirestoreSyncService>((ref) {
  return FirestoreSyncService();
});

class FirestoreSyncService {
  final FirebaseFirestore _firestore;

  FirestoreSyncService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Syncs all local data (Company Info, Parties, Invoices) to Firestore under users/{userId}
  Future<void> syncAllToCloud({
    required String userId,
    required CompanyInfo companyInfo,
    required List<Customer> parties,
    required List<Invoice> invoices,
  }) async {
    final userDoc = _firestore.collection('users').doc(userId);

    // 1. Sync Company Details
    await userDoc.collection('company').doc('info').set({
      ...companyInfo.toJson(),
      'last_synced_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Sync Parties / Customers
    final batch = _firestore.batch();
    for (final party in parties) {
      final docId = party.phone.replaceAll(RegExp(r'\s+'), '');
      if (docId.isNotEmpty) {
        final partyDoc = userDoc.collection('parties').doc(docId);
        batch.set(partyDoc, party.toJson(), SetOptions(merge: true));
      }
    }

    // 3. Sync Invoices
    for (final invoice in invoices) {
      final invoiceDoc = userDoc.collection('invoices').doc(invoice.invoiceNumber);
      batch.set(invoiceDoc, {
        ...invoice.toJson(),
        'invoiceDate': invoice.invoiceDate.toIso8601String(),
        'last_synced_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
