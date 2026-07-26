import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(
      'threejs-mascot',
      (int viewId) => web.HTMLIFrameElement()
        ..src = 'mascot.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'icon': Icons.document_scanner,
      'title': 'Intelligent Document Capture',
      'description': 'Leverage our proprietary neural network OCR for instant, high-fidelity digitization and automatic metadata extraction from complex financial documents.',
      'gradientStart': const Color(0x33A5D0B9), // primaryFixedDim / 20%
    },
    {
      'icon': Icons.verified_user,
      'title': 'Fraud & Compliance Audit',
      'description': 'Mitigate risk with real-time scoring and automated bank account verification, ensuring every transaction adheres to the highest corporate governance standards.',
      'gradientStart': const Color(0x33A0F4C8), // secondaryFixed / 20%
    },
    {
      'icon': Icons.insights,
      'title': 'Executive Insights',
      'description': 'Command your financial landscape with real-time cashflow KPIs and dynamic forecasting tools designed for elite administrative control.',
      'gradientStart': const Color(0x33B1F0CE), // tertiaryFixed / 20%
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        title: Text(
          'CEO-IT',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.primary),
        ),
        actions: [
          if (_currentPage < _onboardingData.length - 1)
            TextButton(
              onPressed: _onGetStarted,
              child: Text(
                'Skip',
                style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 192,
                          height: 192,
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppTheme.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.06),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            gradient: RadialGradient(
                              colors: [
                                data['gradientStart'],
                                Colors.transparent,
                              ],
                              radius: 0.8,
                            ),
                          ),
                          child: const ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            child: HtmlElementView(viewType: 'threejs-mascot'),
                          ),
                        ),
                        Text(
                          data['title'],
                          textAlign: TextAlign.center,
                          style: AppTheme.headlineLarge.copyWith(
                            color: AppTheme.primary,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['description'],
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              color: AppTheme.backgroundLight,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primary
                              : AppTheme.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _currentPage == _onboardingData.length - 1
                          ? _onGetStarted
                          : _onNext,
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
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
