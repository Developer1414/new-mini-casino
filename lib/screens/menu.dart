import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/games_controller.dart';
import 'package:new_mini_casino/models/menu_game_button.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
                        onPressed: () {
                          AdService.showRewardedAd(
                              context: context,
                              func: () {
                                Provider.of<Balance>(context, listen: false)
                                    .getReward(
                                        context: context, rewardCount: 500);
                              });
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.orange.shade400,
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
                                FontAwesomeIcons.dice,
                                color: Colors.white,
                                size: 25.0,
                              ),
                              const SizedBox(width: 10.0),
                              AutoSizeText(
                                'Испытать удачу',
                                style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w700),
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
                    title: AutoSizeText(
                      'Игры',
                      style: GoogleFonts.roboto(
                          color: Colors.black87,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900),
                    ),
                    actions: [
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
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Consumer<Balance>(
                              builder: (context, value, _) {
                                return AutoSizeText(
                                  'Баланс: ${value.currentBalanceString}',
                                  style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w900),
                                );
                              },
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
                              childCount: GamesController().games.length,
                              (context, index) => gameButtonModel(
                                  gameLogo:
                                      GamesController().games[index].gameLogo,
                                  buttonTitle:
                                      GamesController().games[index].title,
                                  onTap: () {
                                    context.beamToNamed(GamesController()
                                        .games[index]
                                        .nextScreen);
                                  },
                                  buttonColor: GamesController()
                                      .games[index]
                                      .buttonColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25.0))),
                            ),
                          ),
                        ]),
                  ));
            }));
  }
}
