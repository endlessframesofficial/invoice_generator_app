import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../customer/domain/customer.dart';
import '../../domain/invoice.dart';
import '../../domain/service_item.dart';
import 'invoice_form_state.dart';

part 'invoice_notifier.g.dart';

@riverpod
class InvoiceNotifier extends _$InvoiceNotifier {
  @override
  InvoiceFormState build() {
    if (kDebugMode) {
      return const InvoiceFormState(
        customerName: "Jeramiah's Home & Bertoni Palliative Care Centre",
        customerPhone: "9562654407",
        customerEmail: "info@bertonicentre.org",
        customerAddress: "Julieta Memorial Building, Panampilly Nagar, Ernakulam",
        paymentStatus: PaymentStatus.partiallyPaid,
        amountPaid: 3500.0,
        items: [
          ServiceItem(
            id: 'mock-1',
            name: 'Ac water service',
            quantity: 1,
            unitPrice: 1200.0,
          ),
          ServiceItem(
            id: 'mock-2',
            name: 'Gas top up',
            quantity: 1,
            unitPrice: 600.0,
          ),
          ServiceItem(
            id: 'mock-3',
            name: 'Ac capacitor replacement',
            quantity: 2,
            unitPrice: 850.0,
          ),
          ServiceItem(
            id: 'mock-4',
            name: 'Copper pipe installation',
            quantity: 4,
            unitPrice: 350.0,
          ),
          ServiceItem(
            id: 'mock-5',
            name: 'Service visit charge',
            quantity: 1,
            unitPrice: 350.0,
          ),
        ],
      );
    }

    // Start with one empty item by default for a smoother user experience
    return InvoiceFormState(
      items: [
        _createEmptyItem(),
      ],
    );
  }

  ServiceItem _createEmptyItem() {
    return ServiceItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: '',
      quantity: 1,
      unitPrice: 0.0,
    );
  }

  void updateCustomerName(String name) {
    state = state.copyWith(
      customerName: name,
      errorMessage: null,
    );
  }

  void updateCustomerPhone(String phone) {
    state = state.copyWith(
      customerPhone: phone,
      errorMessage: null,
    );
  }

  void updateCustomerEmail(String email) {
    state = state.copyWith(
      customerEmail: email,
      errorMessage: null,
    );
  }

  void updateCustomerAddress(String address) {
    state = state.copyWith(
      customerAddress: address,
      errorMessage: null,
    );
  }

  void addServiceItem() {
    final updatedList = List<ServiceItem>.from(state.items)..add(_createEmptyItem());
    state = state.copyWith(
      items: updatedList,
      errorMessage: null,
    );
  }

  void removeServiceItem(String id) {
    final updatedList = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(
      items: updatedList,
      errorMessage: null,
    );
  }

  void updateServiceItem(
    String id, {
    String? name,
    int? quantity,
    double? unitPrice,
  }) {
    final updatedList = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(
          name: name ?? item.name,
          quantity: quantity ?? item.quantity,
          unitPrice: unitPrice ?? item.unitPrice,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      items: updatedList,
      errorMessage: null,
    );
  }

  /// Validates the form state. Returns error message if invalid, null if valid.
  String? getValidationError() {
    if (state.customerName.trim().isEmpty) {
      return 'Customer Name is required.';
    }
    if (state.customerPhone.trim().isEmpty) {
      return 'Phone Number is required.';
    }
    if (state.items.isEmpty) {
      return 'At least one service item is required.';
    }
    for (int i = 0; i < state.items.length; i++) {
      final item = state.items[i];
      if (item.name.trim().isEmpty) {
        return 'Service Name for item ${i + 1} is required.';
      }
      if (item.quantity <= 0) {
        return 'Quantity for item ${i + 1} must be greater than 0.';
      }
      if (item.unitPrice <= 0) {
        return 'Unit Price for item ${i + 1} must be greater than 0.';
      }
    }
    if (state.paymentStatus == PaymentStatus.partiallyPaid) {
      if (state.amountPaid <= 0) {
        return 'Amount Paid must be greater than 0 for partial payment.';
      }
      if (state.amountPaid > state.totalAmount) {
        return 'Amount Paid cannot be greater than the Total Invoice Amount.';
      }
    }
    return null;
  }

  void updatePaymentStatus(PaymentStatus status) {
    state = state.copyWith(
      paymentStatus: status,
      amountPaid: status == PaymentStatus.paid ? state.totalAmount : 0.0,
      errorMessage: null,
    );
  }

  void updateAmountPaid(double amount) {
    state = state.copyWith(
      amountPaid: amount,
      errorMessage: null,
    );
  }

  void updateShowLogo(bool value) {
    state = state.copyWith(showLogo: value);
  }

  void updateShowSignature(bool value) {
    state = state.copyWith(showSignature: value);
  }

  /// Generates the Invoice entity if the form is valid.
  Invoice? generateInvoice() {
    final validationError = getValidationError();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return null;
    }

    final invoiceNumber = state.generatedInvoiceNumber ?? 
        'INV-${DateTime.now().year}${(100 + DateTime.now().minute)}${DateTime.now().second}';
    final invoiceDate = state.generatedInvoiceDate ?? DateTime.now();

    // Cache invoice info in state so it remains consistent
    state = state.copyWith(
      generatedInvoiceNumber: invoiceNumber,
      generatedInvoiceDate: invoiceDate,
      errorMessage: null,
    );

    final customer = Customer(
      name: state.customerName.trim(),
      phone: state.customerPhone.trim(),
      email: state.customerEmail.trim(),
      address: state.customerAddress.trim(),
    );

    double finalAmountPaid = 0.0;
    if (state.paymentStatus == PaymentStatus.paid) {
      finalAmountPaid = state.totalAmount;
    } else if (state.paymentStatus == PaymentStatus.partiallyPaid) {
      finalAmountPaid = state.amountPaid;
    }

    return Invoice(
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      customer: customer,
      items: state.items,
      paymentStatus: state.paymentStatus,
      amountPaid: finalAmountPaid,
      showLogo: state.showLogo,
      showSignature: state.showSignature,
    );
  }

  void resetForm() {
    state = InvoiceFormState(
      items: [_createEmptyItem()],
      paymentStatus: PaymentStatus.unpaid,
      amountPaid: 0.0,
      showLogo: true,
      showSignature: true,
    );
  }
}

/// A provider that holds the currently generated invoice (if any)
/// to make it accessible to other features like PDF generator.
@Riverpod(keepAlive: true)
class CurrentInvoice extends _$CurrentInvoice {
  @override
  Invoice? build() => null;

  void setInvoice(Invoice invoice) {
    state = invoice;
  }

  void clear() {
    state = null;
  }
}
