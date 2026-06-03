import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_notifier.dart';

class DocumentCustomizationSection extends ConsumerWidget {
  const DocumentCustomizationSection({super.key});

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
                  Icons.picture_as_pdf_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'PDF Customization Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Invoice Number Input
            TextFormField(
              initialValue: formState.generatedInvoiceNumber,
              decoration: const InputDecoration(
                labelText: 'Bill Number (Optional)',
                hintText: 'Leave empty to auto-generate',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
                helperText: 'e.g., 2024-001',
              ),
              onChanged: notifier.updateInvoiceNumber,
            ),

            const SizedBox(height: 16),
            
            // Show Logo Switch
            SwitchListTile.adaptive(
              title: const Text(
                'Include Company Logo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              subtitle: const Text(
                'Show technician logo and cartoon drawing in the header',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              value: formState.showLogo,
              onChanged: notifier.updateShowLogo,
              contentPadding: EdgeInsets.zero,
            ),
            
            const Divider(height: 16, color: Color(0xFFE2E8F0)),
            
            // Show Signature Switch
            SwitchListTile.adaptive(
              title: const Text(
                'Include Authorized Signature',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              subtitle: const Text(
                'Show authorized signature graphic at the footer (disable for physical signing)',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              value: formState.showSignature,
              onChanged: notifier.updateShowSignature,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
