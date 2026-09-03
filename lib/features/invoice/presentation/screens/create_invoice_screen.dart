import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fade_in_slide.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../company/presentation/providers/company_provider.dart';
import '../providers/invoice_notifier.dart';
import '../widgets/company_section.dart';
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
  String _selectedFilter = 'All invoices';

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
      ref.read(currentInvoiceProvider.notifier).setInvoice(invoice);
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
            // Tab 0: Home Dashboard (Exact Screen 3 Design)
            _buildHomeDashboardTab(companyInfo),

            // Tab 1: Create Invoice Form
            _buildInvoiceFormTab(),

            // Tab 2: Recent Bills / Reports
            _buildReportsTab(),

            // Tab 3: Menu / Profile
            _buildMenuTab(companyInfo),
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
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_rounded),
              activeIcon: Icon(Icons.menu_open_rounded),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }

  // Drawer
  Widget _buildDrawer(BuildContext context, dynamic companyInfo) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.send_rounded, color: AppTheme.primaryColor, size: 32),
            ),
            accountName: Text(
              companyInfo.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            accountEmail: Text(companyInfo.email, style: const TextStyle(color: Colors.white70)),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded, color: AppTheme.primaryColor),
            title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentBottomNavIndex = 0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_add_rounded),
            title: const Text('Create Invoice'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentBottomNavIndex = 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Recent Bills'),
            onTap: () {
              Navigator.pop(context);
              context.push('/recent-invoices');
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: const Text('App Tour & Features'),
            onTap: () {
              Navigator.pop(context);
              context.push('/onboarding');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Account / Sign In'),
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
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.setBool('is_logged_in', false);
              await prefs.setBool('is_guest', false);
              if (mounted) {
                context.go('/login');
              }
            },
          ),
          const Divider(),
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

  // TAB 0: HOME DASHBOARD (Exact Screen 3 Design)
  Widget _buildHomeDashboardTab(dynamic companyInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Container with Soft Mesh Gradient
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.send_rounded, color: AppTheme.primaryColor, size: 22),
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
                      companyInfo.name.isNotEmpty ? companyInfo.name : 'Rahat Nur',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark, size: 22),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Total / Paid / Pending Metric Cards Row (Screen 3 Top Card)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorderColor, width: 1),
            ),
            child: Row(
              children: [
                _buildMetricColumn('Total invoices', '35', 'Last 24 hours'),
                _buildMetricDivider(),
                _buildMetricColumn('Paid invoice', '30', 'Last 30 days'),
                _buildMetricDivider(),
                _buildMetricColumn('Pending invoice', '05', 'Last 30 days'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Grid Quick Actions (6 Items)
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.92,
            children: [
              _buildActionGridItem(
                label: 'Create invoice',
                icon: Icons.note_add_rounded,
                bgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF15803D),
                onTap: () => setState(() => _currentBottomNavIndex = 1),
              ),
              _buildActionGridItem(
                label: 'Advance invoice',
                icon: Icons.request_quote_rounded,
                bgColor: const Color(0xFFFEF9C3),
                iconColor: const Color(0xFFA16207),
                onTap: () => setState(() => _currentBottomNavIndex = 1),
              ),
              _buildActionGridItem(
                label: 'Customers',
                icon: Icons.people_rounded,
                bgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF1D4ED8),
                onTap: () {},
              ),
              _buildActionGridItem(
                label: 'Items / Services',
                icon: Icons.dashboard_customize_rounded,
                bgColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFC2410C),
                onTap: () {},
              ),
              _buildActionGridItem(
                label: 'Expenses',
                icon: Icons.receipt_rounded,
                bgColor: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFB91C1C),
                onTap: () {},
              ),
              _buildActionGridItem(
                label: 'Income',
                icon: Icons.account_balance_wallet_rounded,
                bgColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF047857),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Recent Transactions Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent transactions',
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

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All invoices'),
                const SizedBox(width: 8),
                _buildFilterChip('Expenses'),
                const SizedBox(width: 8),
                _buildFilterChip('Income'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transactions List Items (Matches Screen 3)
          _buildTransactionTile(
            name: 'Karim Ahmed',
            subtitle: 'Sales • #INV0678 • 25 Jun 2024',
            status: 'Paid',
            statusBg: const Color(0xFFDCFCE7),
            statusColor: const Color(0xFF15803D),
            amount: '₹ 35,000',
          ),
          _buildTransactionTile(
            name: 'Nasir Hussain',
            subtitle: 'Purchase • #INV0677 • 25 Jun 2024',
            status: 'Unpaid',
            statusBg: const Color(0xFFFEF9C3),
            statusColor: const Color(0xFFA16207),
            amount: '₹ 35,000',
          ),
          _buildTransactionTile(
            name: 'Kabir Ahmed',
            subtitle: 'Sales • #INV0676 • 24 Jun 2024',
            status: 'Due',
            statusBg: const Color(0xFFFEE2E2),
            statusColor: const Color(0xFFB91C1C),
            amount: '₹ 12,500',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String subtext) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 2),
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
      margin: const EdgeInsets.symmetric(horizontal: 10),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.cardBorderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.cardBorderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile({
    required String name,
    required String subtitle,
    required String status,
    required Color statusBg,
    required Color statusColor,
    required String amount,
  }) {
    return Container(
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
              name.isNotEmpty ? name[0] : 'K',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
                  status,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 1: CREATE INVOICE FORM
  Widget _buildInvoiceFormTab() {
    final totalAmount = ref.watch(invoiceNotifierProvider.select((state) => state.totalAmount));

    return Column(
      children: [
        // Top App Bar for Form
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create Invoice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              IconButton(
                onPressed: () {
                  ref.read(invoiceNotifierProvider.notifier).resetForm();
                },
                icon: const Icon(Icons.layers_clear_rounded, color: Colors.redAccent),
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
                                  'New Billing Details',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Fill in customer and item details',
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
                  const FadeInSlide(child: CompanySection()),
                  const SizedBox(height: 16),
                  const FadeInSlide(child: CustomerSection()),
                  const SizedBox(height: 16),
                  const FadeInSlide(child: ServiceItemsSection()),
                  const SizedBox(height: 16),
                  const FadeInSlide(child: PaymentSection()),
                  const SizedBox(height: 16),
                  const FadeInSlide(child: DocumentCustomizationSection()),
                  const SizedBox(height: 24),
                  ElevatedButton(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: REPORTS / RECENT INVOICES
  Widget _buildReportsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Invoices & Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/recent-invoices'),
                icon: const Icon(Icons.history_rounded),
                label: const Text('View All Recent Invoices'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: MENU / PROFILE
  Widget _buildMenuTab(dynamic companyInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.mintBackground,
            child: const Icon(Icons.business_rounded, color: AppTheme.primaryColor, size: 36),
          ),
          const SizedBox(height: 12),
          Text(companyInfo.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          Text(companyInfo.email, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.explore_outlined, color: AppTheme.primaryColor),
            title: const Text('App Tour & Features'),
            onTap: () => context.push('/onboarding'),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: AppTheme.primaryColor),
            title: const Text('Sign in with Google'),
            onTap: () => context.push('/login'),
          ),
        ],
      ),
    );
  }
}
