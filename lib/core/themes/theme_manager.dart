import 'package:flutter/material.dart';
import 'package:planta_app/core/themes/color_manager.dart';
import 'package:planta_app/core/themes/font_manager.dart';

enum AppTheme { lightTheme, darkTheme }

class AppThemes {
  static final appThemeData = {
    AppTheme.lightTheme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: ColorManager.seedColorLight,

      fontFamily: FontConstants.fontFamily,
    ),
    AppTheme.darkTheme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: ColorManager.seedColorDark,
      brightness: Brightness.dark,
      fontFamily: FontConstants.fontFamily,
    ),
  };
}
