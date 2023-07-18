import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/stairs_logic.dart';
import 'package:new_mini_casino/models/text_field_model.dart';
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

    return WillPopScope(
      onWillPop: () async => !context.read<StairsLogic>().isGameOn,
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
            height: 188.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
                ]),
            child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: Consumer<StairsLogic>(
                        builder: (ctx, stairsLogic, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoSizeText(
                                        'Прибыль (${stairsLogic.currentCoefficient.isNaN ? '0.00' : stairsLogic.currentCoefficient.toStringAsFixed(2)}x):',
                                        style: GoogleFonts.roboto(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                        )),
                                    AutoSizeText(
                                        stairsLogic.profit < 1000000
                                            ? NumberFormat.simpleCurrency(
                                                    locale:
                                                        ui.Platform.localeName)
                                                .format(stairsLogic.profit)
                                            : NumberFormat
                                                    .compactSimpleCurrency(
                                                        locale: ui.Platform
                                                            .localeName)
                                                .format(stairsLogic.profit),
                                        style: GoogleFonts.roboto(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                        )),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText('Кол. камней:',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      )),
                                  AutoSizeText(
                                      stairsLogic.sliderValue
                                          .round()
                                          .toString(),
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      )),
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
                          );
                        },
                      ),
                    ),
                    Consumer<StairsLogic>(builder: (ctx, stairsLogic, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: !stairsLogic.isGameOn
                                  ? null
                                  : () {
                                      stairsLogic.autoMove();
                                    },
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor: Colors.blueAccent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25.0),
                                      topRight: Radius.circular(25.0)),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: AutoSizeText(
                                  'АВТО',
                                  maxLines: 1,
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: !stairsLogic.isGameOn
                                  ? () {
                                      if (!stairsLogic.isGameOn) {
                                        if (balance.currentBalance <
                                            double.parse(Stairs.betFormatter
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
                                  : stairsLogic.openedColumnIndex.isEmpty
                                      ? null
                                      : () {
                                          if (!stairsLogic.isGameOn) {
                                            if (balance.currentBalance <
                                                double.parse(Stairs.betFormatter
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
                                  !stairsLogic.isGameOn ? 'СТАВКА' : 'ЗАБРАТЬ',
                                  maxLines: 1,
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }),
                  ],
                )),
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
                  icon: const FaIcon(
                    FontAwesomeIcons.arrowLeft,
                    color: Colors.black87,
                    size: 30.0,
                  )),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Stairs',
                  style: GoogleFonts.roboto(
                      color: Colors.black87,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w900),
                ),
                Consumer<Balance>(
                  builder: (context, value, _) {
                    return AutoSizeText(
                      value.currentBalanceString,
                      maxLines: 1,
                      style: GoogleFonts.roboto(
                          color: Colors.black87,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900),
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
                    onPressed: context.watch<StairsLogic>().isGameOn
                        ? null
                        : () {
                            context.beamToNamed('/game-statistic/stairs');
                          },
                    icon: const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.black87,
                      size: 30.0,
                    )),
              ),
            ],
          ),
          body: Consumer<StairsLogic>(
            builder: (context, stairsLogic, child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15.0),
                    child: customTextField(
                        context: context,
                        currencyTextInputFormatter: Stairs.betFormatter,
                        textInputFormatter: Stairs.betFormatter,
                        keyboardType: TextInputType.number,
                        readOnly: stairsLogic.isGameOn,
                        isBetInput: true,
                        controller: Stairs.betController,
                        hintText: 'Ставка...'),
                  ),
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
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
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
                                                    : Container()
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
                                                    : ElevatedButton(
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
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          elevation: 5,
                                                          shadowColor: stairsLogic
                                                                      .currentIndex !=
                                                                  columnIndex
                                                              ? Colors
                                                                  .grey.shade300
                                                              : Colors.brown,
                                                          backgroundColor:
                                                              Colors.grey
                                                                  .shade300,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: stairsLogic.openedColumnIndex[
                                                                            columnIndex] ==
                                                                        rowIndex
                                                                    ? Colors
                                                                        .brown
                                                                        .shade300
                                                                    : Colors
                                                                        .transparent,
                                                                width: 2.0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 5.0,
                                                                    right: 5.0),
                                                            child:
                                                                Container())),
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
