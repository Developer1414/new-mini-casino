import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/game_button_details.dart';

class GamesController {
  static List<GameButtonDetails> games = [
    GameButtonDetails(
        title: 'Mines',
        gameLogo: 'MinesLogo',
        buttonColor: Colors.blueAccent,
        nextScreen: '/mines'),
    GameButtonDetails(
        title: 'Dice',
        gameLogo: 'DiceLogo',
        buttonColor: Colors.green.shade500,
        nextScreen: '/dice'),
    GameButtonDetails(
        title: 'Limbo',
        gameLogo: 'LimboLogo',
        isSoon: true,
        buttonColor: Colors.redAccent,
        nextScreen: '/mines'),
    GameButtonDetails(
        title: 'Fortune wheel',
        gameLogo: 'FortuneWheelLogo',
        buttonColor: Colors.purpleAccent,
        nextScreen: '/fortuneWheel'),
  ];
}
