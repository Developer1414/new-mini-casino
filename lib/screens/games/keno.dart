import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/keno_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:screenshot/screenshot.dart';

class Keno extends StatelessWidget {
  const Keno({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !context.read<KenoLogic>().isGameOn,
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
              bottomNavigationBar: Consumer<KenoLogic>(
                builder: (context, kenoLogic, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 15.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                    'Прибыль (${kenoLogic.coefficient.toStringAsFixed(2)}x):',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                                AutoSizeText(
                                    kenoLogic.profit < 1000000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(kenoLogic.profit)
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(kenoLogic.profit),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontSize: 12.0)),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              height: 50,
                              child: kenoLogic.coefficients.isEmpty
                                  ? Center(
                                      child: AutoSizeText(
                                        'Коэффициентов пока нет',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .color!
                                                    .withOpacity(0.6)),
                                      ),
                                    )
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: kenoLogic.coefficients.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 10.0),
                                      itemBuilder: (context, index) {
                                        return Center(
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            decoration: BoxDecoration(
                                              color: index <=
                                                      kenoLogic
                                                              .currentCoefficient -
                                                          1
                                                  ? Colors.grey.shade100
                                                      .withOpacity(0.1)
                                                  : Colors.grey.shade100
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                  color: index <=
                                                          kenoLogic
                                                                  .currentCoefficient -
                                                              1
                                                      ? Colors.redAccent
                                                      : Colors.grey.shade100
                                                          .withOpacity(0.4),
                                                  width: 2.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: AnimatedOpacity(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                opacity: index <=
                                                        kenoLogic
                                                                .currentCoefficient -
                                                            1
                                                    ? 1.0
                                                    : 0.4,
                                                child: Text(
                                                    '${kenoLogic.coefficients[index]}x',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        kenoLogic.getRandomNumbers();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        backgroundColor: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const FaIcon(
                                            FontAwesomeIcons.dice,
                                            color: Colors.white,
                                            size: 23.0,
                                          ),
                                          const SizedBox(width: 10.0),
                                          AutoSizeText(
                                            'РАНДОМ',
                                            maxLines: 1,
                                            style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                SizedBox(
                                  height: 40.0,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      kenoLogic.clearList();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    child: const FaIcon(
                                      FontAwesomeIcons.xmark,
                                      color: Colors.white,
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: gameBetCount(
                          context: context,
                          gameLogic: kenoLogic,
                          bet: kenoLogic.bet,
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
                            onPressed: kenoLogic.userNumbersList.isEmpty ||
                                    kenoLogic.isGameOn
                                ? null
                                : () {
                                    if (Provider.of<Balance>(context,
                                            listen: false)
                                        .isLoading) {
                                      return;
                                    }

                                    kenoLogic.startGame(context: context);
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
                                    kenoLogic.userNumbersList.isEmpty
                                        ? 'ВЫБЕРИТЕ ЯЧЕЙКИ'
                                        : 'СТАВКА',
                                    maxLines: 1,
                                    style: GoogleFonts.roboto(
                                        color:
                                            kenoLogic.userNumbersList.isEmpty ||
                                                    kenoLogic.isGameOn
                                                ? Colors.white.withOpacity(0.4)
                                                : Colors.white,
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
              appBar: gameAppBarWidget(
                context: context,
                isGameOn: context.watch<KenoLogic>().isGameOn,
                gameName: 'Keno',
              ),
              body: Screenshot(
                controller: screenshotController,
                child: Consumer<KenoLogic>(builder: (ctx, kenoLogic, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: GridView.custom(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: SliverWovenGridDelegate.count(
                              crossAxisCount: 5,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              pattern: const [
                                WovenGridTile(2.2),
                                WovenGridTile(
                                  2.2,
                                  crossAxisRatio: 1,
                                ),
                              ],
                            ),
                            childrenDelegate: SliverChildBuilderDelegate(
                              childCount: 40,
                              (context, index) => ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Material(
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () =>
                                        kenoLogic.selectCustomNumber(index),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                          color: kenoLogic.userNumbersList
                                                  .contains(index)
                                              ? const Color(0xffedf2fb)
                                              : const Color(0xff013a63),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          border: Border.all(
                                              width: kenoLogic.randomNumbersList
                                                      .contains(index)
                                                  ? kenoLogic.userNumbersList
                                                          .contains(index)
                                                      ? 3.0
                                                      : 2.0
                                                  : 0.0,
                                              color: kenoLogic.randomNumbersList
                                                      .contains(index)
                                                  ? kenoLogic.userNumbersList
                                                          .contains(index)
                                                      ? const Color(0xffff002b)
                                                      : Colors.redAccent
                                                          .withOpacity(0.5)
                                                  : Colors.transparent)),
                                      child: Center(
                                        child: AutoSizeText(
                                          (index + 1).toString(),
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontSize: 15.0,
                                                  color: kenoLogic
                                                          .userNumbersList
                                                          .contains(index)
                                                      ? Colors.black87
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .color),
                                        ),
                                      ),
                                    ).animate().fade().scale(
                                          begin: const Offset(0.9, 0.9),
                                          end: const Offset(1.0, 1.0),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
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
