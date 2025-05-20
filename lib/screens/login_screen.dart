import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show LaunchMode;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/screens/main_navigation_screen.dart';
import 'package:myapp/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    _authService.authStateStream.listen((state) {
      if (state.isAuthenticated) {
        // Navigate to main screen when authenticated
        _navigateToMainScreen();
      }
    });
    
    // Check if already authenticated
    if (_authService.isAuthenticated) {
      // Navigate to main screen if already authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToMainScreen();
      });
    }
  }
  
  void _navigateToMainScreen() {
    // If we came from the main navigation screen, just pop back
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Otherwise, replace with the main navigation screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    }
  }
  
  // Method for native Google sign-in on iOS and Android
  Future<void> _nativeGoogleSignIn() async {
    // Using the actual client ID from Supabase configuration
    const webClientId = '2800476783-pidqeje3f1tutjonv0r337b5c47ffc0f.apps.googleusercontent.com';
    // For iOS, you would typically use a different client ID, but we'll use the same one for now
    const iosClientId = '2800476783-pidqeje3f1tutjonv0r337b5c47ffc0f.apps.googleusercontent.com';
    
    debugPrint('Native Google Sign-In: Using client IDs');
    debugPrint('Web Client ID: $webClientId');
    debugPrint('iOS Client ID: $iosClientId');
    
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    
    try {
      debugPrint('Starting native Google Sign-In flow');
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign-In canceled by user');
        return;
      }
      
      debugPrint('Google Sign-In successful: ${googleUser.email}');
      debugPrint('Getting authentication tokens...');
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null) {
        debugPrint('Error: No Access Token found');
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        debugPrint('Error: No ID Token found');
        throw 'No ID Token found.';
      }
      
      debugPrint('Tokens obtained successfully');
      debugPrint('Signing in to Supabase with ID token');
      
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      debugPrint('Supabase sign-in with ID token successful');
    } catch (e) {
      debugPrint('Error during native Google Sign-In: $e');
      rethrow; // Rethrow to be caught by the caller
    }
  }
  
  // Method for web-based Google sign-in on Web, macOS, Windows, and Linux
  Future<void> _webGoogleSignIn() async {
    // For web platforms, we need to specify the correct redirect URL
    String? redirectUrl;
    
    if (kIsWeb) {
      // Get the current URL to determine the correct port
      final currentUrl = Uri.base;
      // Construct the redirect URL with the correct port
      redirectUrl = '${currentUrl.scheme}://${currentUrl.host}:${currentUrl.port}';
      
      // If we're running on localhost, make sure we use the correct port
      // IMPORTANT: Change this port number to match your development server
      // For example, if your Flutter web app runs on port 8000, change 3000 to 8000
      const int flutterWebPort = 3000; // Change this to your actual port number
      
      if (currentUrl.host == 'localhost' && currentUrl.port != flutterWebPort) {
        // Use the specified port for your Flutter web app
        redirectUrl = '${currentUrl.scheme}://${currentUrl.host}:$flutterWebPort';
      }
    }
    
    // Print debug information about the redirect URL
    debugPrint('Google Sign-In Redirect URL: $redirectUrl');
    
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
        scopes: 'email profile',
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo and app name
              Center(
                child: Image.asset(
                  'assets/images/logo-main.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TNS Express',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'Shipment Tracking Application',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Supabase Auth UI
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sign in to continue',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Supabase Auth UI
                      SupaEmailAuth(
                        onSignInComplete: (response) {
                          // Handle successful sign-in
                          _navigateToMainScreen();
                        },
                        onSignUpComplete: (response) {
                          // Handle successful sign-up
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Check your email for confirmation link'),
                            ),
                          );
                        },
                        metadataFields: const [],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Divider with "or" text
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Google Sign-In Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            debugPrint('Google Sign-In button pressed');
                            debugPrint('Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
                            
                            try {
                              // Use the appropriate method based on platform
                              if (kIsWeb) {
                                debugPrint('Using web Google Sign-In method');
                                await _webGoogleSignIn();
                              } else {
                                debugPrint('Using native Google Sign-In method');
                                await _nativeGoogleSignIn();
                              }
                              debugPrint('Google Sign-In completed successfully');
                              // Auth state listener will handle navigation
                            } catch (e) {
                              debugPrint('Error during Google Sign-In: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: theme.colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.g_mobiledata_rounded),
                          label: const Text('Continue with Google'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Terms and privacy policy
              Text(
                'By signing in, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}