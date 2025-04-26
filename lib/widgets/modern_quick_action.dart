import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tag;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool isAnimated;
  final int animationDelay;

  const ModernQuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.tag,
    this.onTap,
    this.accentColor,
    this.isAnimated = true,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = accentColor ?? theme.colorScheme.primary;

    Widget actionCard = Hero(
      tag: 'quick_action_$label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              HapticFeedback.lightImpact();
              onTap!();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we're on a very small screen
                final isVerySmallScreen = constraints.maxWidth < 150;

                return Row(
                  children: [
                    Container(
                      width: isVerySmallScreen ? 32 : 40,
                      height: isVerySmallScreen ? 32 : 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: isVerySmallScreen ? 16 : 20,
                      ),
                    ),
                    SizedBox(width: isVerySmallScreen ? 8 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isVerySmallScreen ? 12 : 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (tag != null)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: EdgeInsets.symmetric(
                                horizontal: isVerySmallScreen ? 4 : 6,
                                vertical: isVerySmallScreen ? 1 : 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: isVerySmallScreen ? 8 : 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Only show arrow on larger screens
                    if (!isVerySmallScreen)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );

    if (isAnimated) {
      return actionCard
          .animate(delay: Duration(milliseconds: 50 * animationDelay))
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
    }

    return actionCard;
  }
}
