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
        title: 'Coinflip',
        gameLogo: 'Coinflip',
        buttonColor: const Color.fromARGB(255, 255, 172, 48),
        nextScreen: '/coinflip'),
    GameButtonDetails(
        title: 'Fortune wheel',
        gameLogo: 'FortuneWheelLogo',
        buttonColor: Colors.purpleAccent,
        nextScreen: '/fortuneWheel'),
    GameButtonDetails(
        title: 'Crash',
        gameLogo: 'LimboLogo',
        isSoon: true,
        buttonColor: Colors.redAccent,
        nextScreen: '/crash'),
  ];
}
