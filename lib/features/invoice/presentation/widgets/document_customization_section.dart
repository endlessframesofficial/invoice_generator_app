import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/signature_pad_dialog.dart';
import '../../../company/presentation/providers/company_provider.dart';
import '../providers/invoice_notifier.dart';

class DocumentCustomizationSection extends ConsumerWidget {
  const DocumentCustomizationSection({super.key});

  Future<void> _pickLogoImage(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final logoUrl = 'data:image/png;base64,$base64String';

        final currentCompany = ref.read(companyInfoStateProvider);
        final updatedCompany = currentCompany.copyWith(logoUrl: logoUrl);
        await ref.read(companyInfoStateProvider.notifier).updateCompanyInfo(updatedCompany);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Company logo added successfully!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting logo image: $e')),
        );
      }
    }
  }

  Future<void> _pickSignatureImage(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 250,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final signatureUrl = 'data:image/png;base64,$base64String';

        final currentCompany = ref.read(companyInfoStateProvider);
        final updatedCompany = currentCompany.copyWith(
          signatureUrl: signatureUrl,
          signatureType: 'uploaded',
        );
        await ref.read(companyInfoStateProvider.notifier).updateCompanyInfo(updatedCompany);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Digital signature uploaded successfully!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting signature image: $e')),
        );
      }
    }
  }

  Future<void> _drawSignatureOnScreen(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => const SignaturePadDialog(),
    );
    if (result != null && result.isNotEmpty) {
      final currentCompany = ref.read(companyInfoStateProvider);
      final updatedCompany = currentCompany.copyWith(
        signatureUrl: result,
        signatureType: 'drawn',
      );
      await ref.read(companyInfoStateProvider.notifier).updateCompanyInfo(updatedCompany);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Digital signature saved successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  Widget _buildImageFromBase64OrUrl(String? str, {double height = 40}) {
    if (str == null || str.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    try {
      if (str.startsWith('data:image')) {
        final base64Data = str.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(bytes, height: height, fit: BoxFit.contain);
      } else if (str.startsWith('http')) {
        return Image.network(str, height: height, fit: BoxFit.contain);
      }
    } catch (_) {}
    return const SizedBox.shrink();
  }

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

            // Company Logo Box
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
                            hasLogo ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            size: 18,
                            color: hasLogo ? const Color(0xFF2E7D32) : AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasLogo ? 'Company Logo Included' : 'Company Logo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: hasLogo ? const Color(0xFF2E7D32) : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: formState.showLogo,
                        onChanged: (val) {
                          notifier.updateShowLogo(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (hasLogo) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: _buildImageFromBase64OrUrl(companyInfo.logoUrl, height: 40),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _pickLogoImage(context, ref),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 14),
                          label: const Text('Change Logo', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          tooltip: 'Remove Logo',
                          onPressed: () async {
                            final updated = companyInfo.copyWith(logoUrl: null);
                            await ref.read(companyInfoStateProvider.notifier).updateCompanyInfo(updated);
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'No logo set. Add your business logo directly below:',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _pickLogoImage(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                          label: const Text('+ Add Logo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Digital Signature Box
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
                            hasSignature ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            size: 18,
                            color: hasSignature ? const Color(0xFF2E7D32) : AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasSignature ? 'Digital Signature Included' : 'Digital Signature',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: hasSignature ? const Color(0xFF2E7D32) : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: formState.showSignature,
                        onChanged: (val) {
                          notifier.updateShowSignature(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (hasSignature) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: _buildImageFromBase64OrUrl(companyInfo.signatureUrl, height: 36),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _drawSignatureOnScreen(context, ref),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.gesture_rounded, size: 14),
                          label: const Text('Redraw', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 4),
                        OutlinedButton.icon(
                          onPressed: () => _pickSignatureImage(context, ref),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.upload_file_rounded, size: 14),
                          label: const Text('Upload', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          tooltip: 'Remove Signature',
                          onPressed: () async {
                            final updated = companyInfo.copyWith(
                              signatureUrl: null,
                              signatureType: null,
                            );
                            await ref.read(companyInfoStateProvider.notifier).updateCompanyInfo(updated);
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No signature set. Add your digital signature directly below:',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _drawSignatureOnScreen(context, ref),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.gesture_rounded, size: 16),
                                label: const Text('Draw Signature', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickSignatureImage(context, ref),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.upload_file_rounded, size: 16),
                                label: const Text('Upload Image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
