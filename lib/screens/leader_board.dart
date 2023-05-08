import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io' as ui;

import 'package:new_mini_casino/models/loading.dart';

class LeaderBoard extends StatelessWidget {
  const LeaderBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            style: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 30.0,
                fontWeight: FontWeight.w900),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('balance', descending: true)
                .limit(100)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loading();
              }

              return ListView.separated(
                  itemBuilder: (context, index) {
                    double moneys = double.parse(
                        snapshot.data?.docs[index].get('balance').toString() ??
                            '0');

                    int totalGames = int.parse(snapshot.data?.docs[index]
                            .get('totalGames')
                            .toString() ??
                        '0');

                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          bottom: index + 1 == snapshot.data?.docs.length
                              ? 15.0
                              : 0.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                          border: (index + 1) == 1 ||
                                  (index + 1) == 2 ||
                                  (index + 1) == 3
                              ? Border.all(
                                  color: Colors.orangeAccent, width: 2.0)
                              : snapshot.data?.docs[index].get('uid') ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? Border.all(
                                      color: Colors.redAccent, width: 2.0)
                                  : null,
                          boxShadow: [
                            BoxShadow(
                                color: (index + 1) == 1 ||
                                        (index + 1) == 2 ||
                                        (index + 1) == 3
                                    ? Colors.orangeAccent.withOpacity(0.5)
                                    : snapshot.data?.docs[index].get('uid') ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid
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
                                        snapshot.data?.docs[index]
                                                .get('name') ??
                                            '',
                                        style: GoogleFonts.roboto(
                                            color: Colors.black87,
                                            fontSize: 23.0,
                                            fontWeight: FontWeight.w900),
                                      ),
                                      const SizedBox(width: 10.0),
                                      snapshot.data?.docs[index].get('uid') !=
                                              FirebaseAuth
                                                  .instance.currentUser!.uid
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
                                                      'Самый богатый',
                                                      textAlign:
                                                          TextAlign.center,
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
                                                      BorderRadius.circular(
                                                          12.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.redAccent
                                                            .withOpacity(0.5),
                                                        blurRadius: 8.0,
                                                        spreadRadius: 1.5)
                                                  ]),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: AutoSizeText(
                                                  'Вы',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ),
                                            ),
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
                          Padding(
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
                    );
                  },
                  separatorBuilder: (contex, index) =>
                      const SizedBox(height: 15.0),
                  itemCount: snapshot.data?.docs.length ?? 0);
            }),
      ),
    );
  }
}
