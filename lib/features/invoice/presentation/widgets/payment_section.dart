import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/invoice.dart';
import '../providers/invoice_notifier.dart';

class PaymentSection extends ConsumerWidget {
  const PaymentSection({super.key});

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
                  Icons.payments_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Material 3 SegmentedButton for selection
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PaymentStatus>(
                segments: const <ButtonSegment<PaymentStatus>>[
                  ButtonSegment<PaymentStatus>(
                    value: PaymentStatus.unpaid,
                    label: Text('Unpaid'),
                    icon: Icon(Icons.cancel_outlined),
                  ),
                  ButtonSegment<PaymentStatus>(
                    value: PaymentStatus.partiallyPaid,
                    label: Text('Partial'),
                    icon: Icon(Icons.star_half_rounded),
                  ),
                  ButtonSegment<PaymentStatus>(
                    value: PaymentStatus.paid,
                    label: Text('Paid'),
                    icon: Icon(Icons.check_circle_outline_rounded),
                  ),
                ],
                selected: <PaymentStatus>{formState.paymentStatus},
                onSelectionChanged: (Set<PaymentStatus> newSelection) {
                  notifier.updatePaymentStatus(newSelection.first);
                },
              ),
            ),
            
            // Animated input field for partially paid amount
            if (formState.paymentStatus == PaymentStatus.partiallyPaid) ...[
              const SizedBox(height: 16),
              PartialAmountInputField(
                amountPaid: formState.amountPaid,
                totalAmount: formState.totalAmount,
                onChanged: notifier.updateAmountPaid,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PartialAmountInputField extends StatefulWidget {
  final double amountPaid;
  final double totalAmount;
  final ValueChanged<double> onChanged;

  const PartialAmountInputField({
    required this.amountPaid,
    required this.totalAmount,
    required this.onChanged,
    super.key,
  });

  @override
  State<PartialAmountInputField> createState() => _PartialAmountInputFieldState();
}

class _PartialAmountInputFieldState extends State<PartialAmountInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.amountPaid > 0 ? widget.amountPaid.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant PartialAmountInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compare parsed double to prevent overwriting currently typed input
    final currentVal = double.tryParse(_controller.text) ?? 0.0;
    if (widget.amountPaid != currentVal) {
      _controller.text = widget.amountPaid > 0 ? widget.amountPaid.toString() : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Amount Received (${AppConstants.currencySymbol}) *',
        helperText: 'Enter amount paid by customer (Max: ${AppConstants.currencySymbol}${widget.totalAmount.toStringAsFixed(2)})',
        prefixIcon: const Icon(Icons.currency_rupee_rounded),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (val) {
        final double parsed = double.tryParse(val) ?? 0.0;
        widget.onChanged(parsed);
      },
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Amount Received is required';
        }
        final double? parsed = double.tryParse(val);
        if (parsed == null || parsed <= 0) {
          return 'Amount must be greater than zero';
        }
        if (parsed > widget.totalAmount) {
          return 'Amount cannot exceed the total invoice amount';
        }
        return null;
      },
    );
  }
}
