import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/customer.dart';
import '../../../customer/presentation/providers/customer_provider.dart';
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
    final formState = ref.watch(invoiceNotifierProvider);
    final savedParties = ref.watch(customerListProvider);

    // Sync controllers if provider state updated externally
    if (formState.customerName != _nameController.text && !FocusScope.of(context).hasFocus) {
      _nameController.text = formState.customerName;
    }
    if (formState.customerPhone != _phoneController.text && !FocusScope.of(context).hasFocus) {
      _phoneController.text = formState.customerPhone;
    }
    if (formState.customerEmail != _emailController.text && !FocusScope.of(context).hasFocus) {
      _emailController.text = formState.customerEmail;
    }
    if (formState.customerAddress != _addressController.text && !FocusScope.of(context).hasFocus) {
      _addressController.text = formState.customerAddress;
    }

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

            // SEARCH & SELECT EXISTING PARTY
            if (savedParties.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.mintBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.search_rounded, size: 16, color: AppTheme.primaryColor),
                        SizedBox(width: 6),
                        Text(
                          'Search & Autofill Existing Party',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Autocomplete<Customer>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return savedParties;
                        }
                        return savedParties.where((Customer party) {
                          return party.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                              party.phone.contains(textEditingValue.text);
                        });
                      },
                      displayStringForOption: (Customer party) => '${party.name} (${party.phone})',
                      onSelected: (Customer selectedParty) {
                        _fillCustomerDetails(selectedParty);
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Type party name or phone number...',
                            isDense: true,
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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
