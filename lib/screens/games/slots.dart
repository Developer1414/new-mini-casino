import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:confetti/confetti.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/background_model.dart';
import 'package:new_mini_casino/widgets/bottom_game_navigation.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class Slots extends StatefulWidget {
  const Slots({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  State<Slots> createState() => _SlotsState();
}

class _SlotsState extends State<Slots> {
  static List<ScrollController> controllers =
      List.generate(3, (index) => ScrollController());

  int time = 0;
  int startIndex = 0;

  List<String> reelItems = [
    'apple',
    'bar',
    'cherries',
    'diamond',
    'grapes',
    'lemon',
    'orange',
    'plum',
    'seven',
    'watermelon'
  ];

  Map<List<String>, double> reelWinners = {
    ['seven', 'seven', 'seven']: 100.0,
    ['diamond', 'diamond', 'diamond']: 80.0,
    ['lemon', 'lemon', 'lemon']: 50.0,
    ['cherries', 'cherries', 'cherries']: 30.0,
    ['grapes', 'grapes', 'grapes']: 20.0,
    ['watermelon', 'watermelon', 'watermelon']: 10.0,
    ['?', 'seven', 'seven']: 5.0,
    ['diamond', '?', 'diamond']: 3.0,
    ['apple', 'apple', '?']: 2.0,
    ['plum', '?', '?']: 1.5,
    ['?', 'orange', '?']: 1.3,
    ['?', '?', 'watermelon']: 1.0,
  };

  List<String> choosedReels = [];

  int coefficientsIndexWinner = -1;

  bool isSpinning = false;
  bool isAutoBets = false;

  static bool isFast = false;

  List<bool> isReelsSpinning = [
    false,
    false,
    false,
  ];

  @override
  void initState() {
    super.initState();

    choosedReels = List.generate(3, (index) => 'question');
  }

  @override
  void dispose() {
    super.dispose();
    confettiController.dispose();
  }

  int getWinnerCoefficient() {
    int coefficientsIndexWinner = -1;

    for (int i = 0; i < reelWinners.keys.toList().length; i++) {
      if (reelWinners.keys.toList()[i][0] == choosedReels[0] &&
          reelWinners.keys.toList()[i][1] == choosedReels[1] &&
          reelWinners.keys.toList()[i][2] == choosedReels[2]) {
        coefficientsIndexWinner = i;

        return coefficientsIndexWinner;
      }
      if (reelWinners.keys.toList()[i][1] == choosedReels[1] &&
          reelWinners.keys.toList()[i][2] == choosedReels[2] &&
          reelWinners.keys.toList()[i][0] == '?') {
        coefficientsIndexWinner = i;

        return coefficientsIndexWinner;
      }
      if (reelWinners.keys.toList()[i][0] == choosedReels[0] &&
          reelWinners.keys.toList()[i][1] == '?' &&
          reelWinners.keys.toList()[i][2] == '?') {
        coefficientsIndexWinner = i;

        return coefficientsIndexWinner;
      }
      if (reelWinners.keys.toList()[i][1] == choosedReels[1] &&
          reelWinners.keys.toList()[i][0] == '?' &&
          reelWinners.keys.toList()[i][2] == '?') {
        coefficientsIndexWinner = i;

        return coefficientsIndexWinner;
      }
      if (reelWinners.keys.toList()[i][0] == choosedReels[0] &&
          reelWinners.keys.toList()[i][2] == choosedReels[2] &&
          reelWinners.keys.toList()[i][1] == '?') {
        coefficientsIndexWinner = i;

        return coefficientsIndexWinner;
      }
      if (reelWinners.keys.toList()[i][2] == choosedReels[2] &&
          reelWinners.keys.toList()[i][0] == '?' &&
          reelWinners.keys.toList()[i][1] == '?') {
        coefficientsIndexWinner = i;

        return coefficientsIndexWinner;
      }
      if (reelWinners.keys.toList()[i][0] == choosedReels[0] &&
          reelWinners.keys.toList()[i][1] == choosedReels[1] &&
          reelWinners.keys.toList()[i][2] == '?') {
        coefficientsIndexWinner = i;

        return coefficientsIndexWinner;
      }
    }

    return coefficientsIndexWinner;
  }

  void makeBet(BuildContext context) async {
    if (isSpinning) return;

    if (Provider.of<Balance>(context, listen: false).currentBalance <
        double.parse(
            Slots.betFormatter.getUnformattedValue().toStringAsFixed(2))) {
      return;
    }

    double bet = Slots.betFormatter.getUnformattedValue().toDouble();

    CommonFunctions.callOnStart(context: context, bet: bet, gameName: 'slots');

    setState(() {
      isSpinning = true;

      coefficientsIndexWinner = -1;

      for (int i = 0; i < 3; i++) {
        isReelsSpinning[i] = true;
      }
    });

    time = 0;
    startIndex = 0;

    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      time++;

      if (!isFast) {
        for (int i = startIndex; i < 3; i++) {
          choosedReels[i] = reelItems[Random().nextInt(reelItems.length)];
          controllers[i].animateTo(100,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear);
        }

        if (time == 10) {
          startIndex++;
          choosedReels[0] =
              reelItems[Random.secure().nextInt(reelItems.length)];
          isReelsSpinning[0] = false;
        }

        if (time == 20) {
          startIndex++;
          choosedReels[1] =
              reelItems[Random.secure().nextInt(reelItems.length)];
          isReelsSpinning[1] = false;
        }

        if (time == 30) {
          choosedReels[2] =
              reelItems[Random.secure().nextInt(reelItems.length)];
          isReelsSpinning[2] = false;

          timer.cancel();
          isSpinning = false;

          coefficientsIndexWinner = getWinnerCoefficient();
        }
      } else {
        for (int i = 0; i < choosedReels.length; i++) {
          choosedReels[i] =
              reelItems[Random.secure().nextInt(reelItems.length)];
        }

        if (time == 5) {
          for (int i = 0; i < choosedReels.length; i++) {
            choosedReels[i] =
                reelItems[Random.secure().nextInt(reelItems.length)];
            isReelsSpinning[i] = false;
          }

          timer.cancel();
          isSpinning = false;

          coefficientsIndexWinner = getWinnerCoefficient();
        }
      }

      if (!timer.isActive) {
        if (coefficientsIndexWinner != -1) {
          if (reelWinners.values.toList()[coefficientsIndexWinner] >= 2.0) {
            if (Provider.of<SettingsController>(context, listen: false)
                .isEnabledConfetti) {
              confettiController.play();
            }
          }

          double profit =
              bet * reelWinners.values.toList()[coefficientsIndexWinner];

          Provider.of<Balance>(context, listen: false).cashout(profit);

          GameStatisticController.updateGameStatistic(
              gameName: 'slots',
              gameStatisticModel:
                  GameStatisticModel(winningsMoneys: profit, maxWin: profit));

          CommonFunctions.callOnProfit(
            context: context,
            bet: bet,
            gameName: 'slots',
            profit: profit,
          );
        } else {
          GameStatisticController.updateGameStatistic(
              gameName: 'slots',
              gameStatisticModel: GameStatisticModel(
                maxLoss: bet,
                lossesMoneys: bet,
              ));
        }

        if (AdService.countBet == 49) {
          setState(() {
            isAutoBets = false;
          });
        }

        AdService.showInterstitialAd(context: context);
      }

      setState(() {});

      if (isAutoBets && !timer.isActive) {
        await Future.delayed(const Duration(milliseconds: 800))
            .whenComplete(() {
          if (isAutoBets) {
            makeBet(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSpinning && !isAutoBets,
      onPopInvoked: (isCan) {
        if (isCan) {
          context.beamBack();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            backgroundModel(),
            Scaffold(
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: bottomGameNavigation(
                  context: context,
                  betFormatter: Slots.betFormatter,
                  betController: Slots.betController,
                  isAutoBets: isAutoBets,
                  isPlaying: isSpinning,
                  switchValue: isFast,
                  isCanSwitch: true,
                  onSwitched: (value) {
                    if (isSpinning) {
                      return;
                    }

                    setState(() {
                      isFast = !isFast;
                    });

                    if (isFast) {
                      alertDialogSuccess(
                        context: context,
                        title: 'Успех',
                        confirmBtnText: 'Окей',
                        text: 'Быстрый режим включен!',
                      );
                    }
                  },
                  onPressed: () => makeBet(context)),
              appBar: AppBar(
                toolbarHeight: 76.0,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: IconButton(
                      splashRadius: 25.0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (isSpinning) return;

                        if (isAutoBets) return;

                        Beamer.of(context).beamBack();
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.arrowLeft,
                        color: Theme.of(context).appBarTheme.iconTheme!.color,
                        size: Theme.of(context).appBarTheme.iconTheme!.size,
                      )),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      'Slots',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    Consumer<Balance>(
                      builder: (context, value, _) {
                        return currencyNormalFormat(
                            context: context, moneys: value.currentBalance);
                      },
                    )
                  ],
                ),
                actions: [
                  IconButton(
                      splashRadius: 25.0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          isAutoBets = !isAutoBets;
                        });

                        if (isAutoBets) {
                          makeBet(context);
                        }
                      },
                      icon: FaIcon(
                        isAutoBets
                            ? FontAwesomeIcons.circleStop
                            : FontAwesomeIcons.rotate,
                        color: isAutoBets
                            ? Colors.redAccent
                            : Theme.of(context).appBarTheme.iconTheme!.color,
                        size: Theme.of(context).appBarTheme.iconTheme!.size,
                      )),
                  const SizedBox(width: 5.0),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (isSpinning) return;

                          if (isAutoBets) return;

                          context.beamToNamed('/game-statistic/slots');
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Screenshot(
                  controller: screenshotController,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int i = 0; i < 3; i++)
                                  coefficient(
                                      isSelected: coefficientsIndexWinner == i,
                                      icons: reelWinners.keys.toList()[i],
                                      coefficient:
                                          reelWinners.values.toList()[i]),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int i = 3; i < 6; i++)
                                  coefficient(
                                      isSelected: coefficientsIndexWinner == i,
                                      icons: reelWinners.keys.toList()[i],
                                      coefficient:
                                          reelWinners.values.toList()[i]),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 0; i < 3; i++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: GlassContainer(
                                    blur: 8,
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Container(
                                      height: 150.0,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          border: Border.all(
                                              color: Colors.lightBlueAccent
                                                  .withOpacity(0.7),
                                              width: 4.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: isReelsSpinning[i] == false
                                            ? Image.asset(
                                                'assets/slots/${choosedReels[i]}.png',
                                              )
                                            : AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 100),
                                                child: ListView.separated(
                                                  key: ValueKey<String>(
                                                      '${choosedReels[i]}${Random().nextInt(10000)}'),
                                                  itemCount: 100,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  controller: controllers[i],
                                                  itemBuilder:
                                                      (context, index) =>
                                                          Image.asset(
                                                    'assets/slots/${choosedReels[i]}.png',
                                                  ),
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          const SizedBox(
                                                              height: 15.0),
                                                )),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int i = 6; i < 9; i++)
                                  coefficient(
                                      isSelected: coefficientsIndexWinner == i,
                                      icons: reelWinners.keys.toList()[i],
                                      coefficient:
                                          reelWinners.values.toList()[i]),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int i = 9; i < 12; i++)
                                  coefficient(
                                      isSelected: coefficientsIndexWinner == i,
                                      icons: reelWinners.keys.toList()[i],
                                      coefficient:
                                          reelWinners.values.toList()[i]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive)
          ],
        ),
      ),
    );
  }

  Widget coefficient(
      {required List<String> icons,
      required double coefficient,
      bool isSelected = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: GlassContainer(
          blur: 8,
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(50, 76, 175, 80)
                    : Colors
                        .transparent, // Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                    color: isSelected
                        ? Colors.green
                        : Colors
                            .transparent, //const Color.fromARGB(200, 83, 91, 121),
                    width: 3.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < icons.length; i++)
                      Image.asset(
                        'assets/slots/${icons[i] != '?' ? icons[i] : 'question'}.png',
                        color: icons[i] == '?' ? Colors.grey.shade400 : null,
                        width: 12.0,
                        height: 12.0,
                      ),
                  ],
                ),
                const SizedBox(height: 5.0),
                AutoSizeText('${coefficient.toStringAsFixed(2)}x',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 5.0,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!
                            .withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
