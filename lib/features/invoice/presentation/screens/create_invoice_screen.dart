import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../company/presentation/providers/company_provider.dart';
import '../providers/invoice_notifier.dart';
import '../widgets/company_section.dart';
import '../widgets/customer_section.dart';
import '../widgets/service_items_section.dart';

import '../widgets/payment_section.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  void _handleGeneratePdf() {
    final notifier = ref.read(invoiceNotifierProvider.notifier);
    
    // Trigger local form field validators
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the validation errors in the form'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final invoice = notifier.generateInvoice();
    
    if (invoice != null) {
      // Set the active invoice in the current invoice provider
      ref.read(currentInvoiceProvider.notifier).setInvoice(invoice);
      
      // Navigate to PDF Preview screen
      context.push('/pdf-preview');
    } else {
      // Show validation error from Riverpod state
      final errorMsg = ref.read(invoiceNotifierProvider).errorMessage ?? 'Validation failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(invoiceNotifierProvider);
    final companyInfo = ref.watch(companyInfoStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Service Invoice'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Form?'),
                  content: const Text('This will clear all customer information and service items.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(invoiceNotifierProvider.notifier).resetForm();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset form',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Bottom padding to prevent overlap with summary bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium banner mimicking the service company
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0277BD), Color(0xFF0097A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.handyman,
                        color: Color(0xFF0277BD),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyInfo.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyInfo.address,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Company Information Settings Card
              const CompanySection(),
              const SizedBox(height: 16),
              
              // Customer Information Card
              const CustomerSection(),
              const SizedBox(height: 16),

              // Service Items Card
              const ServiceItemsSection(),
              const SizedBox(height: 16),

              // Payment Details Card
              const PaymentSection(),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppConstants.currencySymbol}${formState.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleGeneratePdf,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Generate Invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
