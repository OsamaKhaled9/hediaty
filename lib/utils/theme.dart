import 'package:flutter/material.dart';

// Consistent Color Scheme
const Color primaryBlue = Color(0xFF2A6BFF);
const Color backgroundColor = Color(0xFFF1F1F1);
const Color darkGray = Color(0xFF2A2D3D);
const Color lightGray = Color(0xFF7D7D7D);

ThemeData appTheme() {
  return ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: TextTheme(
      headlineLarge:TextStyle(color: darkGray, fontWeight: FontWeight.bold, fontSize: 24),
      bodyLarge: TextStyle(color: darkGray),
      /*headline1: TextStyle(color: darkGray, fontWeight: FontWeight.bold, fontSize: 24),
      headline2: TextStyle(color: darkGray, fontSize: 18),
      bodyText1: TextStyle(color: darkGray),
      bodyText2: TextStyle(color: lightGray),
      subtitle1: TextStyle(color: darkGray), // For smaller text
      subtitle2: TextStyle(color: lightGray), // For smaller light text */
    ),
    appBarTheme: AppBarTheme(
      color: primaryBlue,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryBlue,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
