import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/service_item.dart';
import '../providers/invoice_notifier.dart';
import '../../../../core/constants/app_constants.dart';

class ServiceItemsSection extends ConsumerWidget {
  const ServiceItemsSection({super.key});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Service Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: notifier.addServiceItem,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (formState.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No service items added yet.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: notifier.addServiceItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Item'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: formState.items.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 24,
                  color: Color(0xFFE2E8F0),
                ),
                itemBuilder: (context, index) {
                  final item = formState.items[index];
                  return ServiceItemFormRow(
                    key: ValueKey(item.id),
                    item: item,
                    index: index,
                    onChanged: (name, qty, price) {
                      notifier.updateServiceItem(
                        item.id,
                        name: name,
                        quantity: qty,
                        unitPrice: price,
                      );
                    },
                    onDelete: () => notifier.removeServiceItem(item.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class ServiceItemFormRow extends StatefulWidget {
  final ServiceItem item;
  final int index;
  final void Function(String? name, int? qty, double? price) onChanged;
  final VoidCallback onDelete;

  const ServiceItemFormRow({
    required this.item,
    required this.index,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });

  @override
  State<ServiceItemFormRow> createState() => _ServiceItemFormRowState();
}

class _ServiceItemFormRowState extends State<ServiceItemFormRow> {
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _qtyController = TextEditingController(
        text: widget.item.quantity > 0 ? widget.item.quantity.toString() : '');
    _priceController = TextEditingController(
        text: widget.item.unitPrice > 0 ? widget.item.unitPrice.toString() : '');
  }

  @override
  void didUpdateWidget(covariant ServiceItemFormRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep controllers in sync only if values change outside editing
    if (widget.item.name != _nameController.text) {
      _nameController.text = widget.item.name;
    }
    
    // Compare parsed integer values to avoid overwriting text currently being typed
    final currentQty = int.tryParse(_qtyController.text) ?? 0;
    if (widget.item.quantity != currentQty) {
      _qtyController.text = widget.item.quantity > 0 ? widget.item.quantity.toString() : '';
    }
    
    // Compare parsed double values to avoid overwriting text currently being typed (like trailing zeros or decimal points)
    final currentPrice = double.tryParse(_priceController.text) ?? 0.0;
    if (widget.item.unitPrice != currentPrice) {
      _priceController.text = widget.item.unitPrice > 0 ? widget.item.unitPrice.toString() : '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemTotal = widget.item.quantity * widget.item.unitPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item #${widget.index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              tooltip: 'Delete item',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Service / Item Name *',
            hintText: 'e.g. AC Water Service',
            prefixIcon: Icon(Icons.handyman_outlined),
          ),
          onChanged: (val) => widget.onChanged(val, null, null),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(
                  labelText: 'Qty *',
                  prefixIcon: Icon(Icons.unfold_more_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                onChanged: (val) {
                  final qty = int.tryParse(val) ?? 0;
                  widget.onChanged(null, qty, null);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Unit Price *',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  final price = double.tryParse(val) ?? 0.0;
                  widget.onChanged(null, null, price);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${AppConstants.currencySymbol}${itemTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
