import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/autoclicker_secure.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:provider/provider.dart';

import '../business/balance.dart';

enum KenoRiskStatus { low, medium, high }

class KenoLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isShowInputBet = false;

  KenoRiskStatus riskStatus = KenoRiskStatus.low;

  List<int> randomNumbersList = [];
  List<int> userNumbersList = [];

  int currentCoefficient = 0;

  late BuildContext context;

  List<double> coefficients = [];

  late Timer timer = Timer(const Duration(seconds: 1), () {});

  double profit = 0.0;
  double coefficient = 0.0;
  double bet = 0.0;

  void showInputBet() {
    isShowInputBet = !isShowInputBet;
    notifyListeners();
  }

  void getRandomNumbers() {
    if (isGameOn) {
      return;
    }

    int currentItem = -1;

    userNumbersList.clear();
    randomNumbersList.clear();

    List<int> numbers = [];

    timer.cancel();

    while (numbers.length < 10) {
      int rand = Random.secure().nextInt(40) + 0;

      if (!numbers.contains(rand)) {
        numbers.add(rand);
      }
    }

    if (numbers.length == 10) {
      timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
        if (currentItem < 9) {
          currentItem++;
        } else {
          timer.cancel();
        }

        if (userNumbersList.length < 10) {
          userNumbersList.add(numbers[currentItem]);
        }

        coefficients = calculateCoefficients(10);
        notifyListeners();
      });
    }
  }

  void startGame({required BuildContext context, required double bet}) {
    if (userNumbersList.isEmpty) {
      return;
    }

    if (AutoclickerSecure.isCanPlay) {
      this.bet = bet;
      this.context = context;

      randomNumbersList.clear();

      currentCoefficient = 0;
      int currentItem = -1;
      profit = 0.0;
      coefficient = 0.0;

      isGameOn = true;

      List<int> numbers = [];
      Set<int> alreadyChecked = {};

      timer.cancel();

      CommonFunctions.call(context: context, bet: bet, gameName: 'keno');

      while (numbers.length < 10) {
        int rand = Random.secure().nextInt(40) + 0;

        if (!numbers.contains(rand)) {
          numbers.add(rand);
        }
      }

      if (numbers.length == 10) {
        timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
          if (currentItem + 1 < numbers.length) {
            currentItem++;
          } else {
            timer.cancel();
            isGameOn = false;
          }

          randomNumbersList.add(numbers[currentItem]);

          if (userNumbersList.contains(randomNumbersList[currentItem]) &&
              !alreadyChecked.contains(randomNumbersList[currentItem])) {
            currentCoefficient++;
            coefficient = coefficients[currentCoefficient - 1];
            profit = bet * coefficients[currentCoefficient - 1];

            alreadyChecked.add(randomNumbersList[currentItem]);
          }

          if (randomNumbersList.length == 10) {
            if (profit < bet) {
              GameStatisticController.updateGameStatistic(
                  gameName: 'keno',
                  gameStatisticModel: GameStatisticModel(
                    maxLoss: bet,
                    lossesMoneys: bet,
                  ));
            } else {
              GameStatisticController.updateGameStatistic(
                  gameName: 'keno',
                  gameStatisticModel: GameStatisticModel(
                      winningsMoneys: profit, maxWin: profit));
            }

            Provider.of<Balance>(context, listen: false).cashout(profit);
            AdService.showInterstitialAd(context: context, func: () {});
          }

          notifyListeners();
        });
      }
    } else {
      AutoclickerSecure().checkClicksBeforeCanPlay(context);
    }
  }

  void clearList() {
    if (isGameOn) {
      return;
    }

    currentCoefficient = 0;
    userNumbersList.clear();
    randomNumbersList.clear();
    coefficients.clear();
    notifyListeners();
  }

  void selectCustomNumber(int index) {
    if (isGameOn) {
      return;
    }

    if (userNumbersList.length >= 10 && !userNumbersList.contains(index)) {
      return;
    }

    if (!userNumbersList.contains(index)) {
      userNumbersList.add(index);
    } else {
      userNumbersList.remove(index);
    }

    coefficients.clear();

    coefficients = calculateCoefficients(userNumbersList.length);

    notifyListeners();
  }

  List<double> calculateCoefficients(int selectedCellsCount) {
    List<double> coefficients = [];

    if (selectedCellsCount == 0) {
      return coefficients;
    }

    double startCoefficient = 0.0;
    double endCoefficient = 100.0;

    if (selectedCellsCount != 10) {
      double startCoefficientForTen = 0.0;
      double endCoefficientForTen = 100.0;
      double startCoefficientForOne = 0.001;
      double endCoefficientForOne = 0.0;

      startCoefficient = startCoefficientForOne +
          (startCoefficientForTen - startCoefficientForOne) *
              (selectedCellsCount - 1) /
              9;
      endCoefficient = endCoefficientForOne +
          (endCoefficientForTen - endCoefficientForOne) *
              (selectedCellsCount - 1) /
              9;
    }

    if (selectedCellsCount == 1) {
      coefficients.add(1.05);
      return coefficients;
    }

    double cellCountMultiplier = selectedCellsCount / 10.0;

    for (int i = 0; i < selectedCellsCount; i++) {
      double t = i / (selectedCellsCount - 1);
      num t65 = pow(t, 1.8);
      double coefficient =
          startCoefficient * (1 - t65) * (1 - t65) + endCoefficient * t65 * t65;
      coefficients.add(
          double.parse((coefficient * cellCountMultiplier).toStringAsFixed(2)));
    }

    return coefficients;
  }
}
