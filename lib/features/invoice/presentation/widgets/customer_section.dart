import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_notifier.dart';

class CustomerSection extends ConsumerWidget {
  const CustomerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(invoiceNotifierProvider);
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
              initialValue: formState.customerName,
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
              initialValue: formState.customerPhone,
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
              initialValue: formState.customerEmail,
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: notifier.updateCustomerEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: formState.customerAddress,
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
