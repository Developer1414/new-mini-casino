import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/fortune_wheel_preferences/board_view.dart';
import 'package:new_mini_casino/fortune_wheel_preferences/model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:provider/provider.dart';

class DailyBonus extends StatefulWidget {
  const DailyBonus({super.key});

  @override
  State<DailyBonus> createState() => _DailyBonusState();
}

class _DailyBonusState extends State<DailyBonus>
    with SingleTickerProviderStateMixin {
  dynamic wheelResult = 0;

  double _angle = 0;
  double _current = 0;

  double currentBonus = 0.0;

  late AnimationController _ctrl;
  late Animation _ani;

  final List<Luck> _items = [
    Luck("50000", Colors.green),
    Luck("500", Colors.blueGrey),
    Luck("2000", Colors.orangeAccent),
    Luck("500", Colors.blueGrey),
    Luck("10000", Colors.redAccent),
    Luck("500", Colors.blueGrey),
    Luck("2000", Colors.orangeAccent),
    Luck("500", Colors.blueGrey),
    Luck("10000", Colors.redAccent),
    Luck("500", Colors.blueGrey),
    Luck("2000", Colors.orangeAccent),
    Luck("500", Colors.blueGrey),
    Luck("10000", Colors.redAccent),
    Luck("500", Colors.blueGrey),
    Luck("2000", Colors.orangeAccent),
    Luck("500", Colors.blueGrey),
    Luck("10000", Colors.redAccent),
    Luck("500", Colors.blueGrey),
    Luck("2000", Colors.orangeAccent),
    Luck("500", Colors.blueGrey),
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
    final dailyBonusManager =
        Provider.of<DailyBonusManager>(context, listen: false);

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
          if (dailyBonusManager.isActiveFortuneWheel) {
            dailyBonusManager.spin(false);
            currentBonus = double.parse(_items[index].value);
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
      canPop: false,
      child: Consumer<DailyBonusManager>(builder: (context, value, child) {
        return value.isLoading
            ? loading(context: context)
            : Scaffold(
                bottomNavigationBar: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
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
                              onPressed:
                                  dailyBonusManager.isActiveFortuneWheel ||
                                          !dailyBonusManager.isCanSpinAgain
                                      ? null
                                      : () => dailyBonusManager.spinAgain(
                                          context: context,
                                          voidCallback: () {
                                            _animation();
                                            dailyBonusManager.spin(true);
                                          }),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.redAccent,
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.rectangleAd,
                                    color: dailyBonusManager
                                                .isActiveFortuneWheel ||
                                            !dailyBonusManager.isCanSpinAgain
                                        ? Colors.white.withOpacity(0.4)
                                        : Colors.white,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  AutoSizeText(
                                    'ЕЩЁ РАЗ',
                                    maxLines: 1,
                                    style: GoogleFonts.roboto(
                                        color: dailyBonusManager
                                                    .isActiveFortuneWheel ||
                                                !dailyBonusManager
                                                    .isCanSpinAgain
                                            ? Colors.white.withOpacity(0.4)
                                            : Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
                              onPressed: dailyBonusManager.isActiveFortuneWheel
                                  ? null
                                  : () {
                                      if (!dailyBonusManager.isCanSpinAgain) {
                                        _animation();
                                        dailyBonusManager.spin(true);
                                      } else {
                                        dailyBonusManager.getBonus(
                                            context: context,
                                            bonus: currentBonus);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.green,
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    !dailyBonusManager.isCanSpinAgain
                                        ? FontAwesomeIcons.rotate
                                        : FontAwesomeIcons.gift,
                                    color:
                                        dailyBonusManager.isActiveFortuneWheel
                                            ? Colors.white.withOpacity(0.4)
                                            : Colors.white,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  AutoSizeText(
                                    !dailyBonusManager.isCanSpinAgain
                                        ? 'КРУТИТЬ'
                                        : 'ЗАБРАТЬ',
                                    maxLines: 1,
                                    style: GoogleFonts.roboto(
                                        color: dailyBonusManager
                                                .isActiveFortuneWheel
                                            ? Colors.white.withOpacity(0.4)
                                            : Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Container()),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Ежедневный\n',
                            style: Theme.of(context).textTheme.displayLarge,
                            children: [
                              TextSpan(
                                text: 'Бонус',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(color: Colors.lightBlueAccent),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 10,
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
                                    _buildResult(wheelResult)
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
      }),
    );
  }
}
