import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:provider/provider.dart';

enum BlackjackType { init, idle, win, loss, draft, start, blackjack }

enum Insurance { none, yes, no }

class BlackjackLogic extends ChangeNotifier {
  bool isGameOn = false;
  bool isLoadingMove = false;
  bool gameWithInsurance = true;

  BlackjackType blackjackType = BlackjackType.init;
  Insurance insuranceType = Insurance.none;

  double profit = 0.0;
  double bet = 0.0;
  double insurance = 0.0;

  Map<String, int> cards = {
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    '10': 10,
    'A': 0,
    'J': 10,
    'K': 10,
    'Q': 10
  };

  List<String> lastDealerMoves = [];
  List<String> lastPlayerMoves = [];

  int dealerValue = 0;
  int playerValue = 0;

  String resultPlayerValue = '';
  String resultDealerValue = '';

  late BuildContext context;

  void startGame({required BuildContext context, required double bet}) {
    this.context = context;
    this.bet = bet;

    dealerValue = 0;
    playerValue = 0;
    profit = 0.0;
    insurance = 0.0;

    resultPlayerValue = '';
    resultDealerValue = '';

    blackjackType = BlackjackType.idle;
    insuranceType = Insurance.none;

    lastDealerMoves.clear();
    lastPlayerMoves.clear();

    isGameOn = true;
    isLoadingMove = false;

    CommonFunctions.call(context: context, bet: bet, gameName: 'blackjack');

    startDrawingCards();

    notifyListeners();
  }

