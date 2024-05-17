import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/roulette_wheel_preferences/model.dart';
import 'package:new_mini_casino/games_logic/roulette_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:new_mini_casino/widgets/last_bets_widget.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io' as ui;

class RouletteWheel extends StatefulWidget {
  const RouletteWheel({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter.currency(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.formatString('10000'));

  @override
  State<RouletteWheel> createState() => _RouletteWheelState();
}

class _RouletteWheelState extends State<RouletteWheel>
    with TickerProviderStateMixin {
  dynamic wheelResult = 0;

  double _angle = 0;
  double _current = 0;

  static double currentPlusAngle = 0;
  static double currentAngle = 0;
  static double currentBallAngle = 0;

  late AnimationController _ctrl;
  late Animation _ani;

  late Animation<double> ballAnimation;
  late AnimationController ballAnimationController;

  int currentNumberIndex = 0;

  static Color redColor = const Color(0xffeb2826);
  static Color blackColor = const Color(0xff1e1621);
  static Color greenColor = const Color(0xff009647);

  List<int> resultNumbers = [];
  static List<int> winnerNumbers = [];

  List<int> numbers = [
    0,
    32,
    15,
    19,
    4,
    21,
    2,
    25,
    17,
    34,
    6,
    27,
    13,
    36,
    11,
    30,
    8,
    23,
    10,
    5,
    24,
    16,
    33,
    1,
    20,
    14,
    31,
    9,
    22,
    18,
    29,
    7,
    28,
    12,
    35,
    3,
    26
  ];

  final List<RouletteLuck> _items = List<RouletteLuck>.generate(
      37,
      (index) => RouletteLuck(
          index.toString(),
          index == 0
              ? greenColor
              : index.isEven
                  ? blackColor
                  : redColor));

  double generateDouble(double minValue, double maxValue) {
    return minValue + (maxValue - minValue) * Random.secure().nextDouble();
  }

  void initializeBallAnimation() {
    const duration = Duration(milliseconds: 8000);
    final controller = AnimationController(duration: duration, vsync: this);

    final animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: controller, curve: Curves.fastEaseInToSlowEaseOut),
    );

    ballAnimation = animation;
    ballAnimationController = controller;
  }

  int calIndexTop(value) {
    var base = (2 * pi / _items.length / 2) / (2 * pi);
    return (((base + value) % 1) * _items.length).floor();
  }

