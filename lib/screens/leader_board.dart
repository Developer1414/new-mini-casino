import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'dart:io' as ui;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';

class LeaderBoard extends StatefulWidget {
  const LeaderBoard({super.key});

  static final List<String> items = ['Баланс', 'Кол. игр', 'Участники'];

  static String? selectedValue = items.first;

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  Color? buttonColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        bottomNavigationBar:
            LeaderBoard.selectedValue == LeaderBoard.items.first
                ? Container(
                    height: 60.0,
                    margin: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                        border: Border.all(color: Colors.redAccent, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 10.0)
                        ]),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('balance',
                                isGreaterThan:
                                    context.read<Balance>().currentBalance)
                            .snapshots(),
                        builder: (context, snapshot) {
                          return Center(
                            child: AutoSizeText(
                              'Вы на ${(snapshot.data?.size ?? 0) + 1} месте',
                              style: GoogleFonts.roboto(
                                  color: Colors.black87,
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.w900),
                            ),
                          );
                        }),
                  )
                : Container(height: 15.0),
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
                icon: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.black87,
                  size: 30.0,
                )),
          ),
          title: AutoSizeText(
            'Лидеры',
            maxLines: 1,
            style: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 30.0,
                fontWeight: FontWeight.w900),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  items: LeaderBoard.items
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
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
                      color: Colors.white,
                    ),
                    elevation: 2,
                  ),
                  style: GoogleFonts.roboto(
                      color: Colors.black87,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                    ),
                    iconSize: 30,
                    iconEnabledColor: Colors.black87,
                    iconDisabledColor: Colors.grey,
                  ),
                  dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      width: 200,
                      padding: null,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                      elevation: 8,
                      offset: const Offset(-20, 0),
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
        body: LeaderBoard.selectedValue == LeaderBoard.items[2]
            ? StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('participant', isEqualTo: true)
                    .orderBy('balance', descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return loading();
                  }

                  return snapshot.data!.docs.isEmpty
                      ? Center(
                          child: AutoSizeText(
                            'Участников пока нет',
                            style: GoogleFonts.roboto(
                                color: Colors.black87.withOpacity(0.4),
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      : list(snapshot: snapshot);
                })
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy(
                        LeaderBoard.selectedValue == LeaderBoard.items.first
                            ? 'balance'
                            : 'totalGames',
                        descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return loading();
                  }

                  return list(snapshot: snapshot);
                }),
      ),
    );
  }

  Widget list(
      {required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      bool isShowRaiting = true}) {
    return ListView.separated(
        itemBuilder: (context, index) {
          double moneys = double.parse(
              snapshot.data?.docs[index].get('balance').toString() ?? '0');

          int totalGames = int.parse(
              snapshot.data?.docs[index].get('totalGames').toString() ?? '0');

          return GestureDetector(
            onTap: () {
              /*context.beamToNamed(
                '/user-history/${snapshot.data?.docs[index].get('name')}/${snapshot.data?.docs[index].get('uid')}',
              );*/
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 15.0, right: 15.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: buttonColor,
                  border:
                      (index + 1) == 1 || (index + 1) == 2 || (index + 1) == 3
                          ? Border.all(color: Colors.orangeAccent, width: 2.0)
                          : snapshot.data?.docs[index].get('uid') ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? Border.all(color: Colors.redAccent, width: 2.0)
                              : null,
                  boxShadow: [
                    BoxShadow(
                        color: (index + 1) == 1 ||
                                (index + 1) == 2 ||
                                (index + 1) == 3
                            ? Colors.orangeAccent.withOpacity(0.5)
                            : snapshot.data?.docs[index].get('uid') ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? Colors.redAccent.withOpacity(0.5)
                                : Colors.black.withOpacity(0.3),
                        blurRadius: 10.0)
                  ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AutoSizeText(
                                snapshot.data?.docs[index].get('name') ?? '',
                                style: GoogleFonts.roboto(
                                    color: Colors.black87,
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 10.0),
                              isShowRaiting
                                  ? snapshot.data?.docs[index].get('uid') !=
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? index == 0
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.orange
                                                            .withOpacity(0.5),
                                                        blurRadius: 8.0,
                                                        spreadRadius: 1.5)
                                                  ]),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: AutoSizeText(
                                                  'Самый богатый',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ),
                                            )
                                          : Container()
                                      : Container(
                                          margin: const EdgeInsets.only(
                                              right: 10.0),
                                          decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.redAccent
                                                        .withOpacity(0.5),
                                                    blurRadius: 8.0,
                                                    spreadRadius: 1.5)
                                              ]),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: AutoSizeText(
                                              'Вы',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                        )
                                  : Container(),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          AutoSizeText(
                            'Баланс: ${moneys < 1000000 ? NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(moneys) : NumberFormat.compactSimpleCurrency(locale: ui.Platform.localeName).format(moneys)}\nВсего игр: ${totalGames < 1000000 ? totalGames : NumberFormat.compact(locale: ui.Platform.localeName).format(totalGames)}',
                            style: GoogleFonts.roboto(
                                color: Colors.black87,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      )),
                  !isShowRaiting
                      ? Container()
                      : Padding(
                          padding:
                              const EdgeInsets.only(right: 15.0, top: 15.0),
                          child: AutoSizeText(
                            '#${(index + 1)}',
                            style: GoogleFonts.roboto(
                                color: Colors.black87,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (contex, index) => const SizedBox(height: 15.0),
        itemCount: snapshot.data?.docs.length ?? 0);
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
