import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io' as ui;

import 'package:new_mini_casino/business/store_manager.dart';

class OtherUserProfile extends StatelessWidget {
  const OtherUserProfile(
      {super.key,
      required this.userid,
      required this.userName,
      required this.totalGames,
      required this.balance});

  final String userid;
  final String userName;
  final int totalGames;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => Beamer.of(context).beamBack(),
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
                  Beamer.of(context).beamBack();
                },
                icon: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Theme.of(context).appBarTheme.iconTheme!.color,
                  size: Theme.of(context).appBarTheme.iconTheme!.size,
                )),
          ),
          title: AutoSizeText(
            userName,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 250.0,
                margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.grey.shade900,
                          Colors.grey.shade900.withOpacity(0.8)
                        ]),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10.0)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 12.0, top: 20.0),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: const Image(
                                          image: AssetImage(
                                              'assets/other_images/logo.png'),
                                          width: 45.0,
                                          height: 45.0),
                                    )),
                                Transform.translate(
                                  offset: const Offset(0, 10),
                                  child: AutoSizeText(
                                    'MC Bank',
                                    maxLines: 1,
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: Icon(Icons.wifi_rounded,
                                  color: Colors.white, size: 35.0),
                            )
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 20.0),
                            child: AutoSizeText(
                              'Баланс: ${balance < 1000000 ? NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(balance) : NumberFormat.compactSimpleCurrency(locale: ui.Platform.localeName).format(balance)}',
                              style: GoogleFonts.roboto(
                                  color: Colors.grey.shade300,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800),
                            )),
                        const SizedBox(height: 5.0),
                        Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: AutoSizeText(
                              'Игр: $totalGames',
                              style: GoogleFonts.roboto(
                                  color: Colors.grey.shade300,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700),
                            )),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            userName,
                            style: GoogleFonts.shareTechMono(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700),
                          ),
                          AutoSizeText(
                            'VI\$A',
                            maxLines: 1,
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 15.0),
                          width: 26.0,
                          height: 26.0,
                          child: const CircularProgressIndicator(
                            strokeWidth: 5.0,
                            color: Colors.blueAccent,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        panelModel(
                            context: context,
                            title: 'Автомобили',
                            items: snapshot.data!.data()!.containsKey('cars')
                                ? List<int>.from(snapshot.data!.get('cars'))
                                : [],
                            icon: FontAwesomeIcons.car,
                            storeId: 0),
                        panelModel(
                            context: context,
                            title: 'Дома',
                            items: snapshot.data!.data()!.containsKey('houses')
                                ? List<int>.from(snapshot.data!.get('houses'))
                                : [],
                            icon: FontAwesomeIcons.house,
                            storeId: 2),
                        const SizedBox(height: 15.0)
                      ],
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget panelModel(
      {required String title,
      List<int>? items,
      required BuildContext context,
      required IconData icon,
      required int storeId}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            boxShadow: items == null
                ? null
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5), blurRadius: 10.0)
                  ],
            color: items != null
                ? Theme.of(context).cardColor
                : Colors.grey.shade400.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: items == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      icon,
                      color: Colors.white,
                      size: 22.0,
                    ),
                    const SizedBox(height: 5.0),
                    AutoSizeText(title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 22.0)),
                    const SizedBox(height: 5.0),
                    AutoSizeText(
                      'Игрок еще не приобрёл',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 15.0,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(title,
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 22.0)),
                    AutoSizeText('Всего: ${items.length}',
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(fontSize: 18.0)),
                    const SizedBox(height: 15.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < items.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                  right: i + 1 < items.length ? 15.0 : 0.0),
                              child: Image(
                                fit: BoxFit.cover,
                                height: 150.0,
                                image: AssetImage(
                                  'assets/${StoreManager().stores[storeId].pathTitle}/${items[i]}.png',
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
