import 'package:flutter/material.dart';

class GameButtonDetails {
  final String title;
  final String gameLogo;
  final Color buttonColor;
  final String nextScreen;

  GameButtonDetails(
      {required this.title,
      required this.gameLogo,
      required this.buttonColor,
      required this.nextScreen});
}
