import 'dart:math';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/autoclicker_secure.dart';
import 'package:provider/provider.dart';

class MinesLogic extends ChangeNotifier {
  double sliderValue = 1;
  double bet = 0.0;
  double currentCoefficient = 0.0;
  double profit = 0.0;

  int countMines = 1;

  bool isGameOn = false;

  late BuildContext context;

  List<int> minesIndex = [];
  List<int> brilliantsIndex = [];
  List<int> openedIndexes = [];

  void changeSliderValue(double value) {
    sliderValue = value;
    countMines = value.round();
    notifyListeners();
  }

  checkItem(int index) {
    if (!isGameOn) return;

    if (openedIndexes.contains(index)) return;

    openedIndexes.add(index);

    if (minesIndex.contains(index)) {
      loss();
    } else {
      brilliantsIndex.add(index);
      calculateCoefficient();
    }

    if (brilliantsIndex.length == (25 - countMines)) {
      cashout();
    }

    notifyListeners();
  }

  void loss() {
    isGameOn = false;

    GameStatisticController.updateGameStatistic(
        gameName: 'mines',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    AdService.showInterstitialAd(context: context, func: () {});
  }

  void startGame({double bet = 0.0, required BuildContext context}) {
    if (AutoclickerSecure.isCanPlay) {
      isGameOn = true;

      minesIndex.clear();
      openedIndexes.clear();
      brilliantsIndex.clear();

      profit = 0.0;
      currentCoefficient = 0;

      this.bet = bet;
      this.context = context;

      int rand = 0;

      while (minesIndex.length != countMines) {
        rand = Random.secure().nextInt(25);

        if (!minesIndex.contains(rand)) {
          minesIndex.add(rand);
        }
      }

      GameStatisticController.updateGameStatistic(
          gameName: 'mines',
          incrementTotalGames: true,
          gameStatisticModel: GameStatisticModel());

      Provider.of<Balance>(context, listen: false).placeBet(bet);

      notifyListeners();
    } else {
      AutoclickerSecure().checkClicksBeforeCanPlay(context);
    }
  }

  autoMove() {
    int rand = 0;
    bool successed = false;

    while (!successed) {
      rand = Random.secure().nextInt(25);

      if (!openedIndexes.contains(rand)) {
        checkItem(rand);
        successed = true;
      }
    }

    notifyListeners();
  }

  void cashout() {
    isGameOn = false;

    Provider.of<Balance>(context, listen: false)
        .cashout(openedIndexes.isEmpty ? bet : profit);

    GameStatisticController.updateGameStatistic(
        gameName: 'mines',
        gameStatisticModel:
            GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    notifyListeners();

    AutoclickerSecure().checkAutoclicker();
    AdService.showInterstitialAd(context: context, func: () {});
  }

  double factorial(double fact) {
    double num = fact;

    for (double i = fact - 1; i >= 1; i--) {
      num *= i;
    }
    return num;
  }

  double combination(double n, double d) {
    if (n == d) return 1;
    return factorial(n) / (factorial(d) * factorial(n - d));
  }

  void calculateCoefficient() {
    double n = 25;
    double x = 25 - double.parse(countMines.toString());
    double d = double.parse(openedIndexes.length.toString());

    double first = combination(n, d);
    double second = combination(x, d);

    currentCoefficient = 0.99 * (first / second);

    profit = bet * currentCoefficient;
  }
}
