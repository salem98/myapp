import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myapp/screens/shipment_creation_screen.dart';

class AnimatedLogisticsBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCreatePressed;
  final Widget child;

  const AnimatedLogisticsBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCreatePressed,
    required this.child,
  });

  @override
  State<AnimatedLogisticsBottomBar> createState() => _AnimatedLogisticsBottomBarState();
}

class _AnimatedLogisticsBottomBarState extends State<AnimatedLogisticsBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Icons for the navigation bar
  final List<IconData> _iconList = [
    Icons.home_outlined,
    Icons.history_outlined,
    Icons.search_outlined,
    Icons.person_outline,
  ];

  // Selected icons for the navigation bar
  final List<IconData> _selectedIconList = [
    Icons.home,
    Icons.history,
    Icons.search,
    Icons.person,
  ];

  // Labels for the navigation bar
  final List<String> _labelList = [
    'Home',
    'History',
    'Track',
    'Account',
  ];

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

  // Show shipment options modal
  void _showShipmentOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                  // Navigate to shipment creation screen with Air shipment type
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShipmentCreationScreen(
                        initialShipmentType: ShipmentType.air,
                      ),
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
                  // Navigate to shipment creation screen with Sea shipment type
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShipmentCreationScreen(
                        initialShipmentType: ShipmentType.sea,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ).animate().slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutQuad,
        );
      },
    );
  }

  // Build a shipment type option
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

  @override
  void didUpdateWidget(AnimatedLogisticsBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when the current index changes
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create the floating action button with round design
    final floatingActionButton = FloatingActionButton(
      elevation: 8,
      backgroundColor: theme.colorScheme.primary,
      shape: const CircleBorder(),
      onPressed: () => _showShipmentOptions(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Modern inventory box icon
          Icon(
            Icons.inventory_2_rounded,
            color: theme.colorScheme.onPrimary,
            size: 28,
          ),
        ],
      ).animate().scale(
        duration: 300.ms,
        curve: Curves.easeOutBack,
      ),
    );

    return Scaffold(
      body: widget.child,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          // Use a key based on isActive to force rebuild when active state changes
          return Column(
            key: ValueKey('tab_$index${isActive ? '_active' : ''}'),
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animation
              AnimatedScale(
                scale: isActive ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Icon(
                  isActive ? _selectedIconList[index] : _iconList[index],
                  size: isActive ? 26 : 24,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: theme.textTheme.labelSmall!.copyWith(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: isActive ? 11 : 10,
                ),
                child: Text(
                  _labelList[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
        backgroundColor: theme.colorScheme.surface,
        activeIndex: widget.currentIndex,
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 24,
        rightCornerRadius: 24,
        onTap: widget.onTap,
        shadow: BoxShadow(
          offset: const Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
          color: Colors.black.withOpacity(0.1),
        ),
        height: 60,
      ),
    );
  }
}
