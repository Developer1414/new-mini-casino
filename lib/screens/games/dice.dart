import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:confetti/confetti.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/dice_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:screenshot/screenshot.dart';

class Dice extends StatefulWidget {
  const Dice({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static bool isFetchCompleted = false;

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  State<Dice> createState() => _DiceState();
}

class _DiceState extends State<Dice> with TickerProviderStateMixin {
  late final GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    void makeBet(DiceLogic diceLogic) {
      if (balance.currentBalance <
          double.parse(Dice.betFormatter.getUnformattedValue().toString())) {
        return;
      }

      if (diceLogic.evenOrOddType == EvenOrOddButtonType.empty &&
          diceLogic.numberFromToType == NumberFromToButtonType.empty &&
          diceLogic.selectedNumber == 0) {
        return;
      }

      diceLogic.startGame(
          context: context,
          bet:
              double.parse(Dice.betFormatter.getUnformattedValue().toString()));

      _gifController.reset();
      _gifController.forward().whenComplete(() {
        diceLogic.cashout();
      });
    }

    return PopScope(
      canPop: !context.read<DiceLogic>().isGameOn,
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
              bottomNavigationBar: Consumer<DiceLogic>(
                builder: (context, diceLogic, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                    'Прибыль (${diceLogic.coefficient}x):',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                AutoSizeText(
                                    diceLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(diceLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(diceLogic.profit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: itemButtons(
                                      context: context,
                                      isSelected: diceLogic.numberFromToType ==
                                          NumberFromToButtonType.oneToThree,
                                      diceLogic: diceLogic,
                                      coefficient: 2.0,
                                      text: '1 - 3',
                                      onClick: () {
                                        if (!diceLogic.isGameOn) {
                                          if (diceLogic.numberFromToType ==
                                              NumberFromToButtonType
                                                  .oneToThree) {
                                            diceLogic.unSelectNumbersFromTo();
                                          } else {
                                            diceLogic.selectNumbersFromTo(
                                                NumberFromToButtonType
                                                    .oneToThree);
                                          }
                                        }
                                      }),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: itemButtons(
                                      context: context,
                                      isSelected: diceLogic.numberFromToType ==
                                          NumberFromToButtonType.fourToSix,
                                      diceLogic: diceLogic,
                                      coefficient: 2.0,
                                      text: '4 - 6',
                                      onClick: () {
                                        if (!diceLogic.isGameOn) {
                                          if (diceLogic.numberFromToType ==
                                              NumberFromToButtonType
                                                  .fourToSix) {
                                            diceLogic.unSelectNumbersFromTo();
                                          } else {
                                            diceLogic.selectNumbersFromTo(
                                                NumberFromToButtonType
                                                    .fourToSix);
                                          }
                                        }
                                      }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int index = 0; index < 6; index++)
                                  itemNumber(
                                      number: index + 1, diceLogic: diceLogic)
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: itemButtons(
                                      context: context,
                                      isSelected: diceLogic.evenOrOddType ==
                                          EvenOrOddButtonType.even,
                                      diceLogic: diceLogic,
                                      coefficient: 2.0,
                                      text: 'Even',
                                      onClick: () {
                                        if (!diceLogic.isGameOn) {
                                          if (diceLogic.evenOrOddType ==
                                              EvenOrOddButtonType.even) {
                                            diceLogic.unSelectEvenOrOdd();
                                          } else {
                                            diceLogic.selectOddOrEvenNumbers(
                                                EvenOrOddButtonType.even);
                                          }
                                        }
                                      }),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: itemButtons(
                                      context: context,
                                      isSelected: diceLogic.evenOrOddType ==
                                          EvenOrOddButtonType.odd,
                                      diceLogic: diceLogic,
                                      coefficient: 2.0,
                                      text: 'Odd',
                                      onClick: () {
                                        if (!diceLogic.isGameOn) {
                                          if (diceLogic.evenOrOddType ==
                                              EvenOrOddButtonType.odd) {
                                            diceLogic.unSelectEvenOrOdd();
                                          } else {
                                            diceLogic.selectOddOrEvenNumbers(
                                                EvenOrOddButtonType.odd);
                                          }
                                        }
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        children: [
                          diceLogic.isGameOn
                              ? Container()
                              : SizedBox(
                                  height: 60.0,
                                  width: 80.0,
                                  child: ElevatedButton(
                                    onPressed: () => diceLogic.showInputBet(),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      backgroundColor: const Color(0xFF366ecc),
                                      shape: const RoundedRectangleBorder(),
                                    ),
                                    child: FaIcon(
                                      diceLogic.isShowInputBet
                                          ? FontAwesomeIcons.arrowLeft
                                          : FontAwesomeIcons.keyboard,
                                      color: Colors.white,
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                          Visibility(
                            visible: diceLogic.isShowInputBet,
                            child: Expanded(
                              child: SizedBox(
                                height: 60.0,
                                child: customTextField(
                                    currencyTextInputFormatter:
                                        Dice.betFormatter,
                                    textInputFormatter: Dice.betFormatter,
                                    keyboardType: TextInputType.number,
                                    isBetInput: true,
                                    controller: Dice.betController,
                                    context: context,
                                    hintText: 'Ставка...'),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: !diceLogic.isShowInputBet,
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
                                    onPressed: diceLogic.isGameOn ||
                                            !Dice.isFetchCompleted
                                        ? null
                                        : () => makeBet(diceLogic),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.green,
                                      shape: const RoundedRectangleBorder(),
                                    ),
                                    child: AutoSizeText(
                                      'СТАВКА',
                                      maxLines: 1,
                                      style: GoogleFonts.roboto(
                                          color: diceLogic.isGameOn ||
                                                  !Dice.isFetchCompleted
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
                      onPressed: context.watch<DiceLogic>().isGameOn
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
                      'Dice',
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
                  /*autoBetsModel(
                      context: context,
                      function: () {
                        final diceLogic =
                            Provider.of<DiceLogic>(context, listen: false);
            
                        if (diceLogic.isGameOn || !Dice.isFetchCompleted) {
                          return;
                        } else {
                          makeBet(diceLogic);
                        }
                      }),*/
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: context.watch<DiceLogic>().isGameOn
                            ? null
                            : () => context.beamToNamed('/game-statistic/dice'),
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
                child: Consumer<DiceLogic>(builder: (ctx, diceLogic, _) {
                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                            child: Gif(
                              image: AssetImage(
                                  'assets/animations/dice-${diceLogic.randomNumber}.gif'),
                              controller: _gifController,
                              fps: 60,
                              autostart: Autostart.no,
                              onFetchCompleted: () {
                                if (Dice.isFetchCompleted) return;

                                Dice.isFetchCompleted = true;
                                setState(() {});
                              },
                              placeholder: (context) => AutoSizeText(
                                'Загрузка...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
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

  Widget itemNumber({int number = 1, required DiceLogic diceLogic}) {
    return Container(
      width: 45.0,
      height: 50.0,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Material(
        borderRadius: BorderRadius.circular(15.0),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context)
            .buttonTheme
            .colorScheme!
            .background
            .withOpacity(diceLogic.selectedNumber == number ? 1.0 : 0.7),
        child: InkWell(
          onTap: () {
            if (!diceLogic.isGameOn) {
              if (diceLogic.selectedNumber == number) {
                diceLogic.unSelectNumber();
              } else {
                diceLogic.selectNumber(number: number);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: diceLogic.selectedNumber == number
                    ? Border.all(width: 2.5, color: Colors.lightBlueAccent)
                    : null),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    number.toString(),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 18.0,
                        color: Colors.white.withOpacity(
                            diceLogic.selectedNumber == number ? 1.0 : 0.4)),
                  ),
                  AutoSizeText(
                    'x6.0',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 8.0,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!
                            .withOpacity(diceLogic.selectedNumber == number
                                ? 0.7
                                : 0.4)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget itemButtons(
      {bool isSelected = false,
      required DiceLogic diceLogic,
      required BuildContext context,
      required double coefficient,
      required Function onClick,
      required String text}) {
    return SizedBox(
      width: 50.0,
      height: 50.0,
      child: Material(
        borderRadius: BorderRadius.circular(15.0),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context)
            .buttonTheme
            .colorScheme!
            .background
            .withOpacity(isSelected ? 1.0 : 0.7),
        child: InkWell(
          onTap: () => onClick.call(),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: isSelected
                    ? Border.all(width: 2.5, color: Colors.lightBlueAccent)
                    : null),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    text,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 18.0,
                        color:
                            Colors.white.withOpacity(isSelected ? 1.0 : 0.4)),
                  ),
                  AutoSizeText(
                    'x$coefficient',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 8.0,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!
                            .withOpacity(isSelected ? 0.7 : 0.4)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
