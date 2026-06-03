// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$invoiceNotifierHash() => r'000153f712999b635b44336ed4b50bd7ce893a06';

/// See also [InvoiceNotifier].
@ProviderFor(InvoiceNotifier)
final invoiceNotifierProvider =
    AutoDisposeNotifierProvider<InvoiceNotifier, InvoiceFormState>.internal(
      InvoiceNotifier.new,
      name: r'invoiceNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$invoiceNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InvoiceNotifier = AutoDisposeNotifier<InvoiceFormState>;
String _$currentInvoiceHash() => r'cf6ac82556127fae8eee31406d7012d5bffdae5d';

/// A provider that holds the currently generated invoice (if any)
/// to make it accessible to other features like PDF generator.
///
/// Copied from [CurrentInvoice].
@ProviderFor(CurrentInvoice)
final currentInvoiceProvider =
    NotifierProvider<CurrentInvoice, Invoice?>.internal(
      CurrentInvoice.new,
      name: r'currentInvoiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentInvoiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentInvoice = Notifier<Invoice?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
