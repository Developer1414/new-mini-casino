import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/dice_classic_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:new_mini_casino/widgets/last_bets_widget.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class DiceClassic extends StatelessWidget {
  const DiceClassic({super.key});

  @override
  Widget build(BuildContext context) {
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
                            lastBetsWidget(
                              context: context,
                              list: diceClassicLogic.lastCoefficients,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      List<DiceClassicRound> value =
                                          diceClassicLogic
                                              .lastCoefficients.reversed
                                              .toList();

                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        margin: EdgeInsets.only(
                                            top: 5.0,
                                            bottom: 5.0,
                                            left: index == 0 ? 5.0 : 0.0,
                                            right: index + 1 ==
                                                    diceClassicLogic
                                                        .lastCoefficients.length
                                                ? 5.0
                                                : 0.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: value[index].isWin
                                                ? Colors.green
                                                : Colors.redAccent),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Center(
                                            child: AutoSizeText(
                                              value[index].coefficient,
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w700),
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
                            onTapOutside: (value) {
                              if (double.parse(diceClassicLogic
                                      .textFieldCoefficient.text) <
                                  1.1) {
                                diceClassicLogic.textFieldCoefficient.text =
                                    '1.1';
                              }
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
                                      title: Provider.of<Balance>(context,
                                                  listen: true)
                                              .isLoading
                                          ? const SizedBox(
                                              width: 30.0,
                                              height: 30.0,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 5.5,
                                                color: Colors.white,
                                                strokeCap: StrokeCap.round,
                                              ),
                                            )
                                          : 'Меньше',
                                      subtitle:
                                          ' 0 - ${diceClassicLogic.lessNumber}',
                                      color: Colors.redAccent,
                                      icon: FontAwesomeIcons.arrowDown,
                                      context: context,
                                      function: () async {
                                        if (Provider.of<Balance>(context,
                                                listen: false)
                                            .isLoading) {
                                          return;
                                        }

                                        diceClassicLogic.less(context: context);
                                      }),
                                ),
                                Expanded(
                                  child: buttonModel(
                                      title: Provider.of<Balance>(context,
                                                  listen: true)
                                              .isLoading
                                          ? const SizedBox(
                                              width: 30.0,
                                              height: 30.0,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 5.0,
                                                color: Colors.white,
                                                strokeCap: StrokeCap.round,
                                              ),
                                            )
                                          : 'Больше',
                                      subtitle:
                                          '${diceClassicLogic.moreNumber} - 999999',
                                      color: Colors.green,
                                      icon: FontAwesomeIcons.arrowUp,
                                      context: context,
                                      function: () async {
                                        if (Provider.of<Balance>(context,
                                                listen: false)
                                            .isLoading) {
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
              appBar: gameAppBarWidget(
                context: context,
                isGameOn: context.watch<DiceClassicLogic>().isGameOn,
                gameName: 'Dice Classic',
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
                                fontSize: 80.0,
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
      {required dynamic title,
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
              title.runtimeType == String
                  ? AutoSizeText(title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 20.0,
                          color: Theme.of(context).textTheme.bodyMedium!.color))
                  : title.runtimeType == SizedBox
                      ? title
                      : Container(),
              title.runtimeType == SizedBox
                  ? Container()
                  : Text(subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 10.0,
                          color:
                              Theme.of(context).textTheme.bodyMedium!.color)),
            ],
          ),
        ),
      ),
    );
  }
}
