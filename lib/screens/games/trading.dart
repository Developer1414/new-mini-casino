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
import 'package:new_mini_casino/games_logic/limbo_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class Trading extends StatelessWidget {
  const Trading({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  static TextEditingController targetCoefficient =
      TextEditingController(text: '2.0');

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

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
                            Container(
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Colors.lightBlueAccent.withOpacity(0.1),
                                border: Border.all(
                                    color: Colors.lightBlueAccent, width: 2.0),
                              ),
                              child: limboLogic.lastCoefficients.isEmpty
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
                                            List<LimboRound> value = limboLogic
                                                .lastCoefficients.reversed
                                                .toList();

                                            return Container(
                                              margin: EdgeInsets.only(
                                                  top: 5.0,
                                                  bottom: 5.0,
                                                  left: index == 0 ? 5.0 : 0.0,
                                                  right: index + 1 ==
                                                          limboLogic
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
                                                    '${value[index].coefficient}x',
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
                                          itemCount: limboLogic
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
                            controller: Trading.targetCoefficient,
                            readOnly: limboLogic.isGameOn,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onTap: () {
                              Trading.targetCoefficient.selection =
                                  TextSelection(
                                      baseOffset: 0,
                                      extentOffset: Trading
                                          .targetCoefficient.text.length);
                            },
                            onSubmitted: (value) {
                              if (double.parse(value) < 1.1) {
                                Trading.targetCoefficient.text = '1.1';
                              }
                            },
                            decoration: InputDecoration(
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
                      const SizedBox(height: 15.0),
                      Row(
                        children: [
                          limboLogic.isGameOn
                              ? Container()
                              : SizedBox(
                                  height: 60.0,
                                  width: 80.0,
                                  child: ElevatedButton(
                                    onPressed: () => limboLogic.showInputBet(),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      backgroundColor: const Color(0xFF366ecc),
                                      shape: const RoundedRectangleBorder(),
                                    ),
                                    child: FaIcon(
                                      limboLogic.isShowInputBet
                                          ? FontAwesomeIcons.arrowLeft
                                          : FontAwesomeIcons.keyboard,
                                      color: Colors.white,
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                          Visibility(
                            visible: limboLogic.isShowInputBet,
                            child: Expanded(
                              child: SizedBox(
                                height: 60.0,
                                child: customTextField(
                                    currencyTextInputFormatter:
                                        Trading.betFormatter,
                                    textInputFormatter: Trading.betFormatter,
                                    keyboardType: TextInputType.number,
                                    isBetInput: true,
                                    controller: Trading.betController,
                                    context: context,
                                    hintText: 'Ставка...'),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !limboLogic.isShowInputBet,
                            child: Expanded(
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
                                            if (!limboLogic.isGameOn) {
                                              if (balance.currentBalance <
                                                  double.parse(Trading
                                                      .betFormatter
                                                      .getUnformattedValue()
                                                      .toStringAsFixed(2))) {
                                                return;
                                              }

                                              if (Trading.targetCoefficient.text
                                                      .isEmpty ||
                                                  double.parse(Trading
                                                          .targetCoefficient
                                                          .text)
                                                      .isNegative ||
                                                  double.parse(Trading
                                                          .targetCoefficient
                                                          .text) <
                                                      1) {
                                                return;
                                              }

                                              if (double.parse(Trading
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
                                                    double.parse(Trading
                                                        .targetCoefficient
                                                        .text),
                                            );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.green,
                                      shape: const RoundedRectangleBorder(),
                                    ),
                                    child: AutoSizeText(
                                      'СТАВКА',
                                      maxLines: 1,
                                      style: GoogleFonts.roboto(
                                          color: limboLogic.isGameOn &&
                                                  limboLogic.timer.isActive
                                              ? Colors.white.withOpacity(0.4)
                                              : Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w900),
                                    ),
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
              appBar: AppBar(
                toolbarHeight: 76.0,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: IconButton(
                      splashRadius: 25.0,
                      padding: EdgeInsets.zero,
                      onPressed: context.watch<LimboLogic>().isGameOn
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
                      'Limbo',
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
                            : () =>
                                context.beamToNamed('/game-statistic/limbo'),
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
                            fontSize: 60.0,
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
