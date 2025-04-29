import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

// test note 123
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ndillvmegwjzqwmulhvc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kaWxsdm1lZ3dqenF3bXVsaHZjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0Mzk5NTk5NywiZXhwIjoyMDU5NTcxOTk3fQ.tf8OHPZmE2wLF4HsD_yS1-J_oIxG_TasqpQ49FBqLzc',
  );

  runApp(const TNSApp());
}

class TNSApp extends StatelessWidget {
  const TNSApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TNS Express',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Respect system theme settings
      home: MainNavigationScreen(key: MainNavigationScreen.globalKey),
    );
  }
}


