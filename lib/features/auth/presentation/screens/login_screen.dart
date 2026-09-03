import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../main.dart';

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double strokeWidth = size.width * 0.22;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Rect rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.4, 1.9, false, paint);

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.5, 1.5, false, paint);

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3.0, 0.9, false, paint);

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.9, 2.0, false, paint);

    // Blue horizontal bar
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final double barHeight = strokeWidth;
    final double barWidth = radius * 0.9;
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - barHeight / 2,
        barWidth,
        barHeight,
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate authentication delay
    await Future.delayed(const Duration(milliseconds: 600));

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_guest', false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed in successfully with Google'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
        ),
      );
      context.go('/');
    }
  }

  Future<void> _handleContinueWithoutLogin() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('is_guest', true);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),

              // App Hero / Branding Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0277BD), Color(0xFF01579B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0277BD).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Enne Marakkalle',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Professional Invoice Generator',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Welcome Heading
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to sync your business invoices and settings across all your devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Google Sign-In Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E293B),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0277BD)),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GoogleLogoWidget(size: 22),
                          SizedBox(width: 14),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // Continue without Login Button
              OutlinedButton(
                onPressed: _handleContinueWithoutLogin,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: Color(0xFF94A3B8), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continue without Login',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
