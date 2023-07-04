import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/game_button_details.dart';

class GamesController {
  static List<GameButtonDetails> games = [
    GameButtonDetails(
        title: 'Jackpot (Beta)',
        gameLogo: 'Jackpot',
        buttonColor: const Color.fromARGB(255, 241, 205, 44),
        isNew: true,
        nextScreen: '/jackpot'),
    GameButtonDetails(
        title: 'Mines',
        gameLogo: 'MinesLogo',
        buttonColor: Colors.blueAccent,
        nextScreen: '/mines'),
    GameButtonDetails(
        title: 'Dice',
        gameLogo: 'DiceLogo',
        buttonColor: const Color.fromARGB(255, 255, 172, 48),
        nextScreen: '/dice'),
    GameButtonDetails(
        title: 'Coinflip',
        gameLogo: 'Coinflip',
        buttonColor: const Color.fromARGB(255, 79, 173, 79),
        nextScreen: '/coinflip'),
    GameButtonDetails(
        title: 'Fortune wheel',
        gameLogo: 'FortuneWheelLogo',
        buttonColor: Colors.purpleAccent,
        nextScreen: '/fortuneWheel'),
    GameButtonDetails(
        title: 'Crash',
        gameLogo: 'LimboLogo',
        buttonColor: Colors.redAccent,
        nextScreen: '/crash'),
    GameButtonDetails(
        title: 'Keno',
        gameLogo: 'Keno',
        buttonColor: const Color.fromRGBO(129, 209, 72, 1),
        nextScreen: '/keno'),
  ];
}
