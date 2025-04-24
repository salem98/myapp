import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A card widget designed for enterprise applications with consistent styling
class EnterpriseCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool hasBorder;
  final bool hasShadow;

  const EnterpriseCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
    this.backgroundColor,
    this.hasBorder = false,
    this.hasShadow = true,
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
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? 
                (isDark ? AppTheme.darkSurfaceColor : AppTheme.lightSurfaceColor),
            borderRadius: BorderRadius.circular(16),
            border: hasBorder 
                ? Border.all(
                    color: isDark 
                        ? Colors.grey.shade800 
                        : Colors.grey.shade200,
                    width: 1.0,
                  ) 
                : null,
            boxShadow: hasShadow 
                ? [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withOpacity(0.2) 
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] 
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || icon != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0, 
                    right: 16.0, 
                    top: 16.0, 
                    bottom: 8.0
                  ),
                  child: Row(
                    children: [
                      if (icon != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            icon,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: title != null || icon != null 
                    ? EdgeInsets.only(
                        left: padding.horizontal / 2,
                        right: padding.horizontal / 2,
                        bottom: padding.vertical / 2,
                      )
                    : padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
