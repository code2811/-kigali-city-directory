import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscurePassword = true;

  static const _bg         = Color(0xFF0A0E1A);
  static const _surface2   = Color(0xFF1A2235);
  static const _accent     = Color(0xFF00D4AA);
  static const _textMuted  = Color(0xFF8A9BC0);
  static const _textDim    = Color(0xFF556080);
  static const _border     = Color(0x12FFFFFF);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.8),
            radius: 1.2,
            colors: [Color(0x1E00D4AA), _bg],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_accent, Color(0xFF00A882)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x4D00D4AA),
                                blurRadius: 32,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🗺️', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              TextSpan(text: 'Kigali'),
                              TextSpan(
                                text: 'Dir',
                                style: TextStyle(color: _accent),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'City Services & Places',
                          style: TextStyle(fontSize: 12, color: _textDim),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to your account to continue',
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),

                  const SizedBox(height: 32),

                  _label('Email'),
                  const SizedBox(height: 6),
                  _inputField(
                    hint: 'you@example.com',
                    icon: Icons.mail_outline_rounded,
                    onChanged: (v) => _email = v,
                    validator: (v) =>
                        v != null && v.contains('@') ? null : 'Enter a valid email',
                  ),

                  const SizedBox(height: 16),

                  _label('Password'),
                  const SizedBox(height: 6),
                  _inputField(
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscurePassword,
                    onChanged: (v) => _password = v,
                    validator: (v) =>
                        v != null && v.length >= 6 ? null : 'Password too short',
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _textDim,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 12,
                        color: _accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (auth.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFF4D6D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x33FF4D6D)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFFF4D6D), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: const TextStyle(
                                  color: Color(0xFFFF4D6D), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _primaryButton(
                    label: 'Sign In',
                    isLoading: auth.isLoading,
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        await auth.signIn(_email, _password);
                        await auth.reloadUser();
                        final user = auth.firebaseUser;
                        if (!mounted) return;
                        if (user != null) {
                          Navigator.pushReplacementNamed(context, '/main');
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/signup'),
                      child: RichText(
                        text: const TextSpan(
                          style:
                              TextStyle(fontSize: 13, color: _textDim),
                          children: [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: _accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: _textDim,
        ),
      );

  Widget _inputField({
    required String hint,
    required IconData icon,
    bool obscure = false,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      obscureText: obscure,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textDim, fontSize: 13),
        prefixIcon: Icon(icon, color: _textDim, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: _surface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x6600D4AA), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x66FF4D6D)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x99FF4D6D)),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF4D6D), fontSize: 11),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}