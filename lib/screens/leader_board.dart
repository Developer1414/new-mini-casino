import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io' as ui;
import 'package:new_mini_casino/controllers/games_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  static final List<String> items = ['Уровень', 'Баланс', 'Кол. игр'];

  static double scrollOffset = 0.0;

  static String? selectedValue = items.first;

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  String imageURL =
      'https://ynlxqherxvlancmqppyp.supabase.co/storage/v1/object/public/leader/leader.png';

  @override
  Widget build(BuildContext context) {
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
                LeaderBoard.scrollOffset = 0.0;
                Beamer.of(context).beamBack();
              },
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Theme.of(context).appBarTheme.iconTheme!.color,
                size: Theme.of(context).appBarTheme.iconTheme!.size,
              )),
        ),
        title: AutoSizeText(
          'Лидер дня',
          maxLines: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: StreamBuilder(
          stream: SupabaseController.supabase
              ?.from('leader_day')
              .select('*')
              .asStream(),
          builder: (context, snapshot) {
            Map<dynamic, dynamic> map = snapshot.data == null
                ? {}
                : (snapshot.data as List<dynamic>).first;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return loading(context: context);
            }

            String gameName =
                '${map['game'][0].toUpperCase()}${map['game'].toString().substring(1)}';

            gameName = gameName == 'FortuneWheel' ? 'Fortune Wheel' : gameName;

            DateTime leaderDate = DateTime.parse('${map['date']}Z').toLocal();
            DateTime leaderDateUTC = DateTime.parse('${map['date']}');

            return map.isEmpty ||
                    leaderDateUTC.day != DateTime.now().toUtc().day ||
                    leaderDateUTC.month != DateTime.now().toUtc().month
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: smallHelperPanel(
                          context: context,
                          icon: FontAwesomeIcons.circleXmark,
                          iconColor: Colors.white.withOpacity(0.5),
                          text:
                              'Лидер дня ещё не выбран. Продолжайте играть и становитесь лучшим – возможно, именно вы займёте этот почетный статус!'),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(
                        right: 15.0, left: 15.0, bottom: 15.0),
                    width: double.infinity,
                    height: double.infinity,
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
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0)),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  GamesController.games
                                      .where((element) =>
                                          element.title == gameName)
                                      .first
                                      .buttonColor
                                      .withOpacity(0.7),
                                  Colors.transparent,
                                ]),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 15.0),
                            AutoSizeText(
                              map['name'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 30.0,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            AutoSizeText(
                              double.parse(map['profit'].toString()) < 1000000
                                  ? NumberFormat.simpleCurrency(
                                          locale: ui.Platform.localeName)
                                      .format(double.parse(
                                          map['profit'].toString()))
                                  : NumberFormat.compactSimpleCurrency(
                                          locale: ui.Platform.localeName)
                                      .format(double.parse(
                                          map['profit'].toString())),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18.0,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            AutoSizeText(
                              'Выигрыш',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.white60,
                                fontSize: 10.0,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            Expanded(
                              flex: 2,
                              child: CachedNetworkImage(
                                  imageUrl: imageURL,
                                  cacheKey: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  imageBuilder: (context, imageProvider) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                  placeholder: (context, url) => const Center(
                                        child: SizedBox(
                                          width: 40.0,
                                          height: 40.0,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 6.0,
                                            color: Color.fromARGB(
                                                255, 179, 242, 31),
                                          ),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) => Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const FaIcon(
                                            FontAwesomeIcons.circleExclamation,
                                            color: Colors.redAccent,
                                            size: 50.0,
                                          ),
                                          const SizedBox(height: 5.0),
                                          AutoSizeText(
                                            'Ошибка при загрузке изображения',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 10.0,
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      )),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AutoSizeText(
                                    'Игра: $gameName',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 10.0,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  AutoSizeText(
                                    'Ставка: ${double.parse(map['bet'].toString()) < 100000 ? NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(double.parse(map['bet'].toString())) : NumberFormat.compactSimpleCurrency(locale: ui.Platform.localeName).format(double.parse(map['bet'].toString()))}',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 10.0,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  AutoSizeText(
                                    'Опубликовано в ${DateFormat.jm(ui.Platform.localeName).format(leaderDate)}',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white60,
                                      fontSize: 3.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
          }),
    );
  }
}
