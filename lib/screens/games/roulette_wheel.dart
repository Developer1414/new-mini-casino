import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:confetti/confetti.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/roulette_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/text_field_model.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io' as ui;
import 'dart:ui' as dartUI;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

class RouletteWheel extends StatefulWidget {
  const RouletteWheel({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  State<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends State<RouletteWheel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _ballAnimation;

  double _currentRotationValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _ballAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {
          _currentRotationValue = _animation.value; // Добавлено
        });
      });
  }

  void _startGame() async {
    await _controller.forward(from: 0.0);
    // Выполните дополнительные действия после остановки анимации, например, вычисление
    // цифры, чётности/нечётности и цвета ячейки.
    int stoppedCell = (_currentRotationValue * 37).floor() + 1; // Изменено
    bool isEven = stoppedCell % 2 == 0;
    Color cellColor = stoppedCell == 37
        ? const Color.fromARGB(255, 72, 216, 79)
        : isEven
            ? Colors.black
            : Colors.redAccent;

    print('Stopped at: $stoppedCell');
    print('Is Even: $isEven');
    print('Cell Color: $cellColor');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);
    final fortuneWheelLogic =
        Provider.of<RouletteLogic>(context, listen: false);

    return PopScope(
      canPop: !context.read<RouletteLogic>().isGameOn,
      child: GestureDetector(
        onTap: () {
          if (_controller.isAnimating) {
            _controller.stop();
          } else {
            _startGame();
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
                        Container(
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.lightBlueAccent.withOpacity(0.1),
                            border: Border.all(
                                color: Colors.lightBlueAccent, width: 2.0),
                          ),
                          child: fortuneWheelLogic.lastColors.isEmpty
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
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        List<Color> value = fortuneWheelLogic
                                            .lastColors.reversed
                                            .toList();

                                        return Container(
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
                                      itemCount:
                                          fortuneWheelLogic.lastColors.length),
                                ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 15.0),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  //   child: SizedBox(
                  //       height: 50.0,
                  //       child: Row(
                  //         children: [
                  //           for (int index = 0;
                  //               index <
                  //                   fortuneWheelLogic.buttonsCoefficient.length;
                  //               index++)
                  //             itemNumber(
                  //                 number: fortuneWheelLogic
                  //                     .buttonsCoefficient[index],
                  //                 fortuneWheelLogic: fortuneWheelLogic)
                  //         ],
                  //       )),
                  // ),
                  const SizedBox(height: 15.0),
                  Row(
                    children: [
                      fortuneWheelLogic.isGameOn
                          ? Container()
                          : SizedBox(
                              height: 60.0,
                              width: 80.0,
                              child: ElevatedButton(
                                onPressed: () =>
                                    fortuneWheelLogic.showInputBet(),
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  backgroundColor: const Color(0xFF366ecc),
                                  shape: const RoundedRectangleBorder(),
                                ),
                                child: FaIcon(
                                  fortuneWheelLogic.isShowInputBet
                                      ? FontAwesomeIcons.arrowLeft
                                      : FontAwesomeIcons.keyboard,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                              ),
                            ),
                      Visibility(
                        visible: fortuneWheelLogic.isShowInputBet,
                        child: Expanded(
                          child: SizedBox(
                            height: 60.0,
                            child: customTextField(
                                currencyTextInputFormatter:
                                    RouletteWheel.betFormatter,
                                textInputFormatter: RouletteWheel.betFormatter,
                                keyboardType: TextInputType.number,
                                isBetInput: true,
                                controller: RouletteWheel.betController,
                                context: context,
                                hintText: 'Ставка...'),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !fortuneWheelLogic.isShowInputBet,
                        child: Expanded(
                          child: SizedBox(
                            height: 60.0,
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
                                        if (balance.currentBalance <
                                            double.parse(RouletteWheel
                                                .betFormatter
                                                .getUnformattedValue()
                                                .toString())) {
                                          return;
                                        }

                                        fortuneWheelLogic.startGame(
                                            context: context,
                                            bet: double.parse(RouletteWheel
                                                .betFormatter
                                                .getUnformattedValue()
                                                .toString()));
                                      },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.green,
                                  shape: const RoundedRectangleBorder(),
                                ),
                                child: AutoSizeText(
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
                        ),
                      ),
                    ],
                  ),
                ],
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
                      onPressed: context.watch<RouletteLogic>().isGameOn
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
                      'Roulette',
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
                        onPressed: context.watch<RouletteLogic>().isGameOn
                            ? null
                            : () => context
                                .beamToNamed('/game-statistic/rouletteWheel'),
                        icon: FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                ],
              ),
              body: Screenshot(
                  controller: screenshotController,
                  child: Center(
                      child: GestureDetector(
                    onTap: () {
                      // if (_controller.isAnimating) {
                      //   _controller.stop();
                      // } else {
                      //   _controller.forward(from: 0.0);
                      // }
                    },
                    child: GameWidget(game: MyGame()),

                    // SizedBox(
                    //   width: 300.0,
                    //   height: 300.0,
                    //   child: AnimatedBuilder(
                    //     animation: _animation,
                    //     builder: (context, child) {
                    //       return CustomPaint(
                    //         painter: RoulettePainter(
                    //           rotation: _animation.value * 8 * pi,
                    //           ballAnimation: _ballAnimation,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                  ))),
            ),
            ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive)
          ],
        ),
      ),
    );
  }
}

