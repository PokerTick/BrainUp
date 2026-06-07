import 'package:brainup/pages/Login&Signup/singup.dart';
import 'package:brainup/pages/homepages.dart';
import 'package:brainup/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../services/api_service.dart';
import '../homepages.dart';
import '../trainer_dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMsg;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await ApiService.login(email: email, password: password);

    if (!mounted) return;

    if (result != null) {
      // Save tokens
      await ApiService.saveTokens(
        accessToken: result['accessToken'] as String? ?? '',
        refreshToken: result['refreshToken'] as String? ?? '',
      );

      // Navigate to home, clearing the entire back stack
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Homepages()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Invalid email or password. Please try again.';
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await ApiService.googleSignIn();

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Homepages()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMsg = result['message'] ?? 'Google sign-in failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Purple SVG background (top half)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              child: SvgPicture.asset(
                'lib/assets/BackgroundLogSign.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          // Login form card
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 100, bottom: 40),
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'lib/assets/Logo.png',
                        width: MediaQuery.of(context).size.width * 0.85 * 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMsg != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMsg!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email field
                    const Text(
                      'Email Address',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Enter Email Address',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF4A44F2),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    const Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF4A44F2),
                            width: 1.5,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Remember me + Forgot password
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: const Color(0xFF4A44F2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember me',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF4A44F2),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A44F2),
                          disabledBackgroundColor:
                              const Color(0xFF4A44F2).withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    const Center(
                      child: Text(
                        'Or',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Google login button (placeholder — OAuth flow needed)
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4285F4),
                            Color(0xFFEA4335),
                            Color(0xFFFBBC05),
                            Color(0xFF34A853),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('lib/assets/GoogleLogo.png'),
                              const SizedBox(width: 5),
                              const Text(
                                'Google',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register link
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Singup(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  color: Color(0xFF4A44F2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
