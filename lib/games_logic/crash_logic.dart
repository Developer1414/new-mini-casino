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

  void changeBet(double value) {
    bet = value;
    notifyListeners();
  }

  void startGame(
      {required BuildContext context,
      required double targetCoefficient}) async {
    if (AutoclickerSecure.isCanPlay) {
      CommonFunctions.callOnStart(
          context: context,
          bet: bet,
          gameName: 'crash',
          callback: () {
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

            notifyListeners();
          });
    } else {
      AutoclickerSecure().checkClicksBeforeCanPlay(context);
    }
  }

  void cashout() {
    CommonFunctions.callOnProfit(
      context: context,
      bet: bet,
      gameName: 'Crash',
      profit: profit,
    );

    crashStatus = CrashStatus.win;

    Provider.of<Balance>(context, listen: false).addMoney(profit);

    GameStatisticController.updateGameStatistic(
      gameName: 'crash',
      gameStatisticModel: GameStatisticModel(
        winningsMoneys: profit,
        lossesMoneys: bet,
        maxWin: profit,
      ),
    );

    AdService.showInterstitialAd(context: context, func: () {});

    notifyListeners();

    if (Provider.of<SettingsController>(context, listen: false)
            .isEnabledConfetti &&
        winCoefficient >= 10.0) {
      confettiController.play();
    }

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

    animationController.stop();

    GameStatisticController.updateGameStatistic(
        gameName: 'crash',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    AdService.showInterstitialAd(context: context, func: () {});

    notifyListeners();
  }

  double generateCoefficient() {
    double random = Random.secure().nextDouble();

    if (random < 0.5) {
      return (1 + Random.secure().nextDouble());
    } else if (random < 0.75) {
      return (2 + Random.secure().nextDouble() * 3);
    } else if (random < 0.9) {
      return (5 + Random.secure().nextDouble() * 5);
    } else if (random < 0.97) {
      return (10 + Random.secure().nextDouble() * 10);
    } else if (random < 0.995) {
      return (20 + Random.secure().nextDouble() * 30);
    } else {
      return (50 + Random.secure().nextDouble() * 50);
    }
  }

  void incrementCoefficient() {
    int time = 10;

    double speed = 0.005;

    maxCoefficient = generateCoefficient();

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
