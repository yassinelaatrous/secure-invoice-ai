import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/heavenly_interaction.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _mfaEnabled = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await AuthService.login(role.toLowerCase(), 'password');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Login failed';
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Reset Password',
            style: GoogleFonts.fraunces(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          content: Text(
            'A secure password reset link has been dispatched to your registered email address. Please check your inbox.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Done',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGreen,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: double.infinity,
      color: AppTheme.surfaceCard,
      padding: const EdgeInsets.all(48),
      child: Stack(
        children: [
          FadeInSlide(
            delay: const Duration(milliseconds: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stacked_bar_chart, color: AppTheme.primary, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      'CEO-IT',
                      style: GoogleFonts.fraunces(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Secure, intelligent invoice management for modern executives.',
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: FadeInSlide(
              delay: const Duration(milliseconds: 300),
              direction: const Offset(0, 10),
              child: Row(
                children: [
                  const Icon(Icons.verified, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'ISO 27001 Certified',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.lock, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'End-to-End Encryption',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: FadeInSlide(
            delay: const Duration(milliseconds: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mobile Header
                if (MediaQuery.of(context).size.width < 800) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stacked_bar_chart, color: AppTheme.primary, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        'CEO-IT',
                        style: GoogleFonts.fraunces(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure Executive Platform',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 32),
                ],

                Text(
                  'Welcome back',
                  style: GoogleFonts.fraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please enter your credentials to access your secure space.',
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),

                // Email Field
                Text(
                  'Email Address',
                  style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'executive@company.com',
                    hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.mail_outline, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Password Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Password',
                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    HeavenlyInteraction(
                      onTap: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // MFA Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppTheme.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Multi-Factor Auth',
                            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                      Switch(
                        value: _mfaEnabled,
                        activeThumbColor: AppTheme.primary,
                        onChanged: (val) {
                          setState(() {
                            _mfaEnabled = val;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.primary,
                              content: Text(
                                _mfaEnabled 
                                    ? 'MFA simulation activated! Login will verify policy.'
                                    : 'MFA simulation deactivated.',
                                style: GoogleFonts.dmSans(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.dmSans(color: AppTheme.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(
                  height: 52,
                  child: HeavenlyInteraction(
                    onTap: _isLoading ? null : () => _handleLogin('client'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Sign In',
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sandbox Access
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'SANDBOX ROLE ACCESS',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSandboxRoleBtn('Client'),
                        const SizedBox(width: 8),
                        _buildSandboxRoleBtn('Accountant'),
                        const SizedBox(width: 8),
                        _buildSandboxRoleBtn('Admin'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSandboxRoleBtn(String role) {
    return HeavenlyInteraction(
      onTap: () => _handleLogin(role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          border: Border.all(color: AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          role,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            return Row(
              children: [
                Expanded(child: _buildLeftPanel()),
                Expanded(child: _buildRightPanel()),
              ],
            );
          }
          return _buildRightPanel();
        },
      ),
    );
  }
}