  void changeResultNumbers(int number) {
    resultNumbers.clear();

    int index = numbers.indexWhere((element) => element == number);

    for (int i = index; i < numbers.length; i++) {
      resultNumbers.add(numbers[i]);
    }

    if (number != 0) {
      for (int i = 0; i < index; i++) {
        resultNumbers.add(numbers[i]);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    resultNumbers = List<int>.from(numbers);

    for (int i = 0; i < numbers.length; i++) {
      _items[i].value = numbers[i].toString();
    }

    var duration = const Duration(milliseconds: 8000);
    _ctrl = AnimationController(vsync: this, duration: duration);
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);

    initializeBallAnimation();

    final rouletteLogic = Provider.of<RouletteLogic>(context, listen: false);

    _ctrl.addListener(() {
      if (_ctrl.isAnimating) {
        changeResultNumbers(int.parse(
            _items[calIndexTop(_ani.value * _angle + _current)].value));
      }

      if (_ctrl.isCompleted) {
        rouletteLogic.setNewCoefficient(
            coefficient: resultNumbers[currentNumberIndex],
            color: _items
                .where((element) =>
                    element.value ==
                    resultNumbers[currentNumberIndex].toString())
                .first
                .color);

        rouletteLogic.checkResultNumber(resultNumbers[currentNumberIndex]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fortuneWheelLogic =
        Provider.of<RouletteLogic>(context, listen: false);

    animation() {
      if (!_ctrl.isAnimating) {
        var random = Random().nextDouble();
        _angle = _items.length + Random().nextInt(1) + random;
        _ctrl.forward(from: 0.0).then((_) {
          _current = (_current + random);
          _current = _current - _current ~/ 1;
          _ctrl.reset();
        });
      }
    }

    Widget buildResult() {
      Widget line(double angle) {
        return Transform.rotate(
          angle: angle,
          child: const SizedBox(
            width: 170,
            child: Divider(
              thickness: 2.5,
              color: Color(0xffa49458),
            ),
          ),
        );
      }

      return Material(
        color: const Color(0xffd5c69d),
        shape: const CircleBorder(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            line(1 * (2 * pi / 8)),
            line(2 * (2 * pi / 8)),
            line(3 * (2 * pi / 8)),
            line(4 * (2 * pi / 8)),
            SizedBox(
              height: 170,
              width: 170,
              child: Center(
                child: Transform.rotate(
                  angle: currentPlusAngle,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            spreadRadius: -30.0,
                            blurRadius: 20,
                            color: Color.fromARGB(95, 0, 0, 0))
                      ],
                    ),
                    child: Image.asset(
                      'assets/roulette/Roulette.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return PopScope(
      canPop: !context.read<RouletteLogic>().isGameOn,
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
                          borderRadius: BorderRadius.circular(12.0),
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                List<RouletteRound> value = fortuneWheelLogic
                                    .lastColors.reversed
                                    .toList();

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 25.0,
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
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: value[index].color),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: AutoSizeText(
                                        value[index].coefficient.toString(),
                                        style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 5.0),
                              itemCount: fortuneWheelLogic.lastColors.length),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      gameBetCount(
                        context: context,
                        gameLogic: fortuneWheelLogic,
                        bet: fortuneWheelLogic.bet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                Row(
                  children: [
                    Expanded(
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
                                    fortuneWheelLogic.startGame(
                                        context: context, bet: 100.0);
                                    animation();

                                    initializeBallAnimation();

                                    setState(() {
                                      winnerNumbers.clear();
                                    });

                                    ballAnimationController.forward();
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
                  ],
                ),
              ],
            ),
            appBar: gameAppBarWidget(
              context: context,
              isGameOn: context.watch<RouletteLogic>().isGameOn,
              gameName: 'Roulette',
            ),
            body: Screenshot(
              controller: screenshotController,
              child: Center(
                child: AnimatedBuilder(
                    animation: _ani,
                    builder: (context, child) {
                      wheelResult = _ani.value;
                      currentAngle = wheelResult * _angle;
                      currentPlusAngle = (_current + currentAngle) >= 1
                          ? (_current + currentAngle)
                          : currentPlusAngle;
                      return Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                height: size.height * 1.18,
                                width: size.width * 1.18,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 20,
                                          color: Color.fromARGB(95, 0, 0, 0))
                                    ]),
                              ),
                              Container(
                                height: size.height * 1.2,
                                width: size.width * 1.2,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff1e471f)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                        blurRadius: 20,
                                        color: Color.fromARGB(95, 0, 0, 0))
                                  ],
                                  border: Border.all(
                                      width: 12.0,
                                      color: const Color(0xffa78641)),
                                  shape: BoxShape.circle,
                                ),
                                child: Transform.rotate(
                                  angle: -(_current + currentAngle) * 2 * pi,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      for (var luck in _items) ...[
                                        _buildCard(luck)
                                      ],
                                      for (var luck in _items) ...[
                                        _buildImage(luck)
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: size.height * 0.69,
                                width: size.width * 0.69,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2.0,
                                      color: const Color(0xffa49458)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                height: size.height * 0.83,
                                width: size.width * 0.83,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2.0,
                                      color: const Color(0xffa49458)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              ball(),
                            ],
                          ),
                          buildResult(),
                        ],
                      );
                    }),
              ),
            ),
          ),
          ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive)
        ],
      ),
    );
  }

  int calculateBallIndex(double angle) {
    final base = (2 * pi / _items.length / 2) / (2 * pi);
    return (((base + angle / (2 * pi)) % 1) * _items.length).floor();
  }

  Size get size => Size(MediaQuery.of(context).size.width * 0.7,
      MediaQuery.of(context).size.width * 0.7);

  double _rotote(int index) => (index / _items.length) * 2 * pi;

  double randomInitialAngle() {
    return Random().nextDouble() * 2 * pi;
  }

  Widget ball() {
    return AnimatedBuilder(
      animation: _ani,
      builder: (context, child) {
        double angle = 0.0;

        if (winnerNumbers.length < 200) {
          currentBallAngle = currentPlusAngle * 2 * pi;
          angle = currentBallAngle;

          currentNumberIndex = calculateBallIndex(angle);
        } else {
          angle = currentBallAngle +
              (-currentPlusAngle * 2 * pi + currentBallAngle);
        }

        // currentBallAngle = currentPlusAngle * 2 * pi +
        //     (!ballAnimation.isCompleted ? 0.0 : (-(_current + currentAngle) * 2 * pi));
        // angle = currentBallAngle;

        currentNumberIndex = calculateBallIndex(angle);

        final radius = MediaQuery.of(context).size.width / 3.8;
        final x = radius * cos(angle - pi / 2);
        final y = radius * sin(angle - pi / 2);

        return Transform.translate(
          offset: Offset(x, y),
          child: child,
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.width * 0.03, // 12
        width: MediaQuery.of(context).size.width * 0.03, // 12
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  _buildCard(RouletteLuck luck) {
    // if (winnerNumbers.length < 238) {
    //   if (winnerNumbers.isNotEmpty) {
    //     if (winnerNumbers.last != resultNumbers[currentNumberIndex]) {
    //       winnerNumbers.add(resultNumbers[currentNumberIndex]);
    //     }
    //   } else {
    //     winnerNumbers.add(resultNumbers[currentNumberIndex]);
    //   }

    //   winnerNumbers.add(resultNumbers[currentNumberIndex]);
    //   print('${winnerNumbers.length}: ${winnerNumbers.last}');
    // } else {
    //   //ballAnimationController.stop();
    // }

    if (winnerNumbers.isNotEmpty) {
      if (winnerNumbers.last != resultNumbers[currentNumberIndex]) {
        winnerNumbers.add(resultNumbers[currentNumberIndex]);
      }
    } else {
      winnerNumbers.add(resultNumbers[currentNumberIndex]);
    }
    print('${winnerNumbers.length}: ${winnerNumbers.last}');

    final rotate = _rotote(_items.indexOf(luck));
    final angle = 2 * pi / _items.length;
    return Transform.rotate(
      angle: rotate,
      child: ClipPath(
        clipper: _LuckPath(angle),
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: resultNumbers[currentNumberIndex].toString() == luck.value
                ? [Colors.blueGrey, Colors.blueGrey]
                :
                // winnerNumbers.contains(int.parse(luck.value))
                //         ? [Colors.grey, Colors.grey]
                //         :
                [luck.color, luck.color.withOpacity(0)],
          )),
        ),
      ),
    );
  }

  _buildImage(RouletteLuck luck) {
    final rotate = _rotote(_items.indexOf(luck));
    return Transform.rotate(
      angle: rotate,
      child: Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints:
              BoxConstraints.expand(height: size.height / 12, width: 34),
          child: Center(
            child: RotatedBox(
              quarterTurns: 4,
              child: Text(
                luck.value,
                style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LuckPath extends CustomClipper<Path> {
  final double angle;

  _LuckPath(this.angle);

  @override
  Path getClip(Size size) {
    Path path = Path();
    Offset center = size.center(Offset.zero);
    Rect rect = Rect.fromCircle(center: center, radius: size.width / 2);
    path.moveTo(center.dx, center.dy);
    path.arcTo(rect, -pi / 2 - angle / 2, angle, false);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_LuckPath oldClipper) {
    return angle != oldClipper.angle;
  }
}
