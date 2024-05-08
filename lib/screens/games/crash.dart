import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/crash_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:screenshot/screenshot.dart';

class Crash extends StatefulWidget {
  const Crash({super.key});

  static TextEditingController targetCoefficient =
      TextEditingController(text: '2.0');

  @override
  State<Crash> createState() => _CrashState();
}

class _CrashState extends State<Crash> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    final crashLogic = Provider.of<CrashLogic>(context, listen: false);

    crashLogic.animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _animationController = crashLogic.animationController;

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !context.read<CrashLogic>().isGameOn,
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
              bottomNavigationBar: Consumer<CrashLogic>(
                builder: (context, crashLogic, child) {
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
                                AutoSizeText('Прибыль:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                AutoSizeText(
                                    crashLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(crashLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(crashLogic.profit),
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
                              child: crashLogic.lastCoefficients.isEmpty
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
                                            List<CrashRound> value = crashLogic
                                                .lastCoefficients.reversed
                                                .toList();

                                            return Container(
                                              margin: EdgeInsets.only(
                                                  top: 5.0,
                                                  bottom: 5.0,
                                                  left: index == 0 ? 5.0 : 0.0,
                                                  right: index + 1 ==
                                                          crashLogic
                                                              .lastCoefficients
                                                              .length
                                                      ? 5.0
                                                      : 0.0),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: value[index].isWin
                                                      ? Colors.green
                                                      : Colors.redAccent),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5.0),
                                                  child: AutoSizeText(
                                                    '${value[index].coefficient}x',
                                                    style: GoogleFonts.roboto(
                                                        color: Colors.white,
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(width: 5.0),
                                          itemCount: crashLogic
                                              .lastCoefficients.length),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: SizedBox(
                          height: 50.0,
                          child: TextField(
                            controller: Crash.targetCoefficient,
                            readOnly: crashLogic.isGameOn,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onTap: () {
                              Crash.targetCoefficient.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      Crash.targetCoefficient.text.length);
                            },
                            onSubmitted: (value) {
                              if (double.parse(value) < 1.1) {
                                Crash.targetCoefficient.text = '1.1';
                              }
                            },
                            decoration: InputDecoration(
                                suffix: Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: Text(
                                    'X',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(fontSize: 20.0),
                                  ),
                                ),
                                hintText: 'Целевой коэффициент...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color!
                                            .withOpacity(0.5)),
                                enabledBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .enabledBorder,
                                focusedBorder: Theme.of(context)
                                    .inputDecorationTheme
                                    .focusedBorder),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(fontSize: 20.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: gameBetCount(
                          context: context,
                          gameLogic: crashLogic,
                          bet: crashLogic.bet,
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
                            onPressed: () {
                              if (!crashLogic.isGameOn) {
                                if (Crash.targetCoefficient.text.isEmpty ||
                                    double.parse(Crash.targetCoefficient.text)
                                        .isNegative ||
                                    double.parse(Crash.targetCoefficient.text) <
                                        1) {
                                  return;
                                }

                                if (double.parse(Crash.targetCoefficient.text) <
                                    1.1) {
                                  alertDialogError(
                                    context: context,
                                    title: 'Ошибка',
                                    text: 'Минимальный коэффициент: 1.1',
                                    confirmBtnText: 'Окей',
                                  );

                                  return;
                                }

                                if (Provider.of<Balance>(context, listen: false)
                                    .isLoading) {
                                  return;
                                }

                                crashLogic.startGame(
                                    context: context,
                                    targetCoefficient: double.parse(
                                        Crash.targetCoefficient.text));
                              } else {
                                if (crashLogic.crashStatus ==
                                    CrashStatus.idle) {
                                  crashLogic.cashout();
                                } else if (crashLogic.crashStatus ==
                                    CrashStatus.win) {
                                  crashLogic.stop();
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: crashLogic.timer.isActive &&
                                      crashLogic.crashStatus == CrashStatus.win
                                  ? Colors.redAccent
                                  : crashLogic.isGameOn &&
                                          crashLogic.timer.isActive
                                      ? Colors.blueAccent
                                      : Colors.green,
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
                                    crashLogic.timer.isActive &&
                                            crashLogic.crashStatus ==
                                                CrashStatus.win
                                        ? 'СТОП'
                                        : crashLogic.isGameOn &&
                                                crashLogic.timer.isActive
                                            ? 'ЗАБРАТЬ'
                                            : 'СТАВКА',
                                    maxLines: 1,
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
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
                      onPressed: context.watch<CrashLogic>().isGameOn
                          ? null
                          : () {
                              Navigator.of(context).pop();
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
                      'Crash',
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
                        onPressed: context.watch<CrashLogic>().isGameOn
                            ? null
                            : () => Navigator.of(context).pushNamed(
                                '/game-statistic',
                                arguments: 'crash'),
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
                child: Consumer<CrashLogic>(
                  builder: (ctx, crashLogic, _) {
                    return Column(
                      children: [
                        Expanded(
                            child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0, top: 15.0),
                                child: CustomPaint(
                                  painter: MyLinePainter(_animation.value),
                                  size: Size.infinite,
                                )),
                            AutoSizeText(
                              '${crashLogic.winCoefficient.toStringAsFixed(2)}x',
                              style: GoogleFonts.roboto(
                                  color:
                                      crashLogic.crashStatus == CrashStatus.win
                                          ? Colors.green
                                          : crashLogic.crashStatus ==
                                                  CrashStatus.loss
                                              ? Colors.redAccent
                                              : Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .color,
                                  fontSize: 60.0,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        )),
                      ],
                    );
                  },
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
}

class MyLinePainter extends CustomPainter {
  final double value;

  MyLinePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    final Paint paintShadow = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    final double maxLineLength = size.width * 1.8;
    final double lineLength = maxLineLength * value;
    final double angle = value * (pi / 3.2);
    final double dx = lineLength * cos(angle);
    final double dy = lineLength * sin(angle);

    final double controlX = dx / 2;

    final Paint fillPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final Path fillPath = Path();
    fillPath.moveTo(0, size.height);
    fillPath.quadraticBezierTo(
        controlX, size.height, dx, size.height - dy / 1.45);
    fillPath.lineTo(dx, size.height);
    fillPath.lineTo(0, size.height);

    canvas.drawPath(fillPath, fillPaint);

    path.moveTo(0, size.height);
    path.quadraticBezierTo(controlX, size.height, dx, size.height - dy / 1.45);

    canvas.drawPath(path, paintShadow);
    canvas.drawPath(path, paint);

    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dx, size.height - dy / 1.45), 10.0, circlePaint);
  }

  @override
  bool shouldRepaint(MyLinePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
