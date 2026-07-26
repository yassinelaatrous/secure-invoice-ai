import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'notification_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_in_slide.dart';
import '../widgets/heavenly_interaction.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  Map<String, dynamic>? _user;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await AuthService.getUserInfo();
    setState(() {
      _user = user;
    });
  }

  void _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _editEmail() {
    final controller = TextEditingController(text: _user?['email'] ?? 'user@demo.com');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Update Email Address',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          content: TextField(
            controller: controller,
            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final newEmail = controller.text.trim();
                Navigator.pop(context);
                if (newEmail.isNotEmpty) {
                  setState(() {
                    if (_user != null) {
                      _user!['email'] = newEmail;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.accentGreen,
                      content: Text('Email updated to $newEmail ✓'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text('Save', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Security & Cryptography',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          content: Text(
            'Your account is secured with end-to-end cryptographic keys. Your document vault, tax dossiers, and accounting streams are locked. Only you and your authorized accountant have credentials to read them.',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String role = _user != null ? _user!['role'] ?? 'client' : 'client';
    final String name = _user != null ? _user!['nom'] ?? 'Demo User' : 'Demo User';
    final String email = _user != null ? _user!['email'] ?? 'user@demo.com' : 'user@demo.com';

    String displayRole = 'Client Partner';
    IconData roleIcon = Icons.person;
    if (role == 'accountant' || role == 'comptable') {
      displayRole = 'Certified Accountant';
      roleIcon = Icons.account_balance_wallet_rounded;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom Top App Bar (Stitch style)
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceCreamDark,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCHer2fd8fIdpC7E46qINZ7zGThzIJaI_HHIoWRrwKb9mGbEVG7bnHZZU4qIyS_pLKUljhePnYl1ZIFKxoMhK8hBZ2wK7Mri3ihQSzwdXd_izZVcZv2xS5HYzRa-Tr6LYvJNLrlQXHeP2_CWJFqvTgZ_vS7G8yh1skVS9UB5NCUY1gQMPzakPlHiWNd4lHHjGY_3aDgl12LM6km7KBp7kFATPw8HcJVUTQ4LEt836cLEfloxfLyixvigsDLRjYmJUbdTDT1kPBdGxFE',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CEO-IT',
                    style: GoogleFonts.fraunces(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Profile Card Header
              FadeInSlide(
                delay: const Duration(milliseconds: 50),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                              style: GoogleFonts.fraunces(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(roleIcon, size: 16, color: AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: GoogleFonts.fraunces(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayRole,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Account settings card
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Settings',
                      style: GoogleFonts.fraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.alternate_email_rounded,
                            title: 'Email Address',
                            subtitle: email,
                            onTap: _editEmail,
                          ),
                          const Divider(color: AppTheme.cardBorder, height: 1),
                          _buildSwitchTile(
                            icon: Icons.notifications_active_outlined,
                            title: 'Push Notifications',
                            subtitle: 'Alerts for secure transactions',
                            value: _notificationsEnabled,
                            onChanged: (val) => setState(() => _notificationsEnabled = val),
                          ),
                          const Divider(color: AppTheme.cardBorder, height: 1),
                          _buildSettingsTile(
                            icon: Icons.security_rounded,
                            title: 'Data Privacy & Security',
                            subtitle: 'End-to-end encryption active',
                            onTap: _showPrivacyInfo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sandbox Role Simulations
              FadeInSlide(
                delay: const Duration(milliseconds: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sandbox Options',
                      style: GoogleFonts.fraunces(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildRoleSimulationButton('Client', active: role == 'client'),
                        const SizedBox(width: 8),
                        _buildRoleSimulationButton('Accountant', active: role == 'accountant' || role == 'comptable'),
                        const SizedBox(width: 8),
                        _buildRoleSimulationButton('Admin', active: role == 'admin'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Logout Button
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: HeavenlyInteraction(
                  onTap: _logout,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Log Out',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return HeavenlyInteraction(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 16),
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
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 16),
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
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSimulationButton(String label, {required bool active}) {
    return Expanded(
      child: HeavenlyInteraction(
        onTap: () async {
          if (active) return;
          final targetRole = label == 'Accountant' ? 'accountant' : label.toLowerCase();
          
          await AuthService.logout();
          await AuthService.login(targetRole, 'sandbox');
          
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : AppTheme.surfaceCreamDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? Colors.transparent : AppTheme.cardBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
