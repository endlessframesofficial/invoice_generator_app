import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/invoice/presentation/screens/create_invoice_screen.dart';
import '../../features/invoice/presentation/screens/recent_invoices_screen.dart';
import '../../features/pdf/presentation/screens/pdf_preview_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
