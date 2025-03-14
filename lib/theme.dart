import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:system_theme/system_theme.dart';

const material.ColorScheme brightscheme = material.ColorScheme(
    brightness: Brightness.light,
    primary: Color.fromRGBO(206, 160, 75, 1),
    onPrimary: Color.fromRGBO(12, 9, 3, 1),
    secondary: Color.fromRGBO(146, 226, 161, 1),
    onSecondary: Color.fromRGBO(12, 9, 3, 1),
    error: Color.fromRGBO(255, 0, 0, 1),
    onError: Color.fromRGBO(12, 9, 3, 1),
    surface: Color.fromRGBO(254, 253, 251, 1),
    onSurface: Color.fromRGBO(12, 9, 3, 1),
    tertiary: Color.fromRGBO(114, 218, 185, 1),
    onTertiary: Color.fromRGBO(12, 9, 3, 1));
const material.ColorScheme darkscheme = material.ColorScheme(
    brightness: Brightness.dark,
    primary: Color.fromRGBO(55, 65, 81, 1),
    onPrimary: Color.fromRGBO(146, 166, 255, 1),
    secondary: Color.fromRGBO(61, 69, 62, 1),
    onSecondary: Color.fromRGBO(252, 249, 243, 1),
    error: Color.fromRGBO(98, 19, 19, 1),
    onError: Color.fromRGBO(252, 249, 243, 1),
    surface: Color.fromRGBO(3, 7, 18, 1),
    onSurface: Color.fromRGBO(252, 249, 243, 1),
    tertiary: Color.fromRGBO(37, 141, 108, 1),
    onTertiary: Color.fromRGBO(252, 249, 243, 1));

material.ThemeData personalThemeData = material.ThemeData(
    colorScheme: darkscheme,
    brightness: Brightness.dark,
    useMaterial3: true,
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: material.Colors.white,
        selectionColor: material.Colors.amber[100]?.withAlpha(100),
        selectionHandleColor: Color.fromRGBO(252, 249, 243, 1)));

FluentThemeData fluentThemeData = FluentThemeData(
  scaffoldBackgroundColor: Color.fromRGBO(32, 32, 32, 1),
  cardColor: Color.fromRGBO(40, 40, 40, 1),
  micaBackgroundColor: Color.fromRGBO(32, 32, 32, 1),
  acrylicBackgroundColor: Color.fromRGBO(32, 32, 32, 1),
  typography: Typography.fromBrightness(brightness: Brightness.dark),
  iconTheme: IconThemeData(
    color: Colors.white
  ),
  dialogTheme: ContentDialogThemeData(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      color: Color.fromRGBO(50, 50, 50, 1)
    ),
  ),
    accentColor: SystemTheme.accentColor.accent.toAccentColor()
);
