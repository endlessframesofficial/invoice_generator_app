// Recent Invoices Screen with swipe‑to‑delete
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/invoice_repository.dart';
import '../../domain/invoice.dart';
import '../providers/invoice_notifier.dart';

class RecentInvoicesScreen extends ConsumerStatefulWidget {
  const RecentInvoicesScreen({super.key});

  @override
  ConsumerState<RecentInvoicesScreen> createState() => _RecentInvoicesScreenState();
}

class _RecentInvoicesScreenState extends ConsumerState<RecentInvoicesScreen> {
  late Future<List<Invoice>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  void _loadInvoices() {
    _invoicesFuture = ref.read(invoiceRepositoryProvider).getInvoices();
  }

  // Helper to delete an invoice and refresh the list
  Future<void> _deleteInvoice(String invoiceNumber) async {
    await ref.read(invoiceRepositoryProvider).deleteInvoice(invoiceNumber);
    if (mounted) {
      setState(() {
        _loadInvoices();
      });
    }
  }

  // Confirmation dialog before deletion
  Future<bool?> _showDeleteConfirmDialog(Invoice invoice) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Bill?'),
        content: Text('Remove the bill for ${invoice.customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Bills'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Invoice>>(
        future: _invoicesFuture,
        builder: (c, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final invoices = snapshot.data ?? [];
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey),
                  SizedBox(height: 24),
                  Text('No saved invoices yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (c, index) {
              final invoice = invoices[index];
              return Dismissible(
                key: ValueKey(invoice.invoiceNumber),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final confirm = await _showDeleteConfirmDialog(invoice);
                  return confirm == true;
                },
                onDismissed: (_) async {
                  await _deleteInvoice(invoice.invoiceNumber);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${invoice.invoiceNumber}')),
                  );
                },
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      invoice.customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(invoice.invoiceNumber, style: const TextStyle(fontSize: 12)),
                        Text(dateFormat.format(invoice.invoiceDate), style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${AppConstants.currencySymbol}${invoice.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0288D1), fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(invoice.paymentStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            invoice.paymentStatus.name.toUpperCase(),
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _getStatusColor(invoice.paymentStatus)),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Load the invoice into the form and navigate to PDF preview
                      ref.read(invoiceNotifierProvider.notifier).loadInvoice(invoice);
                      ref.read(currentInvoiceProvider.notifier).setInvoice(invoice);
                      context.push('/pdf-preview');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.partiallyPaid:
        return Colors.orange;
      case PaymentStatus.unpaid:
        return Colors.red;
    }
  }
}
