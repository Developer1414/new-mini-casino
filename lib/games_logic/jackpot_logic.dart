import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:provider/provider.dart';

class JackpotLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isShowInputBet = false;

  double coefficient = 0.0;
  double bet = 0.0;

  int currentTimerBeforePlaying = 0;

  List<String> names = [
    'Jacob',
    'Emily',
    'Michael',
    'Emma',
    'Joshua',
    'Madison',
    'Matthew',
    'Olivia',
    'Ethan',
    'Hannah',
    'Andrew',
    'Abigail',
    'Daniel',
    'Isabella'
  ];

  late BuildContext context;
  late Timer timer = Timer(const Duration(seconds: 1), () {});

  void showInputBet() {
    isShowInputBet = !isShowInputBet;
    notifyListeners();
  }

  void blockBetButton() {
    isGameOn = true;
    notifyListeners();
  }

  void startGame({required BuildContext context, required double bet}) {
    isGameOn = true;

    this.context = context;
    this.bet = bet;

    CommonFunctions.callOnStart(
        context: context, bet: bet, gameName: 'jackpot');

    notifyListeners();
  }

  void onAnimationStopped() {
    isGameOn = false;
    notifyListeners();
  }

  void win({required double profit}) {
    Provider.of<Balance>(context, listen: false).cashout(profit);

    GameStatisticController.updateGameStatistic(
        gameName: 'jackpot',
        gameStatisticModel:
            GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    CommonFunctions.callOnProfit(
      context: context,
      bet: bet,
      gameName: 'jackpot',
      profit: profit,
    );

    if (Provider.of<SettingsController>(context, listen: false)
        .isEnabledConfetti) {
      confettiController.play();
    }

    AdService.showInterstitialAd(context: context, func: () {});
  }

  void loss({required double bet, required BuildContext context}) {
    if (isGameOn) {
      GameStatisticController.updateGameStatistic(
          gameName: 'jackpot',
          gameStatisticModel: GameStatisticModel(
            maxLoss: bet,
            lossesMoneys: bet,
          ));
    }

    AdService.showInterstitialAd(context: context, func: () {});
  }
}
