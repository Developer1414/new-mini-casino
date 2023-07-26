import 'dart:math';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart';

enum CoinflipStatus { dollar, nothing, init }

class CoinflipLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isContinueGame = false;

  CoinflipStatus randomCoinflipStatus = CoinflipStatus.init;
  CoinflipStatus userCoinflipStatus = CoinflipStatus.nothing;

  List<bool> lastGames = [];

  List<double> coefficients = [
    1.9,
    3.8,
    7.6,
    15.2,
    30.4,
    60.8,
    121.6,
    243.2,
    486.4,
    972.8
  ];

  int currentCoefficient = -1;

  double bet = 0.0;
  double profit = 0.0;

  late BuildContext context;

  void startGame(
      {required BuildContext context,
      required double bet,
      required CoinflipStatus status}) {
    isGameOn = true;

    this.bet = bet;
    this.context = context;
    userCoinflipStatus = status;

    if (!isContinueGame) {
      profit = 0.0;
      Provider.of<Balance>(context, listen: false).placeBet(bet);
    }

    randomCoinflipStatus = Random.secure().nextInt(2) == 1
        ? CoinflipStatus.dollar
        : CoinflipStatus.nothing;

    GameStatisticController.updateGameStatistic(
        gameName: 'coinflip',
        incrementTotalGames: true,
        gameStatisticModel: GameStatisticModel());

    notifyListeners();
  }

  void raiseWinnings() {
    currentCoefficient++;
    isGameOn = false;
    lastGames.add(randomCoinflipStatus == CoinflipStatus.dollar &&
            userCoinflipStatus == CoinflipStatus.dollar
        ? true
        : false);

    if (currentCoefficient < coefficients.length) {
      profit = bet * coefficients[currentCoefficient];
      isContinueGame = true;
    } else {
      cashout();
    }
    notifyListeners();
  }

  void cashout() {
    isGameOn = false;
    isContinueGame = false;
    currentCoefficient = -1;

    randomCoinflipStatus = CoinflipStatus.init;

    Provider.of<Balance>(context, listen: false).cashout(profit);

    GameStatisticController.updateGameStatistic(
        gameName: 'coinflip',
        gameStatisticModel:
            GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    notifyListeners();

    AdService.showInterstitialAd(context: context, func: () {});
  }

  void loss() {
    isGameOn = false;
    isContinueGame = false;
    currentCoefficient = -1;
    profit = 0.0;

    lastGames.add(randomCoinflipStatus == CoinflipStatus.dollar ? true : false);

    GameStatisticController.updateGameStatistic(
        gameName: 'coinflip',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    notifyListeners();

    AdService.showInterstitialAd(context: context, func: () {});
  }
}
