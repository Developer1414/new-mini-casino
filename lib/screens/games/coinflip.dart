import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/coinflip_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:new_mini_casino/widgets/last_bets_widget.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class Coinflip extends StatefulWidget {
  const Coinflip({super.key});

  @override
  State<Coinflip> createState() => _CoinflipState();
}

class _CoinflipState extends State<Coinflip>
    with SingleTickerProviderStateMixin {
  String frontCoin = "assets/coinflip/coinFront.png";
  String backCoin = "assets/coinflip/coinBack.png";

  late final AnimationController _controller;
  late final Animation flipAnimation;

  int randAngle = 540;

  bool imageCoin(double x) {
    double criticalAngle = pi / 4;

    x %= (2 * pi);

    bool isFront = x < criticalAngle || x > 2 * pi - criticalAngle;

    return isFront;
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
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            color: index <=
                                                    coinflipLogic
                                                        .currentCoefficient
                                                ? Colors.grey.shade100
                                                    .withOpacity(0.1)
                                                : Colors.grey.shade100
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                                color: index <=
                                                        coinflipLogic
                                                            .currentCoefficient
                                                    ? Colors.green
                                                    : Colors.grey.shade100
                                                        .withOpacity(0.4),
                                                width: 2.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: AnimatedOpacity(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              opacity: index <=
                                                      coinflipLogic
                                                          .currentCoefficient
                                                  ? 1.0
                                                  : 0.4,
                                              child: Text(
                                                '${coinflipLogic.coefficients[index]}x',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              const SizedBox(height: 10.0),
                              lastBetsWidget(
                                context: context,
                                list: coinflipLogic.lastGames,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
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
                                              left: index == 0 ? 5.0 : 0.0,
                                              right: index + 1 ==
                                                      coinflipLogic
                                                          .lastGames.length
                                                  ? 5.0
                                                  : 0.0),
                                          child: Center(
                                            child: Image.asset(value[index]
                                                ? frontCoin
                                                : backCoin),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 5.0),
                                      itemCount:
                                          coinflipLogic.lastGames.length),
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              gameBetCount(
                                context: context,
                                gameLogic: coinflipLogic,
                                bet: coinflipLogic.bet,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          children: [
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
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: Theme.of(context).cardColor,
                                      height: 60.0,
                                      child: ElevatedButton(
                                        onPressed: !coinflipLogic.isGameOn &&
                                                _controller.status !=
                                                    AnimationStatus.forward &&
                                                !Provider.of<Balance>(context,
                                                        listen: true)
                                                    .isLoading
                                            ? () {
                                                coinflipLogic.startGame(
                                                    context: context,
                                                    status:
                                                        CoinflipStatus.dollar,
                                                    onStart: () {
                                                      if (coinflipLogic
                                                              .randomCoinflipStatus ==
                                                          CoinflipStatus
                                                              .nothing) {
                                                        randAngle = 540;
                                                      } else {
                                                        randAngle = 760;
                                                      }

                                                      _controller
                                                        ..reset()
                                                        ..forward(from: 0);
                                                    });
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          backgroundColor: const Color.fromARGB(
                                              255, 98, 206, 107),
                                          shape: const RoundedRectangleBorder(),
                                        ),
                                        child: Provider.of<Balance>(context,
                                                    listen: true)
                                                .isLoading
                                            ? SizedBox(
                                                width: 30.0,
                                                height: 30.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 5.0,
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                  strokeCap: StrokeCap.round,
                                                ),
                                              )
                                            : Transform.translate(
                                                offset: const Offset(0.0, 1.0),
                                                child: Image.asset(frontCoin,
                                                    width: 38.0,
                                                    height: 38.0,
                                                    opacity: !coinflipLogic
                                                                .isGameOn ||
                                                            _controller
                                                                    .status !=
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
                                        onPressed: !coinflipLogic.isGameOn &&
                                                _controller.status !=
                                                    AnimationStatus.forward &&
                                                !Provider.of<Balance>(context,
                                                        listen: true)
                                                    .isLoading
                                            ? () {
                                                coinflipLogic.startGame(
                                                    context: context,
                                                    status:
                                                        CoinflipStatus.nothing,
                                                    onStart: () {
                                                      if (coinflipLogic
                                                              .randomCoinflipStatus ==
                                                          CoinflipStatus
                                                              .nothing) {
                                                        randAngle = 540;
                                                      } else {
                                                        randAngle = 760;
                                                      }

                                                      _controller
                                                        ..reset()
                                                        ..forward(from: 0);
                                                    });
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          backgroundColor: const Color.fromARGB(
                                              255, 255, 102, 102),
                                          shape: const RoundedRectangleBorder(),
                                        ),
                                        child: Provider.of<Balance>(context,
                                                    listen: true)
                                                .isLoading
                                            ? SizedBox(
                                                width: 30.0,
                                                height: 30.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 5.0,
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                  strokeCap: StrokeCap.round,
                                                ),
                                              )
                                            : Transform.translate(
                                                offset: const Offset(0.0, 1.0),
                                                child: Image.asset(backCoin,
                                                    width: 38.0,
                                                    height: 38.0,
                                                    opacity: !coinflipLogic
                                                                .isGameOn ||
                                                            _controller
                                                                    .status !=
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
                          ],
                        ),
                      ],
                    );
                  },
                ),
                appBar: gameAppBarWidget(
                  context: context,
                  isGameOn: context.watch<CoinflipLogic>().isGameOn,
                  gameName: 'Coinflip',
                ),
                body: Screenshot(
                  controller: screenshotController,
                  child:
                      Consumer<CoinflipLogic>(builder: (ctx, coinflipLogic, _) {
                    return Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          double height = 100 * sin(flipAnimation.value * pi);
                          double rotationAngle = 360.0 * flipAnimation.value;

                          double x =
                              -randAngle * pi / 180 * flipAnimation.value;

                          return SizedBox(
                            height: 200,
                            width: 200,
                            child: Transform(
                              transform: Matrix4.identity()
                                ..rotateX(rotationAngle * pi / 180),
                              child: Transform.translate(
                                offset: Offset(10.0, -height),
                                child: AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 300),
                                  crossFadeState: imageCoin(x)
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  firstChild: Image.asset(frontCoin),
                                  secondChild: Image.asset(backCoin),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
