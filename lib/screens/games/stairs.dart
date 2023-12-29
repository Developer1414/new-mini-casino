import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/stairs_logic.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Stairs extends StatefulWidget {
  const Stairs({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  State<Stairs> createState() => _StairsState();
}

class _StairsState extends State<Stairs> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return PopScope(
      canPop: !context.read<StairsLogic>().isGameOn,
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Consumer<StairsLogic>(
            builder: (context, stairsLogic, child) {
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
                                'Прибыль (${stairsLogic.currentCoefficient.isNaN ? '0.00' : stairsLogic.currentCoefficient.toStringAsFixed(2)}x):',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 12.0)),
                            AutoSizeText(
                                stairsLogic.profit < 1000000
                                    ? NumberFormat.simpleCurrency(
                                            locale: ui.Platform.localeName)
                                        .format(stairsLogic.profit)
                                    : NumberFormat.compactSimpleCurrency(
                                            locale: ui.Platform.localeName)
                                        .format(stairsLogic.profit),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 12.0)),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText('Кол. камней:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 12.0)),
                            AutoSizeText(
                                stairsLogic.sliderValue.round().toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 12.0)),
                          ],
                        ),
                        Slider(
                          value: stairsLogic.sliderValue,
                          max: 3,
                          min: 1,
                          divisions: 2,
                          onChanged: (double value) {
                            if (stairsLogic.isGameOn) return;
                            stairsLogic.changeSliderValue(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      stairsLogic.isGameOn
                          ? Container()
                          : SizedBox(
                              height: 60.0,
                              width: 80.0,
                              child: ElevatedButton(
                                onPressed: () => stairsLogic.showInputBet(),
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  backgroundColor: const Color(0xFF366ecc),
                                  shape: const RoundedRectangleBorder(),
                                ),
                                child: FaIcon(
                                  stairsLogic.isShowInputBet
                                      ? FontAwesomeIcons.arrowLeft
                                      : FontAwesomeIcons.keyboard,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              ),
                            ),
                      Visibility(
                        visible: stairsLogic.isShowInputBet,
                        child: Expanded(
                          child: SizedBox(
                            height: 60.0,
                            child: customTextField(
                                currencyTextInputFormatter: Stairs.betFormatter,
                                textInputFormatter: Stairs.betFormatter,
                                keyboardType: TextInputType.number,
                                isBetInput: true,
                                controller: Stairs.betController,
                                context: context,
                                hintText: 'Ставка...'),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !stairsLogic.isShowInputBet,
                        child: Expanded(
                          child: Row(
                            children: [
                              !stairsLogic.isGameOn
                                  ? Container()
                                  : Expanded(
                                      child: SizedBox(
                                        height: 60.0,
                                        child: Container(
                                          color: Theme.of(context).cardColor,
                                          child: ElevatedButton(
                                            onPressed: !stairsLogic.isGameOn
                                                ? null
                                                : () {
                                                    stairsLogic.autoMove();
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 5,
                                              backgroundColor:
                                                  Colors.blueAccent,
                                              shape:
                                                  const RoundedRectangleBorder(),
                                            ),
                                            child: AutoSizeText(
                                              'АВТО',
                                              maxLines: 1,
                                              style: GoogleFonts.roboto(
                                                  color: !stairsLogic.isGameOn
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
                              Expanded(
                                child: SizedBox(
                                  height: 60.0,
                                  child: Container(
                                    color: Theme.of(context).cardColor,
                                    child: ElevatedButton(
                                      onPressed: !stairsLogic.isGameOn
                                          ? () {
                                              if (!stairsLogic.isGameOn) {
                                                if (balance.currentBalance <
                                                    double.parse(Stairs
                                                        .betFormatter
                                                        .getUnformattedValue()
                                                        .toString())) {
                                                  return;
                                                }

                                                stairsLogic.startGame(
                                                    context: context,
                                                    bet: double.parse(Stairs
                                                        .betFormatter
                                                        .getUnformattedValue()
                                                        .toString()));
                                              } else {
                                                stairsLogic.cashout();
                                              }
                                            }
                                          : stairsLogic
                                                  .openedColumnIndex.isEmpty
                                              ? null
                                              : () {
                                                  if (!stairsLogic.isGameOn) {
                                                    if (balance.currentBalance <
                                                        double.parse(Stairs
                                                            .betFormatter
                                                            .getUnformattedValue()
                                                            .toString())) {
                                                      return;
                                                    }

                                                    stairsLogic.startGame(
                                                        context: context,
                                                        bet: double.parse(Stairs
                                                            .betFormatter
                                                            .getUnformattedValue()
                                                            .toString()));
                                                  } else {
                                                    stairsLogic.cashout();
                                                  }
                                                },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.redAccent,
                                        shape: const RoundedRectangleBorder(),
                                      ),
                                      child: AutoSizeText(
                                        !stairsLogic.isGameOn
                                            ? 'СТАВКА'
                                            : 'ЗАБРАТЬ',
                                        maxLines: 1,
                                        style: GoogleFonts.roboto(
                                            color: stairsLogic.isGameOn
                                                ? stairsLogic.openedColumnIndex
                                                        .isEmpty
                                                    ? Colors.white
                                                        .withOpacity(0.4)
                                                    : Colors.white
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
                  onPressed: context.watch<StairsLogic>().isGameOn
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
                  'Stairs',
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
                    onPressed: context.watch<StairsLogic>().isGameOn
                        ? null
                        : () {
                            context.beamToNamed('/game-statistic/stairs');
                          },
                    icon: FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Theme.of(context).appBarTheme.iconTheme!.color,
                      size: Theme.of(context).appBarTheme.iconTheme!.size,
                    )),
              ),
            ],
          ),
          body: Consumer<StairsLogic>(
            builder: (context, stairsLogic, child) {
              return Column(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                            child: ListView.separated(
                                shrinkWrap: true,
                                controller: scrollController,
                                itemCount: 10,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 15.0),
                                itemBuilder: (context, columnIndex) {
                                  return Row(
                                    mainAxisAlignment: stairsLogic
                                            .cellCount[columnIndex].isEven
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.end,
                                    children: [
                                      for (int rowIndex = 0;
                                          rowIndex <
                                              stairsLogic
                                                  .cellCount[columnIndex];
                                          rowIndex++)
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: rowIndex + 1 <
                                                      stairsLogic.cellCount[
                                                          columnIndex]
                                                  ? 10.0
                                                  : 0.0),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                12,
                                            height: 30.0,
                                            child: !stairsLogic.isGameOn
                                                ? stairsLogic.isGameOver
                                                    ? Image(
                                                        image: AssetImage(
                                                          'assets/stairs/${!stairsLogic.stonesIndex[columnIndex]!.contains(rowIndex) ? 'stairs' : 'rocks'}.png',
                                                        ),
                                                        fit: BoxFit.cover,
                                                        opacity: AlwaysStoppedAnimation(
                                                            stairsLogic.openedColumnIndex[
                                                                        columnIndex] ==
                                                                    rowIndex
                                                                ? 1.0
                                                                : 0.4),
                                                      )
                                                    : FaIcon(
                                                        FontAwesomeIcons
                                                            .solidCircleQuestion,
                                                        color: Theme.of(context)
                                                            .canvasColor,
                                                        size: 30.0,
                                                      )
                                                : stairsLogic
                                                        .openedColumnIndex.keys
                                                        .toList()
                                                        .contains(columnIndex)
                                                    ? Image(
                                                        image: AssetImage(
                                                          'assets/stairs/${!stairsLogic.stonesIndex[columnIndex]!.contains(rowIndex) ? 'stairs' : 'rocks'}.png',
                                                        ),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                        opacity: AlwaysStoppedAnimation(
                                                            stairsLogic.openedColumnIndex[
                                                                        columnIndex] ==
                                                                    rowIndex
                                                                ? 1.0
                                                                : 0.4))
                                                    : Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                          border: Border.all(
                                                              color: stairsLogic
                                                                          .currentIndex !=
                                                                      columnIndex
                                                                  ? Colors
                                                                      .transparent
                                                                  : Colors
                                                                      .lightBlueAccent,
                                                              width: 2.0),
                                                        ),
                                                        child: ElevatedButton(
                                                            onPressed: () {
                                                              if (stairsLogic
                                                                      .currentIndex !=
                                                                  columnIndex) {
                                                                return;
                                                              }

                                                              stairsLogic
                                                                  .selectCell(
                                                                      rowIndex,
                                                                      columnIndex);
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor: Colors
                                                                  .lightBlueAccent
                                                                  .withOpacity(
                                                                      0.5),
                                                            ),
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5.0,
                                                                        right:
                                                                            5.0),
                                                                child:
                                                                    Container())),
                                                      ),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                          )))
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
