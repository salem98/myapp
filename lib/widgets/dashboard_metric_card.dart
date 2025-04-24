import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A metric card widget for displaying key metrics on dashboards
class DashboardMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final bool isIncreasing;
  final String? changePercentage;
  final VoidCallback? onTap;

  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.isIncreasing = true,
    this.changePercentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.2) 
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark 
                          ? AppTheme.darkSecondaryTextColor 
                          : AppTheme.lightSecondaryTextColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark 
                          ? AppTheme.darkSecondaryTextColor 
                          : AppTheme.lightSecondaryTextColor,
                    ),
                  ),
                ),
              if (changePercentage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        isIncreasing 
                            ? Icons.arrow_upward 
                            : Icons.arrow_downward,
                        color: isIncreasing 
                            ? Colors.green 
                            : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$changePercentage%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isIncreasing 
                              ? Colors.green 
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'vs last period',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark 
                              ? AppTheme.darkSecondaryTextColor 
                              : AppTheme.lightSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
