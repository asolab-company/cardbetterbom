import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primary = Color(0xFF33AD34);
  static const Color accent = Color(0xFFFCB203);
  static const Color dark = Color(0xFF393A3C);
  static const Color black = Color(0xFF000000);
  static const Color gradientTop = Color(0xFFFCB203);
  static const Color gradientBottom = Color(0xFF202020);
  static const Color white = Color(0xFFFFFFFF);
}

class AppConstants {
  static const bool isDebug = true;
  static const Duration loadingDuration = Duration(seconds: 2);
  static const String brandName = 'CardBetter';
  static const String brandDescription = 'Think before you buy';
  static const String privacyPolicyUrl = 'https://docs.google.com/document/d/e/2PACX-1vSKOV1aKQwcFRi_5cti31bLK6f4EIi2hxhIOoCWleVqoc5QDgExTD4AoJeWbfQbMMTFyHusg-44h5__/pub';
  static const String termsOfUseUrl = 'https://docs.google.com/document/d/e/2PACX-1vSKOV1aKQwcFRi_5cti31bLK6f4EIi2hxhIOoCWleVqoc5QDgExTD4AoJeWbfQbMMTFyHusg-44h5__/pub';
  static const String firstEntryKey = 'first_entry_completed';
  static const String notificationsKey = 'notifications_enabled';
}

class AppGradients {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gradientTop, AppColors.gradientBottom],
    stops: [0.0, 0.5],
  );
}
