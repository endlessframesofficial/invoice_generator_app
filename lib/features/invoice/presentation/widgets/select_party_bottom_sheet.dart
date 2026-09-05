import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/customer.dart';
import '../../../customer/presentation/providers/customer_provider.dart';

class SelectPartyBottomSheet extends ConsumerStatefulWidget {
  final ValueChanged<Customer> onSelectCustomer;

  const SelectPartyBottomSheet({
    super.key,
    required this.onSelectCustomer,
  });

  @override
  ConsumerState<SelectPartyBottomSheet> createState() => _SelectPartyBottomSheetState();
}

class _SelectPartyBottomSheetState extends ConsumerState<SelectPartyBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Contact>? _phoneContacts;
  bool _isLoadingContacts = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _phoneContacts == null && !_isLoadingContacts) {
        _loadPhoneContacts();
      }
    });
    // Request contacts after frame callback so dialog appears smoothly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPhoneContacts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPhoneContacts() async {
    setState(() {
      _isLoadingContacts = true;
      _permissionDenied = false;
    });

    try {
      var status = await Permission.contacts.status;
      if (!status.isGranted) {
        status = await Permission.contacts.request();
      }

      if (status.isGranted) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        if (mounted) {
          setState(() {
            _phoneContacts = contacts;
            _isLoadingContacts = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _isLoadingContacts = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _isLoadingContacts = false;
        });
      }
    }
  }

  Customer _contactToCustomer(Contact contact) {
    String name = contact.displayName.trim();
    if (name.isEmpty) {
      name = '${contact.name.first} ${contact.name.last}'.trim();
    }
    if (name.isEmpty) {
      name = 'Contact';
    }

    String phone = '';
    if (contact.phones.isNotEmpty) {
      phone = contact.phones.first.number.trim();
    }

    String email = '';
    if (contact.emails.isNotEmpty) {
      email = contact.emails.first.address.trim();
    }

    String address = '';
    if (contact.addresses.isNotEmpty) {
      address = contact.addresses.first.address.trim();
    }

    return Customer(
      name: name,
      phone: phone,
      email: email,
      address: address,
    );
  }

  void _showAddPartyDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Party', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Party / Customer Name *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address (Optional)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Billing Address (Optional)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newParty = Customer(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                address: addressCtrl.text.trim(),
              );
              await ref.read(customerListProvider.notifier).addCustomer(newParty);
              if (mounted) {
                Navigator.pop(ctx);
                widget.onSelectCustomer(newParty);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save & Select', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedParties = ref.watch(customerListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle pill
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header title & close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Party / Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Search input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.mintBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tab Bar (All Parties vs Device Contacts)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.primaryColor,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_alt_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('All Parties'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.import_contacts_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Contacts'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // TabBarView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Saved Parties
                _buildSavedPartiesTab(savedParties),

                // TAB 2: Device Phone Contacts
                _buildPhoneContactsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPartiesTab(List<Customer> savedParties) {
    final filtered = savedParties.where((party) {
      if (_searchQuery.isEmpty) return true;
      return party.name.toLowerCase().contains(_searchQuery) || party.phone.contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        // Quick Add New Party Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddPartyDialog(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.person_add_rounded, color: AppTheme.primaryColor, size: 18),
              label: const Text(
                '+ Add New Party Directly',
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: savedParties.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No saved parties found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap "+ Add New Party Directly" above or pick from Contacts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              : (filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No saved party matches "$_searchQuery"',
                          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final party = filtered[index];
                        final initial = party.name.isNotEmpty ? party.name[0].toUpperCase() : 'P';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.mintBackground,
                            child: Text(
                              initial,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                            ),
                          ),
                          title: Text(
                            party.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                party.phone,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                              ),
                              if (party.address.isNotEmpty)
                                Text(
                                  party.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.mintBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Select',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          onTap: () {
                            widget.onSelectCustomer(party);
                            Navigator.pop(context);
                          },
                        );
                      },
                    )),
        ),
      ],
    );
  }

  Widget _buildPhoneContactsTab() {
    if (_isLoadingContacts) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Loading phone contacts...', style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    if (_permissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.contacts_rounded, size: 60, color: Colors.orange.shade300),
              const SizedBox(height: 12),
              const Text(
                'Permission Required',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please grant contacts permission to select phone contacts.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final status = await Permission.contacts.status;
                  if (status.isPermanentlyDenied) {
                    await openAppSettings();
                  } else {
                    await _loadPhoneContacts();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 18),
                label: const Text('Grant Permission / Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final contacts = _phoneContacts ?? [];

    if (contacts.isEmpty) {
      return const Center(
        child: Text(
          'No phone contacts found.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    final filtered = contacts.where((contact) {
      if (_searchQuery.isEmpty) return true;
      final name = contact.displayName.toLowerCase();
      final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
      return name.contains(_searchQuery) || phone.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No contact matches "$_searchQuery"',
          style: const TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contact = filtered[index];
        final name = contact.displayName.isNotEmpty
            ? contact.displayName
            : '${contact.name.first} ${contact.name.last}'.trim();
        final phone = contact.phones.isNotEmpty ? contact.phones.first.number : 'No phone number';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Text(
              initial,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
          ),
          subtitle: Text(
            phone,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Select',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          onTap: () {
            final customer = _contactToCustomer(contact);
            widget.onSelectCustomer(customer);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
