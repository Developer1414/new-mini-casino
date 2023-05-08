import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/coinflip_logic.dart';
import 'package:new_mini_casino/models/text_field_model.dart';
import 'package:provider/provider.dart';

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
          coinflipLogic.loss();
        } else {
          coinflipLogic.raiseWinnings();
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

    return WillPopScope(
        onWillPop: () async {
          return !context.read<CoinflipLogic>().isGameOn;
        },
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: GestureDetector(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: Container(
                height: 182.0,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10.0)
                    ]),
                child: Consumer<CoinflipLogic>(
                  builder: (ctx, coinflipLogic, _) {
                    return Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText(
                                      'Прибыль (${coinflipLogic.currentCoefficient == -1 ? 0 : coinflipLogic.coefficients[coinflipLogic.currentCoefficient]}x):',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: AutoSizeText(
                                        coinflipLogic.profit < 1000000
                                            ? NumberFormat.simpleCurrency(
                                                    locale:
                                                        ui.Platform.localeName)
                                                .format(coinflipLogic.profit)
                                            : NumberFormat
                                                    .compactSimpleCurrency(
                                                        locale: ui.Platform
                                                            .localeName)
                                                .format(coinflipLogic.profit),
                                        style: GoogleFonts.roboto(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
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
                                              border: index ==
                                                      coinflipLogic
                                                          .currentCoefficient
                                                  ? Border.all(
                                                      width: 2.0,
                                                      color: Colors.green)
                                                  : null,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1.0,
                                                    blurRadius: 5.0)
                                              ],
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(15.0))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                '${coinflipLogic.coefficients[index]}x',
                                                style: GoogleFonts.roboto(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                )),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: !coinflipLogic.isWin ||
                                              _controller.status ==
                                                  AnimationStatus.forward
                                          ? null
                                          : () {
                                              coinflipLogic.cashout();
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
                                          'ЗАБРАТЬ',
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
                                      onPressed: !coinflipLogic.isGameOn ||
                                              coinflipLogic.isWin &&
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
                                                  bet: double.parse(Coinflip
                                                      .betFormatter
                                                      .getUnformattedValue()
                                                      .toString()));

                                              if (!coinflipLogic.isWin) {
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
                                ],
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
                      onPressed: context.watch<CoinflipLogic>().isGameOn
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
                      'Coinflip',
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
                        onPressed: context.watch<CoinflipLogic>().isGameOn
                            ? null
                            : () =>
                                context.beamToNamed('/game-statistic/coinflip'),
                        icon: const FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: Colors.black87,
                          size: 30.0,
                        )),
                  ),
                ],
              ),
              body: Consumer<CoinflipLogic>(builder: (ctx, coinflipLogic, _) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15.0),
                      child: customTextField(
                          currencyTextInputFormatter: Coinflip.betFormatter,
                          textInputFormatter: Coinflip.betFormatter,
                          context: context,
                          keyboardType: TextInputType.number,
                          readOnly: coinflipLogic.isGameOn,
                          isBetInput: true,
                          controller: Coinflip.betController,
                          hintText: 'Ставка...'),
                    ),
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
                    Container(
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
                      child: coinflipLogic.lastGames.isEmpty
                          ? Center(
                              child: AutoSizeText(
                                'Ставок ещё нет',
                                style: GoogleFonts.roboto(
                                    color: Colors.black87.withOpacity(0.4),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                List<bool> value =
                                    coinflipLogic.lastGames.reversed.toList();

                                return Container(
                                  margin: EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 5.0,
                                      left: index == 0 ? 5.0 : 0.0,
                                      right: index + 1 ==
                                              coinflipLogic.lastGames.length
                                          ? 5.0
                                          : 0.0),
                                  child: Center(
                                    child: Image.asset(
                                        value[index] ? frontCoin : backCoint),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 5.0),
                              itemCount: coinflipLogic.lastGames.length),
                    )
                  ],
                );
              }),
            ),
          ),
        ));
  }
}
