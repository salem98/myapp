import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/debug_tracking_screen.dart'; // Import the debug tracking screen
import 'theme/app_theme.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ndillvmegwjzqwmulhvc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kaWxsdm1lZ3dqenF3bXVsaHZjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0Mzk5NTk5NywiZXhwIjoyMDU5NTcxOTk3fQ.tf8OHPZmE2wLF4HsD_yS1-J_oIxG_TasqpQ49FBqLzc',
  );

  runApp(const TNSApp());
}

class TNSApp extends StatefulWidget {
  const TNSApp({super.key});

  @override
  State<TNSApp> createState() => _TNSAppState();
}

class _TNSAppState extends State<TNSApp> {
  final _authService = AuthService();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    
    // Check initial auth state
    _isAuthenticated = _authService.isAuthenticated;
    
    // Listen to auth state changes
    _authService.authStateStream.listen((state) {
      setState(() {
        _isAuthenticated = state.isAuthenticated;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TNS Express',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respect system theme settings
      home: const MainNavigationScreen(), // Always show MainNavigationScreen
      // For debugging tracking issues:
      // home: const DebugTrackingScreen(),
    );
  }
}

