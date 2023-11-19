import 'package:flutter/material.dart';

class GameButtonDetails {
  final String title;
  final String gameLogo;
  final Color buttonColor;
  final String nextScreen;
  final bool forPremium;
  final bool isNew;

  GameButtonDetails(
      {required this.title,
      required this.gameLogo,
      this.forPremium = false,
      this.isNew = false,
      required this.buttonColor,
      required this.nextScreen});
}