class MyGame extends FlameGame with HasGameRef {
  static MyGame? instance;

  double screenWidth = 0.0;
  double screenHeight = 0.0;

  MyGame() {
    instance = this;
  }

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    screenWidth = gameRef.size.x;
    screenHeight = gameRef.size.y;

    add(RouletteBoard(
        Vector2(screenWidth / 6, screenHeight / 6), 150.0, 120.0, 37));
  }
}

class RouletteBoard extends PositionComponent {
  double outerRadius;
  double innerRadius;
  int segmentCount;

  RouletteBoard(
      Vector2 position, this.outerRadius, this.innerRadius, this.segmentCount)
      : super(position: position, anchor: Anchor.center) {
    createBoard();
  }

  void createBoard() {
    double segmentAngle = 2 * pi / segmentCount;

    for (int i = 0; i < segmentCount; i++) {
      double startAngle = i * segmentAngle;
      double endAngle = (i + 1) * segmentAngle;

      // Create a colored segment with an inner circle
      Color segmentColor =
          i == 0 ? Colors.green : (i.isEven ? Colors.black : Colors.red);

      // Adjust the innerRadius to control the size of the inner circle
      double adjustedInnerRadius = innerRadius;

      add(RouletteSegment(position.x, position.y, outerRadius,
          adjustedInnerRadius, startAngle, endAngle, segmentColor));
    }
  }
}

class RouletteSegment extends PositionComponent {
  double outerRadius;
  double innerRadius;
  double startAngle;
  double endAngle;
  Color segmentColor;

  RouletteSegment(double centerX, double centerY, this.outerRadius,
      this.innerRadius, this.startAngle, this.endAngle, this.segmentColor)
      : super(position: Vector2(centerX, centerY), anchor: Anchor.center);

  @override
  void render(Canvas c) {
    Paint paint = Paint()..color = segmentColor;
    c.drawArc(Rect.fromCircle(center: position.toOffset(), radius: outerRadius),
        startAngle, endAngle - startAngle, true, paint);

    // Draw the inner circle
    Paint innerCirclePaint = Paint()
      ..color = Colors.white; // You can adjust the color
    c.drawCircle(position.toOffset(), innerRadius, innerCirclePaint);

    // Draw borders between segments
    Paint borderPaint = Paint()..color = Colors.grey;
    c.drawLine(
        position.toOffset(),
        position.toOffset() +
            Offset(
                outerRadius * cos(startAngle), outerRadius * sin(startAngle)),
        borderPaint);
  }
}
