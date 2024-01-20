import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/game_button_details.dart';

class GamesController {
  static List<GameButtonDetails> games = [
    GameButtonDetails(
        title: 'Slots',
        gameLogo: 'Slots',
        buttonColor: const Color.fromARGB(255, 221, 129, 75),
        nextScreen: '/slots'),
    // GameButtonDetails(
    //     title: 'Plinko',
    //     gameLogo: 'PlinkoLogo',
    //     forPremium: true,
    //     buttonColor: Colors.deepPurple,
    //     nextScreen: '/plinko'),
    GameButtonDetails(
        title: 'Blackjack',
        gameLogo: 'Blackjack',
        buttonColor: Colors.blueGrey.shade800,
        nextScreen: '/blackjack'),
    GameButtonDetails(
        title: 'Stairs',
        gameLogo: 'Stairs',
        buttonColor: const Color.fromARGB(255, 221, 163, 75),
        nextScreen: '/stairs'),
    GameButtonDetails(
        title: 'Jackpot',
        gameLogo: 'Jackpot',
        buttonColor: const Color.fromARGB(255, 241, 205, 44),
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
        title: 'FortuneWheel',
        gameLogo: 'FortuneWheelLogo',
        buttonColor: Colors.purpleAccent,
        nextScreen: '/fortuneWheel'),
    GameButtonDetails(
        title: 'Crash',
        gameLogo: 'Crash',
        forPremium: true,
        buttonColor: Colors.redAccent,
        nextScreen: '/crash'),
    GameButtonDetails(
        title: 'Keno',
        gameLogo: 'Keno',
        buttonColor: const Color.fromRGBO(129, 209, 72, 1),
        nextScreen: '/keno'),
  ];
}
