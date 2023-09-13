import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/dice_logic.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

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

    return WillPopScope(
      onWillPop: () async {
        return !context.read<DiceLogic>().isGameOn;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Container(
            height: 312.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0)),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
                ]),
            child: Consumer<DiceLogic>(
              builder: (ctx, diceLogic, _) {
                return Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText(
                                  'Прибыль (${diceLogic.coefficient}x):',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontSize: 20.0)),
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
                                      .copyWith(fontSize: 20.0)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
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
                                const SizedBox(width: 15.0),
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
                            const SizedBox(height: 15.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int index = 0; index < 6; index++)
                                  itemNumber(
                                      number: index + 1,
                                      diceLogic: diceLogic,
                                      coefficient:
                                          diceLogic.buttonsCoefficient[index])
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            Row(
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
                                const SizedBox(width: 15.0),
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
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: diceLogic.isGameOn ||
                                    !Dice.isFetchCompleted
                                ? null
                                : () {
                                    if (balance.currentBalance <
                                        double.parse(Dice.betFormatter
                                            .getUnformattedValue()
                                            .toString())) {
                                      return;
                                    }

                                    if (diceLogic.evenOrOddType ==
                                            EvenOrOddButtonType.empty &&
                                        diceLogic.numberFromToType ==
                                            NumberFromToButtonType.empty &&
                                        diceLogic.selectedNumber == 0) {
                                      return;
                                    }

                                    diceLogic.startGame(
                                        context: context,
                                        bet: double.parse(Dice.betFormatter
                                            .getUnformattedValue()
                                            .toString()));

                                    _gifController.reset();
                                    _gifController.forward().whenComplete(() {
                                      diceLogic.cashout();
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              backgroundColor: Colors.green,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25.0),
                                    topRight: Radius.circular(25.0)),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: AutoSizeText(
                                'СТАВКА',
                                maxLines: 1,
                                style: GoogleFonts.roboto(
                                    color: diceLogic.isGameOn ||
                                            !Dice.isFetchCompleted
                                        ? Colors.white.withOpacity(0.4)
                                        : Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
              },
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
                    return AutoSizeText(
                      value.currentBalanceString,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.displaySmall,
                    );
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
          body: Consumer<DiceLogic>(builder: (ctx, diceLogic, _) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                  child: customTextField(
                      currencyTextInputFormatter: Dice.betFormatter,
                      textInputFormatter: Dice.betFormatter,
                      context: context,
                      keyboardType: TextInputType.number,
                      readOnly: diceLogic.isGameOn,
                      isBetInput: true,
                      controller: Dice.betController,
                      hintText: 'Ставка...'),
                ),
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
    );
  }

  Widget itemNumber(
      {int number = 1,
      double coefficient = 0.0,
      required DiceLogic diceLogic}) {
    return SizedBox(
      width: 50.0,
      height: 50.0,
      child: Material(
        borderRadius: BorderRadius.circular(15.0),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).buttonTheme.colorScheme!.background,
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
                    ? Border.all(width: 2.5, color: Colors.blueAccent)
                    : null),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    number.toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AutoSizeText(
                    'x2.0',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 10.0,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!
                            .withOpacity(0.7)),
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
        color: Theme.of(context).buttonTheme.colorScheme!.background,
        child: InkWell(
          onTap: () => onClick.call(),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: isSelected
                    ? Border.all(width: 2.5, color: Colors.blueAccent)
                    : null),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 23.0),
                  ),
                  AutoSizeText(
                    'x$coefficient',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 10.0,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!
                            .withOpacity(0.7)),
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
