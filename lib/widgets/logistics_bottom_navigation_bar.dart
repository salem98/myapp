import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LogisticsBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LogisticsBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<LogisticsBottomNavigationBar> createState() => _LogisticsBottomNavigationBarState();
}

class _LogisticsBottomNavigationBarState extends State<LogisticsBottomNavigationBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isCreateButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCreateButton() {
    setState(() {
      _isCreateButtonPressed = !_isCreateButtonPressed;
      if (_isCreateButtonPressed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bottom navigation items
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home button
                  _buildNavItem(
                    context,
                    0,
                    'Home',
                    Icons.home_outlined,
                    Icons.home,
                  ),

                  // History button
                  _buildNavItem(
                    context,
                    1,
                    'History',
                    Icons.history_outlined,
                    Icons.history,
                  ),

                  // Spacer for the center button
                  const SizedBox(width: 60),

                  // Tracking button
                  _buildNavItem(
                    context,
                    2,
                    'Track',
                    Icons.search_outlined,
                    Icons.search,
                  ),

                  // Account button
                  _buildNavItem(
                    context,
                    3,
                    'Account',
                    Icons.person_outline,
                    Icons.person,
                  ),
                ],
              ),
            ),
          ),

          // Create shipment floating button with parcel icon
          GestureDetector(
            onTap: _toggleCreateButton,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isCreateButtonPressed
                      ? Transform.rotate(
                          angle: _animationController.value * 0.25 * 3.14159,
                          child: Icon(
                            Icons.close,
                            color: theme.colorScheme.onPrimary,
                            size: 28,
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            // Parcel box
                            Icon(
                              Icons.inventory_2,
                              color: theme.colorScheme.onPrimary,
                              size: 28,
                            ),

                            // Plus sign
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    color: theme.colorScheme.onTertiary,
                                    size: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).animate(
                          target: _isCreateButtonPressed ? 0.0 : 1.0,
                        ).scaleXY(
                          begin: 0.8,
                          end: 1.0,
                          curve: Curves.easeOutBack,
                          duration: 300.ms,
                        ),
                );
              },
            ),
          ),

          // Create shipment options (visible when button is pressed)
          if (_isCreateButtonPressed)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildShipmentOption(
                      context,
                      'Create Parcel',
                      Icons.inventory_2,
                      theme.colorScheme.primary,
                    ),
                    _buildShipmentOption(
                      context,
                      'Express Delivery',
                      Icons.local_shipping,
                      theme.colorScheme.tertiary,
                    ),
                    _buildShipmentOption(
                      context,
                      'International',
                      Icons.flight_takeoff,
                      theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ).animate().slideY(
                begin: 1.0,
                end: 0.0,
                duration: 300.ms,
                curve: Curves.easeOutQuad,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String label,
    IconData icon,
    IconData selectedIcon,
  ) {
    final isSelected = widget.currentIndex == index;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: InkWell(
        onTap: () => widget.onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ).animate(
                target: isSelected ? 1 : 0,
              ).scaleXY(
                begin: 1.0,
                end: 1.2,
                duration: 200.ms,
                curve: Curves.easeOutBack,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        // Close the menu
        _toggleCreateButton();
        // Show a snackbar to indicate the action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Creating $label'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
