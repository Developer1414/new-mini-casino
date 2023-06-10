import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/games_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/models/menu_game_button.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AllGames extends StatelessWidget {
  const AllGames({super.key});

  @override
  Widget build(BuildContext context) {
    AccountController accountController = AccountController();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: Provider.of<Balance>(context).loadBalance(),
            builder: (context, snapshot) {
              return Scaffold(
                  bottomNavigationBar: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .get()
                              .then((value) async {
                            if (value.data()!.containsKey('freeBonusInfo')) {
                              List freeBonusInfo =
                                  value.get('freeBonusInfo') as List;

                              if ((freeBonusInfo[1] as Timestamp)
                                      .toDate()
                                      .day ==
                                  DateTime.now().day) {
                                if (int.parse(freeBonusInfo[0].toString()) >=
                                    (AccountController.isPremium ? 10 : 5)) {
                                  if (AccountController.isPremium) {
                                    // ignore: use_build_context_synchronously
                                    alertDialogError(
                                        context: context,
                                        title: 'Ошибка',
                                        text:
                                            'Вы превысили лимит бесплатного бонуса (10 использований в день). Попробуйте на следующий день.');
                                    return;
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    await QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.confirm,
                                        title: 'Ошибка',
                                        text:
                                            'Вы превысили лимит бесплатного бонуса (5 использований в день). Хотите приобрести Mini Casino Premium с доступом к 10 бесплатным бонусам в день и другим возможностям всего за 99 рублей?',
                                        confirmBtnText: 'Да',
                                        cancelBtnText: 'Нет',
                                        confirmBtnColor: Colors.green,
                                        animType:
                                            QuickAlertAnimType.slideInDown,
                                        onCancelBtnTap: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        },
                                        onConfirmBtnTap: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();

                                          context.beamToNamed('/premium');
                                        });
                                  }
                                  return;
                                }
                              }
                            }

                            // ignore: use_build_context_synchronously
                            AdService.showRewardedAd(
                                context: context,
                                func: () async {
                                  Provider.of<Balance>(context, listen: false)
                                      .getReward(
                                          context: context,
                                          rewardCount: double.parse((Random()
                                                      .nextInt(AccountController
                                                              .isPremium
                                                          ? 900
                                                          : 200) +
                                                  100)
                                              .toString()));
                                });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.purple.shade400,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.coins,
                                color: Colors.white,
                                size: 25.0,
                              ),
                              const SizedBox(width: 10.0),
                              AutoSizeText(
                                'Бесплатный бонус',
                                maxLines: 1,
                                style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      )),
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
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.confirm,
                                title: 'Подтверждение',
                                text:
                                    'Вы уверены что хотите выйти из аккаунта?',
                                confirmBtnText: 'Нет',
                                cancelBtnText: 'Да',
                                showCancelBtn: true,
                                confirmBtnColor: Colors.redAccent,
                                animType: QuickAlertAnimType.slideInDown,
                                onCancelBtnTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();

                                  accountController.signOut().whenComplete(() {
                                    context.beamToReplacementNamed('/login');
                                  });
                                },
                                onConfirmBtnTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                });
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.rightFromBracket,
                            color: Colors.redAccent,
                            size: 30.0,
                          )),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'Игры',
                          style: GoogleFonts.roboto(
                              color: Colors.black87,
                              fontSize: 30.0,
                              fontWeight: FontWeight.w900),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          child: Consumer<Balance>(
                            builder: (context, value, _) {
                              return AutoSizeText(
                                value.currentBalanceString,
                                style: GoogleFonts.roboto(
                                    color: Colors.black87,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w900),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                            splashRadius: 25.0,
                            padding: EdgeInsets.zero,
                            onPressed: () => context.beamToNamed('/premium'),
                            icon: const FaIcon(
                              FontAwesomeIcons.solidStar,
                              color: Colors.redAccent,
                              size: 28.0,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                            splashRadius: 25.0,
                            padding: EdgeInsets.zero,
                            onPressed: () =>
                                context.beamToNamed('/leader-board'),
                            icon: const FaIcon(
                              FontAwesomeIcons.rankingStar,
                              color: Colors.black87,
                              size: 28.0,
                            )),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, bottom: 15.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SizedBox(
                                height: 60.0,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.beamToNamed('/raffle_info');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    shadowColor:
                                        const Color.fromARGB(255, 255, 0, 96)
                                            .withOpacity(0.8),
                                    backgroundColor:
                                        const Color.fromARGB(255, 255, 0, 96),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const FaIcon(
                                          FontAwesomeIcons.sackDollar,
                                          color: Colors.white,
                                          size: 25.0,
                                        ),
                                        const SizedBox(width: 10.0),
                                        AutoSizeText(
                                          'Розыгрыш',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.w900,
                                              shadows: [
                                                Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    blurRadius: 20.0)
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GridView.custom(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: SliverWovenGridDelegate.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 0,
                                pattern: const [
                                  WovenGridTile(1),
                                  WovenGridTile(
                                    7 / 7,
                                    crossAxisRatio: 0.9,
                                    alignment: AlignmentDirectional.centerEnd,
                                  ),
                                ],
                              ),
                              childrenDelegate: SliverChildBuilderDelegate(
                                childCount: GamesController.games.length,
                                (context, index) => gameButtonModel(
                                    gameLogo:
                                        GamesController.games[index].gameLogo,
                                    isSoon: GamesController.games[index].isSoon,
                                    buttonTitle:
                                        GamesController.games[index].title,
                                    onTap: () {
                                      context.beamToNamed(GamesController
                                          .games[index].nextScreen);
                                    },
                                    buttonColor: GamesController
                                        .games[index].buttonColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(25.0))),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15.0),
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(80, 42, 171, 238),
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 42, 171, 238),
                                      width: 2.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Telegram',
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.w900,
                                        ))),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                          'Подписывайтесь на наш телеграм канал, чтобы не пропускать новости и обновления!',
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.roboto(
                                              textStyle: TextStyle(
                                            color:
                                                Colors.black87.withOpacity(0.7),
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w700,
                                          ))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: SizedBox(
                                        height: 60.0,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (!await launchUrl(
                                                Uri.parse(
                                                    'https://t.me/mini_casino_info'),
                                                mode: LaunchMode
                                                    .externalNonBrowserApplication)) {
                                              throw Exception(
                                                  'Could not launch ${Uri.parse('https://t.me/mini_casino_info')}');
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 5,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 42, 171, 238),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const FaIcon(
                                                FontAwesomeIcons.telegram,
                                                color: Colors.white,
                                                size: 30.0,
                                              ),
                                              const SizedBox(width: 10.0),
                                              AutoSizeText(
                                                'Mini Casino',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 25.0,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ));
            }));
  }
}
