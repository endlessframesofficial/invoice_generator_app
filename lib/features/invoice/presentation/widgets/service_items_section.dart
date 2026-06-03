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
                separatorBuilder: (context, index) => const SizedBox(height: 16),
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
    _qtyController = TextEditingController(text: widget.item.quantity.toString());
    _priceController = TextEditingController(
        text: widget.item.unitPrice > 0 ? widget.item.unitPrice.toString() : '');
  }

  @override
  void didUpdateWidget(covariant ServiceItemFormRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if name has changed externally
    if (widget.item.name != _nameController.text) {
      final cursorPosition = _nameController.selection;
      _nameController.text = widget.item.name;
      try {
        _nameController.selection = cursorPosition;
      } catch (_) {}
    }
    
    // Check if quantity has changed externally
    final currentQty = int.tryParse(_qtyController.text) ?? 1;
    if (widget.item.quantity != currentQty) {
      final cursorPosition = _qtyController.selection;
      _qtyController.text = widget.item.quantity.toString();
      try {
        _qtyController.selection = cursorPosition;
      } catch (_) {}
    }
    
    // Check if price has changed externally
    final currentPrice = double.tryParse(_priceController.text) ?? 0.0;
    if (widget.item.unitPrice != currentPrice) {
      final cursorPosition = _priceController.selection;
      _priceController.text = widget.item.unitPrice > 0 ? widget.item.unitPrice.toString() : '';
      try {
        _priceController.selection = cursorPosition;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _decrementQty() {
    final currentVal = int.tryParse(_qtyController.text) ?? 1;
    if (currentVal > 1) {
      final newVal = currentVal - 1;
      _qtyController.text = newVal.toString();
      widget.onChanged(null, newVal, null);
    }
  }

  void _incrementQty() {
    final currentVal = int.tryParse(_qtyController.text) ?? 1;
    final newVal = currentVal + 1;
    _qtyController.text = newVal.toString();
    widget.onChanged(null, newVal, null);
  }

  @override
  Widget build(BuildContext context) {
    final itemTotal = widget.item.quantity * widget.item.unitPrice;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ITEM #${widget.index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                ),
                tooltip: 'Delete item',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Service / Item Name *',
              hintText: 'e.g. AC Water Service',
              prefixIcon: Icon(Icons.handyman_outlined, size: 20),
            ),
            onChanged: (val) => widget.onChanged(val, null, null),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unit Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.currency_rupee_rounded, size: 16),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onChanged: (val) {
                        final price = double.tryParse(val) ?? 0.0;
                        widget.onChanged(null, null, price);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Quantity Stepper
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Qty',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _decrementQty,
                            icon: const Icon(Icons.remove_rounded, size: 20),
                            color: const Color(0xFF475569),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _qtyController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                              onChanged: (val) {
                                final qty = int.tryParse(val) ?? 1;
                                widget.onChanged(null, qty, null);
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: _incrementQty,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            color: const Color(0xFF475569),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Item Total',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0277BD), Color(0xFF0097A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0277BD).withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '${AppConstants.currencySymbol}${itemTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
