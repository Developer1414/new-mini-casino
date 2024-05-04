import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/jackpot_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:screenshot/screenshot.dart';

class Jackpot extends StatefulWidget {
  const Jackpot({super.key});

  static StreamController<int> controller = StreamController<int>.broadcast();

  static List<FortuneItem> items = [];
  static List<String> players = [];

  static int currentTimeBeforePlaying = 10;
  static int playersCount = 0;
  static int winnedPlayerIndex = 0;
  static double currentBalance = 0;
  static double myBet = 0;
  static double coefficient = 0;
  static double profit = 0;
  static bool isBlockButton = false;
  static Timer timer = Timer(const Duration(seconds: 1), () {});

  @override
  State<Jackpot> createState() => _JackpotState();
}

class _JackpotState extends State<Jackpot> {
  void disposeGame() {
    Jackpot.controller.close();
    Jackpot.timer.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    disposeGame();
    Jackpot.controller = StreamController<int>.broadcast();
  }

  void createGame() {
    if (mounted) {
      setState(() {
        Jackpot.items.clear();
        Jackpot.players.clear();
        Jackpot.isBlockButton = false;
      });
    }

    Jackpot.currentTimeBeforePlaying = 10;
    Jackpot.playersCount = 0;
    Jackpot.currentBalance = 0;
    Jackpot.myBet = 0;
    Jackpot.coefficient = 0;
    Jackpot.profit = 0;
    Jackpot.winnedPlayerIndex = 0;
    int rand = 0;

    Jackpot.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (context.mounted) {
        setState(() {
          Jackpot.currentTimeBeforePlaying--;
        });
      }

      if (Jackpot.playersCount == 0) {
        if (context.mounted) {
          setState(() {
            Jackpot.currentTimeBeforePlaying = 10;
          });
        }
      }

      if (Jackpot.currentTimeBeforePlaying > 0) {
        rand = Random().nextInt(9) + 1;

        int maxBalance =
            Jackpot.myBet.round() <= 0 ? 500 : Jackpot.myBet.round();

        if (rand <= 4) {
          setState(() {
            double balance = Random().nextInt(maxBalance) + 100;

            Jackpot.currentBalance += balance;

            String botName = JackpotLogic()
                .names[Random().nextInt(JackpotLogic().names.length) + 0];

            Jackpot.items.add(fortuneItem(nickname: botName, bet: balance));

            Jackpot.players.add(botName);

            Jackpot.playersCount++;

            if (Jackpot.myBet > 0) {
              Jackpot.coefficient = Jackpot.currentBalance / Jackpot.myBet;
            }
          });
        }

        if (Jackpot.currentTimeBeforePlaying < 3 && Jackpot.playersCount == 1) {
          setState(() {
            double balance = Random().nextInt(maxBalance) + 1;

            Jackpot.currentBalance += balance;

            String botName =
                'Бот-${NumberFormat('000').format(int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(9, 12)))}';

            Jackpot.items.add(fortuneItem(nickname: botName, bet: balance));

            Jackpot.players.add(botName);

            Jackpot.playersCount++;
          });
        }
      } else {
        timer.cancel();

        setState(() {
          int rand = Fortune.randomInt(0, Jackpot.items.length);

          Jackpot.winnedPlayerIndex = rand;
          Jackpot.controller.add(rand);
          Jackpot.isBlockButton = true;
        });
      }
    });
  }

  void makeBet(
      {required BuildContext context,
      required JackpotLogic jackpotLogic,
      required Balance balance}) {
    if (!jackpotLogic.isGameOn || Jackpot.isBlockButton) {
      if (jackpotLogic.bet < 100.0) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'В этой игре ставка не может быть меньше 100 рублей!',
          confirmBtnText: 'Окей',
        );

        return;
      }

      jackpotLogic.startGame(
          context: context,
          callback: () {
            createGame();

            Jackpot.playersCount++;
            Jackpot.myBet = jackpotLogic.bet;

            Jackpot.players.add('user');

            setState(() {
              Jackpot.currentBalance += jackpotLogic.bet;

              Jackpot.items.add(fortuneItem(
                  nickname: 'Вы', isBot: false, bet: jackpotLogic.bet));
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return PopScope(
      canPop: !context.read<JackpotLogic>().isGameOn,
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
              bottomNavigationBar: Consumer<JackpotLogic>(
                builder: (context, jackpotLogic, child) {
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
                                AutoSizeText(
                                    'Прибыль (${Jackpot.coefficient.toStringAsFixed(2)}x):',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                AutoSizeText(
                                    Jackpot.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(Jackpot.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(Jackpot.profit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            gameBetCount(
                              context: context,
                              gameLogic: jackpotLogic,
                              bet: jackpotLogic.bet,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60.0,
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5.0)
                          ], color: Theme.of(context).cardColor),
                          child: ElevatedButton(
                            onPressed:
                                Jackpot.isBlockButton || jackpotLogic.isGameOn
                                    ? null
                                    : () => makeBet(
                                        context: context,
                                        jackpotLogic: jackpotLogic,
                                        balance: balance),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.green,
                              shape: const RoundedRectangleBorder(),
                            ),
                            child: Provider.of<Balance>(context, listen: true)
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
                                        color: Jackpot.isBlockButton ||
                                                jackpotLogic.isGameOn
                                            ? Colors.white.withOpacity(0.4)
                                            : Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w900),
                                  ),
                          ),
                        ),
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
                      onPressed: context.watch<JackpotLogic>().isGameOn
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
                      'Jackpot',
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
                        onPressed: context.watch<JackpotLogic>().isGameOn
                            ? null
                            : () =>
                                context.beamToNamed('/game-statistic/jackpot'),
                        icon: FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Consumer<JackpotLogic>(
                        builder: (context, jackpotLogic, child) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                                color: Colors.lightBlueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                    color:
                                        Colors.lightBlueAccent.withOpacity(0.7),
                                    width: 2.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Jackpot.items.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText('Сделайте ставку',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall),
                                          AutoSizeText(
                                              'Чем больше ваша ставка, тем больше ставка ботов',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      fontSize: 12.0,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .color!
                                                          .withOpacity(0.6))),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AutoSizeText(
                                                'Участников: ${Jackpot.playersCount}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                            const SizedBox(height: 5.0),
                                            AutoSizeText(
                                                'Баланс: ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(Jackpot.currentBalance)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          ],
                                        ),
                                        const SizedBox(height: 15.0),
                                        Screenshot(
                                          controller: screenshotController,
                                          child: FortuneBar(
                                            height: 235,
                                            animateFirst: false,
                                            onAnimationEnd: () async {
                                              jackpotLogic.onAnimationStopped();

                                              if (context.mounted) {
                                                setState(() {
                                                  if (Jackpot.players[Jackpot
                                                          .winnedPlayerIndex] ==
                                                      'user') {
                                                    Jackpot.profit =
                                                        Jackpot.currentBalance;

                                                    jackpotLogic.win(
                                                        profit: Jackpot.profit);
                                                  } else {
                                                    jackpotLogic.loss(
                                                        context: context);
                                                  }
                                                });
                                              }

                                              if (context.mounted) {
                                                setState(() {
                                                  Jackpot.isBlockButton = false;
                                                });
                                              }

                                              jackpotLogic.onAnimationStopped();
                                            },
                                            physics: NoPanPhysics(),
                                            styleStrategy: UniformStyleStrategy(
                                                borderColor: Colors.blueAccent,
                                                color: Colors.lightBlueAccent
                                                    .withOpacity(0.7),
                                                borderWidth: 0.0),
                                            selected: Jackpot.controller.stream,
                                            items: Jackpot.items,
                                          ),
                                        ),
                                        const SizedBox(height: 15.0),
                                        Jackpot.currentTimeBeforePlaying == 0
                                            ? Container()
                                            : Center(
                                                child: AutoSizeText(
                                                    'Старт через ${Jackpot.currentTimeBeforePlaying} сек.',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            fontSize: 20.0)),
                                              ),
                                      ],
                                    ),
                            )),
                      );
                    }),
                  )
                ],
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

  FortuneItem fortuneItem(
      {required String nickname, bool isBot = true, required double bet}) {
    return FortuneItem(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            isBot ? FontAwesomeIcons.ghost : FontAwesomeIcons.person,
            color: isBot
                ? Color((Random().nextDouble() * 0xFFFFFF).toInt())
                    .withOpacity(1.0)
                : Colors.black87,
            size: 35.0,
          ),
          const SizedBox(height: 5.0),
          AutoSizeText(
            nickname,
            style: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 18.0,
                fontWeight: FontWeight.w700),
          ),
          AutoSizeText(
            NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
                .format(bet),
            style: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 12.0,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
