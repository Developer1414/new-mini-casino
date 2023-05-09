import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/crash_logic.dart';
import 'package:new_mini_casino/models/text_field_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Crash extends StatefulWidget {
  const Crash({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

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
    final balance = Provider.of<Balance>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        return !context.read<CrashLogic>().isGameOn;
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
            child: Consumer<CrashLogic>(
              builder: (ctx, crashLogic, _) {
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
                                  'Прибыль (${crashLogic.winCoefficient.toStringAsFixed(2)}x):',
                                  style: GoogleFonts.roboto(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: AutoSizeText(
                                    crashLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(crashLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(crashLogic.profit),
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
                              onPressed: () {
                                if (!crashLogic.isGameOn) {
                                  if (balance.currentBalance <
                                      double.parse(Crash.betFormatter
                                          .getUnformattedValue()
                                          .toStringAsFixed(2))) {
                                    return;
                                  }

                                  if (Crash.targetCoefficient.text.isEmpty ||
                                      double.parse(Crash.targetCoefficient.text)
                                          .isNegative ||
                                      double.parse(
                                              Crash.targetCoefficient.text) <
                                          1) {
                                    return;
                                  }

                                  crashLogic.startGame(
                                      context: context,
                                      targetCoefficient: double.parse(
                                          Crash.targetCoefficient.text),
                                      bet: double.parse(Crash.betFormatter
                                          .getUnformattedValue()
                                          .toString()));
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
                                elevation: 5,
                                backgroundColor: crashLogic.timer.isActive &&
                                        crashLogic.crashStatus ==
                                            CrashStatus.win
                                    ? Colors.redAccent
                                    : crashLogic.isGameOn &&
                                            crashLogic.timer.isActive
                                        ? Colors.blueAccent
                                        : Colors.green,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25.0),
                                      topRight: Radius.circular(25.0)),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: AutoSizeText(
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
                  onPressed: context.watch<CrashLogic>().isGameOn
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
                  'Crash',
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
                    onPressed: context.watch<CrashLogic>().isGameOn
                        ? null
                        : () => context.beamToNamed('/game-statistic/crash'),
                    icon: const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.black87,
                      size: 30.0,
                    )),
              ),
            ],
          ),
          body: Consumer<CrashLogic>(
            builder: (ctx, crashLogic, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: customTextField(
                              currencyTextInputFormatter: Crash.betFormatter,
                              textInputFormatter: Crash.betFormatter,
                              keyboardType: TextInputType.number,
                              readOnly: crashLogic.isGameOn,
                              isBetInput: true,
                              controller: Crash.betController,
                              context: context,
                              hintText: 'Ставка...'),
                        ),
                        const SizedBox(width: 15.0),
                        Expanded(
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
                            decoration: InputDecoration(
                                hintText: 'Коэффициент...',
                                hintStyle: GoogleFonts.roboto(
                                    color: Colors.black87.withOpacity(0.5),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15.0)),
                                    borderSide: BorderSide(
                                        width: 2.5,
                                        color:
                                            Colors.black87.withOpacity(0.3))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15.0)),
                                    borderSide: BorderSide(
                                        width: 2.5,
                                        color:
                                            Colors.black87.withOpacity(0.5)))),
                            style: GoogleFonts.roboto(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            shadows: [
                              Shadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 15.0)
                            ],
                            color: crashLogic.crashStatus == CrashStatus.win
                                ? Colors.green
                                : crashLogic.crashStatus == CrashStatus.loss
                                    ? Colors.redAccent
                                    : Colors.black87,
                            fontSize: 60.0,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  )),
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
                    child: crashLogic.lastCoefficients.isEmpty
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
                              List<CrashRound> value = crashLogic
                                  .lastCoefficients
                                  
                                  .reversed
                                  .toList();

                              return Container(
                                margin: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 5.0,
                                    left: index == 0 ? 5.0 : 0.0,
                                    right: index + 1 ==
                                            crashLogic.lastCoefficients.length
                                        ? 5.0
                                        : 0.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: value[index].isWin
                                        ? Colors.green
                                        : Colors.redAccent),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AutoSizeText(
                                      '${value[index].coefficient}x',
                                      style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 5.0),
                            itemCount: crashLogic.lastCoefficients.length),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget mathButton(String buttonTitle, String mathOperator) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: () {
          if (mathOperator == '/') {
            double n = (double.parse(
                        Crash.betFormatter.getUnformattedValue().toString()) /
                    2) *
                10;
            Crash.betController.text = Crash.betFormatter.format(n.toString());
          } else if (mathOperator == '*') {
            Crash.betController.text = Crash.betFormatter.format((double.parse(
                        (Crash.betFormatter.getUnformattedValue() * 10)
                            .toString()) *
                    2)
                .toString());
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Center(
          child: AutoSizeText(
            buttonTitle,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.w700),
          ),
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
    Paint paint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    Path path = Path();
    final double x = size.width * value;
    final double y = size.height * (1 - value);

    path.moveTo(0, size.height);
    path.lineTo(x, y);
    path.lineTo(x, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    path = Path();
    path.moveTo(0, size.height);
    path.lineTo(x, y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MyLinePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}