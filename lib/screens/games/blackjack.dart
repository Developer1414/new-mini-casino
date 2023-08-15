import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/blackjack_logic.dart';
import 'package:new_mini_casino/models/text_field_model.dart';
import 'package:provider/provider.dart';

class Blackjack extends StatelessWidget {
  const Blackjack({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return WillPopScope(
        onWillPop: () async {
          return !context.read<BlackjackLogic>().isGameOn;
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
                height: 117.0,
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
                child: Consumer<BlackjackLogic>(
                  builder: (ctx, blackjackLogic, _) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText('Прибыль:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 20.0)),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: AutoSizeText(
                                        blackjackLogic.profit < 1000000
                                            ? NumberFormat.simpleCurrency(
                                                    locale:
                                                        ui.Platform.localeName)
                                                .format(blackjackLogic.profit)
                                            : NumberFormat
                                                    .compactSimpleCurrency(
                                                        locale: ui.Platform
                                                            .localeName)
                                                .format(blackjackLogic.profit),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(fontSize: 20.0)),
                                  ),
                                ],
                              ),
                            ),
                            blackjackLogic.isGameOn &&
                                    blackjackLogic.blackjackType ==
                                        BlackjackType.start
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: Row(
                                      children: [
                                        buttonModel(
                                            title: 'ЕЩЁ',
                                            color: Colors.green,
                                            function: blackjackLogic
                                                    .isLoadingMove
                                                ? () {}
                                                : () {
                                                    blackjackLogic.hitMove();
                                                  }),
                                        blackjackLogic.lastPlayerMoves.length ==
                                                2
                                            ? const SizedBox(width: 15.0)
                                            : Container(),
                                        blackjackLogic.lastPlayerMoves.length ==
                                                2
                                            ? buttonModel(
                                                title: 'X2',
                                                color: Colors.blueAccent,
                                                function:
                                                    blackjackLogic.isLoadingMove
                                                        ? () {}
                                                        : () {
                                                            blackjackLogic
                                                                .doubleMove();
                                                          })
                                            : Container(),
                                        const SizedBox(width: 15.0),
                                        buttonModel(
                                            title: 'СТОП',
                                            color: Colors.redAccent,
                                            function: blackjackLogic
                                                    .isLoadingMove
                                                ? () {}
                                                : () {
                                                    blackjackLogic.standMove();
                                                  }),
                                      ],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 64.0,
                                          child: ElevatedButton(
                                            onPressed: blackjackLogic
                                                        .isGameOn &&
                                                    blackjackLogic
                                                            .blackjackType ==
                                                        BlackjackType.idle
                                                ? null
                                                : () {
                                                    if (!blackjackLogic
                                                        .isGameOn) {
                                                      if (balance
                                                              .currentBalance <
                                                          double.parse(betFormatter
                                                              .getUnformattedValue()
                                                              .toStringAsFixed(
                                                                  2))) {
                                                        return;
                                                      }

                                                      blackjackLogic.startGame(
                                                          context: context,
                                                          bet: double.parse(
                                                              betFormatter
                                                                  .getUnformattedValue()
                                                                  .toString()));
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 5,
                                              backgroundColor: Colors.green,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(25.0),
                                                    topRight:
                                                        Radius.circular(25.0)),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(18.0),
                                              child: AutoSizeText(
                                                'СТАВКА',
                                                maxLines: 1,
                                                style: GoogleFonts.roboto(
                                                    color: blackjackLogic
                                                                .isGameOn &&
                                                            blackjackLogic
                                                                    .blackjackType ==
                                                                BlackjackType
                                                                    .idle
                                                        ? Colors.white
                                                            .withOpacity(0.4)
                                                        : Colors.white,
                                                    fontSize: 24.0,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15.0),
                                      !blackjackLogic.isGameOn
                                          ? Expanded(
                                              child: Container(
                                                height: 64.0,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  25.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  25.0)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    AutoSizeText('Страховка:',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!),
                                                    CupertinoSwitch(
                                                      value: blackjackLogic
                                                          .gameWithInsurance,
                                                      onChanged: (value) {
                                                        blackjackLogic
                                                            .changeInsuranceValue(
                                                                value);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container()
                                    ],
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
                      onPressed: context.watch<BlackjackLogic>().isGameOn
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
                      'Blackjack',
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
                        onPressed: context.watch<BlackjackLogic>().isGameOn
                            ? null
                            : () => context
                                .beamToNamed('/game-statistic/blackjack'),
                        icon: FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                ],
              ),
              body: Consumer<BlackjackLogic>(
                builder: (context, blackjackLogic, child) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: customTextField(
                                  currencyTextInputFormatter: betFormatter,
                                  textInputFormatter: betFormatter,
                                  keyboardType: TextInputType.number,
                                  readOnly: blackjackLogic.isGameOn,
                                  isBetInput: true,
                                  controller: betController,
                                  context: context,
                                  hintText: 'Ставка...'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              blackjackLogic.lastDealerMoves.isEmpty
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            for (int i = 0;
                                                i <
                                                    blackjackLogic
                                                        .lastDealerMoves.length;
                                                i++)
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(5.0),
                                                decoration: const BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black54,
                                                        blurRadius: 20,
                                                        spreadRadius: 0.1,
                                                        blurStyle:
                                                            BlurStyle.normal),
                                                  ],
                                                ),
                                                child: Image.asset(
                                                    height: 130,
                                                    'assets/blackjack/${blackjackLogic.lastDealerMoves.length == 2 && i == 1 && blackjackLogic.isGameOn ? 'ShirtCard' : blackjackLogic.lastDealerMoves[i]}.png'),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 15.0),
                              AutoSizeText(
                                blackjackLogic.lastDealerMoves.length == 2 &&
                                        blackjackLogic.isGameOn
                                    ? blackjackLogic.lastDealerMoves.first !=
                                            'A'
                                        ? blackjackLogic.cards[blackjackLogic
                                                .lastDealerMoves.first]
                                            .toString()
                                        : '1 / 11'
                                    : blackjackLogic.resultDealerValue,
                                style: Theme.of(context)
                                    .appBarTheme
                                    .titleTextStyle,
                              ),
                            ],
                          ),
                          blackjackLogic.blackjackType == BlackjackType.init
                              ? Column(
                                  children: [
                                    Image.asset(
                                        height: 150,
                                        'assets/games_logo/Blackjack.png'),
                                    const SizedBox(height: 15.0),
                                    AutoSizeText(
                                      blackjackLogic.status(),
                                      style: blackjackLogic.blackjackType ==
                                              BlackjackType.init
                                          ? Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                          : Theme.of(context)
                                              .textTheme
                                              .titleMedium!,
                                    ),
                                  ],
                                )
                              : AutoSizeText(
                                  blackjackLogic.status(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: blackjackLogic.blackjackType ==
                                                  BlackjackType.loss
                                              ? Colors.redAccent
                                              : blackjackLogic.blackjackType ==
                                                          BlackjackType.win ||
                                                      blackjackLogic
                                                              .blackjackType ==
                                                          BlackjackType
                                                              .blackjack
                                                  ? Colors.green
                                                  : blackjackLogic
                                                              .blackjackType ==
                                                          BlackjackType.draft
                                                      ? Colors.orange
                                                      : Colors.white),
                                ),
                          Column(
                            children: [
                              AutoSizeText(
                                blackjackLogic.resultPlayerValue,
                                style: Theme.of(context)
                                    .appBarTheme
                                    .titleTextStyle,
                              ),
                              const SizedBox(height: 15.0),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (int i = 0;
                                          i <
                                              blackjackLogic
                                                  .lastPlayerMoves.length;
                                          i++)
                                        Container(
                                          margin: const EdgeInsets.all(5.0),
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black54,
                                                  blurRadius: 20,
                                                  //offset: Offset(5, 10),
                                                  spreadRadius: 0.1,
                                                  blurStyle: BlurStyle.normal),
                                            ],
                                          ),
                                          child: Image.asset(
                                              height: 130,
                                              'assets/blackjack/${blackjackLogic.lastPlayerMoves[i]}.png'),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))
                    ],
                  );
                },
              ),
            )));
  }

  Widget buttonModel(
      {required String title,
      required Color color,
      required Function function}) {
    return Expanded(
      child: SizedBox(
        height: 64.0,
        child: ElevatedButton(
          onPressed: () => function.call(),
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: color,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: AutoSizeText(
              title,
              maxLines: 1,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
