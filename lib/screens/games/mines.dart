import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io' as ui;
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/mines_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class Mines extends StatelessWidget {
  const Mines({super.key});

  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !context.read<MinesLogic>().isGameOn,
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
              key: scaffoldKey,
              bottomNavigationBar: Consumer<MinesLogic>(
                builder: (context, minesLogic, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                    'Прибыль (${minesLogic.currentCoefficient.isNaN ? '0.00' : minesLogic.currentCoefficient.toStringAsFixed(2)}x):',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                AutoSizeText(
                                    minesLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(minesLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(minesLogic.profit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                            Row(
                              children: [
                                AutoSizeText('Кол. мин:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                Expanded(
                                  child: Slider(
                                    value: minesLogic.sliderValue,
                                    max: 24,
                                    min: 1,
                                    divisions: 23,
                                    onChanged: (double value) {
                                      if (minesLogic.isGameOn) return;
                                      minesLogic.changeSliderValue(value);
                                    },
                                  ),
                                ),
                                AutoSizeText(
                                    minesLogic.sliderValue.round().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                            gameBetCount(
                              context: context,
                              gameLogic: minesLogic,
                              bet: minesLogic.bet,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                !minesLogic.isGameOn
                                    ? Container()
                                    : Expanded(
                                        child: SizedBox(
                                          height: 60.0,
                                          child: Container(
                                            color: Theme.of(context).cardColor,
                                            child: ElevatedButton(
                                              onPressed: !minesLogic.isGameOn
                                                  ? null
                                                  : () {
                                                      minesLogic.autoMove();
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                elevation: 5,
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                shape:
                                                    const RoundedRectangleBorder(),
                                              ),
                                              child: AutoSizeText(
                                                'АВТО',
                                                maxLines: 1,
                                                style: GoogleFonts.roboto(
                                                    color: !minesLogic.isGameOn
                                                        ? Colors.white
                                                            .withOpacity(0.4)
                                                        : Colors.white,
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                Expanded(
                                  child: SizedBox(
                                    height: 60.0,
                                    child: Container(
                                      color: Theme.of(context).cardColor,
                                      child: ElevatedButton(
                                        onPressed: !minesLogic.isGameOn
                                            ? () {
                                                if (Provider.of<Balance>(
                                                        context,
                                                        listen: false)
                                                    .isLoading) {
                                                  return;
                                                }

                                                if (!minesLogic.isGameOn) {
                                                  minesLogic.startGame(
                                                    context: context,
                                                  );
                                                } else {
                                                  minesLogic.cashout();
                                                }
                                              }
                                            : minesLogic.openedIndexes.isEmpty
                                                ? null
                                                : () {
                                                    if (Provider.of<Balance>(
                                                            context,
                                                            listen: false)
                                                        .isLoading) {
                                                      return;
                                                    }

                                                    if (!minesLogic.isGameOn) {
                                                      minesLogic.startGame(
                                                        context: context,
                                                      );
                                                    } else {
                                                      minesLogic.cashout();
                                                    }
                                                  },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.green,
                                          shape: const RoundedRectangleBorder(),
                                        ),
                                        child: Provider.of<Balance>(context,
                                                    listen: true)
                                                .isLoading
                                            ? const SizedBox(
                                                width: 30.0,
                                                height: 30.0,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 5.0,
                                                  color: Colors.white,
                                                  strokeCap: StrokeCap.round,
                                                ),
                                              )
                                            : AutoSizeText(
                                                !minesLogic.isGameOn
                                                    ? 'СТАВКА'
                                                    : 'ЗАБРАТЬ',
                                                maxLines: 1,
                                                style: GoogleFonts.roboto(
                                                    color: !minesLogic.isGameOn
                                                        ? Colors.white
                                                        : minesLogic
                                                                .openedIndexes
                                                                .isNotEmpty
                                                            ? Colors.white
                                                            : Colors.white
                                                                .withOpacity(
                                                                    0.4),
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ),
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
              appBar: AppBar(
                toolbarHeight: 76.0,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: IconButton(
                      splashRadius: 25.0,
                      padding: EdgeInsets.zero,
                      onPressed: context.watch<MinesLogic>().isGameOn
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
                      'Mines',
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
                        onPressed: context.watch<MinesLogic>().isGameOn
                            ? null
                            : () {
                                Navigator.of(context).pushNamed(
                                    '/game-statistic',
                                    arguments: 'mines');
                              },
                        icon: FaIcon(
                          FontAwesomeIcons.circleInfo,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                ],
              ),
              body: body(),
            ),
            ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive)
          ],
        ),
      ),
    );
  }

  static Widget body() {
    return Screenshot(
      controller: screenshotController,
      child: Consumer<MinesLogic>(builder: (ctx, minesLogic, _) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: GridView.custom(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverWovenGridDelegate.count(
                          crossAxisCount: 5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          pattern: const [
                            WovenGridTile(1),
                            WovenGridTile(
                              7 / 7,
                              crossAxisRatio: 1,
                              alignment: AlignmentDirectional.centerEnd,
                            ),
                          ],
                        ),
                        childrenDelegate: SliverChildBuilderDelegate(
                          childCount: 25,
                          (context, index) => Material(
                            clipBehavior: Clip.antiAlias,
                            borderRadius: BorderRadius.circular(15.0),
                            color: setItemColor(minesLogic, index, context),
                            elevation: 5.0,
                            child: InkWell(
                              onTap: () => minesLogic.checkItem(index),
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                child: !minesLogic.isGameOn
                                    ? minesLogic.minesIndex.isNotEmpty
                                        ? Image.asset(
                                            'assets/mines/${!minesLogic.minesIndex.contains(index) ? 'brilliant' : 'bomb'}.png',
                                          )
                                        : Container()
                                    : minesLogic.openedIndexes.contains(index)
                                        ? Image.asset(
                                            'assets/mines/${!minesLogic.minesIndex.contains(index) ? 'brilliant' : 'bomb'}.png',
                                          )
                                        : Container(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  static Color setItemColor(
      MinesLogic minesLogic, int index, BuildContext context) {
    if (minesLogic.minesIndex.isNotEmpty) {
      if (minesLogic.openedIndexes.contains(index)) {
        if (!minesLogic.minesIndex.contains(index)) {
          return Colors.blueAccent.shade100;
        } else {
          return Colors.redAccent.shade100;
        }
      } else {
        return Theme.of(context).canvasColor;
      }
    } else {
      return Theme.of(context).canvasColor;
    }
  }
}
