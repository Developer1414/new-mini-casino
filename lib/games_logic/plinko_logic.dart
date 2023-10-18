import 'package:flutter/material.dart';

class PlinkoLogic extends ChangeNotifier {
  double coefficient = 0.0;
  bool isGameOn = false;

  int countBallsAlive = 0;

  List<double> lastCoefficients = [];

  void addNewCoefficient(double coefficient) {
    lastCoefficients.add(coefficient);
    notifyListeners();
  }
}
