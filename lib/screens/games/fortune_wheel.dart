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
import 'package:new_mini_casino/fortune_wheel_preferences/board_view.dart';
import 'package:new_mini_casino/fortune_wheel_preferences/model.dart';
import 'package:new_mini_casino/games_logic/fortune_wheel_logic.dart';
import 'package:new_mini_casino/models/text_field_model.dart';
import 'package:provider/provider.dart';

class FortuneWheel extends StatefulWidget {
  const FortuneWheel({super.key});

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.format('10000'));

  @override
  State<FortuneWheel> createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel>
    with SingleTickerProviderStateMixin {
  dynamic wheelResult = 0;

  double _angle = 0;
  double _current = 0;

  late AnimationController _ctrl;
  late Animation _ani;

  final List<Luck> _items = [
    Luck("30x", Colors.green),
    Luck("2x", Colors.blueGrey),
    Luck("3x", Colors.orangeAccent),
    Luck("2x", Colors.blueGrey),
    Luck("5x", Colors.redAccent),
    Luck("2x", Colors.blueGrey),
    Luck("3x", Colors.orangeAccent),
    Luck("2x", Colors.blueGrey),
    Luck("5x", Colors.redAccent),
    Luck("2x", Colors.blueGrey),
    Luck("3x", Colors.orangeAccent),
    Luck("2x", Colors.blueGrey),
    Luck("5x", Colors.redAccent),
    Luck("2x", Colors.blueGrey),
    Luck("3x", Colors.orangeAccent),
    Luck("2x", Colors.blueGrey),
    Luck("5x", Colors.redAccent),
    Luck("2x", Colors.blueGrey),
    Luck("3x", Colors.orangeAccent),
    Luck("2x", Colors.blueGrey),
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
    final balance = Provider.of<Balance>(context, listen: false);
    final fortuneWheelLogic =
        Provider.of<FortuneWheelLogic>(context, listen: false);

    _animation() {
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

    int _calIndex(value) {
      var base = (2 * pi / _items.length / 2) / (2 * pi);
      return (((base + value) % 1) * _items.length).floor();
    }

    _buildResult(value) {
      var index = _calIndex(value * _angle + _current);

      if (!_ctrl.isAnimating) {
        Future.delayed(Duration.zero, () async {
          if (fortuneWheelLogic.isGameOn) {
            if (_items[index].value == '${fortuneWheelLogic.selectedNumber}x') {
              fortuneWheelLogic.cashout();
            } else {
              fortuneWheelLogic.loose();
            }
          }

          /*switch (_items[index].value) {
            case '2x':
              controller.lastColors.add(Colors.blueGrey);
              break;
            case '3x':
              controller.lastColors.add(Colors.orangeAccent);
              break;
            case '5x':
              controller.lastColors.add(Colors.redAccent);
              break;
            case '30x':
              controller.lastColors.add(Colors.green);
              break;
          }*/
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

    selectX(String myX) async {
      if (fortuneWheelLogic.isGameOn) {
        return;
      }

      _animation();
    }

    return WillPopScope(
      onWillPop: () async {
        return !context.read<FortuneWheelLogic>().isGameOn;
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
            height: 182.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
                ]),
            child: Consumer<FortuneWheelLogic>(
              builder: (ctx, fortuneWheelLogic, _) {
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
                                  'Прибыль (${fortuneWheelLogic.selectedNumber}x):',
                                  style: GoogleFonts.roboto(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: AutoSizeText(
                                    fortuneWheelLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(fortuneWheelLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(fortuneWheelLogic.profit),
                                    style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (int index = 0;
                                    index <
                                        fortuneWheelLogic
                                            .buttonsCoefficient.length;
                                    index++)
                                  itemNumber(
                                      number: fortuneWheelLogic
                                          .buttonsCoefficient[index],
                                      fortuneWheelLogic: fortuneWheelLogic)
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: fortuneWheelLogic.isGameOn
                                  ? null
                                  : () {
                                      if (balance.currentBalance <
                                          double.parse(FortuneWheel.betFormatter
                                              .getUnformattedValue()
                                              .toString())) {
                                        return;
                                      }

                                      if (fortuneWheelLogic.selectedNumber ==
                                          0) {
                                        return;
                                      }

                                      _animation();

                                      fortuneWheelLogic.startGame(
                                          context: context,
                                          bet: double.parse(FortuneWheel
                                              .betFormatter
                                              .getUnformattedValue()
                                              .toString()));
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
                  onPressed: context.watch<FortuneWheelLogic>().isGameOn
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
                  'Fortune Wheel',
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
                    onPressed: context.watch<FortuneWheelLogic>().isGameOn
                        ? null
                        : () =>
                            context.beamToNamed('/game-statistic/fortuneWheel'),
                    icon: const FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: Colors.black87,
                      size: 30.0,
                    )),
              ),
            ],
          ),
          body:
              Consumer<FortuneWheelLogic>(builder: (ctx, fortuneWheelLogic, _) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                  child: customTextField(
                      textInputFormatter: FortuneWheel.betFormatter,
                      keyboardType: TextInputType.number,
                      readOnly: fortuneWheelLogic.isGameOn,
                      isBetInput: true,
                      controller: FortuneWheel.betController,
                      hintText: 'Ставка...'),
                ),
                Expanded(
                  child: AnimatedBuilder(
                      animation: _ani,
                      builder: (context, child) {
                        wheelResult = _ani.value;
                        final angle = wheelResult * _angle;
                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            BoardView(
                                items: _items, current: _current, angle: angle),
                            _buildResult(wheelResult)
                          ],
                        );
                      }),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget itemNumber(
      {int number = 1, required FortuneWheelLogic fortuneWheelLogic}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: SizedBox(
          height: 50.0,
          child: Material(
            borderRadius: BorderRadius.circular(15.0),
            clipBehavior: Clip.antiAlias,
            color: Colors.grey.shade200,
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
                    borderRadius: BorderRadius.circular(15.0),
                    border: fortuneWheelLogic.selectedNumber == number
                        ? Border.all(width: 2.5, color: Colors.blueAccent)
                        : null),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        '${number}x',
                        style: GoogleFonts.roboto(
                            color: Colors.black87,
                            fontSize: 25.0,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
