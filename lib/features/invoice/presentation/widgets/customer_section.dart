import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_notifier.dart';

class CustomerSection extends ConsumerStatefulWidget {
  const CustomerSection({super.key});

  @override
  ConsumerState<CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends ConsumerState<CustomerSection> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(invoiceNotifierProvider);
    _nameController = TextEditingController(text: formState.customerName);
    _phoneController = TextEditingController(text: formState.customerPhone);
    _emailController = TextEditingController(text: formState.customerEmail);
    _addressController = TextEditingController(text: formState.customerAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync with resets: if customerName in provider is empty and our controller isn't, clear all
    final providerName = ref.watch(invoiceNotifierProvider.select((s) => s.customerName));
    if (providerName.isEmpty && _nameController.text.isNotEmpty) {
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _addressController.clear();
    }

    final notifier = ref.read(invoiceNotifierProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_pin_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Customer Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: notifier.updateCustomerName,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Customer Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              onChanged: notifier.updateCustomerPhone,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Phone Number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: notifier.updateCustomerEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Site/Billing Address (Optional)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              maxLines: 2,
              onChanged: notifier.updateCustomerAddress,
            ),
          ],
        ),
      ),
    );
  }
}
