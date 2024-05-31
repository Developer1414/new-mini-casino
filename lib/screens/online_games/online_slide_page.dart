import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/online_games_controller.dart';
import 'package:new_mini_casino/controllers/online_games_logic/online_slide_logic.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/check_online_game_widget.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'dart:io' as ui;

import 'package:provider/provider.dart';

class OnlineSlidePage extends StatefulWidget {
  const OnlineSlidePage({super.key});

  static List<Map<String, dynamic>> elements = [];
  static ScrollController scrollController = ScrollController();

  @override
  State<OnlineSlidePage> createState() => _OnlineSlidePageState();
}

class _OnlineSlidePageState extends State<OnlineSlidePage> {
  double itemWidth = 300.0;
  double itemHeight = 300.0;

  bool isScrolling = false;

  Color calculateColor(double bet) {
    double normalizedBet = (bet / 100000).clamp(0.0, 1.0);
    return Color.lerp(Colors.grey, Colors.orange, normalizedBet)!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineSlideLogic>(
        builder: (context, onlineSlideLogic, child) {
      return onlineSlideLogic.isLoading
          ? loading(context: context)
          : Scaffold(
              appBar: gameAppBarWidget(
                context: context,
                isGameOn: context.watch<OnlineSlideLogic>().isGameOn,
                isShowActions: onlineSlideLogic.isGameWork,
                onPressed: () =>
                    context.read<OnlineSlideLogic>().disconnect(context),
                gameName: 'Slide',
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            String hash = '';
                            String check = '';

                            String temp =
                                '${onlineSlideLogic.currentWinnerIndex}_${SupabaseController.supabase!.auth.currentUser!.id}';

                            hash = generateHash(temp);
                            check = temp;

                            return checkGameMobalBottomSheet(
                              hash: hash,
                              check: check,
                              isGameOn: onlineSlideLogic.isGameOn,
                            );
                          },
                        );
                      },
                      child: AutoSizeText(
                        'Проверить игру',
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w100,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: !onlineSlideLogic.isGameWork
                  ? Container(height: 0.0)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, bottom: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText('Прибыль:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontSize: 12.0)),
                              AutoSizeText(
                                  onlineSlideLogic.profit < 1000000
                                      ? NumberFormat.simpleCurrency(
                                              locale: ui.Platform.localeName)
                                          .format(onlineSlideLogic.profit)
                                      : NumberFormat.compactSimpleCurrency(
                                              locale: ui.Platform.localeName)
                                          .format(onlineSlideLogic.profit),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontSize: 12.0)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: gameBetCount(
                            context: context,
                            gameLogic: onlineSlideLogic,
                            bet: onlineSlideLogic.bet,
                            isBlockBetPanel: !onlineSlideLogic.isGameWork ||
                                !onlineSlideLogic.isConnected ||
                                onlineSlideLogic.isMakedBet,
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
                              onPressed: onlineSlideLogic.isMakedBet ||
                                      onlineSlideLogic.isGameOn
                                  ? null
                                  : () async {
                                      if (Provider.of<Balance>(context,
                                              listen: false)
                                          .isLoading) {
                                        return;
                                      }

                                      onlineSlideLogic.startGame(
                                        context: context,
                                      );
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
                                      'СТАВКА',
                                      maxLines: 1,
                                      style: GoogleFonts.roboto(
                                          color: onlineSlideLogic.isMakedBet ||
                                                  onlineSlideLogic.isGameOn
                                              ? Colors.white.withOpacity(0.4)
                                              : Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w900),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
              body: Column(
                children: [
                  Container(
                    height: 60.0,
                    margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.grey.shade50.withOpacity(0.08),
                      border: Border.all(
                          color: Colors.grey.shade100.withOpacity(0.4),
                          width: 2.0),
                    ),
                    child: onlineSlideLogic.usersList.isEmpty
                        ? Center(
                            child: AutoSizeText('Игроков ещё нет',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .color!
                                            .withOpacity(0.4))),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  List<dynamic> value = onlineSlideLogic
                                      .usersList.reversed
                                      .toList();

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(
                                        top: 5.0,
                                        bottom: 5.0,
                                        left: index == 0 ? 5.0 : 0.0,
                                        right: index + 1 ==
                                                onlineSlideLogic
                                                    .usersList.length
                                            ? 5.0
                                            : 0.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            value[index]['status'].toString() ==
                                                    'win'
                                                ? const Color.fromARGB(
                                                    255, 109, 250, 114)
                                                : value[index]['status']
                                                            .toString() ==
                                                        'loss'
                                                    ? const Color.fromARGB(
                                                        255, 250, 109, 109)
                                                    : Colors.white60,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Theme.of(context).cardColor,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: AutoSizeText(
                                          '${value[index]['name']}\n${double.parse(value[index]['bet'].toString()) < 100000 ? NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(value[index]['bet']) : NumberFormat.compactSimpleCurrency(locale: ui.Platform.localeName).format(value[index]['bet'])}',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 5.0),
                                itemCount: onlineSlideLogic.usersList.length),
                          ),
                  ),
                  const SizedBox(height: 15.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.coins,
                              color: Colors.white,
                              size: 16.0,
                            ),
                            const SizedBox(width: 5.0),
                            AutoSizeText(
                              NumberFormat.simpleCurrency(
                                      locale: ui.Platform.localeName)
                                  .format(onlineSlideLogic.totalBalance),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            AutoSizeText(
                              onlineSlideLogic.usersList.length.toString(),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(width: 5.0),
                            const FaIcon(
                              FontAwesomeIcons.solidUser,
                              color: Colors.white,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: onlineSlideLogic.pause > -1 &&
                            onlineSlideLogic.isConnected
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedFlipCounter(
                                  duration: const Duration(milliseconds: 500),
                                  value: onlineSlideLogic.pause,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontSize: 40.0,
                                        fontWeight: FontWeight.w700,
                                      )),
                              AutoSizeText('Ожидание ставок',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500,
                                      )),
                            ],
                          )
                        : !onlineSlideLogic.isConnected ||
                                onlineSlideLogic.isWaitingBets
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40.0,
                                    height: 40.0,
                                    margin: const EdgeInsets.only(bottom: 10.0),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 6.0,
                                      strokeCap: StrokeCap.round,
                                      color: Color.fromARGB(255, 179, 242, 31),
                                    ),
                                  ),
                                  AutoSizeText(
                                      onlineSlideLogic.isWaitingBets
                                          ? 'Ожидание ставок'
                                          : 'Подключение...',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500,
                                          )),
                                ],
                              )
                            : !onlineSlideLogic.isGameOn
                                ? Center(
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      margin:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 6.0,
                                        strokeCap: StrokeCap.round,
                                        color:
                                            Color.fromARGB(255, 179, 242, 31),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: SizedBox(
                                      height: itemHeight,
                                      child: ListView.builder(
                                        clipBehavior: Clip.none,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        controller:
                                            OnlineSlidePage.scrollController,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            OnlineSlidePage.elements.length,
                                        itemBuilder: (context, index) {
                                          final element =
                                              OnlineSlidePage.elements[index];
                                          double bet = double.parse(
                                              element['bet'].toString());

                                          Color color = calculateColor(bet);

                                          return Container(
                                            height: itemHeight,
                                            width: itemWidth,
                                            margin: const EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              color: color,
                                              border: onlineSlideLogic
                                                          .currentWinnerIndex ==
                                                      index
                                                  ? Border.all(
                                                      color:
                                                          lighten(color, 0.15),
                                                      width: 5.0,
                                                    )
                                                  : null,
                                              boxShadow: onlineSlideLogic
                                                          .currentWinnerIndex !=
                                                      index
                                                  ? null
                                                  : [
                                                      BoxShadow(
                                                        color: color
                                                            .withOpacity(0.5),
                                                        blurRadius: 20.0,
                                                        spreadRadius: 10.0,
                                                      ),
                                                    ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      AutoSizeText(
                                                        bet < 1000000
                                                            ? NumberFormat.simpleCurrency(
                                                                    locale: ui
                                                                        .Platform
                                                                        .localeName)
                                                                .format(bet)
                                                            : NumberFormat.compactSimpleCurrency(
                                                                    locale: ui
                                                                        .Platform
                                                                        .localeName)
                                                                .format(bet),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      AutoSizeText(
                                                        '${element['winChance']}%',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: AutoSizeText(
                                                        element['name'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize: 40.0,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                              .animate(
                                                  target: index !=
                                                              onlineSlideLogic
                                                                  .currentWinnerIndex &&
                                                          !isScrolling
                                                      ? 1
                                                      : 0)
                                              .tint(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              )
                                              .scaleXY(
                                                delay: 100.ms,
                                                begin: 1.0,
                                                end: 0.95,
                                              );
                                        },
                                      ),
                                    ),
                                  ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     scrollController.jumpTo(0);
                  //     elements.shuffle();

                  //     rand = Random().nextInt(31) + 50;
                  //     scrollToIndex(rand);

                  //     print(rand);

                  //     setState(() {
                  //       isScrolling = true;
                  //     });

                  //     Future.delayed(const Duration(milliseconds: 4500), () {
                  //       setState(() {
                  //         isScrolling = false;
                  //       });
                  //     });
                  //   },
                  //   child: const Text('Прокрутить к выбранному'),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () {
                  // elements.clear();

                  // double totalBets = users
                  //     .map((user) => double.parse(user['bet'].toString()))
                  //     .reduce((a, b) => double.parse((a + b).toString()));

                  // int totalElements = 100;

                  // List counts = users
                  //     .map((user) =>
                  //         ((user['bet'] / totalBets) * totalElements)
                  //             .round())
                  //     .toList();

                  // int currentTotal = counts.reduce((a, b) => a + b);
                  // while (currentTotal != totalElements) {
                  //   for (int i = 0; i < counts.length; i++) {
                  //     if (currentTotal < totalElements) {
                  //       counts[i]++;
                  //       currentTotal++;
                  //     } else if (currentTotal > totalElements &&
                  //         counts[i] > 0) {
                  //       counts[i]--;
                  //       currentTotal--;
                  //     }
                  //     if (currentTotal == totalElements) break;
                  //   }
                  // }

                  // for (int i = 0; i < users.length; i++) {
                  //   for (int j = 0; j < counts[i]; j++) {
                  //     elements.add({
                  //       'name': users[i]['name'],
                  //       'bet': users[i]['bet'],
                  //       'winChance': (users[i]['bet'] / totalBets * 100)
                  //           .toStringAsFixed(2),
                  //     });
                  //   }
                  // }

                  // elements.shuffle();

                  //     setState(() {});
                  //   },
                  //   child: const Text('Shuffle'),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     users.add(
                  //       {
                  //         'name': 'Alex',
                  //         'bet': Random().nextDouble() * 10000,
                  //         'color': Colors.primaries[
                  //             Random().nextInt(Colors.primaries.length)],
                  //       },
                  //     );

                  //     setState(() {});
                  //   },
                  //   child: const Text('Add user'),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     users.clear();

                  //     setState(() {});
                  //   },
                  //   child: const Text('Clean'),
                  // ),
                ],
              ));
    });
  }
}

Color lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final hslLightened =
      hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLightened.toColor();
}
