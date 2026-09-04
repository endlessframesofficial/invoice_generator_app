import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Called upon user login: Ensures users/{uid} and users/{uid}/subscription/current exist,
  /// and migrates any existing local guest invoices to Firestore.
  Future<void> handleGuestToLoginMigration({
    required User user,
    required CompanyInfo companyInfo,
    required List<Customer> parties,
    required List<Invoice> localInvoices,
  }) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userDocRef.get();

    // 1. Create users/{uid} document if not existing
    if (!userSnapshot.exists) {
      await userDocRef.set({
        'name': user.displayName ?? companyInfo.name,
        'email': user.email ?? companyInfo.email,
        'phone': user.phoneNumber ?? companyInfo.phone,
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Initialize default subscription entitlement under users/{uid}/subscription/current
      await userDocRef.collection('subscription').doc('current').set({
        'plan': 'free',
        'status': 'active',
        'expiresAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update basic details
      await userDocRef.update({
        'name': user.displayName ?? companyInfo.name,
        'email': user.email ?? companyInfo.email,
        'phone': user.phoneNumber ?? companyInfo.phone,
        'photoUrl': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // 2. Migrate existing local guest invoices to Firestore
    if (localInvoices.isNotEmpty) {
      await syncAllToCloud(
        userId: user.uid,
        companyInfo: companyInfo,
        parties: parties,
        invoices: localInvoices,
      );
    }
  }

  /// Syncs local data (Company Info, Parties, Invoices) to Firestore under users/{userId}
  Future<void> syncAllToCloud({
    required String userId,
    required CompanyInfo companyInfo,
    required List<Customer> parties,
    required List<Invoice> invoices,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // 1. Sync Company Details
      await userDoc.collection('company').doc('info').set({
        ...companyInfo.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Sync Parties / Customers
      final batch = _firestore.batch();
      for (final party in parties) {
        final docId = party.phone.replaceAll(RegExp(r'\s+'), '');
        final validDocId = docId.isNotEmpty ? docId : 'party_${DateTime.now().millisecondsSinceEpoch}';
        final partyDoc = userDoc.collection('parties').doc(validDocId);
        batch.set(partyDoc, party.toJson(), SetOptions(merge: true));
      }

      // 3. Sync Invoices
      for (final invoice in invoices) {
        final invoiceDoc = userDoc.collection('invoices').doc(invoice.invoiceNumber);
        batch.set(
          invoiceDoc,
          {
            'invoiceNumber': invoice.invoiceNumber,
            'customerName': invoice.customer.name,
            'customerPhone': invoice.customer.phone,
            'items': invoice.items.map((item) => item.toJson()).toList(),
            'subtotal': invoice.totalAmount,
            'tax': 0.0,
            'total': invoice.totalAmount,
            'notes': '',
            'paymentStatus': invoice.paymentStatus.name,
            'amountPaid': invoice.amountPaid,
            'createdAt': invoice.invoiceDate.toIso8601String(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.code == 'unavailable') {
        throw Exception('Cloud Firestore database is not initialized in Firebase Console. Please create Firestore Database in your Firebase Console.');
      } else if (e.code == 'permission-denied') {
        throw Exception('Firestore permission denied. Please update Security Rules in Firebase Console to allow write access.');
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }
}
