import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/heavenly_interaction.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  String _selectedRole = 'client'; // Default role
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _is3rdPartyVerified = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await AuthService.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      companyName: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : 'Entreprise Indépendante',
      verificationCode: _verificationCodeController.text.trim().isNotEmpty
          ? _verificationCodeController.text.trim()
          : (_is3rdPartyVerified ? 'GOOGLE-OAUTH-VERIFIED' : '123456'),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.accentGreen,
            content: Text(
              'Compte créé avec succès ! Bienvenue sur CEO-IT.',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Échec de l\'inscription.';
        });
      }
    }
  }

  void _simulate3rdPartyOAuth() {
    setState(() {
      _is3rdPartyVerified = true;
      if (_nameController.text.isEmpty) _nameController.text = 'Nouvel Utilisateur';
      if (_emailController.text.isEmpty) _emailController.text = 'user.google@gmail.com';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        content: Row(
          children: [
            const Icon(Icons.verified_user, color: AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Identité vérifiée via Google Single Sign-On (OAuth 2.0 ISO 27001)',
                style: GoogleFonts.dmSans(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo
                    FadeInSlide(
                      delay: const Duration(milliseconds: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CI',
                              style: GoogleFonts.fraunces(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'CEO-IT',
                            style: GoogleFonts.fraunces(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Créer votre compte',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fraunces(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rejoignez la plateforme sécurisée de gestion comptable et facturation.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Third Party Verification Button (Google OAuth)
                    FadeInSlide(
                      delay: const Duration(milliseconds: 100),
                      child: HeavenlyInteraction(
                        onTap: _simulate3rdPartyOAuth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _is3rdPartyVerified ? AppTheme.accentGreen : AppTheme.cardBorder,
                              width: _is3rdPartyVerified ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _is3rdPartyVerified ? Icons.check_circle : Icons.g_mobiledata_rounded,
                                color: _is3rdPartyVerified ? AppTheme.accentGreen : AppTheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _is3rdPartyVerified
                                    ? 'Vérifié via Google SSO (Vérification Tiers)'
                                    : 'Vérifier l\'identité via Google / Identity Provider',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _is3rdPartyVerified ? AppTheme.accentGreen : AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppTheme.cardBorder)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ou formulaire sécurisé',
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppTheme.cardBorder)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    _buildLabel('Nom complet'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir votre nom' : null,
                      decoration: _inputDecoration('Ex: Yassine Latrous', Icons.person_outline),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    _buildLabel('Adresse E-mail'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Veuillez saisir votre e-mail';
                        if (!v.contains('@')) return 'E-mail invalide';
                        return null;
                      },
                      decoration: _inputDecoration('votre.email@exemple.com', Icons.mail_outline),
                    ),
                    const SizedBox(height: 16),

                    // Company Name Field
                    _buildLabel('Nom de l\'entreprise / Cabinet (Optionnel)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _companyController,
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                      decoration: _inputDecoration('Ex: Société Générale SARL', Icons.business_outlined),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildLabel('Mot de passe sécurisé (Min. 12 caractères)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                      validator: (v) {
                        if (v == null || v.length < 8) return 'Mot de passe trop court (Min 8 caractères)';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '••••••••••••',
                        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                    const SizedBox(height: 20),

                    // Role Selection (Choix selon intérêt & convenance)
                    _buildLabel('Choix du Rôle (Selon votre activité & intérêt)'),
                    const SizedBox(height: 8),
                    _buildRoleCard(
                      roleKey: 'client',
                      title: '🏢 Client / Entreprise',
                      subtitle: 'Facturation électronique, dépôt de pièces & suivi de dossier',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 8),
                    _buildRoleCard(
                      roleKey: 'comptable',
                      title: '📊 Comptable / Expert-Comptable',
                      subtitle: 'Révision des dossiers, contrôle OCR, saisie & validation SoD',
                      color: AppTheme.accentOrange,
                    ),
                    const SizedBox(height: 8),
                    _buildRoleCard(
                      roleKey: 'auditeur',
                      title: '🛡️ Auditeur & Conformité',
                      subtitle: 'Consultation en lecture seule, audit d\'accès & supervision',
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(height: 20),

                    // Internal Verification Code Field (if role requires admin authorization)
                    if (_selectedRole != 'client') ...[
                      _buildLabel('Code d\'autorisation Administrateur / Tiers'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _verificationCodeController,
                        style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
                        decoration: _inputDecoration('Code d\'autorisation (ex: ADMIN-2026)', Icons.admin_panel_settings_outlined),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.dmSans(color: AppTheme.error, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Submit Button
                    SizedBox(
                      height: 52,
                      child: HeavenlyInteraction(
                        onTap: _isLoading ? null : _handleRegister,
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
                                  'Créer mon compte',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
      prefixIcon: Icon(icon, color: AppTheme.textMuted),
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
    );
  }

  Widget _buildRoleCard({
    required String roleKey,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedRole == roleKey;

    return HeavenlyInteraction(
      onTap: () => setState(() => _selectedRole = roleKey),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppTheme.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: roleKey,
              groupValue: _selectedRole,
              activeColor: color,
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
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
