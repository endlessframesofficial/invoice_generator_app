import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/customer.dart';
import '../providers/invoice_form_state.dart';
import '../providers/invoice_notifier.dart';
import 'select_party_bottom_sheet.dart';

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

  void _fillCustomerDetails(Customer party) {
    _nameController.text = party.name;
    _phoneController.text = party.phone;
    _emailController.text = party.email;
    _addressController.text = party.address;

    ref.read(invoiceNotifierProvider.notifier).updateCustomerInfo(
          name: party.name,
          phone: party.phone,
          email: party.email,
          address: party.address,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to form state updates and sync text fields dynamically
    ref.listen<InvoiceFormState>(invoiceNotifierProvider, (previous, next) {
      if (_nameController.text != next.customerName) {
        _nameController.text = next.customerName;
      }
      if (_phoneController.text != next.customerPhone) {
        _phoneController.text = next.customerPhone;
      }
      if (_emailController.text != next.customerEmail) {
        _emailController.text = next.customerEmail;
      }
      if (_addressController.text != next.customerAddress) {
        _addressController.text = next.customerAddress;
      }
    });

    final notifier = ref.read(invoiceNotifierProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ],
            ),

            const SizedBox(height: 12),

            // SELECT PARTY / CONTACT BOTTOM SHEET BUTTON
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SelectPartyBottomSheet(
                    onSelectCustomer: (customer) {
                      _fillCustomerDetails(customer);
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.mintBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_search_rounded, color: AppTheme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Party or Contact',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pick from saved parties or phone contacts',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryColor, size: 16),
                  ],
                ),
              ),
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
