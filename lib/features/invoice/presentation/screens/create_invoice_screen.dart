import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../company/domain/company_info.dart';
import '../../../company/presentation/providers/company_provider.dart';
import '../../../customer/domain/customer.dart';
import '../../../customer/presentation/providers/customer_provider.dart';
import '../../data/invoice_repository.dart';
import '../../domain/invoice.dart';
import '../providers/invoice_notifier.dart';
import '../widgets/customer_section.dart';
import '../widgets/document_customization_section.dart';
import '../widgets/payment_section.dart';
import '../widgets/service_items_section.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentBottomNavIndex = 0;

  void _handleGeneratePdf() {
    final notifier = ref.read(invoiceNotifierProvider.notifier);

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the validation errors in the form'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final invoice = notifier.generateInvoice();

    if (invoice != null) {
      // Automatically save party if not already present in database
      final customer = invoice.customer;
      if (customer.name.trim().isNotEmpty && customer.phone.trim().isNotEmpty) {
        ref.read(customerListProvider.notifier).addCustomer(customer);
      }

      ref.read(currentInvoiceProvider.notifier).setInvoice(invoice);
      // Invalidate saved invoices provider to update Home tab instantly
      ref.invalidate(savedInvoicesListProvider);
      context.push('/pdf-preview');
    } else {
      final errorMsg = ref.read(invoiceNotifierProvider).errorMessage ?? 'Validation failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _selectPartyForInvoice(Customer customer) {
    ref.read(invoiceNotifierProvider.notifier).updateCustomerInfo(
          name: customer.name,
          phone: customer.phone,
          email: customer.email,
          address: customer.address,
        );
    setState(() {
      _currentBottomNavIndex = 1; // Switch to Invoices tab
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${customer.name} for new invoice'),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyInfo = ref.watch(companyInfoStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      drawer: _buildDrawer(context, companyInfo),
      body: SafeArea(
        child: IndexedStack(
          index: _currentBottomNavIndex,
          children: [
            // Tab 0: Clean Home Dashboard
            _buildHomeDashboardTab(companyInfo),

            // Tab 1: Clean Invoices Form (No company info card, no history button)
            _buildInvoicesTab(),

            // Tab 2: Parties / Customers
            _PartiesTab(onSelectPartyForInvoice: _selectPartyForInvoice),

            // Tab 3: Settings & Company Details Update
            const _SettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.cardBorderColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() {
              _currentBottomNavIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Parties',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // Drawer
  Widget _buildDrawer(BuildContext context, dynamic companyInfo) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final authUser = ref.watch(authStateProvider).value;
    final photoUrl = authUser?.photoURL;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (photoUrl != null && photoUrl.trim().isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
              child: (photoUrl == null || photoUrl.trim().isEmpty)
                  ? const Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 32)
                  : null,
            ),
            accountName: Text(
              companyInfo.name.isNotEmpty ? companyInfo.name : (authUser?.displayName ?? 'User'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            accountEmail: Text(
              isLoggedIn ? (companyInfo.email.isNotEmpty ? companyInfo.email : (authUser?.email ?? 'Signed In User')) : 'Guest Account',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded, color: AppTheme.primaryColor),
            title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentBottomNavIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Invoices'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentBottomNavIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('Parties & Customers'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentBottomNavIndex = 2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings & Company Profile'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentBottomNavIndex = 3);
            },
          ),
          const Divider(),
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.account_circle_outlined, color: AppTheme.primaryColor),
              title: const Text('Sign In'),
              onTap: () {
                Navigator.pop(context);
                context.push('/login');
              },
            ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authRepositoryProvider).signOut();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'BILLINGBOOK',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '🇮🇳 Made with ❤️ in India',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 0: CLEAN HOME DASHBOARD
  Widget _buildHomeDashboardTab(dynamic companyInfo) {
    final invoicesAsync = ref.watch(savedInvoicesListProvider);
    final authUser = ref.watch(authStateProvider).value;
    final photoUrl = authUser?.photoURL;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE6F4EA), Color(0xFFF3E8FF), Color(0xFFE0F2FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        backgroundImage: (photoUrl != null && photoUrl.trim().isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (photoUrl == null || photoUrl.trim().isEmpty)
                            ? const Icon(Icons.menu_rounded, color: AppTheme.primaryColor, size: 22)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      companyInfo.name.isNotEmpty ? companyInfo.name : 'BillingBook User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark, size: 22),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Real Metric Summary Cards
          invoicesAsync.when(
            data: (invoices) {
              final totalCount = invoices.length;
              final paidCount = invoices.where((i) => i.paymentStatus == PaymentStatus.paid).length;
              final totalRevenue = invoices.fold(0.0, (sum, i) => sum + i.totalAmount);

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorderColor, width: 1),
                ),
                child: Row(
                  children: [
                    _buildMetricColumn('Total Invoices', '$totalCount', 'Generated'),
                    _buildMetricDivider(),
                    _buildMetricColumn('Paid Invoices', '$paidCount', 'Fully Settled'),
                    _buildMetricDivider(),
                    _buildMetricColumn('Total Billed', '₹${totalRevenue.toStringAsFixed(0)}', 'Revenue'),
                  ],
                ),
              );
            },
            loading: () => Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Dashboard overview'),
            ),
          ),

          const SizedBox(height: 24),

          // Clean Core Quick Actions (4 Cards)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.8,
            children: [
              _buildActionGridItem(
                label: 'Create Invoice',
                icon: Icons.note_add_rounded,
                bgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF15803D),
                onTap: () => setState(() => _currentBottomNavIndex = 1),
              ),
              _buildActionGridItem(
                label: 'Parties & Customers',
                icon: Icons.people_rounded,
                bgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF1D4ED8),
                onTap: () => setState(() => _currentBottomNavIndex = 2),
              ),
              _buildActionGridItem(
                label: 'Recent Bills',
                icon: Icons.history_rounded,
                bgColor: const Color(0xFFFEF9C3),
                iconColor: const Color(0xFFA16207),
                onTap: () => context.push('/recent-invoices'),
              ),
              _buildActionGridItem(
                label: 'Settings & Profile',
                icon: Icons.settings_rounded,
                bgColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFC2410C),
                onTap: () => setState(() => _currentBottomNavIndex = 3),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Real Recent Invoices Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Invoices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/recent-invoices'),
                child: const Text('See all', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Real Saved Invoices List
          invoicesAsync.when(
            data: (invoices) {
              if (invoices.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorderColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        'No invoices created yet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap "Create Invoice" to generate your first bill',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => setState(() => _currentBottomNavIndex = 1),
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        label: const Text('Create Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }

              // Display up to 5 recent invoices
              final recentList = invoices.take(5).toList();
              return Column(
                children: recentList.map((invoice) => _buildRealInvoiceTile(invoice)).toList(),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // TAB 1: CLEAN INVOICES TAB
  Widget _buildInvoicesTab() {
    return Column(
      children: [
        // Clean Top App Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create Invoice',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              IconButton(
                onPressed: () {
                  ref.read(invoiceNotifierProvider.notifier).resetForm();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice form reset')),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                tooltip: 'Reset form',
              ),
            ],
          ),
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeInSlide(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Billing Invoice',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Fill in customer and service details to generate PDF',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FadeInSlide(child: CustomerSection()),
                  const SizedBox(height: 16),
                  const FadeInSlide(child: ServiceItemsSection()),
                  const SizedBox(height: 16),
                  const FadeInSlide(child: PaymentSection()),
                  const SizedBox(height: 16),
                  const FadeInSlide(child: DocumentCustomizationSection()),
                  const SizedBox(height: 24),
                  Consumer(
                    builder: (context, ref, child) {
                      final totalAmount = ref.watch(invoiceNotifierProvider.select((s) => s.totalAmount));
                      return ElevatedButton(
                        onPressed: _handleGeneratePdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Generate PDF (₹${totalAmount.toStringAsFixed(2)})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealInvoiceTile(Invoice invoice) {
    final statusBg = invoice.paymentStatus == PaymentStatus.paid
        ? const Color(0xFFDCFCE7)
        : (invoice.paymentStatus == PaymentStatus.partiallyPaid ? const Color(0xFFFEF9C3) : const Color(0xFFFEE2E2));
    final statusColor = invoice.paymentStatus == PaymentStatus.paid
        ? const Color(0xFF15803D)
        : (invoice.paymentStatus == PaymentStatus.partiallyPaid ? const Color(0xFFA16207) : const Color(0xFFB91C1C));
    final statusLabel = invoice.paymentStatus == PaymentStatus.paid
        ? 'Paid'
        : (invoice.paymentStatus == PaymentStatus.partiallyPaid ? 'Partial' : 'Unpaid');

    final formattedDate = '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}';

    return GestureDetector(
      onTap: () {
        ref.read(currentInvoiceProvider.notifier).setInvoice(invoice);
        context.push('/pdf-preview');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorderColor, width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.mintBackground,
              radius: 20,
              child: Text(
                invoice.customer.name.isNotEmpty ? invoice.customer.name[0].toUpperCase() : 'I',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.customer.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${invoice.invoiceNumber} • $formattedDate',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ ${invoice.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String subtext) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(subtext, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      height: 36,
      width: 1,
      color: AppTheme.cardBorderColor,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildActionGridItem({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.cardBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TAB 2: PARTIES TAB
class _PartiesTab extends ConsumerStatefulWidget {
  final ValueChanged<Customer> onSelectPartyForInvoice;

  const _PartiesTab({required this.onSelectPartyForInvoice});

  @override
  ConsumerState<_PartiesTab> createState() => _PartiesTabState();
}

class _PartiesTabState extends ConsumerState<_PartiesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddPartyDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Party', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Party / Customer Name*'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number*'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Phone is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final newParty = Customer(
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                        );
                        await ref.read(customerListProvider.notifier).addCustomer(newParty);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added party: ${newParty.name}')),
                          );
                        }
                      }
                    },
                    child: const Text('Save Party', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parties = ref.watch(customerListProvider);
    final filteredParties = parties.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.phone.contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Parties & Customers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ElevatedButton.icon(
                onPressed: _showAddPartyDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                label: const Text('+ Add Party', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search by party name or phone...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredParties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty ? 'No parties found. Click "+ Add Party" to create one.' : 'No party matching "$_searchQuery"',
                          style: const TextStyle(color: AppTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredParties.length,
                    itemBuilder: (ctx, idx) {
                      final party = filteredParties[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.cardBorderColor, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.mintBackground,
                                child: Text(
                                  party.name.isNotEmpty ? party.name[0].toUpperCase() : 'P',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      party.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      party.phone,
                                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                    ),
                                    if (party.email.isNotEmpty)
                                      Text(
                                        party.email,
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => widget.onSelectPartyForInvoice(party),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.mintBackground,
                                  foregroundColor: AppTheme.primaryColor,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// TAB 3: SETTINGS TAB WITH UPDATE DETAILS OF COMPANY
class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab();

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isSyncing = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final company = ref.read(companyInfoStateProvider);
    _nameController = TextEditingController(text: company.name);
    _phoneController = TextEditingController(text: company.phone);
    _emailController = TextEditingController(text: company.email);
    _addressController = TextEditingController(text: company.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveCompanyDetails() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedCompany = CompanyInfo(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
    );

    await ref.read(companyInfoStateProvider.notifier).updateCompanyInfo(updatedCompany);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Company details updated successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _handleCloudSync() async {
    setState(() => _isSyncing = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      final userId = user?.uid ?? 'guest_user_${DateTime.now().day}';
      final companyInfo = ref.read(companyInfoStateProvider);
      final parties = ref.read(customerListProvider);
      final invoices = await ref.read(invoiceRepositoryProvider).getInvoices();

      await ref.read(firestoreSyncServiceProvider).syncAllToCloud(
            userId: userId,
            companyInfo: companyInfo,
            parties: parties,
            invoices: invoices,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Synced ${invoices.length} invoices & ${parties.length} parties to Cloud Firestore!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorText = e.toString().replaceAll('Exception: ', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorText),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyInfoStateProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final authUser = ref.watch(authStateProvider).value;
    final photoUrl = authUser?.photoURL;

    // Sync controllers if state changed externally
    if (company.name != _nameController.text && !FocusScope.of(context).hasFocus) {
      _nameController.text = company.name;
    }
    if (company.phone != _phoneController.text && !FocusScope.of(context).hasFocus) {
      _phoneController.text = company.phone;
    }
    if (company.email != _emailController.text && !FocusScope.of(context).hasFocus) {
      _emailController.text = company.email;
    }
    if (company.address != _addressController.text && !FocusScope.of(context).hasFocus) {
      _addressController.text = company.address;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Settings & Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 16),

          // Account Badge Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.mintBackground,
                    backgroundImage: (photoUrl != null && photoUrl.trim().isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.trim().isEmpty)
                        ? const Icon(Icons.business_rounded, color: AppTheme.primaryColor, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name.isNotEmpty ? company.name : 'BillingBook Business',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLoggedIn ? (company.email.isNotEmpty ? company.email : 'Logged In User') : 'Guest Session',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLoggedIn ? AppTheme.mintBackground : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isLoggedIn ? 'Signed In' : 'Guest Mode',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLoggedIn ? AppTheme.primaryColor : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // UPDATE DETAILS OF COMPANY SECTION
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Update Company Details',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'These details appear on your printed PDF invoices',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const Divider(height: 24),

                    // Company Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Company / Business Name*',
                        prefixIcon: Icon(Icons.business_rounded, color: AppTheme.primaryColor, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Company name cannot be empty';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number*',
                        prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // Email Address
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor, size: 20),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Business Address',
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.primaryColor, size: 20),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _handleSaveCompanyDetails,
                        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Save Company Details',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // CLOUD SYNC SECTION (Only for Logged-In Users)
          if (isLoggedIn) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_sync_rounded, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Cloud Sync (Firestore)',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sync company details, parties, and invoices to Firebase Cloud Firestore',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSyncing ? null : _handleCloudSync,
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor)),
                              )
                            : const Icon(Icons.cloud_upload_rounded, color: AppTheme.primaryColor),
                        label: Text(
                          _isSyncing ? 'Syncing to Firestore...' : 'Sync with Cloud',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Account Options & Logout
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history_rounded, color: AppTheme.primaryColor),
                  title: const Text('Recent Invoices & Bills'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/recent-invoices'),
                ),
                if (!isLoggedIn) const Divider(height: 1),
                if (!isLoggedIn)
                  ListTile(
                    leading: const Icon(Icons.account_circle_outlined, color: AppTheme.primaryColor),
                    title: const Text('Sign in with Google'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/login'),
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Clear secure session & log out'),
                  onTap: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
