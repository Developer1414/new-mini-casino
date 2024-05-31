import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/limbo_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:new_mini_casino/widgets/last_bets_widget.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class Limbo extends StatelessWidget {
  const Limbo({super.key});

  static TextEditingController targetCoefficient =
      TextEditingController(text: '2.0');

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !context.read<LimboLogic>().isGameOn,
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
              bottomNavigationBar: Consumer<LimboLogic>(
                builder: (context, limboLogic, child) {
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
                                    limboLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(limboLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(limboLogic.profit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            lastBetsWidget(
                              context: context,
                              list: limboLogic.lastCoefficients,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      List<LimboRound> value = limboLogic
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
                                                    limboLogic
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
                                              '${value[index].coefficient}x',
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
                                    itemCount:
                                        limboLogic.lastCoefficients.length),
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
                            controller: Limbo.targetCoefficient,
                            readOnly: limboLogic.isGameOn,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onTap: () {
                              Limbo.targetCoefficient.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      Limbo.targetCoefficient.text.length);
                            },
                            onTapOutside: (value) {
                              if (double.parse(Limbo.targetCoefficient.text) <
                                  1.1) {
                                Limbo.targetCoefficient.text = '1.1';
                              }
                            },
                            onSubmitted: (value) {
                              if (double.parse(value) < 1.1) {
                                Limbo.targetCoefficient.text = '1.1';
                              }
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
                      const SizedBox(height: 13.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: gameBetCount(
                          context: context,
                          gameLogic: limboLogic,
                          bet: limboLogic.bet,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 60.0,
                              child: Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5.0)
                                ], color: Theme.of(context).cardColor),
                                child: ElevatedButton(
                                  onPressed: limboLogic.isGameOn &&
                                          limboLogic.timer.isActive
                                      ? null
                                      : () {
                                          if (Provider.of<Balance>(context,
                                                  listen: false)
                                              .isLoading) {
                                            return;
                                          }

                                          if (!limboLogic.isGameOn) {
                                            if (Limbo.targetCoefficient.text
                                                    .isEmpty ||
                                                double.parse(Limbo
                                                        .targetCoefficient.text)
                                                    .isNegative ||
                                                double.parse(Limbo
                                                        .targetCoefficient
                                                        .text) <
                                                    1) {
                                              return;
                                            }

                                            if (double.parse(Limbo
                                                    .targetCoefficient.text) <
                                                1.1) {
                                              alertDialogError(
                                                context: context,
                                                title: 'Ошибка',
                                                text:
                                                    'Минимальный коэффициент: 1.1',
                                                confirmBtnText: 'Окей',
                                              );

                                              return;
                                            }

                                            limboLogic.startGame(
                                                context: context,
                                                selectedCoefficient:
                                                    double.parse(Limbo
                                                        .targetCoefficient
                                                        .text));
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.green,
                                    shape: const RoundedRectangleBorder(),
                                  ),
                                  child: Provider.of<Balance>(context,
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
                                      : AutoSizeText(
                                          'СТАВКА',
                                          maxLines: 1,
                                          style: GoogleFonts.roboto(
                                              color: limboLogic.isGameOn &&
                                                      limboLogic.timer.isActive
                                                  ? Colors.white
                                                      .withOpacity(0.4)
                                                  : Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w900),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              appBar: gameAppBarWidget(
                context: context,
                isGameOn: context.watch<LimboLogic>().isGameOn,
                gameName: 'Limbo',
              ),
              body: Screenshot(
                controller: screenshotController,
                child: Consumer<LimboLogic>(
                  builder: (ctx, limboLogic, _) {
                    return Center(
                      child: AutoSizeText(
                        '${limboLogic.targetCoefficient.toStringAsFixed(2)}x',
                        style: GoogleFonts.roboto(
                            color: limboLogic.crashStatus == LimboStatus.win
                                ? Colors.green
                                : limboLogic.crashStatus == LimboStatus.loss
                                    ? Colors.redAccent
                                    : Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .color,
                            fontSize: 80.0,
                            fontWeight: FontWeight.w900),
                      ),
                    );
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
}
