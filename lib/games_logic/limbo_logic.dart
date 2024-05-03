import 'dart:async';
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

enum LimboStatus { win, loss, idle }

class LimboRound {
  final String coefficient;
  final bool isWin;

  LimboRound({required this.coefficient, required this.isWin});
}

class LimboLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isWin = false;
  bool isShowInputBet = false;

  double targetCoefficient = 0.0;
  double selectedCoefficient = 0.0;
  double profit = 0.0;
  double bet = 0.0;

  LimboStatus crashStatus = LimboStatus.idle;

  List<LimboRound> lastCoefficients = [];

  late Timer timer = Timer(const Duration(seconds: 1), () {});

  late BuildContext context;

  void showInputBet() {
    isShowInputBet = !isShowInputBet;
    notifyListeners();
  }

  void changeBet(double value) {
    bet = value;
    notifyListeners();
  }

  void startGame(
      {required BuildContext context,
      required double selectedCoefficient}) async {
    if (AutoclickerSecure.isCanPlay) {
      CommonFunctions.callOnStart(
          context: context,
          bet: bet,
          gameName: 'limbo',
          callback: () {
            this.selectedCoefficient = selectedCoefficient;
            this.context = context;

            isGameOn = true;

            targetCoefficient = 1.0;
            profit = 0.0;

            crashStatus = LimboStatus.idle;

            incrementCoefficient();

            notifyListeners();
          });
    } else {
      AutoclickerSecure().checkClicksBeforeCanPlay(context);
    }
  }

  void cashout() {
    crashStatus = LimboStatus.win;

    profit = bet * selectedCoefficient;

    Provider.of<Balance>(context, listen: false).addMoney(profit);

    GameStatisticController.updateGameStatistic(
        gameName: 'limbo',
        gameStatisticModel:
            GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    lastCoefficients.add(LimboRound(
        coefficient: targetCoefficient.toStringAsFixed(2), isWin: true));

    CommonFunctions.callOnProfit(
      context: context,
      bet: bet,
      gameName: 'Limbo',
      profit: profit,
    );

    AdService.showInterstitialAd(context: context, func: () {});

    isGameOn = false;

    notifyListeners();

    if (Provider.of<SettingsController>(context, listen: false)
            .isEnabledConfetti &&
        targetCoefficient >= 50.0 &&
        selectedCoefficient >= 50.0) {
      confettiController.play();
    }

    AutoclickerSecure().checkAutoclicker();
  }

  void loss() {
    isGameOn = false;
    profit = 0.0;

    timer.cancel();

    crashStatus = LimboStatus.loss;

    GameStatisticController.updateGameStatistic(
        gameName: 'limbo',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    lastCoefficients.add(LimboRound(
        coefficient: targetCoefficient.toStringAsFixed(2), isWin: false));

    AdService.showInterstitialAd(context: context, func: () {});

    notifyListeners();
  }

  double generateDouble(double minValue, double maxValue) {
    return minValue + (maxValue - minValue) * Random.secure().nextDouble();
  }

  void incrementCoefficient() {
    int time = 3;

    double maxCoefficient = 0.0;
    double speed = 0.01;

    double randomNumber = Random().nextDouble();
    double scaledNumber = -log(randomNumber) * 2.8;
    maxCoefficient = scaledNumber.clamp(1.0, 100.0);

    timer = Timer.periodic(Duration(milliseconds: time), (timer) {
      if (targetCoefficient < maxCoefficient) {
        speed += maxCoefficient >= 50
            ? 0.02
            : maxCoefficient >= 10
                ? 0.01
                : maxCoefficient < 10 && maxCoefficient > 2
                    ? 0.005
                    : 0.0001;

        targetCoefficient += speed;
      } else {
        timer.cancel();
        targetCoefficient = maxCoefficient;
      }

      if (!timer.isActive) {
        if (targetCoefficient >= selectedCoefficient) {
          cashout();
        } else {
          loss();
        }
      }

      notifyListeners();
    });
  }
}
