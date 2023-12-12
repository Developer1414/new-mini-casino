import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:confetti/confetti.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';

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
  List<ScrollController> controllers =
      List.generate(3, (index) => ScrollController());

  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 1));

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

    CommonFunctions.call(context: context, bet: bet, gameName: 'slots');

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

      for (int i = startIndex; i < 3; i++) {
        choosedReels[i] = reelItems[Random().nextInt(reelItems.length)];
        controllers[i].animateTo(100,
            duration: const Duration(milliseconds: 100), curve: Curves.linear);
      }

      if (time == 10) {
        startIndex++;
        choosedReels[0] = reelItems[Random.secure().nextInt(reelItems.length)];
        isReelsSpinning[0] = false;
      }

      if (time == 20) {
        startIndex++;
        choosedReels[1] = reelItems[Random.secure().nextInt(reelItems.length)];
        isReelsSpinning[1] = false;
      }

      if (time == 30) {
        choosedReels[2] = reelItems[Random.secure().nextInt(reelItems.length)];
        isReelsSpinning[2] = false;

        timer.cancel();
        isSpinning = false;

        coefficientsIndexWinner = getWinnerCoefficient();
      }

      if (!timer.isActive) {
        if (coefficientsIndexWinner != -1) {
          if (reelWinners.values.toList()[coefficientsIndexWinner] >= 2.0) {
            confettiController.play();
          }

          double profit =
              bet * reelWinners.values.toList()[coefficientsIndexWinner];

          Provider.of<Balance>(context, listen: false).cashout(profit);

          GameStatisticController.updateGameStatistic(
              gameName: 'slots',
              gameStatisticModel:
                  GameStatisticModel(winningsMoneys: profit, maxWin: profit));
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
    return WillPopScope(
      onWillPop: () async {
        if (isSpinning) return false;

        if (isAutoBets) return false;

        return true;
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
            Scaffold(
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: Container(
                height: 80.0,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0)),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10.0)
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      //height: 80.0,
                      margin: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (isAutoBets || isSpinning) return;

                          makeBet(context);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: isAutoBets || isSpinning
                              ? Colors.redAccent
                              : Colors.green,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: isAutoBets || isSpinning
                              ? FaIcon(
                                  FontAwesomeIcons.lock,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .iconTheme!
                                      .color,
                                  size: 28.0,
                                )
                              : AutoSizeText(
                                  'СТАВКА',
                                  maxLines: 1,
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w900),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15.0),
                    child: customTextField(
                        currencyTextInputFormatter: Slots.betFormatter,
                        textInputFormatter: Slots.betFormatter,
                        keyboardType: TextInputType.number,
                        isBetInput: true,
                        controller: Slots.betController,
                        context: context,
                        hintText: 'Ставка...'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 0; i < 3; i++)
                              coefficient(
                                  isSelected: coefficientsIndexWinner == i,
                                  icons: reelWinners.keys.toList()[i],
                                  coefficient: reelWinners.values.toList()[i]),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 3; i < 6; i++)
                              coefficient(
                                  isSelected: coefficientsIndexWinner == i,
                                  icons: reelWinners.keys.toList()[i],
                                  coefficient: reelWinners.values.toList()[i]),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < 3; i++)
                          Expanded(
                            child: Container(
                              //width: 120.0,
                              height: 150.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .cardColor
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: Theme.of(context).cardColor,
                                      width: 5.0)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: isReelsSpinning[i] == false
                                    ? Image.asset(
                                        'assets/slots/${choosedReels[i]}.png',
                                        color: choosedReels[i] == 'question'
                                            ? Theme.of(context).cardColor
                                            : null,
                                      )
                                    : AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 100),
                                        child: ListView.separated(
                                          key:
                                              ValueKey<String>(choosedReels[i]),
                                          itemCount: 100,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          controller: controllers[i],
                                          itemBuilder: (context, index) =>
                                              Image.asset(
                                            'assets/slots/${choosedReels[i]}.png',
                                          ),
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(height: 15.0),
                                        )),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 6; i < 9; i++)
                              coefficient(
                                  isSelected: coefficientsIndexWinner == i,
                                  icons: reelWinners.keys.toList()[i],
                                  coefficient: reelWinners.values.toList()[i]),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 9; i < 12; i++)
                              coefficient(
                                  isSelected: coefficientsIndexWinner == i,
                                  icons: reelWinners.keys.toList()[i],
                                  coefficient: reelWinners.values.toList()[i]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        margin: const EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
                color: isSelected ? Colors.green : Theme.of(context).cardColor,
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
                    color: icons[i] == '?'
                        ? Theme.of(context).buttonTheme.colorScheme!.background
                        : null,
                    width: 20.0,
                    height: 20.0,
                  ),
              ],
            ),
            const SizedBox(height: 5.0),
            AutoSizeText('${coefficient.toStringAsFixed(2)}x',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 12.0,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .color!
                        .withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}
