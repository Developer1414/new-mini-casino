import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/game_button_details.dart';

String generateHash(String text) {
  var encoder = utf8.encoder;
  List<int> bytes = encoder.convert(text);
  return sha256.convert(bytes).toString();
}

class OnlineGamesController {
  static List<GameButtonDetails> games = [
    GameButtonDetails(
      title: 'Crash',
      gameLogo: 'Crash',
      buttonColor: Colors.redAccent,
      nextScreen: '/online-crash',
    ),
    GameButtonDetails(
      title: 'Slide',
      gameLogo: 'Slide',
      buttonColor: const Color.fromARGB(255, 134, 82, 255),
      nextScreen: '/online-slide',
    ),
  ];
}
