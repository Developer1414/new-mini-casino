import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:provider/provider.dart';

class FortuneWheelLogic extends ChangeNotifier {
  bool isGameOn = false;

  double coefficient = 0.0;
  double bet = 0.0;
  double profit = 0.0;

  int selectedNumber = 2;

  List<int> buttonsCoefficient = [2, 3, 5, 30];

  List<Color> lastColors = [];

  late BuildContext context;

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

  void startGame({required BuildContext context}) {
    isGameOn = true;

    this.context = context;

    profit = 0.0;

    CommonFunctions.callOnStart(
        context: context, bet: bet, gameName: 'fortuneWheel');

    notifyListeners();
  }

  void setNewColor(Color color) {
    lastColors.add(color);
    notifyListeners();
  }

  void cashout() {
    isGameOn = false;

    profit = bet * selectedNumber;

    Provider.of<Balance>(context, listen: false).cashout(profit);

    GameStatisticController.updateGameStatistic(
        gameName: 'fortuneWheel',
        gameStatisticModel:
            GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    CommonFunctions.callOnProfit(
      context: context,
      bet: bet,
      gameName: 'Fortune Wheel',
      profit: profit,
    );

    notifyListeners();

    if (Provider.of<SettingsController>(context, listen: false)
        .isEnabledConfetti) {
      confettiController.play();
    }

    AdService.showInterstitialAd(context: context, func: () {});
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
