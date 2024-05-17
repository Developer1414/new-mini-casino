import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:provider/provider.dart';

class RouletteRound {
  final int coefficient;
  final Color color;

  RouletteRound({required this.coefficient, required this.color});
}

class RouletteLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isShowInputBet = false;

  double coefficient = 0.0;
  double bet = 0.0;
  double profit = 0.0;

  int selectedNumber = 2;

  List<int> buttonsCoefficient = [2, 3, 5, 30];

  List<RouletteRound> lastColors = [];

  late BuildContext context;

  double startRandomAngle = 0.0;
  double countCircles = 0.0;

  void changeBet(double value) {
    bet = value;
    notifyListeners();
  }

  void selectNumber({required int number}) {
    selectedNumber = number;
    notifyListeners();
  }

  void unSelectNumber() {
    selectedNumber = 0;
    notifyListeners();
  }

  void startGame({required BuildContext context, required double bet}) {
    //isGameOn = true;
    notifyListeners(); //     double ballAngle = widget.currentPlusAngle * 2 * pi;

    // CommonFunctions.callOnStart(
    //     context: context,
    //     bet: bet,
    //     gameName: 'fortuneWheel',
    //     callback: () {
    //       isGameOn = true;

    //       this.bet = bet;
    //       this.context = context;

    //       profit = 0.0;

    //       notifyListeners();
    //     });
  }

  void setNewCoefficient({required int coefficient, required Color color}) {
    lastColors.add(RouletteRound(coefficient: coefficient, color: color));
    notifyListeners();
  }

  void checkResultNumber(int resultNumber) {
    isGameOn = false;

    notifyListeners();
  }

  void cashout() {
    // profit = bet * selectedNumber;

    // Provider.of<Balance>(context, listen: false).addMoney(profit);

    // GameStatisticController.updateGameStatistic(
    //     gameName: 'fortuneWheel',
    //     gameStatisticModel:
    //         GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    // CommonFunctions.callOnProfit(
    //   context: context,
    //   bet: bet,
    //   gameName: 'fortuneWheel',
    //   profit: profit,
    // );

    // notifyListeners();

    // if (Provider.of<SettingsController>(context, listen: false)
    //     .isEnabledConfetti) {
    //   confettiController.play();
    // }

    // AdService.showInterstitialAd(context: context, func: () {});
  }

  void loose() {
    isGameOn = false;

    profit = 0.0;

    GameStatisticController.updateGameStatistic(
        gameName: 'fortuneWheel',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    notifyListeners();

    AdService.showInterstitialAd(context: context, func: () {});
  }
}
