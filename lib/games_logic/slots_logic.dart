import 'package:flutter/material.dart';

class SlotsLogic extends ChangeNotifier {
  double bet = 100.0;

  bool isGameOn = false;

  void changeBet(double value) {
    bet = value;
    notifyListeners();
  }

  void changeGameStatus(bool value) {
    isGameOn = value;
    notifyListeners();
  }
}
