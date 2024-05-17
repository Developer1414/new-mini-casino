import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/games_controller.dart';
import 'package:new_mini_casino/controllers/latest_max_wins_controller.dart';
import 'dart:io' as ui;

import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/models/latest_max_win_users.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';

class LatestMaxWins extends StatefulWidget {
  const LatestMaxWins({super.key});

  @override
  State<LatestMaxWins> createState() => _LatestMaxWinsState();
}

class _LatestMaxWinsState extends State<LatestMaxWins> {
  bool isLoading = false;

  Map<String, List<LatestMaxWinsUsers>> users = {};

  Future getUsers() async {
    setState(() {
      isLoading = true;
    });

    final list = await SupabaseController.supabase!
        .from('latest_max_wins')
        .select()
        .order('date', ascending: false);

    for (int i = 0; i < list.length; i++) {
      LatestMaxWinsUsers user = LatestMaxWinsUsers(
        userName: list[i]['name'],
        gameName: list[i]['game'],
        date: DateTime.parse('${list[i]['date']}Z').toLocal(),
        coefficient: double.parse(list[i]['win'].toString()) /
            double.parse(list[i]['bet'].toString()),
        bet: double.parse(list[i]['bet'].toString()),
        profit: double.parse(list[i]['win'].toString()),
      );

      if (!users.containsKey(user.userName)) {
        users.addAll({
          user.userName: [user]
        });
      } else {
        users[user.userName]!.add(user);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LatestMaxWinsController>(
      builder: (context, latestMaxWinsController, child) {
        return latestMaxWinsController.isLoading || isLoading
            ? loading(context: context)
            : Scaffold(
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
                          Navigator.of(context).pop();
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
                body: users.isEmpty
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
                        itemCount: users.entries.toList().length > 100
                            ? 100
                            : users.entries.toList().length,
                        itemBuilder: (context, index) {
                          String gameName =
                              users.entries.toList()[index].value[0].gameName;

                          gameName = gameName == 'FortuneWheel'
                              ? 'Fortune Wheel'
                              : gameName;

                          return Container(
                              margin: EdgeInsets.only(
                                  left: 15.0,
                                  right: 15.0,
                                  bottom: index + 1 ==
                                          (users.entries.toList().length > 100
                                              ? 100
                                              : users.entries.toList().length)
                                      ? 15.0
                                      : 0.0),
                              decoration: BoxDecoration(
                                color: GamesController.games
                                    .where((element) =>
                                        element.title.toLowerCase() ==
                                        gameName.toLowerCase())
                                    .first
                                    .buttonColor
                                    .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12.0),
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
                                          users.entries
                                              .toList()[index]
                                              .value
                                              .first
                                              .userName,
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
                                    const SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 10.0,
                                                spreadRadius: 1.0,
                                              )
                                            ],
                                            color: const Color(0xFF495057),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: AutoSizeText(
                                            users.entries
                                                        .toList()[index]
                                                        .value
                                                        .first
                                                        .bet <
                                                    100000
                                                ? NumberFormat.simpleCurrency(
                                                        locale: ui.Platform
                                                            .localeName)
                                                    .format(users.entries
                                                        .toList()[index]
                                                        .value
                                                        .first
                                                        .bet)
                                                : NumberFormat
                                                        .compactSimpleCurrency(
                                                            locale: ui.Platform
                                                                .localeName)
                                                    .format(users.entries
                                                        .toList()[index]
                                                        .value
                                                        .first
                                                        .bet),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                              color: const Color(0xfff8f9fa),
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w700,
                                            ),
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
                                              '${users.entries.toList()[index].value.first.coefficient.toStringAsFixed(2)}x',
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 10.0,
                                                spreadRadius: 1.0,
                                              )
                                            ],
                                            color: const Color(0xffff9900),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: AutoSizeText(
                                            users.entries
                                                        .toList()[index]
                                                        .value
                                                        .first
                                                        .profit <
                                                    100000
                                                ? NumberFormat.simpleCurrency(
                                                        locale: ui.Platform
                                                            .localeName)
                                                    .format(users.entries
                                                        .toList()[index]
                                                        .value
                                                        .first
                                                        .profit)
                                                : NumberFormat
                                                        .compactSimpleCurrency(
                                                            locale: ui.Platform
                                                                .localeName)
                                                    .format(users.entries
                                                        .toList()[index]
                                                        .value
                                                        .first
                                                        .profit),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                              color: const Color(0xfffffae5),
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        users.entries
                                                    .toList()[index]
                                                    .value
                                                    .length ==
                                                1
                                            ? Container()
                                            : SizedBox(
                                                height: 30.0,
                                                child: IconButton(
                                                    splashRadius: null,
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    padding: EdgeInsets.zero,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    onPressed: () =>
                                                        latestMaxWinsController
                                                            .chooseUser(index),
                                                    icon: FaIcon(
                                                      latestMaxWinsController
                                                                  .choosedUser ==
                                                              index
                                                          ? FontAwesomeIcons
                                                              .solidSquareCaretUp
                                                          : FontAwesomeIcons
                                                              .solidSquareCaretDown,
                                                      color: Theme.of(context)
                                                          .appBarTheme
                                                          .iconTheme!
                                                          .color,
                                                      size: 20,
                                                    )),
                                              ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: AutoSizeText(
                                            '${DateFormat.MMMd(ui.Platform.localeName).format(users.entries.toList()[index].value.first.date)} в ${DateFormat.jm(ui.Platform.localeName).format(users.entries.toList()[index].value.first.date)}',
                                            style: GoogleFonts.roboto(
                                              color: Colors.white60,
                                              fontSize: 3.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    latestMaxWinsController.choosedUser == index
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10.0),
                                              AutoSizeText(
                                                'Прошлые крупные выигрыши:',
                                                style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 10.0),
                                              ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: users.entries
                                                            .toList()[index]
                                                            .value
                                                            .length >
                                                        10
                                                    ? 10
                                                    : users.entries
                                                        .toList()[index]
                                                        .value
                                                        .length,
                                                itemBuilder:
                                                    (context, newIndex) {
                                                  return userPanel(
                                                      index: newIndex,
                                                      users: users.entries
                                                          .toList()[index]
                                                          .value,
                                                      context: context);
                                                },
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const SizedBox(
                                                            height: 15.0),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              ));
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15.0),
                      ),
              );
      },
    );
  }

  Widget userPanel({
    required int index,
    required List<LatestMaxWinsUsers> users,
    required BuildContext context,
  }) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            )
          ],
          color: GamesController.games
              .where((element) =>
                  element.title.toLowerCase() ==
                  users[index].gameName.toLowerCase())
              .first
              .buttonColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    users[index].bet < 100000
                        ? NumberFormat.simpleCurrency(
                                locale: ui.Platform.localeName)
                            .format(users[index].bet)
                        : NumberFormat.compactSimpleCurrency(
                                locale: ui.Platform.localeName)
                            .format(users[index].bet),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: const Color(0xfff8f9fa),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Column(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.arrowRightLong,
                        color: Theme.of(context).appBarTheme.iconTheme!.color,
                        size: 18.0,
                      ),
                      Text(
                        '${users[index].coefficient.toStringAsFixed(2)}x',
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
                    users[index].profit < 100000
                        ? NumberFormat.simpleCurrency(
                                locale: ui.Platform.localeName)
                            .format(users[index].profit)
                        : NumberFormat.compactSimpleCurrency(
                                locale: ui.Platform.localeName)
                            .format(users[index].profit),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: const Color(0xfffffae5),
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    users[index].gameName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 15.0,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AutoSizeText(
                      '${DateFormat.MMMd(ui.Platform.localeName).format(users[index].date)} в ${DateFormat.jm(ui.Platform.localeName).format(users[index].date)}',
                      style: GoogleFonts.roboto(
                        color: Colors.white60,
                        fontSize: 3.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
