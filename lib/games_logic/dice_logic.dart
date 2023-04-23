import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart';

enum EvenOrOddButtonType { even, odd, empty }

enum NumberFromToButtonType { oneToThree, fourToSix, empty }

class DiceLogic extends ChangeNotifier {
  bool isGameOn = false;

  double profit = 0.0;
  double coefficient = 0.0;
  double bet = 0.0;

  EvenOrOddButtonType evenOrOddType = EvenOrOddButtonType.empty;
  NumberFromToButtonType numberFromToType = NumberFromToButtonType.empty;

  int selectedNumber = 1;
  int randomNumber = 1;

  List<double> buttonsCoefficient = [1.05, 1.4, 2.5, 3.6, 4.7, 5.8];

  List<int> oneToTheeList = [1, 2, 3];
  List<int> fourToSixList = [4, 5, 6];

  late BuildContext context;

  void selectNumbersFromTo(NumberFromToButtonType type) {
    evenOrOddType = EvenOrOddButtonType.empty;

    selectedNumber = 0;
    numberFromToType = type;
    coefficient = 2.0;

    notifyListeners();
  }

  void unSelectNumbersFromTo() {
    numberFromToType = NumberFromToButtonType.empty;
    coefficient = 0;

    notifyListeners();
  }

  void selectOddOrEvenNumbers(EvenOrOddButtonType type) {
    numberFromToType = NumberFromToButtonType.empty;

    selectedNumber = 0;
    evenOrOddType = type;
    coefficient = 2;

    notifyListeners();
  }

  void unSelectEvenOrOdd() {
    evenOrOddType = EvenOrOddButtonType.empty;
    coefficient = 0;

    notifyListeners();
  }

  void selectNumber({required int number, required double coefficient}) {
    evenOrOddType = EvenOrOddButtonType.empty;
    numberFromToType = NumberFromToButtonType.empty;

    selectedNumber = number;
    this.coefficient = coefficient;

    notifyListeners();
  }

  void unSelectNumber() {
    selectedNumber = 0;
    coefficient = 0;

    notifyListeners();
  }

  void startGame({required BuildContext context, required double bet}) {
    isGameOn = true;

    this.bet = bet;
    this.context = context;

    randomNumber = Random().nextInt(6) + 1;
    profit = 0.0;

    GameStatisticController.updateGameStatistic(
        gameName: 'dice',
        incrementTotalGames: true,
        gameStatisticModel: GameStatisticModel());

    Provider.of<Balance>(context, listen: false).placeBet(bet);

    if (kDebugMode) {
      print(randomNumber);
    }

    AdService.showInterstitialAd(context: context, func: () {});

    notifyListeners();
  }

  void cashout() {
    isGameOn = false;

    if (randomNumber == selectedNumber ||
        randomNumber.isEven && evenOrOddType == EvenOrOddButtonType.even ||
        randomNumber.isOdd && evenOrOddType == EvenOrOddButtonType.odd ||
        numberFromToType == NumberFromToButtonType.oneToThree &&
            oneToTheeList.contains(randomNumber) ||
        numberFromToType == NumberFromToButtonType.fourToSix &&
            fourToSixList.contains(randomNumber)) {
      profit = bet * coefficient;

      Provider.of<Balance>(context, listen: false).cashout(profit);

      GameStatisticController.updateGameStatistic(
          gameName: 'dice',
          gameStatisticModel:
              GameStatisticModel(winningsMoneys: profit, maxWin: profit));
    } else {
      profit = 0.0;

      GameStatisticController.updateGameStatistic(
          gameName: 'dice',
          gameStatisticModel: GameStatisticModel(
            maxLoss: bet,
            lossesMoneys: bet,
          ));
    }

    notifyListeners();
  }
}
