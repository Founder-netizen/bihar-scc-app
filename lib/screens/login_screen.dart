import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _stayLoggedIn = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    
    // Auto-check biometrics if possible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoBiometric();
    });
  }

  void _checkAutoBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // We can't easily check 'userId' existence here without making the checkBiometric 
    // more robust, but the provider already handles stored credentials.
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF004B23), // Bihar Green
              Color(0xFF002D15), // Deep Forest Green
              Color(0xFF001A0C), // Near Black Green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient Glow Effects
            Positioned(
              top: -100,
              right: -50,
              child: _buildGlowCircle(300, const Color(0xFFFFD700).withOpacity(0.08)),
            ),
            Positioned(
              bottom: -150,
              left: -50,
              child: _buildGlowCircle(400, const Color(0xFF00FF87).withOpacity(0.05)),
            ),
            
            FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Premium Logo Container
                        _buildLogo(),
                        const SizedBox(height: 32),
                        
                        // Header Text
                        _buildHeader(),
                        const SizedBox(height: 48),
                        
                        // Login Glass Card
                        _buildLoginCard(authProvider),
                        const SizedBox(height: 32),
                        
                        // Biometric Quick Access
                        _buildBiometricButton(authProvider),
                        
                        const SizedBox(height: 40),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.account_balance_rounded, size: 64, color: Color(0xFFFFD700)),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'MNSSBY PORTAL',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFD700),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'BIHAR STUDENT\n',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: 'CREDIT CARD',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFFD700),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(AuthProvider authProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              _buildModernTextField(
                controller: _usernameController,
                label: 'User Name',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 24),
              _buildModernTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _stayLoggedIn,
                      onChanged: (v) => setState(() => _stayLoggedIn = v ?? true),
                      activeColor: const Color(0xFFFFD700),
                      checkColor: const Color(0xFF004B23),
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Stay logged in for quick access',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildLoginButton(authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFFFD700).withOpacity(0.7), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthProvider authProvider) {
    return authProvider.isLoading
        ? const CircularProgressIndicator(color: Color(0xFFFFD700))
        : Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFC9A200)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _handleLogin(authProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                'SIGN IN SECURELY',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0D1D14),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          );
  }

  Widget _buildBiometricButton(AuthProvider authProvider) {
    return OutlinedButton.icon(
      onPressed: () async {
        final success = await authProvider.checkBiometric();
        if (!success && mounted) {
           _showErrorSnackBar('Biometric authentication failed.');
        }
      },
      icon: const Icon(Icons.fingerprint_rounded, size: 28),
      label: Text(
        'LOGIN WITH BIOMETRICS',
        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFFFD700),
        side: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: Colors.white10),
        const SizedBox(height: 16),
        Text(
          'GOVERNMENT OF BIHAR',
          style: GoogleFonts.outfit(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Education Finance Corporation Ltd.',
          style: GoogleFonts.outfit(
            color: Colors.white24,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter your credentials.');
      return;
    }

    final success = await authProvider.login(
      _usernameController.text,
      _passwordController.text,
      _stayLoggedIn,
    );
    
    if (!success && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF002D15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white12)),
          title: Text('Authentication Failed', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            authProvider.errorMessage ?? 'Please check your username and password.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('RETRY', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    }
  }
}
