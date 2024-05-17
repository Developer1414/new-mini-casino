import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'dart:io' as ui;

import 'package:provider/provider.dart';

class GameStatistic extends StatelessWidget {
  const GameStatistic({super.key, required this.game});

  final String game;

  @override
  Widget build(BuildContext context) {
    final statistic = Provider.of<GameStatisticController>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 76.0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: IconButton(
                  splashRadius: 25.0,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.arrowLeft,
                    color: Theme.of(context).appBarTheme.iconTheme!.color,
                    size: Theme.of(context).appBarTheme.iconTheme!.size,
                  )),
            ),
            title: AutoSizeText(
              'Статистика',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
          body: FutureBuilder(
            future: Provider.of<GameStatisticController>(context)
                .loadStatistic(game),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loading(context: context);
              }

              return statistic.gameStatisticModel == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.chartSimple,
                              color: Colors.white60,
                              size: 30.0,
                            ),
                            const SizedBox(height: 5.0),
                            AutoSizeText('Статистики пока нет',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  fontSize: 15.0,
                                  letterSpacing: 0.1,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white60,
                                )),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 15.0,
                              crossAxisSpacing: 15.0,
                              children: [
                                gridItem(
                                    context: context,
                                    title: 'Ставок',
                                    isMoneys: false,
                                    number: double.parse(statistic
                                        .gameStatisticModel!.totalGames
                                        .toString())),
                                gridItem(
                                    context: context,
                                    title: 'Побед',
                                    isMoneys: false,
                                    isPercent: true,
                                    number: (double.parse(statistic
                                                .gameStatisticModel!
                                                .winGamesCount
                                                .toString()) /
                                            double.parse(statistic
                                                .gameStatisticModel!.totalGames
                                                .toString())) *
                                        100),
                                gridItem(
                                    context: context,
                                    title: 'Выигрыш',
                                    number: statistic
                                        .gameStatisticModel!.winningsMoneys),
                                gridItem(
                                    context: context,
                                    title: 'Проигрыш',
                                    number: statistic
                                        .gameStatisticModel!.lossesMoneys),
                                gridItem(
                                    context: context,
                                    title: 'Макс. выигрыш',
                                    number:
                                        statistic.gameStatisticModel!.maxWin),
                                gridItem(
                                    context: context,
                                    title: 'Макс. проигрыш',
                                    number:
                                        statistic.gameStatisticModel!.maxLoss),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, bottom: 15.0),
                            child: smallHelperPanel(
                              icon: FontAwesomeIcons.circleInfo,
                              context: context,
                              text:
                                  'Вся статистика хранится на вашем устройстве. Если Вы удалите игру или очистите кеш - данные будут удалены.',
                            ),
                          ),
                        ],
                      ),
                    );
            },
          )),
    );
  }

  Widget gridItem(
      {required String title,
      required BuildContext context,
      required double number,
      bool isMoneys = true,
      bool isPercent = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: AutoSizeText(
              isMoneys
                  ? number < 100000
                      ? NumberFormat.simpleCurrency(
                              locale: ui.Platform.localeName)
                          .format(number)
                      : NumberFormat.compactSimpleCurrency(
                              locale: ui.Platform.localeName)
                          .format(number)
                  : isPercent
                      ? '${number.toInt()}%'
                      : NumberFormat.compact(locale: 'en_US').format(number),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .appBarTheme
                  .titleTextStyle!
                  .copyWith(fontSize: 35.0),
            ),
          ),
          AutoSizeText(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 12.0,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .color!
                      .withOpacity(0.6))),
        ],
      ),
    );
  }
}
