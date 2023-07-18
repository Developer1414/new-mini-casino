import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart';

class StairsLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isGameOver = false;

  double currentCoefficient = 0.0;
  double sliderValue = 1;
  double profit = 0.0;
  double bet = 0.0;

  Map<int, List<int>> stonesIndex = {};
  List<int> cellCount = [7, 6, 7, 3, 5, 3, 4, 2, 6, 5];

  Map<int, int> openedColumnIndex = {};

  int countStones = 1;
  int currentIndex = 9;

  late BuildContext context;

  void changeSliderValue(double value) {
    sliderValue = value;
    countStones = value.round();
    notifyListeners();
  }

  void startGame({double bet = 0.0, required BuildContext context}) {
    this.bet = bet;
    this.context = context;

    isGameOn = true;
    isGameOver = false;

    stonesIndex.clear();
    cellCount.clear();
    openedColumnIndex.clear();

    currentIndex = 9;
    currentCoefficient = 0;
    profit = 0;

    List<List<int>> stones = List.generate(10, (_) => []);

    for (int i = 0; i < 10; i++) {
      int cells = Random.secure().nextInt(4) + 4;
      cellCount.add(cells);
    }

    for (var i = 0; i < 10; i++) {
      while (stones[i].length != countStones) {
        int rand = Random.secure().nextInt(cellCount[i]);

        if (!stones[i].contains(rand)) {
          stones[i].add(rand);
        }
      }
    }

    for (int i = 0; i < 10; i++) {
      stonesIndex.addAll({i: stones[i]});
    }

    GameStatisticController.updateGameStatistic(
        gameName: 'stairs',
        incrementTotalGames: true,
        gameStatisticModel: GameStatisticModel());

    Provider.of<Balance>(context, listen: false).placeBet(bet);

    notifyListeners();
  }

  void selectCell(int rowIndex, int columnIndex) {
    if (!isGameOn) return;

    openedColumnIndex.addAll({columnIndex: rowIndex});

    if (!stonesIndex[columnIndex]!.contains(rowIndex)) {
      currentIndex--;

      currentCoefficient =
          (11 - double.parse(currentIndex.toString())) * countStones * 32 / 100;

      profit = bet * currentCoefficient;

      if (currentIndex == -1) {
        cashout();
      }
    } else {
      loss();
    }

    notifyListeners();
  }

  void autoMove() {
    int rand = 0;
    bool successed = false;

    while (!successed) {
      rand = Random.secure().nextInt(cellCount[currentIndex]);

      if (openedColumnIndex[currentIndex] != rand) {
        selectCell(rand, currentIndex);
        successed = true;
      }
    }

    notifyListeners();
  }

  void cashout() {
    isGameOn = false;
    isGameOver = true;

    Provider.of<Balance>(context, listen: false).cashout(profit);

    GameStatisticController.updateGameStatistic(
        gameName: 'stairs',
        gameStatisticModel:
            GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    notifyListeners();

    AdService.showInterstitialAd(context: context, func: () {});
  }

  void loss() {
    isGameOver = true;
    isGameOn = false;

    GameStatisticController.updateGameStatistic(
        gameName: 'stairs',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    AdService.showInterstitialAd(context: context, func: () {});
  }
}
