import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/bonus_manager.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/controllers/games_controller.dart';
import 'package:new_mini_casino/models/menu_game_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AllGames extends StatefulWidget {
  const AllGames({super.key});

  @override
  State<AllGames> createState() => _AllGamesState();
}

class _AllGamesState extends State<AllGames> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Consumer<BonusManager>(
          builder: (ctx, value, _) {
            return Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async => value.getFreeBonus(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.purple.shade400,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0)),
                          ),
                        ),
                        child: value.isLoadingBonus
                            ? const Padding(
                                padding: EdgeInsets.all(18.0),
                                child: SizedBox(
                                  width: 26.0,
                                  height: 26.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5.0,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    top: 18.0, bottom: 18.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.gift,
                                      color: Colors.white,
                                      size: 22.0,
                                    ),
                                    const SizedBox(width: 10.0),
                                    AutoSizeText(
                                      'Бонус',
                                      maxLines: 1,
                                      style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.w800),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          StoreManager.showOnlyMyItems = false;
                          context.beamToNamed('/store-items');
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: Colors.green,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0)),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 18.0, bottom: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.store,
                                color: Colors.white,
                                size: 22.0,
                              ),
                              const SizedBox(width: 10.0),
                              AutoSizeText(
                                'Магазин',
                                maxLines: 1,
                                style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w800),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
          },
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
                onPressed: () {
                  context.beamToNamed('/profile');
                },
                icon: const FaIcon(
                  FontAwesomeIcons.solidUser,
                  color: Colors.black87,
                  size: 28.0,
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
                child: Consumer<Balance>(builder: (ctx, balance, _) {
                  return AutoSizeText(
                    balance.currentBalanceString,
                    style: GoogleFonts.roboto(
                        color: Colors.black87,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900),
                  );
                }),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                splashRadius: 25.0,
                padding: EdgeInsets.zero,
                onPressed: () => context.beamToNamed('/promocode'),
                icon: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color.fromARGB(255, 100, 34, 255),
                  size: 32.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                  splashRadius: 25.0,
                  padding: EdgeInsets.zero,
                  onPressed: () => context.beamToNamed('/leader-board'),
                  icon: const FaIcon(
                    FontAwesomeIcons.rankingStar,
                    color: Colors.black87,
                    size: 25.0,
                  )),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    height: 60.0,
                    child: ElevatedButton(
                      onPressed: () {
                        context.beamToNamed('/premium');
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        shadowColor: Colors.redAccent.withOpacity(0.8),
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.solidStar,
                              color: Colors.white,
                              size: 22.0,
                            ),
                            const SizedBox(width: 10.0),
                            AutoSizeText(
                              'Premium',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 22.0,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20.0,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
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
                  childCount: GamesController.games.length.isEven
                      ? GamesController.games.length
                      : GamesController.games.length + 1,
                  (context, index) => GamesController.games.length.isEven
                      ? gameButtonModel(
                          gameLogo: GamesController.games[index].gameLogo,
                          isSoon: GamesController.games[index].isSoon,
                          isNew: GamesController.games[index].isNew,
                          buttonTitle: GamesController.games[index].title,
                          onTap: () {
                            context.beamToNamed(
                                GamesController.games[index].nextScreen);
                          },
                          buttonColor: GamesController.games[index].buttonColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25.0)))
                      : index == GamesController.games.length
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: Colors.black87, width: 2.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.lock,
                                      color: Colors.black87,
                                      size: 30.0,
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text('Скоро здесь будет новая игра',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700,
                                        ))),
                                  ],
                                ),
                              ),
                            )
                          : gameButtonModel(
                              gameLogo: GamesController.games[index].gameLogo,
                              isSoon: GamesController.games[index].isSoon,
                              isNew: GamesController.games[index].isNew,
                              buttonTitle: GamesController.games[index].title,
                              onTap: () {
                                context.beamToNamed(
                                    GamesController.games[index].nextScreen);
                              },
                              buttonColor:
                                  GamesController.games[index].buttonColor,
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
                        color: const Color.fromARGB(255, 42, 171, 238),
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
                              color: Colors.black87.withOpacity(0.7),
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
                                  Uri.parse('https://t.me/mini_casino_info'),
                                  mode: LaunchMode
                                      .externalNonBrowserApplication)) {
                                throw Exception(
                                    'Could not launch ${Uri.parse('https://t.me/mini_casino_info')}');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              backgroundColor:
                                  const Color.fromARGB(255, 42, 171, 238),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
  }
}
