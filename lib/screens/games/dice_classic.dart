import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/dice_classic_logic.dart';
import 'package:new_mini_casino/games_logic/limbo_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class DiceClassic extends StatelessWidget {
  const DiceClassic({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return PopScope(
      canPop: !context.read<DiceClassicLogic>().isGameOn,
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
              bottomNavigationBar: Consumer<DiceClassicLogic>(
                builder: (context, diceClassicLogic, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText('Прибыль:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                AutoSizeText(
                                    diceClassicLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(diceClassicLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(diceClassicLogic.profit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            Container(
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Colors.lightBlueAccent.withOpacity(0.1),
                                border: Border.all(
                                    color: Colors.lightBlueAccent, width: 2.0),
                              ),
                              child: diceClassicLogic.lastCoefficients.isEmpty
                                  ? Center(
                                      child: AutoSizeText('Ставок ещё нет',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .color!
                                                      .withOpacity(0.4))),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            List<DiceClassicRound> value =
                                                diceClassicLogic
                                                    .lastCoefficients.reversed
                                                    .toList();

                                            return Container(
                                              margin: EdgeInsets.only(
                                                  top: 5.0,
                                                  bottom: 5.0,
                                                  left: index == 0 ? 5.0 : 0.0,
                                                  right: index + 1 ==
                                                          diceClassicLogic
                                                              .lastCoefficients
                                                              .length
                                                      ? 5.0
                                                      : 0.0),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: value[index].isWin
                                                      ? Colors.green
                                                      : Colors.redAccent),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: Center(
                                                  child: AutoSizeText(
                                                    value[index].coefficient,
                                                    style: GoogleFonts.roboto(
                                                        color: Colors.white,
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(width: 5.0),
                                          itemCount: diceClassicLogic
                                              .lastCoefficients.length),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: SizedBox(
                          height: 50.0,
                          child: TextField(
                            controller: diceClassicLogic.textFieldCoefficient,
                            readOnly: diceClassicLogic.isGameOn,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onTap: () {
                              diceClassicLogic.textFieldCoefficient.selection =
                                  TextSelection(
                                      baseOffset: 0,
                                      extentOffset: diceClassicLogic
                                          .textFieldCoefficient.text.length);
                            },
                            onSubmitted: (value) {
                              if (double.parse(value) < 1.02) {
                                diceClassicLogic.textFieldCoefficient.text =
                                    '1.02';
                              }

                              if (double.parse(value) > 98.0) {
                                diceClassicLogic.textFieldCoefficient.text =
                                    '98.0';
                              }

                              diceClassicLogic
                                  .changeCoefficient(double.parse(value));
                            },
                            onChanged: (value) {
                              if (value.isEmpty) return;

                              if (double.parse(value) > 98.0) {
                                diceClassicLogic.textFieldCoefficient.text =
                                    '98.0';
                              }

                              diceClassicLogic
                                  .changeCoefficient(double.parse(value));
                            },
                            decoration: InputDecoration(
                                suffix: Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: Text(
                                    'X',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(fontSize: 20.0),
                                  ),
                                ),
                                hintText: 'Целевой коэффициент...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color!
                                            .withOpacity(0.5)),
                                enabledBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .enabledBorder,
                                focusedBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .focusedBorder),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(fontSize: 20.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          children: [
                            AutoSizeText('Шанс:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 12.0)),
                            Expanded(
                              child: Slider(
                                value: clampDouble(
                                    diceClassicLogic.selectedChanceWinning,
                                    1.02,
                                    98.0),
                                max: 98.0,
                                min: 1.02,
                                onChanged: (double value) {
                                  if (diceClassicLogic.isGameOn) return;
                                  diceClassicLogic.changeChanceWinning(value);
                                },
                              ),
                            ),
                            AutoSizeText(
                                '${diceClassicLogic.selectedChanceWinning.toStringAsFixed(2)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 12.0)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: gameBetCount(
                          context: context,
                          gameLogic: diceClassicLogic,
                          bet: diceClassicLogic.bet,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: buttonModel(
                                      title: 'Меньше',
                                      subtitle:
                                          ' 0 - ${diceClassicLogic.lessNumber}',
                                      color: Colors.redAccent,
                                      icon: FontAwesomeIcons.arrowDown,
                                      context: context,
                                      function: () {
                                        if (balance.currentBalance <
                                            diceClassicLogic.bet) {
                                          return;
                                        }

                                        diceClassicLogic.less(context: context);
                                      }),
                                ),
                                Expanded(
                                  child: buttonModel(
                                      title: 'Больше',
                                      subtitle:
                                          '${diceClassicLogic.moreNumber} - 999999',
                                      color: Colors.green,
                                      icon: FontAwesomeIcons.arrowUp,
                                      context: context,
                                      function: () {
                                        if (balance.currentBalance <
                                            diceClassicLogic.bet) {
                                          return;
                                        }

                                        diceClassicLogic.more(context: context);
                                      }),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                },
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
                      onPressed: context.watch<DiceClassicLogic>().isGameOn
                          ? null
                          : () {
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
                      'Dice Classic',
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
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: context.watch<LimboLogic>().isGameOn
                            ? null
                            : () => context
                                .beamToNamed('/game-statistic/dice-classic'),
                        icon: FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                ],
              ),
              body: Screenshot(
                controller: screenshotController,
                child: Consumer<DiceClassicLogic>(
                  builder: (ctx, diceClassicLogic, _) {
                    return Center(
                        child: AnimatedFlipCounter(
                      duration: const Duration(milliseconds: 500),
                      value: diceClassicLogic.targetCoefficient,
                      textStyle:
                          Theme.of(context).textTheme.displaySmall!.copyWith(
                                letterSpacing: -0.4,
                                fontSize: 60.0,
                                fontWeight: FontWeight.w900,
                                color: diceClassicLogic.diceClassicStatus ==
                                        DiceClassicStatus.win
                                    ? Colors.green
                                    : diceClassicLogic.diceClassicStatus ==
                                            DiceClassicStatus.loss
                                        ? Colors.redAccent
                                        : Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .color,
                              ),
                    ));
                  },
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

  Widget buttonModel(
      {required String title,
      required String subtitle,
      required Color color,
      required IconData? icon,
      required BuildContext context,
      required VoidCallback function}) {
    return SizedBox(
      height: 60.0,
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5.0)
        ], color: Theme.of(context).cardColor),
        child: ElevatedButton(
          onPressed: () => function.call(),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: color,
            shape: const RoundedRectangleBorder(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 20.0,
                      color: Theme.of(context).textTheme.bodyMedium!.color)),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 10.0,
                      color: Theme.of(context).textTheme.bodyMedium!.color)),
            ],
          ),
        ),
      ),
    );
  }
}
