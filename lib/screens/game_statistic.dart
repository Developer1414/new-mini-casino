import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'dart:io' as ui;

import 'package:provider/provider.dart';

class GameStatistic extends StatelessWidget {
  const GameStatistic({super.key, required this.game});

  final String game;

  @override
  Widget build(BuildContext context) {
    final statistic = Provider.of<GameStatisticController>(context);

    return WillPopScope(
      onWillPop: () async {
        context.beamBack();
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
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
                      context.beamBack();
                      //Beamer.of(context).beamBack();
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      color: Colors.black87,
                      size: 30.0,
                    )),
              ),
              title: AutoSizeText(
                'Статистика',
                style: GoogleFonts.roboto(
                    color: Colors.black87,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900),
              ),
            ),
            body: FutureBuilder(
              future: Provider.of<GameStatisticController>(context)
                  .loadStatistic(game),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loading();
                }

                return statistic.gameStatisticModel == null
                    ? Center(
                        child: AutoSizeText(
                          'Статистики пока нет',
                          style: GoogleFonts.roboto(
                              color: Colors.black87.withOpacity(0.4),
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              crossAxisCount: 1,
                              childAspectRatio: 3.0,
                              children: [
                                gridItem(
                                    title: 'Ставок',
                                    isMoneys: false,
                                    number: double.parse(statistic
                                        .gameStatisticModel!.totalGames
                                        .toString())),
                                gridItem(
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
                                    title: 'Выигрыш',
                                    number: statistic
                                        .gameStatisticModel!.winningsMoneys),
                                gridItem(
                                    title: 'Проигрыш',
                                    number: statistic
                                        .gameStatisticModel!.lossesMoneys),
                                gridItem(
                                    title: 'Макс. выигрыш за ставку',
                                    number:
                                        statistic.gameStatisticModel!.maxWin),
                                gridItem(
                                    title: 'Макс. проигрыш за ставку',
                                    number:
                                        statistic.gameStatisticModel!.maxLoss),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, bottom: 15.0),
                              child: AutoSizeText(
                                'Вся статистика хранится на вашем устройстве. Если вы удалите игру или очистите кеш, данные будут удалены.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  color: Colors.black87.withOpacity(0.4),
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            )),
      ),
    );
  }

  Widget gridItem(
      {required String title,
      required double number,
      bool isMoneys = true,
      bool isPercent = false}) {
    return Container(
      margin: EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          bottom: 15.0,
          top: !isMoneys && !isPercent ? 15.0 : 0.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: AutoSizeText(
              isMoneys
                  ? number < 1000000
                      ? NumberFormat.simpleCurrency(
                              locale: ui.Platform.localeName)
                          .format(number)
                      : NumberFormat.compactSimpleCurrency(
                              locale: ui.Platform.localeName)
                          .format(number)
                  : isPercent
                      ? '${number.toStringAsFixed(2)}%'
                      : NumberFormat.compact(locale: ui.Platform.localeName)
                          .format(number),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 35.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AutoSizeText(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: Colors.black87,
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
