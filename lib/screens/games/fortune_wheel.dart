import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/fortune_wheel_preferences/board_view.dart';
import 'package:new_mini_casino/fortune_wheel_preferences/model.dart';
import 'package:new_mini_casino/games_logic/fortune_wheel_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:new_mini_casino/widgets/last_bets_widget.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class FortuneWheel extends StatefulWidget {
  const FortuneWheel({super.key});

  @override
  State<FortuneWheel> createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel>
    with SingleTickerProviderStateMixin {
  bool isSimplifiedView = false;

  dynamic wheelResult = 0;
  double _angle = 0;
  double _current = 0;

  late AnimationController _ctrl;
  late Animation _ani;

  static Color maxWinColor = const Color(0xffff595e);
  static Color aroundMaxWinColor = const Color(0xffffca3a);
  static Color middleWinColor = const Color(0xff8ac926);
  static Color smallWinColor = const Color(0xff1982c4);

  final List<Luck> _items = [
    Luck("30x", maxWinColor),
    Luck("2x", smallWinColor),
    Luck("3x", middleWinColor),
    Luck("2x", smallWinColor),
    Luck("5x", aroundMaxWinColor),
    Luck("2x", smallWinColor),
    Luck("3x", middleWinColor),
    Luck("2x", smallWinColor),
    Luck("5x", aroundMaxWinColor),
    Luck("2x", smallWinColor),
    Luck("3x", middleWinColor),
    Luck("2x", smallWinColor),
    Luck("5x", aroundMaxWinColor),
    Luck("2x", smallWinColor),
    Luck("3x", middleWinColor),
    Luck("2x", smallWinColor),
    Luck("5x", aroundMaxWinColor),
    Luck("2x", smallWinColor),
    Luck("3x", middleWinColor),
    Luck("2x", smallWinColor),
  ];

  @override
  void initState() {
    super.initState();
    var duration = const Duration(milliseconds: 5000);
    _ctrl = AnimationController(vsync: this, duration: duration);
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);
  }

  @override
  Widget build(BuildContext context) {
    final fortuneWheelLogic =
        Provider.of<FortuneWheelLogic>(context, listen: false);

    animation() {
      if (!_ctrl.isAnimating) {
        var random = Random().nextDouble();
        _angle = 20 + Random().nextInt(5) + random;
        _ctrl.forward(from: 0.0).then((_) {
          _current = (_current + random);
          _current = _current - _current ~/ 1;
          _ctrl.reset();
        });
      }
    }

    int calIndex(value) {
      var base = (2 * pi / _items.length / 2) / (2 * pi);
      return (((base + value) % 1) * _items.length).floor();
    }

    buildResult(value) {
      var index = calIndex(value * _angle + _current);

      if (!_ctrl.isAnimating) {
        Future.delayed(Duration.zero, () async {
          if (fortuneWheelLogic.isGameOn) {
            if (_items[index].value == '${fortuneWheelLogic.selectedNumber}x') {
              fortuneWheelLogic.cashout();
            } else {
              fortuneWheelLogic.loose();
            }

            switch (_items[index].value) {
              case '2x':
                fortuneWheelLogic.setNewColor(smallWinColor);
                break;
              case '3x':
                fortuneWheelLogic.setNewColor(middleWinColor);
                break;
              case '5x':
                fortuneWheelLogic.setNewColor(aroundMaxWinColor);
                break;
              case '30x':
                fortuneWheelLogic.setNewColor(maxWinColor);
                break;
            }
          }
        });
      }

      return Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: SizedBox(
          height: 72,
          width: 72,
          child: Center(
            child: Text(
              _items[index].value,
              style: GoogleFonts.roboto(
                  fontSize: 22,
                  color: Colors.black87,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: !context.read<FortuneWheelLogic>().isGameOn,
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
              bottomNavigationBar: Column(
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
                                'Прибыль (${fortuneWheelLogic.selectedNumber}x):',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 12.0)),
                            AutoSizeText(
                                fortuneWheelLogic.profit < 1000000
                                    ? NumberFormat.simpleCurrency(
                                            locale: ui.Platform.localeName)
                                        .format(fortuneWheelLogic.profit)
                                    : NumberFormat.compactSimpleCurrency(
                                            locale: ui.Platform.localeName)
                                        .format(fortuneWheelLogic.profit),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 12.0)),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        lastBetsWidget(
                          context: context,
                          list: fortuneWheelLogic.lastColors,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  List<Color> value = fortuneWheelLogic
                                      .lastColors.reversed
                                      .toList();

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 15.0,
                                    margin: EdgeInsets.only(
                                        top: 5.0,
                                        bottom: 5.0,
                                        left: index == 0 ? 5.0 : 0.0,
                                        right: index + 1 ==
                                                fortuneWheelLogic
                                                    .lastColors.length
                                            ? 5.0
                                            : 0.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: value[index]),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 5.0),
                                itemCount: fortuneWheelLogic.lastColors.length),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                        height: 50.0,
                        child: Row(
                          children: [
                            for (int index = 0;
                                index <
                                    fortuneWheelLogic.buttonsCoefficient.length;
                                index++)
                              itemNumber(
                                  number: fortuneWheelLogic
                                      .buttonsCoefficient[index],
                                  fortuneWheelLogic: fortuneWheelLogic)
                          ],
                        )),
                  ),
                  const SizedBox(height: 15.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: gameBetCount(
                      context: context,
                      gameLogic: fortuneWheelLogic,
                      bet: fortuneWheelLogic.bet,
                    ),
                  ),
                  const SizedBox(height: 15.0),
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
                        onPressed: fortuneWheelLogic.isGameOn
                            ? null
                            : () {
                                if (fortuneWheelLogic.selectedNumber == 0) {
                                  return;
                                }

                                if (Provider.of<Balance>(context, listen: false)
                                    .isLoading) {
                                  return;
                                }

                                fortuneWheelLogic.startGame(
                                    context: context,
                                    callback: () {
                                      animation();
                                    });
                              },
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
                                    color: !fortuneWheelLogic.isGameOn
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              appBar: gameAppBarWidget(
                context: context,
                isGameOn: context.watch<FortuneWheelLogic>().isGameOn,
                gameName: 'Fortune Wheel',
                actions: [
                  IconButton(
                      splashRadius: 25.0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          isSimplifiedView = !isSimplifiedView;
                        });
                      },
                      icon: FaIcon(
                        isSimplifiedView
                            ? FontAwesomeIcons.magnifyingGlassMinus
                            : FontAwesomeIcons.magnifyingGlassPlus,
                        color: Theme.of(context).appBarTheme.iconTheme!.color,
                        size: Theme.of(context).appBarTheme.iconTheme!.size,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: () => fortuneWheelLogic.isGameOn
                            ? null
                            : Navigator.of(context).pushNamed('/game-statistic',
                                arguments: 'fortune-wheel'),
                        icon: FaIcon(
                          FontAwesomeIcons.chartSimple,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                ],
              ),
              body: Screenshot(
                controller: screenshotController,
                child: Center(
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(80.0),
                    child: Transform.rotate(
                      angle: !isSimplifiedView ? 0.0 : -360 / pi,
                      child: Transform.translate(
                        offset: Offset(0, !isSimplifiedView ? 0.0 : 200),
                        child: Transform.scale(
                          scale: !isSimplifiedView ? 1.0 : 2.5,
                          child: AnimatedBuilder(
                              animation: _ani,
                              builder: (context, child) {
                                wheelResult = _ani.value;
                                final angle = wheelResult * _angle;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    BoardView(
                                        items: _items,
                                        current: _current,
                                        angle: angle),
                                    buildResult(wheelResult)
                                  ],
                                );
                              }),
                        ),
                      ),
                    ),
                  ),
                ),
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

  Widget itemNumber(
      {int number = 1, required FortuneWheelLogic fortuneWheelLogic}) {
    Color currentColor = number == 2
        ? smallWinColor
        : number == 3
            ? middleWinColor
            : number == 5
                ? aroundMaxWinColor
                : number == 30
                    ? maxWinColor
                    : Colors.white;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Material(
          borderRadius: BorderRadius.circular(12.0),
          clipBehavior: Clip.antiAlias,
          color: fortuneWheelLogic.selectedNumber != number
              ? currentColor.withOpacity(0.4)
              : currentColor,
          child: InkWell(
            onTap: () {
              if (!fortuneWheelLogic.isGameOn) {
                if (fortuneWheelLogic.selectedNumber == number) {
                  fortuneWheelLogic.unSelectNumber();
                } else {
                  fortuneWheelLogic.selectNumber(number: number);
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: fortuneWheelLogic.selectedNumber == number
                      ? Border.all(
                          width: 2.5,
                          color: fortuneWheelLogic.selectedNumber != number
                              ? Colors.transparent
                              : lighten(currentColor, 0.2),
                        )
                      : null),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      '${number}x',
                      maxLines: 1,
                      style: GoogleFonts.roboto(
                          color: fortuneWheelLogic.selectedNumber == number
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
