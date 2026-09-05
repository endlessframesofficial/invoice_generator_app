import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../company/presentation/providers/company_provider.dart';
import '../providers/invoice_notifier.dart';

class DocumentCustomizationSection extends ConsumerWidget {
  const DocumentCustomizationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(invoiceNotifierProvider);
    final notifier = ref.read(invoiceNotifierProvider.notifier);
    final companyInfo = ref.watch(companyInfoStateProvider);

    final hasLogo = companyInfo.logoUrl != null && companyInfo.logoUrl!.trim().isNotEmpty;
    final hasSignature = companyInfo.signatureUrl != null && companyInfo.signatureUrl!.trim().isNotEmpty;

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

            // Date Picker (Optional)
            TextFormField(
              key: ValueKey(formState.generatedInvoiceDate),
              initialValue: formState.generatedInvoiceDate != null
                  ? DateFormat('dd-MM-yyyy').format(formState.generatedInvoiceDate!)
                  : '',
              readOnly: true,
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: formState.generatedInvoiceDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  notifier.updateInvoiceDate(selectedDate);
                }
              },
              decoration: InputDecoration(
                labelText: 'Bill Date (Optional)',
                hintText: 'Leave empty for current date',
                prefixIcon: const Icon(Icons.calendar_month_rounded),
                suffixIcon: formState.generatedInvoiceDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          notifier.updateInvoiceDate(null);
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Company Logo Availability Status & Switch
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasLogo ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                            size: 18,
                            color: hasLogo ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasLogo ? 'Company Logo Available' : 'No Logo Set in Settings',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: hasLogo ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: formState.showLogo,
                        onChanged: (val) {
                          if (!hasLogo && val) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notice: No custom logo uploaded yet. You can upload a logo under Settings.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                          notifier.updateShowLogo(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLogo
                        ? 'Include your custom uploaded company logo on the invoice header.'
                        : 'No custom logo set. Go to Settings > Update Company Details to upload your logo.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Digital Signature Availability Status & Switch
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              hasSignature ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                              size: 18,
                              color: hasSignature ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                hasSignature
                                    ? 'Digital Signature Available (${companyInfo.signatureType == 'drawn' ? 'Drawn' : 'Image'})'
                                    : 'No Signature Set in Settings',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: hasSignature ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: formState.showSignature,
                        onChanged: (val) {
                          if (!hasSignature && val) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notice: No digital signature set yet. Go to Settings to draw or upload your signature.'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                          notifier.updateShowSignature(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasSignature
                        ? 'Include your saved digital signature on the invoice footer.'
                        : 'No digital signature set. Go to Settings > Update Company Details to draw or upload your signature.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