  void startDrawingCards({int count = 0}) {
    int countCards = count;

    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (countCards < 4) {
        countCards++;

        if (countCards.isOdd) {
          hitMove();
        } else {
          createMove(true);
        }

        if (countCards == 3 &&
            cards[lastDealerMoves.first] == 10 &&
            insuranceType == Insurance.none &&
            gameWithInsurance) {
          timer.cancel();

          final balance = Provider.of<Balance>(context, listen: false);

          if (balance.currentBalance >= bet / 2) {
            alertDialogConfirm(
                context: context,
                title: 'Страховка',
                text: 'Хотите получить страховку?',
                barrierDismissible: false,
                confirmBtnText: 'Да',
                cancelBtnText: 'Нет',
                onConfirmBtnTap: () {
                  Provider.of<Balance>(context, listen: false)
                      .placeBet(bet / 2);

                  insurance = bet / 2;

                  insuranceType = Insurance.yes;

                  Navigator.of(context, rootNavigator: true).pop();

                  startDrawingCards(count: countCards);
                },
                onCancelBtnTap: () {
                  Navigator.of(context, rootNavigator: true).pop();

                  insuranceType = Insurance.no;

                  startDrawingCards(count: countCards);
                });
          } else {
            insuranceType = Insurance.no;
            startDrawingCards(count: countCards);
          }
        } else {
          if (countCards == 4) {
            timer.cancel();
            checkCardsPlayerAndDealer();
          }
        }
      }

      notifyListeners();
    });
  }

  void checkCardsPlayerAndDealer() {
    blackjackType = BlackjackType.start;

    if (lastPlayerMoves.contains('A')) {
      if (lastPlayerMoves.first == 'A') {
        if (cards[lastPlayerMoves[1]] == 10) {
          win(isBlackjack: true);
          resultPlayerValue = '21';
        }
      } else {
        if (lastPlayerMoves.contains('A')) {
          if (playerValue + 11 == 21) {
            win(isBlackjack: true);
            resultPlayerValue = '21';
          }
        }
      }
    } else {
      if (lastDealerMoves.first == 'A') {
        if (cards[lastDealerMoves[1]] == 10) {
          loss();
          resultDealerValue = '21';
        }
      } else {
        if (lastDealerMoves.contains('A')) {
          if (dealerValue + 11 == 21) {
            loss();
            resultDealerValue = '21';

            if (insuranceType == Insurance.yes) {
              Provider.of<Balance>(context, listen: false)
                  .cashout(bet + insurance);
            }
          }
        }
      }
    }
  }

  void createMove(bool isDealer, {bool isDouble = false}) {
    String value = '';

    if (!isDealer) {
      if (lastPlayerMoves.isNotEmpty && lastPlayerMoves.last == 'A') {
        while (value.isEmpty) {
          String temp =
              cards.keys.toList()[Random.secure().nextInt(cards.length)];

          if (temp != 'A') {
            value = temp;
          }
        }
      } else {
        value = cards.keys.toList()[Random.secure().nextInt(cards.length)];
      }

      if (value == 'A') {
        resultPlayerValue = '${playerValue + 1} / ${playerValue + 11}';
      } else {
        if (lastPlayerMoves.isNotEmpty) {
          if (lastPlayerMoves.last != 'A') {
            playerValue += cards[value]!;
          } else {
            if (playerValue + 11 + cards[value]! <= 21) {
              playerValue += 11 + cards[value]!;
            } else {
              playerValue += 1 + cards[value]!;
            }
          }
        } else {
          playerValue += cards[value]!;
        }

        resultPlayerValue = playerValue.toString();
      }

      lastPlayerMoves.add(value);

      if (lastPlayerMoves.length > 2) {
        if (playerValue == 21) {
          standMove();
        } else if (playerValue > 21) {
          loss();
        } else {
          if (isDouble) {
            standMove();
          }
        }
      }
    } else {
      if (lastDealerMoves.isNotEmpty && lastDealerMoves.last == 'A') {
        while (value.isEmpty) {
          String temp =
              cards.keys.toList()[Random.secure().nextInt(cards.length)];

          if (temp != 'A') {
            value = temp;
          }
        }
      } else {
        value = cards.keys.toList()[Random.secure().nextInt(cards.length)];
      }

      if (dealerValue < 17) {
        if (value == 'A') {
          resultDealerValue = '${dealerValue + 1} / ${dealerValue + 11}';
        } else {
          if (lastDealerMoves.isNotEmpty) {
            if (lastDealerMoves.last != 'A') {
              dealerValue += cards[value]!;
            } else {
              if (dealerValue + 11 + cards[value]! <= 21) {
                dealerValue += 11 + cards[value]!;
              } else {
                dealerValue += 1 + cards[value]!;
              }
            }
          } else {
            dealerValue += cards[value]!;
          }

          resultDealerValue = dealerValue.toString();
        }

        lastDealerMoves.add(value);

        if (lastDealerMoves.length > 2) {
          if (dealerValue == 21) {
            loss();
          }
        }
      }
    }

    notifyListeners();
  }

  void hitMove({bool isDouble = false}) {
    createMove(false, isDouble: isDouble);
    notifyListeners();
  }

  void standMove() {
    isLoadingMove = true;
    notifyListeners();

    if (lastPlayerMoves.last == 'A') {
      if (playerValue + 11 <= 21) {
        playerValue += 11;
      } else {
        playerValue += 1;
      }

      resultPlayerValue = playerValue.toString();
    }

    Timer.periodic(
        Duration(
            milliseconds:
                cards[lastDealerMoves[0]]! + cards[lastDealerMoves[1]]! >= 17
                    ? 0
                    : 300), (timer) {
      if (dealerValue < 17) {
        createMove(true);
      } else {
        if (dealerValue == playerValue) {
          draft();
        } else if (dealerValue <= 21) {
          if (dealerValue > playerValue) {
            loss();
          } else {
            win();
          }
        } else {
          win();
        }

        timer.cancel();
      }

      notifyListeners();
    });

    notifyListeners();
  }

  void doubleMove() {
    final balance = Provider.of<Balance>(context, listen: false);

    if (balance.currentBalance < bet) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        text: 'Недостаточно средств на балансе!',
        confirmBtnText: 'Окей',
      );
      return;
    }

    isLoadingMove = true;

    balance.placeBet(bet);
    bet *= 2;
    hitMove(isDouble: true);
    notifyListeners();
  }

  void splitMove() {
    notifyListeners();
  }

  void loss() {
    isGameOn = false;
    blackjackType = BlackjackType.loss;

    GameStatisticController.updateGameStatistic(
        gameName: 'blackjack',
        gameStatisticModel: GameStatisticModel(
          maxLoss: bet,
          lossesMoneys: bet,
        ));

    notifyListeners();
  }

  void win({bool isBlackjack = false}) {
    isGameOn = false;
    blackjackType = isBlackjack ? BlackjackType.blackjack : BlackjackType.win;

    profit = isBlackjack ? bet * 2.5 : bet * 2;

    Provider.of<Balance>(context, listen: false).cashout(profit);

    GameStatisticController.updateGameStatistic(
        gameName: 'blackjack',
        gameStatisticModel:
            GameStatisticModel(winningsMoneys: profit, maxWin: profit));

    notifyListeners();
  }

  void draft() {
    isGameOn = false;
    blackjackType = BlackjackType.draft;

    Provider.of<Balance>(context, listen: false).cashout(bet);

    notifyListeners();
  }

  void changeInsuranceValue(bool value) {
    gameWithInsurance = value;
    notifyListeners();
  }

  String status() {
    return blackjackType == BlackjackType.win
        ? 'Выигрыш!'
        : blackjackType == BlackjackType.blackjack
            ? 'Blackjack!'
            : blackjackType == BlackjackType.loss
                ? 'Проигрыш!'
                : blackjackType == BlackjackType.draft
                    ? 'Ничья!'
                    : blackjackType == BlackjackType.init
                        ? 'Сделайте ставку'
                        : '';
  }
}
