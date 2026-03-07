import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  static const _bg       = Color(0xFF0A0E1A);
  static const _surface2 = Color(0xFF1A2235);
  static const _accent   = Color(0xFF00D4AA);
  static const _textMuted= Color(0xFF8A9BC0);
  static const _textDim  = Color(0xFF556080);
  static const _danger   = Color(0xFFFF4D6D);
  static const _border   = Color(0x12FFFFFF);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.firebaseUser;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.0,
            colors: [Color(0x1500D4AA), _bg],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0x1200D4AA),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x3300D4AA),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('📬', style: TextStyle(fontSize: 38)),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Verify your\nemail address',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'We sent a verification link to your email.\nPlease check your inbox and verify\nbefore continuing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mail_outline_rounded,
                          color: _accent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        email,
                        style: const TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () async {
                    await auth.reloadUser();
                    final refreshed = auth.firebaseUser;
                    if (!context.mounted) return;
                    if (refreshed != null && refreshed.emailVerified) {
                      Navigator.pushReplacementNamed(context, '/main');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Email not verified yet.'),
                          backgroundColor: _surface2,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_accent, Color(0xFF00B896)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4000D4AA),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "I've Verified — Continue →",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () async {
                    await user?.sendEmailVerification();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Verification email resent.'),
                        backgroundColor: _surface2,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border),
                    ),
                    child: const Center(
                      child: Text(
                        'Resend verification email',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Didn't receive the email?\nCheck your spam folder or resend.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: _textDim,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () async {
                    await auth.signOut();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: _danger, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Sign out',
                        style: TextStyle(
                          color: _danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}