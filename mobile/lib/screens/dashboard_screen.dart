import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'capture_screen.dart';
import 'profile_screen.dart'; // Admin Role Control
import 'personal_profile_screen.dart';
import 'workspaces/admin_workspace.dart';
import 'workspaces/accountant_workspace.dart';
import 'workspaces/client_workspace.dart';
import 'message_center_screen.dart';

import '../widgets/heavenly_interaction.dart';
import '../widgets/fade_in_slide.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUserInfo();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Widget _getWorkspaceForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return AdminWorkspace(
          onScanPressed: () {
            setState(() {
              _currentIndex = 2; // Go to Capture tab
            });
            _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 400),
              curve: const Cubic(0.16, 1, 0.3, 1),
            );
          },
        );
      case 'accountant':
      case 'comptable':
      case 'expert_comptable':
      case 'assistant_comptable':
      case 'auditeur':
        return const AccountantWorkspace();
      case 'client':
      default:
        return const ClientWorkspace();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final String role = _user?['role'] ?? 'client';
    final isUserAdmin = role.toLowerCase() == 'admin';

    final List<Widget> tabs = [
      _getWorkspaceForRole(role),
      const MessageCenterScreen(),
      const CaptureScreen(),
      isUserAdmin ? const ProfileScreen() : const PersonalProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: FadeInSlide(
        duration: const Duration(milliseconds: 600),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard, // bg-surface
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.04), // shadow-[0_-4px_16px_rgba(26,28,27,0.04)]
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavBtn(0, 'Dashboard', Icons.dashboard),
            _buildBottomNavBtn(1, 'Messages', Icons.chat_bubble),
            _buildBottomNavBtn(2, 'Capture', Icons.center_focus_strong),
            _buildBottomNavBtn(
              3, 
              isUserAdmin ? 'Admin' : 'Profile', 
              isUserAdmin ? Icons.admin_panel_settings : Icons.person
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBtn(int index, String label, IconData icon) {
    final isActive = _currentIndex == index;
    return HeavenlyInteraction(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: const Cubic(0.16, 1, 0.3, 1), // easeOutExpo
        );
      },
      scaleDown: 0.94,
      hoverScale: 1.05,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.secondary.withValues(alpha: 0.2) : Colors.transparent, // bg-secondary-container equivalent
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primary : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.labelLarge.copyWith(
                color: isActive ? AppTheme.primary : AppTheme.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
