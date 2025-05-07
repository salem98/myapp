import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:myapp/widgets/modern_quick_action.dart';
import 'package:myapp/screens/tracking_screen.dart';
import 'package:myapp/screens/restricted_inquiry_screen.dart';
import 'package:myapp/screens/freight_calculator_screen_new.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine number of columns based on screen width
    // Use 1 column for very small screens, 2 for normal mobile, 3 for tablets/desktop
    final int columnCount;
    if (screenWidth < 360) {
      columnCount = 1; // Very small screens get 1 column
    } else if (screenWidth < 600) {
      columnCount = 2; // Normal mobile screens get 2 columns
    } else {
      columnCount = 3; // Tablets and desktops get 3 columns
    }

    // Adjust padding based on screen size
    final EdgeInsets sectionPadding;
    if (screenWidth < 360) {
      sectionPadding = const EdgeInsets.all(12.0);
    } else {
      sectionPadding = const EdgeInsets.all(16.0);
    }

    return Container(
      padding: sectionPadding,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900.withOpacity(0.3) : Colors.grey.shade50.withOpacity(0.7),
        borderRadius: BorderRadius.circular(screenWidth < 360 ? 16 : 24),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth < 360 ? 18 : 22,
                ),
              ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),

              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {},
                tooltip: 'Customize',
                iconSize: screenWidth < 360 ? 20 : 24,
                padding: screenWidth < 360 ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
              ).animate().fadeIn(duration: 300.ms),
            ],
          ),
          SizedBox(height: screenWidth < 360 ? 12 : 16),

          // Staggered Grid View for Quick Actions
          MasonryGridView.count(
            crossAxisCount: columnCount,
            mainAxisSpacing: screenWidth < 360 ? 8 : 12,
            crossAxisSpacing: screenWidth < 360 ? 8 : 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              // Define quick actions
              // Define quick actions with responsive labels
              final bool useShortLabels = screenWidth < 360 || columnCount == 1;

              final List<Map<String, dynamic>> quickActions = [
                {
                  'icon': Icons.language,
                  'label': useShortLabels ? 'Int\'l Routes' : 'International Routes',
                  'tag': 'Best Value',
                  'color': Colors.blue,
                },
                {
                  'icon': Icons.search,
                  'label': 'Track Package',
                  'onTap': () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrackingScreen(),
                      ),
                    );
                  },
                  'color': Colors.orange,
                },
                {
                  'icon': Icons.access_time,
                  'label': 'Consolidation Order',
                  'color': Colors.purple,
                },
                {
                  'icon': Icons.rule,
                  'label': useShortLabels ? 'Restricted' : 'Restricted Inquiry',
                  'onTap': () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RestrictedInquiryScreen(),
                      ),
                    );
                  },
                  'color': Colors.teal,
                },
                {
                  'icon': Icons.map,
                  'label': 'Coverage Area',
                  'color': Colors.green,
                },
                {
                  'icon': Icons.straighten,
                  'label': useShortLabels ? 'Calculator' : 'Freight Calculator',
                  'onTap': () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FreightCalculatorScreen(),
                      ),
                    );
                  },
                  'color': Colors.red,
                },
                {
                  'icon': Icons.info_outline,
                  'label': 'Product Info',
                  'color': Colors.indigo,
                },
                {
                  'icon': Icons.business,
                  'label': useShortLabels ? 'Enterprise' : 'Enterprise Registration',
                  'tag': 'New',
                  'color': Colors.amber.shade700,
                },
              ];

              final action = quickActions[index];

              return ModernQuickAction(
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                tag: action['tag'] as String?,
                onTap: action['onTap'] as VoidCallback?,
                accentColor: action['color'] as Color?,
                animationDelay: index,
              );
            },
          ),
        ],
      ),
    );
  }
}
