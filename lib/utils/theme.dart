import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData updatedTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal.shade700, // New seed color for the theme
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF00796B), // Teal-based app bar color
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    centerTitle: true,
    iconTheme: IconThemeData(
      color: Colors.white, // Icon color for app bar
    ),
  ),
  textTheme: GoogleFonts.latoTextTheme(
    TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: Colors.teal.shade800,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.teal.shade600,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
        height: 1.4,
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal.shade700, // Default button color
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.teal.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Colors.teal.shade400,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Colors.teal.shade700,
        width: 2.0,
      ),
    ),
    labelStyle: TextStyle(
      color: Colors.teal.shade700,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
);
