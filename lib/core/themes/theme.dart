import 'package:flutter/material.dart';
import 'package:wmsapp/core/themes/text_style.dart';

abstract final class AppTheme {
  static get theme => ThemeData(
    //    colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: AppTextStyle.semiBoldMedium.copyWith(color: Colors.black),
    ),
  );
}
