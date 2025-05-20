import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/history_screen.dart';
import 'package:myapp/screens/tracking_screen.dart';
import 'package:myapp/screens/account_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/widgets/animated_logistics_bottom_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  // Global key to access the state
  static final GlobalKey<_MainNavigationScreenState> globalKey = GlobalKey<_MainNavigationScreenState>();

  // Static method to navigate to tracking screen with a tracking number
  static void navigateToTracking(BuildContext context, String trackingNumber) {
    if (globalKey.currentState != null) {
      globalKey.currentState!.navigateToTrackingWithNumber(trackingNumber);
    }
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final _authService = AuthService();
  int _currentIndex = 0;
  String? _trackingNumber;
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

  // Make screens late initialized so we can update them with tracking numbers
  late final List<Widget> _screens = [
    const HomeScreen(hideBottomBar: true),
    const HistoryScreen(),
    TrackingScreen(trackingNumber: _trackingNumber),
    const AccountScreen(),
  ];

  // Method to navigate to tracking screen with a tracking number
  void navigateToTrackingWithNumber(String trackingNumber) {
    print("MainNavigationScreen: Navigating to tracking with number: $trackingNumber");
    
    setState(() {
      _trackingNumber = trackingNumber;
      _currentIndex = 2; // Switch to tracking tab

      // Update the tracking screen with the new tracking number
      _screens[2] = TrackingScreen(trackingNumber: trackingNumber);
      
      print("MainNavigationScreen: Updated tracking screen with number: $trackingNumber");
    });
  }
  
  // Check if the user is authenticated for protected screens
  bool _checkAuthForProtectedScreen(int index) {
    // History screen is at index 1, Account screen is at index 3
    if ((index == 1 || index == 3) && !_isAuthenticated) {
      return false;
    }
    return true;
  }
  
  // Navigate to login screen
  void _navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedLogisticsBottomBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        // Check authentication for protected screens
        if (_checkAuthForProtectedScreen(index)) {
          setState(() {
            _currentIndex = index;
          });
        } else {
          // Navigate to login screen for protected screens
          _navigateToLogin();
        }
      },
      onCreatePressed: () {
        // Show shipment options modal
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) {
            return _buildShipmentOptionsModal(context);
          },
        );
      },
      child: _screens[_currentIndex],
    );
  }

  Widget _buildShipmentOptionsModal(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.add_box_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Shipment Type',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Air Shipment Option
          _buildShipmentTypeOption(
            context,
            'Air Shipment',
            'Faster delivery with air freight',
            Icons.flight_takeoff_rounded,
            theme.colorScheme.primary,
            () {
              Navigator.pop(context);
              // Show a snackbar to indicate the action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Creating Air Shipment'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),

          // Sea Shipment Option
          _buildShipmentTypeOption(
            context,
            'Sea Shipment',
            'Cost-effective for larger cargo',
            Icons.directions_boat_rounded,
            theme.colorScheme.secondary,
            () {
              Navigator.pop(context);
              // Show a snackbar to indicate the action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Creating Sea Shipment'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShipmentTypeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
