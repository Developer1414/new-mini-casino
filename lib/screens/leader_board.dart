import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io' as ui;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  static final List<String> items = ['Уровень', 'Баланс', 'Кол. игр'];

  static double scrollOffset = 0.0;

  static String? selectedValue = items.first;

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  @override
  Widget build(BuildContext context) {
    ScrollController controller =
        ScrollController(initialScrollOffset: LeaderBoard.scrollOffset);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Container(
        height: 60.0,
        margin: const EdgeInsets.only(top: 15.0),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(color: Colors.black87.withOpacity(0.4), blurRadius: 5.0)
            ]),
        child: StreamBuilder(
            stream: SupabaseController.supabase
                ?.from('users')
                .select('*')
                .order(
                    LeaderBoard.selectedValue == LeaderBoard.items.first
                        ? 'level'
                        : LeaderBoard.selectedValue == LeaderBoard.items[1]
                            ? 'balance'
                            : 'totalGames',
                    ascending: false)
                .asStream(),
            builder: (context, snapshot) {
              int userPlace = 0;
              int realUserPlace = 0;

              if (snapshot.data != null) {
                userPlace = (snapshot.data as List<dynamic>).indexWhere(
                    (element) =>
                        element['uid'] ==
                        SupabaseController.supabase?.auth.currentUser!.id);

                realUserPlace = userPlace;

                userPlace = userPlace < 3
                    ? userPlace + 1
                    : userPlace < 13
                        ? (userPlace + 1) - (userPlace - (userPlace - 3))
                        : (userPlace + 1) - (userPlace - (userPlace - 13));
              }

              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      'Вы на $userPlace месте',
                      style: Theme.of(context)
                          .appBarTheme
                          .titleTextStyle!
                          .copyWith(fontSize: 23.0),
                    ),
                    const SizedBox(width: 10.0),
                    userPlace > 100
                        ? Container()
                        : Container(
                            decoration: BoxDecoration(
                              color: realUserPlace < 3
                                  ? Colors.lightGreen
                                  : realUserPlace < 13
                                      ? Colors.blue
                                      : realUserPlace < 100
                                          ? Colors.deepPurple
                                          : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                'ТОП-${realUserPlace < 3 ? 3 : realUserPlace < 13 ? 10 : realUserPlace < 100 ? 100 : 1000}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          )
                  ],
                ),
              );
            }),
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
          'Лидеры',
          maxLines: 1,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                items: LeaderBoard.items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 14.0)),
                        ))
                    .toList(),
                value: LeaderBoard.selectedValue,
                onChanged: (value) {
                  setState(() {
                    LeaderBoard.selectedValue = value;
                  });
                },
                buttonStyleData: ButtonStyleData(
                  height: 50,
                  width: 160,
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                      color: Theme.of(context).cardColor),
                  elevation: 2,
                ),
                style: GoogleFonts.roboto(
                    color: Colors.black87,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700),
                iconStyleData: IconStyleData(
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                  ),
                  iconSize: 30,
                  iconEnabledColor:
                      Theme.of(context).appBarTheme.iconTheme!.color,
                  iconDisabledColor: Colors.grey,
                ),
                dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    padding: null,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Theme.of(context).cardColor,
                    ),
                    elevation: 8,
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all(6),
                      thumbVisibility: MaterialStateProperty.all(true),
                    )),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                  padding: EdgeInsets.only(left: 14, right: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: SupabaseController.supabase
              ?.from('users')
              .select('*')
              .order(
                  LeaderBoard.selectedValue == LeaderBoard.items.first
                      ? 'level'
                      : LeaderBoard.selectedValue == LeaderBoard.items[1]
                          ? 'balance'
                          : 'totalGames',
                  ascending: false)
              .limit(113)
              .asStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loading(context: context);
            }

            return list(
                map: (snapshot.data as List<dynamic>), controller: controller);
          }),
    );
  }

  Widget list(
      {required List<dynamic> map,
      required ScrollController controller,
      bool isShowRaiting = true}) {
    return ListView.separated(
        itemCount: map.length,
        controller: controller,
        itemBuilder: (context, index) {
          double balance = 0.0;

          int totalGames = 0;

          double level = 1;

          int pinId = -1;

          if (LeaderBoard.selectedValue == LeaderBoard.items.first) {
            level = double.parse(map[index]['level'].toString());
          } else if (LeaderBoard.selectedValue == LeaderBoard.items[1]) {
            balance = double.parse(map[index]['balance'].toString());
          } else if (LeaderBoard.selectedValue == LeaderBoard.items[2]) {
            totalGames = int.parse(map[index]['totalGames'].toString());
          }

          /*if (snapshot.data!.docs[index].data().containsKey('selectedpins')) {
            pinId = int.parse(
                snapshot.data!.docs[index].get('selectedpins').toString());
          }*/

          return Container(
            padding: EdgeInsets.only(
              top: 15.0,
              bottom: index == 2 || index == 12 ? 15.0 : 0.0,
            ),
            margin:
                EdgeInsets.only(bottom: index == 2 || index == 12 ? 15.0 : 0.0),
            decoration: BoxDecoration(
                color: index < 3
                    ? Colors.lightGreen
                    : index < 13
                        ? Colors.blue.withOpacity(1.0 - (index / 100))
                        : index < 100
                            ? Colors.deepPurple.withOpacity(1.0 - (index / 100))
                            : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: index == 0 || index == 3 || index == 13
                      ? const Radius.circular(15.0)
                      : const Radius.circular(0.0),
                  topRight: index == 0 || index == 3 || index == 13
                      ? const Radius.circular(15.0)
                      : const Radius.circular(0.0),
                  bottomLeft: index == 2 || index == 12
                      ? const Radius.circular(15.0)
                      : const Radius.circular(0.0),
                  bottomRight: index == 2 || index == 12
                      ? const Radius.circular(15.0)
                      : const Radius.circular(0.0),
                )),
            child: GestureDetector(
              onTap: () {
                /* LeaderBoard.scrollOffset = controller.offset;
                context.beamToNamed(
                  '/other-user-profile/${map[index]['name']}/${map[index]['uid']}/$pinId',
                );*/
              },
              child: Column(
                children: [
                  index == 0 || index == 3 || index == 13
                      ? Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, bottom: 15.0),
                          child: AutoSizeText(
                            'ТОП-${index == 0 ? 3 : index == 3 ? 10 : 100}',
                            maxLines: 1,
                            style: Theme.of(context)
                                .appBarTheme
                                .titleTextStyle!
                                .copyWith(fontSize: 25.0),
                          ),
                        )
                      : Container(),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Theme.of(context).cardColor,
                        border: map[index]['uid'] ==
                                SupabaseController
                                    .supabase?.auth.currentUser!.id
                            ? Border.all(color: Colors.white, width: 2.0)
                            : null,
                        boxShadow: [
                          BoxShadow(
                              color: map[index]['uid'] ==
                                      SupabaseController
                                          .supabase?.auth.currentUser!.id
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.3),
                              blurRadius: 10.0)
                        ]),
                    child: Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LeaderBoard.selectedValue != LeaderBoard.items.first
                                ? Container()
                                : Container(
                                    height: 60.0,
                                    margin: const EdgeInsets.only(
                                        left: 12.0, top: 12.0, bottom: 12.0),
                                    decoration: ShapeDecoration(
                                      shape: const CircleBorder(),
                                      color: Theme.of(context).cardColor,
                                    ),
                                    child: CircleProgressBar(
                                      foregroundColor: const Color.fromARGB(
                                          255, 179, 242, 31),
                                      backgroundColor: Theme.of(context)
                                          .buttonTheme
                                          .colorScheme!
                                          .background,
                                      strokeWidth: 7.0,
                                      value: level - level.truncate(),
                                      child: Center(
                                          child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AutoSizeText(
                                              NumberFormat.compact(
                                                      locale: 'en_US')
                                                  .format(level.floor()),
                                              maxLines: 1,
                                              minFontSize: 10.0,
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      )),
                                    ),
                                  ),
                            Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        AutoSizeText(map[index]['name'] ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(fontSize: 23.0)),
                                        const SizedBox(width: 5.0),
                                        pinId != -1
                                            ? Image(
                                                image: AssetImage(
                                                    'assets/pins/$pinId.png'),
                                                width: 25.0,
                                                height: 25.0)
                                            : Container(),
                                        const SizedBox(width: 6.0),
                                        isShowRaiting
                                            ? map[index]['uid'] !=
                                                    SupabaseController.supabase
                                                        ?.auth.currentUser!.id
                                                ? Container()
                                                : Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    decoration: BoxDecoration(
                                                        color: Colors.redAccent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors
                                                                  .redAccent
                                                                  .withOpacity(
                                                                      0.5),
                                                              blurRadius: 8.0,
                                                              spreadRadius: 1.5)
                                                        ]),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: AutoSizeText(
                                                        'Вы',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.roboto(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900),
                                                      ),
                                                    ),
                                                  )
                                            : Container(),
                                      ],
                                    ),
                                    const SizedBox(height: 5.0),
                                    LeaderBoard.selectedValue ==
                                            LeaderBoard.items.first
                                        ? Container()
                                        : LeaderBoard.selectedValue ==
                                                LeaderBoard.items[1]
                                            ? Row(
                                                children: [
                                                  const FaIcon(
                                                    FontAwesomeIcons.sackDollar,
                                                    color: Colors.green,
                                                    size: 18.0,
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.5,
                                                    child: AutoSizeText(
                                                        'Баланс: ${balance < 1000000 ? NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(balance) : NumberFormat.compactSimpleCurrency(locale: ui.Platform.localeName).format(balance)}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis)),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  const FaIcon(
                                                    FontAwesomeIcons.gamepad,
                                                    color: Colors.blueGrey,
                                                    size: 18.0,
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  AutoSizeText(
                                                      'Игр: ${NumberFormat.compact(locale: ui.Platform.localeName).format(totalGames)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium),
                                                ],
                                              )
                                  ],
                                )),
                          ],
                        ),
                        !isShowRaiting
                            ? Container()
                            : Container(
                                width: 50.0,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .buttonTheme
                                        .colorScheme!
                                        .background,
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15.0),
                                        topRight: Radius.circular(12.0))),
                                child: Center(
                                  child: AutoSizeText(
                                    '#${index < 3 ? index + 1 : index < 13 ? (index + 1) - (index - (index - 3)) : (index + 1) - (index - (index - 13))}',
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontSize: 18.0),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (contex, index) => const SizedBox(
            height: /* index == 0 || index == 1 ? 0.0 : 15.0*/ 0.0));
  }
}
