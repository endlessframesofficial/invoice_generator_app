import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../domain/customer.dart';

final customerListProvider = StateNotifierProvider<CustomerListNotifier, List<Customer>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CustomerListNotifier(prefs);
});

class CustomerListNotifier extends StateNotifier<List<Customer>> {
  final dynamic _prefs;
  static const String _storageKey = 'saved_parties_list';

  CustomerListNotifier(this._prefs) : super([]) {
    _loadCustomers();
  }

  void _loadCustomers() {
    try {
      final jsonList = _prefs.getStringList(_storageKey) ?? [];
      if (jsonList.isNotEmpty) {
        state = jsonList
            .map((e) => Customer.fromJson(jsonDecode(e) as Map<String, dynamic>))
            .toList();
      } else {
        state = [];
      }
    } catch (_) {
      state = [];
    }
  }

  Future<void> addCustomer(Customer customer) async {
    final cleanPhone = customer.phone.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final cleanName = customer.name.trim().toLowerCase();

    // Avoid duplicate entries: check if party exists by phone or name
    final index = state.indexWhere((c) {
      final p = c.phone.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      final n = c.name.trim().toLowerCase();
      return (p.isNotEmpty && p == cleanPhone) || (n.isNotEmpty && n == cleanName);
    });

    if (index != -1) {
      final updatedList = List<Customer>.from(state);
      updatedList[index] = customer;
      state = updatedList;
    } else {
      state = [customer, ...state];
    }
    await _saveToPrefs(state);
  }

  Future<void> removeCustomer(String phone) async {
    state = state.where((c) => c.phone != phone).toList();
    await _saveToPrefs(state);
  }

  Future<void> _saveToPrefs(List<Customer> customers) async {
    try {
      final jsonList = customers.map((c) => jsonEncode(c.toJson())).toList();
      await _prefs.setStringList(_storageKey, jsonList);
    } catch (_) {}
  }
}
