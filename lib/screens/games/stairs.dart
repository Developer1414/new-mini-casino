import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/stairs_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:screenshot/screenshot.dart';

class Stairs extends StatefulWidget {
  const Stairs({super.key});

  @override
  State<Stairs> createState() => _StairsState();
}

class _StairsState extends State<Stairs> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !context.read<StairsLogic>().isGameOn,
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
              bottomNavigationBar: Consumer<StairsLogic>(
                builder: (context, stairsLogic, child) {
                  return Column(
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
                                    'Прибыль (${stairsLogic.currentCoefficient.isNaN ? '0.00' : stairsLogic.currentCoefficient.toStringAsFixed(2)}x):',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                AutoSizeText(
                                    stairsLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(stairsLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(stairsLogic.profit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                            Row(
                              children: [
                                AutoSizeText('Кол. камней:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                Expanded(
                                  child: Slider(
                                    value: stairsLogic.sliderValue,
                                    max: 3,
                                    min: 1,
                                    divisions: 2,
                                    onChanged: (double value) {
                                      if (stairsLogic.isGameOn) return;
                                      stairsLogic.changeSliderValue(value);
                                    },
                                  ),
                                ),
                                AutoSizeText(
                                    stairsLogic.sliderValue.round().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                            gameBetCount(
                              context: context,
                              gameLogic: stairsLogic,
                              bet: stairsLogic.bet,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        children: [
                          !stairsLogic.isGameOn
                              ? Container()
                              : Expanded(
                                  child: SizedBox(
                                    height: 60.0,
                                    child: Container(
                                      color: Theme.of(context).cardColor,
                                      child: ElevatedButton(
                                        onPressed: !stairsLogic.isGameOn
                                            ? null
                                            : () {
                                                stairsLogic.autoMove();
                                              },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          backgroundColor: Colors.blueAccent,
                                          shape: const RoundedRectangleBorder(),
                                        ),
                                        child: AutoSizeText(
                                          'АВТО',
                                          maxLines: 1,
                                          style: GoogleFonts.roboto(
                                              color: !stairsLogic.isGameOn
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
                            child: SizedBox(
                              height: 60.0,
                              child: Container(
                                color: Theme.of(context).cardColor,
                                child: ElevatedButton(
                                  onPressed: !stairsLogic.isGameOn
                                      ? () {
                                          if (Provider.of<Balance>(context,
                                                  listen: false)
                                              .isLoading) {
                                            return;
                                          }

                                          if (!stairsLogic.isGameOn) {
                                            stairsLogic.startGame(
                                                context: context);
                                          } else {
                                            stairsLogic.cashout();
                                          }
                                        }
                                      : stairsLogic.openedColumnIndex.isEmpty
                                          ? null
                                          : () async {
                                              if (Provider.of<Balance>(context,
                                                      listen: false)
                                                  .isLoading) {
                                                return;
                                              }

                                              if (!stairsLogic.isGameOn) {
                                                stairsLogic.startGame(
                                                    context: context);
                                              } else {
                                                stairsLogic.cashout();
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
                                          child: CircularProgressIndicator(
                                            strokeWidth: 5.0,
                                            color: Colors.white,
                                            strokeCap: StrokeCap.round,
                                          ),
                                        )
                                      : AutoSizeText(
                                          !stairsLogic.isGameOn
                                              ? 'СТАВКА'
                                              : 'ЗАБРАТЬ',
                                          maxLines: 1,
                                          style: GoogleFonts.roboto(
                                              color: stairsLogic.isGameOn
                                                  ? stairsLogic
                                                          .openedColumnIndex
                                                          .isEmpty
                                                      ? Colors.white
                                                          .withOpacity(0.4)
                                                      : Colors.white
                                                  : Colors.white,
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
                  );
                },
              ),
              appBar: gameAppBarWidget(
                context: context,
                isGameOn: context.watch<StairsLogic>().isGameOn,
                gameName: 'Stairs',
              ),
              body: Screenshot(
                controller: screenshotController,
                child: Consumer<StairsLogic>(
                  builder: (context, stairsLogic, child) {
                    return Column(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Center(
                                  child:
                                      !stairsLogic.isGameOn &&
                                              !stairsLogic.isGameOver
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                    height: 150,
                                                    'assets/games_logo/Stairs.png'),
                                                const SizedBox(height: 15.0),
                                                AutoSizeText(
                                                  'Сделайте ставку',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium,
                                                ),
                                              ],
                                            )
                                          : ListView.separated(
                                              shrinkWrap: true,
                                              controller: scrollController,
                                              itemCount: 10,
                                              separatorBuilder: (context,
                                                      index) =>
                                                  const SizedBox(height: 15.0),
                                              itemBuilder:
                                                  (context, columnIndex) {
                                                return Row(
                                                  mainAxisAlignment: stairsLogic
                                                          .cellCount[
                                                              columnIndex]
                                                          .isEven
                                                      ? MainAxisAlignment.start
                                                      : MainAxisAlignment.end,
                                                  children: [
                                                    for (int rowIndex = 0;
                                                        rowIndex <
                                                            stairsLogic
                                                                    .cellCount[
                                                                columnIndex];
                                                        rowIndex++)
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            right: rowIndex +
                                                                        1 <
                                                                    stairsLogic
                                                                            .cellCount[
                                                                        columnIndex]
                                                                ? 10.0
                                                                : 0.0),
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              12,
                                                          height: 30.0,
                                                          child: !stairsLogic
                                                                  .isGameOn
                                                              ? stairsLogic
                                                                      .isGameOver
                                                                  ? Image(
                                                                      image:
                                                                          AssetImage(
                                                                        'assets/stairs/${!stairsLogic.stonesIndex[columnIndex]!.contains(rowIndex) ? 'stairs' : 'rocks'}.png',
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      opacity: AlwaysStoppedAnimation(stairsLogic.openedColumnIndex[columnIndex] ==
                                                                              rowIndex
                                                                          ? 1.0
                                                                          : 0.4),
                                                                    )
                                                                  : FaIcon(
                                                                      FontAwesomeIcons
                                                                          .solidCircleQuestion,
                                                                      color: const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              221,
                                                                              163,
                                                                              75)
                                                                          .withOpacity(
                                                                              0.7),
                                                                      size:
                                                                          30.0,
                                                                    )
                                                              : stairsLogic
                                                                      .openedColumnIndex
                                                                      .keys
                                                                      .toList()
                                                                      .contains(
                                                                          columnIndex)
                                                                  ? Image(
                                                                      image:
                                                                          AssetImage(
                                                                        'assets/stairs/${!stairsLogic.stonesIndex[columnIndex]!.contains(rowIndex) ? 'stairs' : 'rocks'}.png',
                                                                      ),
                                                                      width:
                                                                          40.0,
                                                                      height:
                                                                          40.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      opacity: AlwaysStoppedAnimation(stairsLogic.openedColumnIndex[columnIndex] ==
                                                                              rowIndex
                                                                          ? 1.0
                                                                          : 0.4))
                                                                  : Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15.0),
                                                                        border: Border.all(
                                                                            color: stairsLogic.currentIndex != columnIndex
                                                                                ? Colors.transparent
                                                                                : const Color.fromARGB(255, 255, 199, 114),
                                                                            width: 2.0),
                                                                      ),
                                                                      child:
                                                                          Material(
                                                                        clipBehavior:
                                                                            Clip.antiAlias,
                                                                        color: Colors
                                                                            .transparent,
                                                                        shape:
                                                                            const CircleBorder(),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            if (stairsLogic.currentIndex !=
                                                                                columnIndex) {
                                                                              return;
                                                                            }

                                                                            stairsLogic.selectCell(rowIndex,
                                                                                columnIndex);
                                                                          },
                                                                          child:
                                                                              FaIcon(
                                                                            FontAwesomeIcons.solidCircleQuestion,
                                                                            color:
                                                                                const Color.fromARGB(255, 221, 163, 75).withOpacity(0.7),
                                                                            size:
                                                                                26.0,
                                                                          ),
                                                                        ),
                                                                      )),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              }),
                                )))
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
