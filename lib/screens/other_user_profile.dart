import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io' as ui;

import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/widgets/imporant_user_profile_info_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/profile_button_model.dart';

class OtherUserProfile extends StatelessWidget {
  const OtherUserProfile(
      {super.key,
      required this.userId,
      required this.userName,
      required this.pinId});

  final String userId;
  final String userName;
  final int pinId;

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
            title: Row(
              children: [
                AutoSizeText(
                  userName,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                const SizedBox(width: 10.0),
                pinId != -1
                    ? Image(
                        image: AssetImage('assets/pins/$pinId.png'),
                        width: 25.0,
                        height: 25.0)
                    : Container(),
              ],
            ),
          ),
          body: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                double level = 1.0;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loading(context: context);
                }

                if (snapshot.data?.data()!.containsKey('level') ?? false) {
                  level = double.parse(
                      snapshot.data?.get('level').toString() ?? '1.0');
                }

                double balance = double.parse(
                    snapshot.data?.get('balance').toString() ?? '0');

                int totalGames = int.parse(
                    snapshot.data?.get('totalGames').toString() ?? '0');

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15.0),
                          Container(
                            height: 180.0,
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: Theme.of(context).cardColor,
                            ),
                            child: CircleProgressBar(
                              foregroundColor: Colors.green,
                              backgroundColor: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .background,
                              strokeWidth: 10.0,
                              value: level - level.truncate(),
                              child: Center(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      level.floor().toStringAsFixed(0),
                                      maxLines: 1,
                                      style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 40.0,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    AutoSizeText('LVL',
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontSize: 12.0,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .color!
                                                    .withOpacity(0.7))),
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 15.0),
                        child: Column(
                          children: [
                            importantUserProfileInfo(
                                context: context,
                                content: NumberFormat.simpleCurrency(
                                        locale: ui.Platform.localeName)
                                    .format(balance),
                                title: 'Баланс'),
                            const SizedBox(height: 15.0),
                            importantUserProfileInfo(
                                context: context,
                                content: NumberFormat.compact(locale: 'ru_RU')
                                    .format(totalGames),
                                title: 'Игр'),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 2.0,
                        margin: const EdgeInsets.symmetric(horizontal: 25.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Theme.of(context).cardColor),
                      ),
                      const SizedBox(height: 15.0),
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: profileButton(
                                context: context,
                                icon: FontAwesomeIcons.car,
                                text: 'Имущество',
                                onPressed: () {
                                  StoreManager.storeViewer =
                                      StoreViewer.otherUser;
                                  StoreManager.otherUserId = userId;
                                  Beamer.of(context)
                                      .beamToNamed('/store-items');
                                }),
                          )),
                    ],
                  ),
                );
              })

          /*SingleChildScrollView(
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
        ),*/
          ),
    );
  }
}
