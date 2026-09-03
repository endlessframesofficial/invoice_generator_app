import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String badgeText;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.badgeText,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = const [
    OnboardingStep(
      title: 'Create Invoices Instantly',
      description: 'Generate sleek, professional billing documents for your clients in seconds with automated tax & discount calculations.',
      icon: Icons.receipt_long_rounded,
      gradientColors: [Color(0xFF0277BD), Color(0xFF0097A7)],
      badgeText: 'Step 1 of 4',
    ),
    OnboardingStep(
      title: 'Customize Business & Payments',
      description: 'Add your company details, logo, and integrated UPI payment QR codes for fast, seamless customer payments.',
      icon: Icons.qr_code_2_rounded,
      gradientColors: [Color(0xFF00838F), Color(0xFF00ACC1)],
      badgeText: 'Step 2 of 4',
    ),
    OnboardingStep(
      title: 'PDF Generation & Sharing',
      description: 'Preview print-ready PDF invoices directly in the app. Print or share instantly via WhatsApp, email, or other apps.',
      icon: Icons.picture_as_pdf_rounded,
      gradientColors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
      badgeText: 'Step 3 of 4',
    ),
    OnboardingStep(
      title: 'Track & Manage Recent Bills',
      description: 'Access your bill history, search past invoices easily, and recreate or re-share client bills anytime.',
      icon: Icons.history_rounded,
      gradientColors: [Color(0xFF2E7D32), Color(0xFF43A047)],
      badgeText: 'Step 4 of 4',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _steps.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isLastPage)
            TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Visual Illustration Card
                        Container(
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: step.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: step.gradientColors[0].withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background decorative circles
                              Positioned(
                                right: -20,
                                top: -20,
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              Positioned(
                                left: -30,
                                bottom: -30,
                                child: CircleAvatar(
                                  radius: 90,
                                  backgroundColor: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        step.icon,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        step.badgeText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Title
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF0277BD)
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(56, 52),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF0277BD),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: const Color(0xFF0277BD),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage ? 'Get Started' : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastPage
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
