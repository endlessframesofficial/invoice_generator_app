import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/invoice/presentation/screens/create_invoice_screen.dart';
import '../../features/invoice/presentation/screens/recent_invoices_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/pdf/presentation/screens/pdf_preview_screen.dart';
import '../../main.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final isGuest = prefs.getBool('is_guest') ?? false;

  String initialLocation;
  if (!hasCompletedOnboarding) {
    initialLocation = '/onboarding';
  } else if (!isLoggedIn && !isGuest) {
    initialLocation = '/login';
  } else {
    initialLocation = '/';
  }

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'create-invoice',
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: '/pdf-preview',
        name: 'pdf-preview',
        builder: (context, state) => const PdfPreviewScreen(),
      ),
      GoRoute(
        path: '/recent-invoices',
        name: 'recent-invoices',
        builder: (context, state) => const RecentInvoicesScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('No route defined for ${state.uri}'),
      ),
    ),
  );
}
