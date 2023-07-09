import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/autoclicker_secure.dart';
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

      GameStatisticController.updateGameStatistic(
          gameName: 'crash',
          incrementTotalGames: true,
          gameStatisticModel: GameStatisticModel());

      Provider.of<Balance>(context, listen: false).placeBet(bet);

      incrementCoefficient();

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

  void incrementCoefficient() {
    int temp = Random.secure().nextInt(100);

    int time = 10;

    if (temp < 50.0) {
      maxCoefficient = Random.secure().nextDouble() * (1.5 - 1.0) + 1.0;
    } else if (temp >= 50.0 && temp < 75) {
      maxCoefficient = Random.secure().nextDouble() * (5.0 - 1.0) + 1.0;
    } else if (temp >= 75.0 && temp < 85) {
      maxCoefficient = Random.secure().nextDouble() * (10.0 - 1.0) + 1.0;
    } else if (temp >= 85.0 && temp < 95) {
      maxCoefficient = Random.secure().nextDouble() * (15.0 - 1.0) + 1.0;
    } else if (temp >= 95.0 && temp < 99.5) {
      maxCoefficient = Random.secure().nextDouble() * (35.0 - 1.0) + 1.0;
    } else if (temp >= 99.5) {
      maxCoefficient = Random.secure().nextDouble() * (100.0 - 1.0) + 1.0;
    }

    timer = Timer.periodic(Duration(milliseconds: time), (timer) {
      if (winCoefficient < maxCoefficient) {
        winCoefficient += 0.01;
        profit = bet * winCoefficient;
      } else {
        timer.cancel();
      }

      if (!timer.isActive) {
        if (winCoefficient < targetCoefficient) {
          crashStatus = CrashStatus.loss;
          lastCoefficients.add(CrashRound(
              coefficient: maxCoefficient.toStringAsFixed(2), isWin: false));
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
