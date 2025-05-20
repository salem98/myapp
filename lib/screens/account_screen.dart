import 'package:flutter/material.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Listen to auth state changes
    _authService.authStateStream.listen((state) {
      if (mounted) {
        _refreshUserData();
      }
    });
  }
  
  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Get current user from auth service
    _currentUser = _authService.currentUser;

    setState(() {
      _isLoading = false;
    });
  }

  // Refresh user data
  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    // Get current user from auth service
    _currentUser = _authService.currentUser;
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // User avatar - show profile image if available
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            backgroundImage: _currentUser?.userMetadata?['avatar_url'] != null
                                ? NetworkImage(_currentUser!.userMetadata!['avatar_url'] as String)
                                : null,
                            child: _currentUser?.userMetadata?['avatar_url'] == null
                                ? Icon(
                                    Icons.person,
                                    size: 36,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User name - use full_name from metadata, name from user, or email as fallback
                                Text(
                                  _currentUser?.userMetadata?['full_name'] as String? ??
                                      _currentUser?.userMetadata?['name'] as String? ??
                                      _currentUser?.email?.split('@').first ??
                                      'User',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // User email
                                Text(
                                  _currentUser?.email ?? 'No email provided',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                // Phone number if available
                                if (_currentUser?.phone != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentUser?.phone ?? '',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {},
                            tooltip: 'Edit Profile',
                          ),
                        ],
                      ),
                    ),
                  ),
            
            const SizedBox(height: 24),
            
            // Account stats
            Row(
              children: [
                _buildStatCard(
                  context,
                  '12',
                  'Active Shipments',
                  Icons.local_shipping_outlined,
                  theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  '48',
                  'Completed',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account options
            Text(
              'Account Options',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildOptionTile(
              context,
              'My Addresses',
              'Manage your shipping addresses',
              Icons.location_on_outlined,
              onTap: () {},
            ),
            
            _buildOptionTile(
              context,
              'Payment Methods',
              'Manage your payment options',
              Icons.payment_outlined,
              onTap: () {},
            ),
            
            _buildOptionTile(
              context,
              'Notifications',
              'Set your notification preferences',
              Icons.notifications_outlined,
              onTap: () {},
            ),
            
            _buildOptionTile(
              context,
              'Privacy & Security',
              'Manage your account security',
              Icons.security_outlined,
              onTap: () {},
            ),
            
            _buildOptionTile(
              context,
              'Help & Support',
              'Get help with your shipments',
              Icons.help_outline,
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  ) ?? false;
                  
                  if (shouldLogout && context.mounted) {
                    try {
                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logging out...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      
                      // Sign out using the instance of AuthService
                      await _authService.signOut();
                      
                      // Navigate to login screen
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false, // Remove all previous routes
                        );
                      }
                    } catch (e) {
                      // Show error message if logout fails
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error logging out: ${e.toString()}'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.error,
                  ),
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App version
            Center(
              child: Text(
                'App Version 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: ListTile(
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
