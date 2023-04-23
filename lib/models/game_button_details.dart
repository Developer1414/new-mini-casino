import 'package:flutter/material.dart';

class GameButtonDetails {
  final String title;
  final String gameLogo;
  final Color buttonColor;
  final String nextScreen;
  final bool isSoon;

  GameButtonDetails(
      {required this.title,
      required this.gameLogo,
      this.isSoon = false,
      required this.buttonColor,
      required this.nextScreen});
}
