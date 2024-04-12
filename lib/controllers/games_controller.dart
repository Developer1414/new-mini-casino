import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/game_button_details.dart';

class GamesController {
  static List<GameButtonDetails> games = [
    // GameButtonDetails(
    //     title: 'Trading',
    //     gameLogo: 'FortuneWheelLogo',
    //     buttonColor: Color.fromARGB(255, 210, 251, 64),
    //     nextScreen: '/trading'),

    GameButtonDetails(
        title: 'Dice Classic',
        gameLogo: 'DiceClassic',
        forPremium: true,
        buttonColor: const Color.fromARGB(255, 136, 71, 126),
        nextScreen: '/dice-classic'),

    GameButtonDetails(
        title: 'Limbo',
        gameLogo: 'Limbo',
        buttonColor: const Color.fromARGB(255, 98, 64, 251),
        nextScreen: '/limbo'),

    // GameButtonDetails(
    //     title: 'Roulette',
    //     gameLogo: 'FortuneWheelLogo',
    //     buttonColor: const Color.fromARGB(255, 64, 67, 251),
    //     nextScreen: '/roulette-wheel'),
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
        buttonColor: const Color.fromARGB(255, 67, 87, 97),
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
        title: 'Fortune Wheel',
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
