import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/blackjack_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io' as ui;

class Blackjack extends StatelessWidget {
  const Blackjack({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return PopScope(
        canPop: !context.read<BlackjackLogic>().isGameOn,
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
                  bottomNavigationBar: Consumer<BlackjackLogic>(
                    builder: (context, blackjackLogic, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 15.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoSizeText('Прибыль:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(fontSize: 12.0)),
                                    AutoSizeText(
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
                                            .copyWith(fontSize: 12.0)),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                gameBetCount(
                                  context: context,
                                  gameLogic: blackjackLogic,
                                  bet: blackjackLogic.bet,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          blackjackLogic.isGameOn &&
                                  blackjackLogic.blackjackType ==
                                      BlackjackType.start
                              ? Row(
                                  children: [
                                    buttonModel(
                                        title: 'ЕЩЁ',
                                        color: Colors.green,
                                        blackjackLogic: blackjackLogic,
                                        context: context,
                                        balance: balance,
                                        function: blackjackLogic.isLoadingMove
                                            ? () {}
                                            : () {
                                                blackjackLogic.hitMove();
                                              }),
                                    blackjackLogic.lastPlayerMoves.length == 2
                                        ? buttonModel(
                                            title: 'X2',
                                            color: Colors.blueAccent,
                                            blackjackLogic: blackjackLogic,
                                            context: context,
                                            balance: balance,
                                            function: blackjackLogic
                                                    .isLoadingMove
                                                ? () {}
                                                : () {
                                                    blackjackLogic.doubleMove();
                                                  })
                                        : Container(),
                                    buttonModel(
                                        title: 'СТОП',
                                        color: Colors.redAccent,
                                        blackjackLogic: blackjackLogic,
                                        context: context,
                                        balance: balance,
                                        function: blackjackLogic.isLoadingMove
                                            ? () {}
                                            : () {
                                                blackjackLogic.standMove();
                                              }),
                                  ],
                                )
                              : Row(
                                  children: [
                                    blackjackLogic.isGameOn
                                        ? Container()
                                        : SizedBox(
                                            height: 60.0,
                                            width: 80.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 5.0)
                                                ],
                                                color: const Color(0xFF3d7ce6),
                                              ),
                                              child: Switch(
                                                value: blackjackLogic
                                                    .gameWithInsurance,
                                                onChanged: (value) {
                                                  blackjackLogic
                                                      .changeInsuranceValue(
                                                          value);

                                                  if (blackjackLogic
                                                      .gameWithInsurance) {
                                                    alertDialogSuccess(
                                                      context: context,
                                                      title: 'Успех',
                                                      confirmBtnText: 'Окей',
                                                      text:
                                                          'Страховка включена!',
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                    Expanded(
                                      child: SizedBox(
                                        height: 60.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 5.0)
                                              ],
                                              color:
                                                  Theme.of(context).cardColor),
                                          child: ElevatedButton(
                                            onPressed: blackjackLogic
                                                        .isGameOn &&
                                                    blackjackLogic
                                                            .blackjackType ==
                                                        BlackjackType.idle
                                                ? null
                                                : () {
                                                    if (Provider.of<Balance>(
                                                            context,
                                                            listen: false)
                                                        .isLoading) {
                                                      return;
                                                    }

                                                    if (!blackjackLogic
                                                        .isGameOn) {
                                                      blackjackLogic.startGame(
                                                          context: context);
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: Colors.green,
                                              shape:
                                                  const RoundedRectangleBorder(),
                                            ),
                                            child: Provider.of<Balance>(context,
                                                        listen: true)
                                                    .isLoading
                                                ? const SizedBox(
                                                    width: 30.0,
                                                    height: 30.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 5.0,
                                                      color: Colors.white,
                                                      strokeCap:
                                                          StrokeCap.round,
                                                    ),
                                                  )
                                                : AutoSizeText(
                                                    'СТАВКА',
                                                    maxLines: 1,
                                                    style: GoogleFonts.roboto(
                                                        color: blackjackLogic
                                                                .isGameOn
                                                            ? Colors.white30
                                                            : Colors.white,
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w900),
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
                    isGameOn: context.watch<BlackjackLogic>().isGameOn,
                    gameName: 'Blackjack',
                  ),
                  body: Screenshot(
                    controller: screenshotController,
                    child: Center(
                      child: Consumer<BlackjackLogic>(
                        builder: (context, blackjackLogic, child) {
                          return Column(
                            children: [
                              Expanded(
                                  child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      blackjackLogic.lastDealerMoves.isEmpty
                                          ? Container()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0, right: 15.0),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    for (int i = 0;
                                                        i <
                                                            blackjackLogic
                                                                .lastDealerMoves
                                                                .length;
                                                        i++)
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(5.0),
                                                        decoration:
                                                            const BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .black54,
                                                                blurRadius: 20,
                                                                spreadRadius:
                                                                    0.1,
                                                                blurStyle:
                                                                    BlurStyle
                                                                        .normal),
                                                          ],
                                                        ),
                                                        child: Image.asset(
                                                            height: 110,
                                                            'assets/blackjack/${blackjackLogic.lastDealerMoves.length == 2 && i == 1 && blackjackLogic.isGameOn ? 'ShirtCard' : blackjackLogic.lastDealerMoves[i]}.png'),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      const SizedBox(height: 15.0),
                                      AutoSizeText(
                                        blackjackLogic.lastDealerMoves.length ==
                                                    2 &&
                                                blackjackLogic.isGameOn
                                            ? blackjackLogic.lastDealerMoves
                                                        .first !=
                                                    'A'
                                                ? blackjackLogic.cards[
                                                        blackjackLogic
                                                            .lastDealerMoves
                                                            .first]
                                                    .toString()
                                                : '1 / 11'
                                            : blackjackLogic.resultDealerValue,
                                        style: Theme.of(context)
                                            .appBarTheme
                                            .titleTextStyle,
                                      ),
                                    ],
                                  ),
                                  blackjackLogic.blackjackType ==
                                          BlackjackType.init
                                      ? Column(
                                          children: [
                                            Image.asset(
                                                height: 150,
                                                'assets/games_logo/Blackjack.png'),
                                            const SizedBox(height: 15.0),
                                            AutoSizeText(
                                              blackjackLogic.status(),
                                              style: blackjackLogic
                                                          .blackjackType ==
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
                                                  color: blackjackLogic
                                                              .blackjackType ==
                                                          BlackjackType.loss
                                                      ? Colors.redAccent
                                                      : blackjackLogic.blackjackType ==
                                                                  BlackjackType
                                                                      .win ||
                                                              blackjackLogic
                                                                      .blackjackType ==
                                                                  BlackjackType
                                                                      .blackjack
                                                          ? Colors.green
                                                          : blackjackLogic
                                                                      .blackjackType ==
                                                                  BlackjackType
                                                                      .draft
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      blackjackLogic
                                                          .lastPlayerMoves
                                                          .length;
                                                  i++)
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(5.0),
                                                  decoration:
                                                      const BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black54,
                                                          blurRadius: 20,
                                                          //offset: Offset(5, 10),
                                                          spreadRadius: 0.1,
                                                          blurStyle:
                                                              BlurStyle.normal),
                                                    ],
                                                  ),
                                                  child: Image.asset(
                                                      height: 110,
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
                    ),
                  ),
                ),
                ConfettiWidget(
                    confettiController: confettiController,
                    blastDirectionality: BlastDirectionality.explosive)
              ],
            )));
  }

  Widget buttonModel(
      {required String title,
      required Color color,
      required BlackjackLogic blackjackLogic,
      required BuildContext context,
      required Balance balance,
      required VoidCallback function}) {
    return Expanded(
      child: SizedBox(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900),
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
