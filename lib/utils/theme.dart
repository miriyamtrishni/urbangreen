// lib/utils/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primaryColor,
  hintColor: AppColors.accentColor,
  scaffoldBackgroundColor: AppColors.secondaryColor, // White background
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.green,
  ).copyWith(
    secondary: AppColors.accentColor,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(), // Use Poppins font
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryColor, // App bar color
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor, // Button background color
      textStyle: GoogleFonts.poppins(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
);
