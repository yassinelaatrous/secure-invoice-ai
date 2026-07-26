import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Auto-discover the active backend server IP address
  await AuthService.discoverBaseUrl();
  
  // Check if session token is already stored in shared preferences
  final bool loggedIn = await AuthService.isLoggedIn();
  
  runApp(SecureInvoiceApp(isLoggedIn: loggedIn));
}

class MajesticScrollBehavior extends MaterialScrollBehavior {
  const MajesticScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class SecureInvoiceApp extends StatelessWidget {
  final bool isLoggedIn;

  const SecureInvoiceApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureInvoice AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: const MajesticScrollBehavior(),
      home: isLoggedIn ? const DashboardScreen() : const OnboardingScreen(),
    );
  }
}
