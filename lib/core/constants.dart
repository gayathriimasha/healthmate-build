import 'package:flutter/material.dart';

class AppColors {
  // New color palette - ONLY these colors allowed
  static const Color background = Color(0xFFEFF4F9); // Very light background
  static const Color primaryBlue = Color(0xFF6D94AA); // Primary blue (medium)
  static const Color lightBlue = Color(0xFFDCE8EF); // Light blue
  static const Color mutedBlueGrey = Color(0xFF9FB0BA); // Muted blue-grey
  static const Color accentOrange = Color(0xFFF38F5F); // Accent orange (use sparingly)
  static const Color pureWhite = Color(0xFFFDFEFE); // Pure white
  static const Color lightGreyBg = Color(0xFFCDD6DC); // Light grey background
  static const Color darkerSteel = Color(0xFF537F98); // Darker steel blue

  // Semantic color mappings
  static const Color primary = primaryBlue;
  static const Color surface = pureWhite;
  static const Color border = lightGreyBg;
  static const Color accent = accentOrange;

  // Text colors using palette
  static const Color textPrimary = darkerSteel;
  static const Color textSecondary = mutedBlueGrey;
  static const Color textLight = mutedBlueGrey;

  // Status colors using palette
  static const Color error = accentOrange;
  static const Color warning = accentOrange;
  static const Color success = primaryBlue;

  // Data visualization colors - using palette only
  static const Color stepsColor = primaryBlue;
  static const Color caloriesColor = accentOrange;
  static const Color waterColor = Color(0xFF4A9EC1); // More visible blue for water
  static const Color sleepColor = mutedBlueGrey;
}

class AppTextStyles {
  // Typography hierarchy with clear font weights
  // Font family will be set globally in theme.dart
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600, // Semi-bold for headings
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600, // Semi-bold for headings
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium for section titles
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular for body
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular for body
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular for labels
    color: AppColors.textSecondary,
    height: 1.4,
  );
}

class AppSizes {
  // Consistent border radius: 8px everywhere
  static const double borderRadius = 8.0;

  // Subtle elevation - very low
  static const double cardElevation = 0.5;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
}

// Subtle shadow definitions
class AppShadows {
  // Very subtle card shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.darkerSteel.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Slightly more prominent for elevated elements
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: AppColors.darkerSteel.withOpacity(0.12),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Very soft shadow for floating elements
  static List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: AppColors.darkerSteel.withOpacity(0.06),
      blurRadius: 6,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
}
