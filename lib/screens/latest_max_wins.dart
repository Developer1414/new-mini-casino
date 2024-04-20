import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/games_controller.dart';
import 'dart:io' as ui;

import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';

class LatestMaxWins extends StatelessWidget {
  const LatestMaxWins({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = SupabaseController.supabase!
        .from('latest_max_wins')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .limit(100);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 76.0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: IconButton(
              splashRadius: 25.0,
              padding: EdgeInsets.zero,
              onPressed: () async {
                Beamer.of(context).beamBack();
              },
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Theme.of(context).appBarTheme.iconTheme!.color,
                size: Theme.of(context).appBarTheme.iconTheme!.size,
              )),
        ),
        title: AutoSizeText(
          'Крупные выигрыши',
          maxLines: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loading(context: context);
          }

          List<Map<String, dynamic>> list = snapshot.data ?? [];
          //List<dynamic> list = snapshot.data;

          return list.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: smallHelperPanel(
                        context: context,
                        icon: FontAwesomeIcons.circleXmark,
                        iconColor: Colors.redAccent,
                        text: 'Крупные выигрыши ещё не определены!'),
                  ),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    String gameName =
                        '${list[index]['game'][0].toUpperCase()}${list[index]['game'].toString().substring(1)}';

                    gameName =
                        gameName == 'FortuneWheel' ? 'Fortune Wheel' : gameName;

                    DateTime date =
                        DateTime.parse('${list[index]['date']}Z').toLocal();

                    return Container(
                        margin: EdgeInsets.only(
                            left: 15.0,
                            right: 15.0,
                            bottom: index + 1 == list.length ? 15.0 : 0.0),
                        decoration: BoxDecoration(
                          color: GamesController.games
                              .where((element) => element.title == gameName)
                              .first
                              .buttonColor
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                              color: GamesController.games
                                  .where((element) => element.title == gameName)
                                  .first
                                  .buttonColor
                                  .withOpacity(0.7),
                              width: 2.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText(
                                    list[index]['name'],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  AutoSizeText(
                                    gameName,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText(
                                    double.parse(
                                                list[index]['bet'].toString()) <
                                            100000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(double.parse(
                                                list[index]['bet'].toString()))
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(double.parse(
                                                list[index]['bet'].toString())),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.arrowRightLong,
                                        color: Theme.of(context)
                                            .appBarTheme
                                            .iconTheme!
                                            .color,
                                        size: 18.0,
                                      ),
                                      Text(
                                        '${(double.parse(list[index]['win'].toString()) / double.parse(list[index]['bet'].toString())).toStringAsFixed(2)}x',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AutoSizeText(
                                    double.parse(
                                                list[index]['win'].toString()) <
                                            100000
                                        ? NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(double.parse(
                                                list[index]['win'].toString()))
                                        : NumberFormat.compactSimpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(double.parse(
                                                list[index]['win'].toString())),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: const Color.fromARGB(
                                          255, 88, 201, 92),
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: AutoSizeText(
                                  '${DateFormat.MMMd(ui.Platform.localeName).format(date)} в ${DateFormat.jm(ui.Platform.localeName).format(date)}',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white60,
                                    fontSize: 3.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 15.0),
                  itemCount: list.length,
                );
        },
      ),
    );
  }
}
