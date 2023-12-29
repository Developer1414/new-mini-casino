import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/autoclicker_secure.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:provider/provider.dart';

enum CrashStatus { win, loss, idle }

class CrashRound {
  final String coefficient;
  final bool isWin;

  CrashRound({required this.coefficient, required this.isWin});
}

class CrashLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isWin = false;
  bool isShowInputBet = false;

  CrashStatus crashStatus = CrashStatus.idle;

  late AnimationController animationController;

  double maxCoefficient = 0.0;
  double winCoefficient = 1.00;
  double targetCoefficient = 0.0;
  double profit = 0.0;
  double bet = 0.0;

  List<CrashRound> lastCoefficients = [];

  late Timer timer = Timer(const Duration(seconds: 1), () {});

  late BuildContext context;

  void showInputBet() {
    isShowInputBet = !isShowInputBet;
    notifyListeners();
  }

  void startGame(
      {required BuildContext context,
      required double bet,
      required double targetCoefficient}) {
    if (AutoclickerSecure.isCanPlay) {
      this.bet = bet;
      this.targetCoefficient = targetCoefficient;
      this.context = context;

      winCoefficient = 1.00;
      maxCoefficient = 0.0;

      isGameOn = true;

      crashStatus = CrashStatus.idle;

      animationController
        ..reset()
        ..forward();

      incrementCoefficient();

      CommonFunctions.call(context: context, bet: bet, gameName: 'crash');

      notifyListeners();
    } else {
      AutoclickerSecure().checkClicksBeforeCanPlay(context);
    }
  }

  void cashout() {
    crashStatus = CrashStatus.win;

    Provider.of<Balance>(context, listen: false).cashout(profit);

    GameStatisticController.updateGameStatistic(
        gameName: 'crash',
        gameStatisticModel:
            GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    AdService.showInterstitialAd(context: context, func: () {});

    notifyListeners();

    AutoclickerSecure().checkAutoclicker();
  }

  void stop() {
    timer.cancel();
    animationController
      ..stop()
      ..reset();
    crashStatus = CrashStatus.idle;
    isGameOn = false;
    lastCoefficients.add(CrashRound(
        coefficient: maxCoefficient.toStringAsFixed(2), isWin: true));
    profit = 0.0;
    winCoefficient = 0.0;
    notifyListeners();
  }

  void loss() {
    isGameOn = false;
    profit = 0.0;

    timer.cancel();

    crashStatus = CrashStatus.loss;

    animationController
      ..stop()
      ..reset();

    GameStatisticController.updateGameStatistic(
        gameName: 'crash',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    AdService.showInterstitialAd(context: context, func: () {});

    notifyListeners();
  }

  double generateDouble(double minValue, double maxValue) {
    return minValue + (maxValue - minValue) * Random.secure().nextDouble();
  }

  void incrementCoefficient() {
    int temp = Random.secure().nextInt(100);
    int time = 10;

    double speed = 0.005;

    if (temp < 45.0) {
      maxCoefficient = generateDouble(1.0, 1.5);
    } else if (temp >= 45.0 && temp < 70) {
      maxCoefficient = generateDouble(1.0, 10.0);
    } else if (temp >= 70.0 && temp < 80) {
      maxCoefficient = generateDouble(1.0, 15.0);
    } else if (temp >= 80.0 && temp < 90) {
      maxCoefficient = generateDouble(1.0, 20.0);
    } else if (temp >= 90.0 && temp < 95.0) {
      maxCoefficient = generateDouble(1.0, 40.0);
    } else if (temp >= 95.0) {
      maxCoefficient = generateDouble(1.0, 100.0);
    }

    timer = Timer.periodic(Duration(milliseconds: time), (timer) {
      if (winCoefficient < maxCoefficient) {
        winCoefficient += speed;
        profit = bet * winCoefficient;
        speed += 0.0001;
      } else {
        timer.cancel();
        winCoefficient = maxCoefficient;
      }

      if (!timer.isActive) {
        if (winCoefficient < targetCoefficient) {
          lastCoefficients.add(CrashRound(
              coefficient: maxCoefficient.toStringAsFixed(2),
              isWin: crashStatus == CrashStatus.win ? true : false));
          notifyListeners();
          loss();
        } else if (winCoefficient >= targetCoefficient) {
          crashStatus = CrashStatus.win;
          isGameOn = false;
          animationController.stop();
          lastCoefficients.add(CrashRound(
              coefficient: maxCoefficient.toStringAsFixed(2), isWin: true));
          notifyListeners();
        }
      } else {
        if (crashStatus != CrashStatus.win) {
          if (winCoefficient >= targetCoefficient) {
            cashout();
          }
        }

        if (maxCoefficient >= 10 && winCoefficient >= 5.0) {
          time = 3;
        } else if (maxCoefficient >= 30 && winCoefficient >= 10.0) {
          time = 1;
        }
      }

      notifyListeners();
    });
  }
}
