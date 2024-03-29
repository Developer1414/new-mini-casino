import 'dart:math';

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
import 'package:new_mini_casino/games_logic/coinflip_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class Coinflip extends StatefulWidget {
  const Coinflip({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  State<Coinflip> createState() => _CoinflipState();
}

class _CoinflipState extends State<Coinflip>
    with SingleTickerProviderStateMixin {
  String frontCoin = "assets/coinflip/coinFront.png";
  String backCoint = "assets/coinflip/coinBack.png";

  late final AnimationController _controller;
  late final Animation flipAnimation;

  int randAngle = 540;

  String imageCoin(x) {
    int _t = (-x ~/ (pi / 2)) % 4;
    return _t == 0 || _t == 3 || _t == 4 ? frontCoin : backCoint;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    flipAnimation = Tween(begin: 0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1, curve: Curves.bounceOut)));

    final coinflipLogic = Provider.of<CoinflipLogic>(context, listen: false);

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (randAngle == 540) {
          if (coinflipLogic.randomCoinflipStatus ==
              coinflipLogic.userCoinflipStatus) {
            coinflipLogic.raiseWinnings();
          } else {
            coinflipLogic.loss();
          }
        } else {
          if (coinflipLogic.randomCoinflipStatus ==
              coinflipLogic.userCoinflipStatus) {
            coinflipLogic.raiseWinnings();
          } else {
            coinflipLogic.loss();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return PopScope(
        canPop: !context.read<CoinflipLogic>().isGameOn &&
            !Provider.of<CoinflipLogic>(context, listen: false).isContinueGame,
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
                bottomNavigationBar: Consumer<CoinflipLogic>(
                  builder: (context, coinflipLogic, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText(
                                      'Прибыль (${coinflipLogic.currentCoefficient == -1 ? 0 : coinflipLogic.coefficients[coinflipLogic.currentCoefficient]}x):',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 12.0)),
                                  AutoSizeText(
                                      coinflipLogic.profit < 1000000
                                          ? NumberFormat.simpleCurrency(
                                                  locale:
                                                      ui.Platform.localeName)
                                              .format(coinflipLogic.profit)
                                          : NumberFormat.compactSimpleCurrency(
                                                  locale:
                                                      ui.Platform.localeName)
                                              .format(coinflipLogic.profit),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 12.0)),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              SizedBox(
                                height: 50,
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        coinflipLogic.coefficients.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 10.0),
                                    itemBuilder: (context, index) {
                                      return Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: index <=
                                                    coinflipLogic
                                                        .currentCoefficient
                                                ? Colors.lightBlueAccent
                                                    .withOpacity(0.1)
                                                : Colors.lightBlueAccent
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            border: Border.all(
                                                color: index <=
                                                        coinflipLogic
                                                            .currentCoefficient
                                                    ? Colors.lightBlueAccent
                                                    : Colors.lightBlueAccent
                                                        .withOpacity(0.4),
                                                width: 2.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                '${coinflipLogic.coefficients[index]}x',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: Colors.white
                                                            .withOpacity(index <=
                                                                    coinflipLogic
                                                                        .currentCoefficient
                                                                ? 1.0
                                                                : 0.4))),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              const SizedBox(height: 10.0),
                              Container(
                                height: 40.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color:
                                      Colors.lightBlueAccent.withOpacity(0.1),
                                  border: Border.all(
                                      color: Colors.lightBlueAccent,
                                      width: 2.0),
                                ),
                                child: coinflipLogic.lastGames.isEmpty
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
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              List<bool> value = coinflipLogic
                                                  .lastGames.reversed
                                                  .toList();

                                              return Container(
                                                margin: EdgeInsets.only(
                                                    top: 5.0,
                                                    bottom: 5.0,
                                                    left:
                                                        index == 0 ? 5.0 : 0.0,
                                                    right: index + 1 ==
                                                            coinflipLogic
                                                                .lastGames
                                                                .length
                                                        ? 5.0
                                                        : 0.0),
                                                child: Center(
                                                  child: Image.asset(
                                                      value[index]
                                                          ? frontCoin
                                                          : backCoint),
                                                ),
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(width: 5.0),
                                            itemCount:
                                                coinflipLogic.lastGames.length),
                                      ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          children: [
                            coinflipLogic.currentCoefficient != -1 ||
                                    coinflipLogic.isGameOn
                                ? Container()
                                : SizedBox(
                                    height: 60.0,
                                    width: 80.0,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          coinflipLogic.showInputBet(),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        backgroundColor:
                                            const Color(0xFF366ecc),
                                        shape: const RoundedRectangleBorder(),
                                      ),
                                      child: FaIcon(
                                        coinflipLogic.isShowInputBet
                                            ? FontAwesomeIcons.arrowLeft
                                            : FontAwesomeIcons.keyboard,
                                        color: Colors.white,
                                        size: 25.0,
                                      ),
                                    ),
                                  ),
                            coinflipLogic.currentCoefficient == -1
                                ? Container()
                                : Expanded(
                                    child: SizedBox(
                                      height: 60.0,
                                      child: Container(
                                        color: Theme.of(context).cardColor,
                                        child: ElevatedButton(
                                          onPressed: coinflipLogic
                                                          .randomCoinflipStatus !=
                                                      coinflipLogic
                                                          .userCoinflipStatus ||
                                                  _controller.status ==
                                                      AnimationStatus.forward
                                              ? null
                                              : () {
                                                  coinflipLogic.cashout();
                                                },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: Colors.redAccent,
                                            shape:
                                                const RoundedRectangleBorder(),
                                          ),
                                          child: AutoSizeText(
                                            'ЗАБРАТЬ',
                                            maxLines: 1,
                                            style: GoogleFonts.roboto(
                                                color: coinflipLogic
                                                                .randomCoinflipStatus !=
                                                            coinflipLogic
                                                                .userCoinflipStatus ||
                                                        _controller.status ==
                                                            AnimationStatus
                                                                .forward
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
                            Visibility(
                              visible: coinflipLogic.isShowInputBet,
                              child: Expanded(
                                child: SizedBox(
                                  height: 60.0,
                                  child: customTextField(
                                      currencyTextInputFormatter:
                                          Coinflip.betFormatter,
                                      textInputFormatter: Coinflip.betFormatter,
                                      keyboardType: TextInputType.number,
                                      isBetInput: true,
                                      controller: Coinflip.betController,
                                      context: context,
                                      hintText: 'Ставка...'),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !coinflipLogic.isShowInputBet,
                              child: Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: Theme.of(context).cardColor,
                                        height: 60.0,
                                        child: ElevatedButton(
                                          onPressed: !coinflipLogic.isGameOn &&
                                                  _controller.status !=
                                                      AnimationStatus.forward
                                              ? () {
                                                  if (balance.currentBalance <
                                                      double.parse(Coinflip
                                                          .betFormatter
                                                          .getUnformattedValue()
                                                          .toString())) {
                                                    return;
                                                  }

                                                  coinflipLogic.startGame(
                                                      context: context,
                                                      status:
                                                          CoinflipStatus.dollar,
                                                      bet: double.parse(Coinflip
                                                          .betFormatter
                                                          .getUnformattedValue()
                                                          .toString()));

                                                  if (coinflipLogic
                                                          .randomCoinflipStatus ==
                                                      CoinflipStatus.nothing) {
                                                    randAngle = 540;
                                                  } else {
                                                    randAngle = 760;
                                                  }

                                                  _controller
                                                    ..reset()
                                                    ..forward(from: 0);
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            elevation: 5,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 98, 206, 107),
                                            shape:
                                                const RoundedRectangleBorder(),
                                          ),
                                          child: Transform.translate(
                                            offset: const Offset(0.0, 1.0),
                                            child: Image.asset(frontCoin,
                                                width: 38.0,
                                                height: 38.0,
                                                opacity: !coinflipLogic
                                                            .isGameOn ||
                                                        _controller.status !=
                                                            AnimationStatus
                                                                .forward
                                                    ? const AlwaysStoppedAnimation(
                                                        1.0)
                                                    : const AlwaysStoppedAnimation(
                                                        0.4)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        color: Theme.of(context).cardColor,
                                        height: 60.0,
                                        child: ElevatedButton(
                                          onPressed: !coinflipLogic.isGameOn ||
                                                  _controller.status !=
                                                      AnimationStatus.forward
                                              ? () {
                                                  if (balance.currentBalance <
                                                      double.parse(Coinflip
                                                          .betFormatter
                                                          .getUnformattedValue()
                                                          .toString())) {
                                                    return;
                                                  }

                                                  coinflipLogic.startGame(
                                                      context: context,
                                                      status: CoinflipStatus
                                                          .nothing,
                                                      bet: double.parse(Coinflip
                                                          .betFormatter
                                                          .getUnformattedValue()
                                                          .toString()));

                                                  if (coinflipLogic
                                                          .randomCoinflipStatus ==
                                                      CoinflipStatus.nothing) {
                                                    randAngle = 540;
                                                  } else {
                                                    randAngle = 760;
                                                  }

                                                  _controller
                                                    ..reset()
                                                    ..forward(from: 0);
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            elevation: 5,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 255, 102, 102),
                                            shape:
                                                const RoundedRectangleBorder(),
                                          ),
                                          child: Transform.translate(
                                            offset: const Offset(0.0, 1.0),
                                            child: Image.asset(backCoint,
                                                width: 38.0,
                                                height: 38.0,
                                                opacity: !coinflipLogic
                                                            .isGameOn ||
                                                        _controller.status !=
                                                            AnimationStatus
                                                                .forward
                                                    ? const AlwaysStoppedAnimation(
                                                        1.0)
                                                    : const AlwaysStoppedAnimation(
                                                        0.4)),
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
                        onPressed: context.watch<CoinflipLogic>().isGameOn ||
                                context.watch<CoinflipLogic>().isContinueGame
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
                        'Coinflip',
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
                          onPressed: context.watch<CoinflipLogic>().isGameOn ||
                                  context.watch<CoinflipLogic>().isContinueGame
                              ? null
                              : () => context
                                  .beamToNamed('/game-statistic/coinflip'),
                          icon: FaIcon(
                            FontAwesomeIcons.circleInfo,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color,
                            size: Theme.of(context).appBarTheme.iconTheme!.size,
                          )),
                    ),
                  ],
                ),
                body: Screenshot(
                  controller: screenshotController,
                  child:
                      Consumer<CoinflipLogic>(builder: (ctx, coinflipLogic, _) {
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15.0),
                                  child: AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        double x = -randAngle *
                                            pi /
                                            180 *
                                            flipAnimation.value;
                                        double y =
                                            12 * pi / 180 * flipAnimation.value;
                                        double z =
                                            30 * pi / 180 * flipAnimation.value;

                                        return SizedBox(
                                          height: 250,
                                          width: 250,
                                          child: Transform(
                                            transform: Matrix4.identity()
                                              ..setEntry(3, 2, 0.005)
                                              ..rotateY(y)
                                              ..rotateX(x)
                                              ..rotateZ(z),
                                            alignment: Alignment.center,
                                            child: Image.asset(imageCoin(x)),
                                          ),
                                        );
                                      }))),
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
        ));
  }
}
