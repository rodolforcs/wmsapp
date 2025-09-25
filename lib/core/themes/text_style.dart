import 'package:flutter/material.dart';

abstract final class AppTextStyle {
  static const titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const subtitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const boldSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const regularSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const boldMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const semiBoldMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const boldLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const regular = TextStyle(
    fontSize: 14,
  );

  static const errorText = TextStyle(
    color: Colors.red,
  );
}
