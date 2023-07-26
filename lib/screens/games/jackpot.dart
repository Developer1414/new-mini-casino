import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/jackpot_logic.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/models/text_field_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Jackpot extends StatefulWidget {
  const Jackpot({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

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

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  State<Jackpot> createState() => _JackpotState();
}

class _JackpotState extends State<Jackpot> {
  @override
  void initState() {
    super.initState();
    createGame();
  }

  @override
  void dispose() {
    super.dispose();
    Jackpot.controller.close();
    Jackpot.controller = StreamController<int>.broadcast();
    Jackpot.timer.cancel();
  }

  void createGame() {
    if (context.mounted) {
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

    // ignore: unused_local_variable
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
            Jackpot.myBet.round() <= 0 ? 100 : Jackpot.myBet.round();

        if (rand <= 4) {
          setState(() {
            double balance = Random().nextInt(maxBalance) + 1;

            Jackpot.currentBalance += balance;

            String botName =
                'Бот-${NumberFormat('000').format(int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(9, 12)))}';

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

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        return !context.read<JackpotLogic>().isGameOn;
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
                ]),
            child: Consumer<JackpotLogic>(
              builder: (ctx, jackpotLogic, _) {
                return Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText(
                                  'Прибыль (${Jackpot.coefficient.toStringAsFixed(2)}x):',
                                  style: GoogleFonts.roboto(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: AutoSizeText(
                                    Jackpot.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(Jackpot.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(Jackpot.profit),
                                    style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: Jackpot.isBlockButton ||
                                      jackpotLogic.isGameOn
                                  ? null
                                  : () {
                                      if (!jackpotLogic.isGameOn ||
                                          Jackpot.isBlockButton) {
                                        if (balance.currentBalance <
                                            double.parse(Jackpot.betFormatter
                                                .getUnformattedValue()
                                                .toStringAsFixed(2))) {
                                          return;
                                        }

                                        if (double.parse(Jackpot.betFormatter
                                                .getUnformattedValue()
                                                .toString()) <
                                            100.0) {
                                          alertDialogError(
                                            context: context,
                                            title: 'Ошибка',
                                            text:
                                                'В этой игре ставка не может быть меньше 100 рублей!',
                                            confirmBtnText: 'Окей',
                                          );

                                          return;
                                        }

                                        Jackpot.playersCount++;
                                        Jackpot.myBet = double.parse(Jackpot
                                            .betFormatter
                                            .getUnformattedValue()
                                            .toString());

                                        Jackpot.players.add('user');

                                        jackpotLogic.startGame(
                                            context: context,
                                            bet: Jackpot.myBet);

                                        setState(() {
                                          Jackpot.currentBalance +=
                                              double.parse(Jackpot.betFormatter
                                                  .getUnformattedValue()
                                                  .toString());

                                          Jackpot.items.add(fortuneItem(
                                              nickname: 'Вы',
                                              isBot: false,
                                              bet: double.parse(Jackpot
                                                  .betFormatter
                                                  .getUnformattedValue()
                                                  .toString())));
                                        });
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
                                  'СТАВКА',
                                  maxLines: 1,
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w900),
                                ),
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
                  onPressed: context.watch<JackpotLogic>().isGameOn
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
                  'Jackpot',
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
                    onPressed: context.watch<JackpotLogic>().isGameOn
                        ? null
                        : () => context.beamToNamed('/game-statistic/jackpot'),
                    icon: const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.black87,
                      size: 30.0,
                    )),
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<JackpotLogic>(
                builder: (context, jackpotLogic, child) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: customTextField(
                              currencyTextInputFormatter: Jackpot.betFormatter,
                              textInputFormatter: Jackpot.betFormatter,
                              keyboardType: TextInputType.number,
                              readOnly: jackpotLogic.isGameOn,
                              isBetInput: true,
                              controller: Jackpot.betController,
                              context: context,
                              hintText: 'Ставка...'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Consumer<JackpotLogic>(
                    builder: (context, jackpotLogic, child) {
                  return Container(
                      margin: const EdgeInsets.all(15.0),
                      height: 40.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10.0)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Jackpot.items.isEmpty
                            ? Center(
                                child: AutoSizeText(
                                  'Игроков ещё нет',
                                  style: GoogleFonts.roboto(
                                      color: Colors.black87.withOpacity(0.4),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        'Игроков: ${Jackpot.playersCount}',
                                        style: GoogleFonts.roboto(
                                            color: Colors.black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 5.0),
                                      AutoSizeText(
                                        'Баланс: ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(Jackpot.currentBalance)}',
                                        style: GoogleFonts.roboto(
                                            color: Colors.black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: FortuneBar(
                                      height: 250.0,
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
                                                  context: context,
                                                  bet: double.parse(Jackpot
                                                      .betFormatter
                                                      .getUnformattedValue()
                                                      .toString()));
                                            }
                                          });
                                        }

                                        await Future.delayed(
                                            const Duration(seconds: 2));

                                        if (context.mounted) {
                                          setState(() {
                                            Jackpot.isBlockButton = false;
                                          });
                                        }

                                        Jackpot.controller.close();
                                        Jackpot.controller =
                                            StreamController<int>.broadcast();
                                        Jackpot.timer.cancel();
                                        jackpotLogic.onAnimationStopped();
                                        createGame();
                                      },
                                      physics: NoPanPhysics(),
                                      styleStrategy: UniformStyleStrategy(
                                          borderColor: Colors.blueAccent,
                                          color: Colors.grey.shade300,
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
                                            style: GoogleFonts.roboto(
                                                color: Colors.black87,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                  Expanded(child: Container()),
                                  AutoSizeText(
                                    'Чем больше ваша ставка, тем больше ставка ботов',
                                    style: GoogleFonts.roboto(
                                        color: Colors.black87.withOpacity(0.4),
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                      ));
                }),
              )
            ],
          ),
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