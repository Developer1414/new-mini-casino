import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/main.dart';

import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/autoclicker_secure.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:provider/provider.dart';

enum DiceClassicStatus { win, loss, idle }

class DiceClassicRound {
  final String coefficient;
  final bool isWin;

  DiceClassicRound({required this.coefficient, required this.isWin});
}

class DiceClassicLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isShowInputBet = false;
  bool isProfitTaked = false;

  double profit = 0.0;
  double bet = 0.0;

  int lessNumber = 9999;
  int moreNumber = 990000;

  int targetCoefficient = Random.secure().nextInt(1000001);

  double selectedChanceWinning = 50.0;

  DiceClassicStatus diceClassicStatus = DiceClassicStatus.idle;

  List<DiceClassicRound> lastCoefficients = [];

  late BuildContext context;

  TextEditingController textFieldCoefficient =
      TextEditingController(text: '2.0');

  void changeBet(double value) {
    bet = value;
    notifyListeners();
  }

  void changeChanceWinning(double chance) {
    textFieldCoefficient.text = (100 / chance).toStringAsFixed(2);

    selectedChanceWinning = chance;

    calculateNumbers();

    notifyListeners();
  }

  void changeCoefficient(double coefficient) {
    if (coefficient <= 1.0 || coefficient > 98.0) return;

    selectedChanceWinning = 100 / coefficient;

    calculateNumbers();

    notifyListeners();
  }

  void calculateNumbers() {
    lessNumber = selectedChanceWinning.toInt() * 9999;
    moreNumber = 1000000 - (selectedChanceWinning.toInt() * 10000);
  }

  Future startGame({
    required BuildContext context,
    required bool more,
  }) async {
    if (AutoclickerSecure.isCanPlay && !isProfitTaked) {
      await CommonFunctions.callOnStart(
          context: context,
          bet: bet,
          gameName: 'dice-classic',
          callback: () async {
            this.context = context;

            isGameOn = true;

            targetCoefficient = 0;
            profit = 0.0;

            incrementCoefficient(more);

            notifyListeners();
          });
    } else {
      AutoclickerSecure().checkClicksBeforeCanPlay(context);
    }
  }

  void more({required BuildContext context}) async {
    await startGame(context: context, more: true);
  }

  void less({required BuildContext context}) async {
    await startGame(context: context, more: false);
  }

  Future cashout() async {
    profit = bet * double.parse(textFieldCoefficient.text);

    isProfitTaked = true;

    await Provider.of<Balance>(context, listen: false)
        .addMoney(profit)
        .whenComplete(() {
      GameStatisticController.updateGameStatistic(
        gameName: 'dice-classic',
        gameStatisticModel: GameStatisticModel(
          winningsMoneys: profit,
          lossesMoneys: bet,
          maxWin: profit,
        ),
      );

      lastCoefficients.add(DiceClassicRound(
          coefficient: targetCoefficient.toString(), isWin: true));

      diceClassicStatus = DiceClassicStatus.win;

      CommonFunctions.callOnProfit(
        context: context,
        bet: bet,
        gameName: 'Dice Classic',
        profit: profit,
      );

      AdService.showInterstitialAd(context: context, func: () {});

      isGameOn = false;

      notifyListeners();

      if (Provider.of<SettingsController>(context, listen: false)
              .isEnabledConfetti &&
          selectedChanceWinning <= 10.0) {
        confettiController.play();
      }

      AutoclickerSecure().checkAutoclicker();
    });

    isProfitTaked = false;
  }

  void loss() {
    isGameOn = false;
    profit = 0.0;

    GameStatisticController.updateGameStatistic(
        gameName: 'dice-classic',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    diceClassicStatus = DiceClassicStatus.loss;

    lastCoefficients.add(DiceClassicRound(
        coefficient: targetCoefficient.toString(), isWin: false));

    AdService.showInterstitialAd(context: context, func: () {});

    notifyListeners();
  }

  Future incrementCoefficient(bool more) async {
    targetCoefficient = Random.secure().nextInt(1000001);

    isGameOn = false;

    if (more) {
      if (targetCoefficient >= moreNumber && targetCoefficient <= 999999) {
        await cashout();
      } else {
        loss();
      }
    } else {
      if (targetCoefficient >= 0 && targetCoefficient <= lessNumber) {
        await cashout();
      } else {
        loss();
      }
    }

    notifyListeners();
  }
}
