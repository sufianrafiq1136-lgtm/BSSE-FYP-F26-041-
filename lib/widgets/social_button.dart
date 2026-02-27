import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onPressed;
  final bool useIconData;
  final IconData? iconData;
  final Color? iconColor;

  const SocialButton({
    super.key,
    this.iconPath = '',
    this.onPressed,
    this.useIconData = false,
    this.iconData,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: useIconData
              ? Icon(
                  iconData,
                  size: 26,
                  color: iconColor ?? AppColors.textPrimary,
                )
              : Image.asset(
                  iconPath,
                  width: 26,
                  height: 26,
                ),
        ),
      ),
    );
  }
}

// Social button with text widget (for different layout)
class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const SocialIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: color,
          ),
        ),
      ),
    );
  }
}
