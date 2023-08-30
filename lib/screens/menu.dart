import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/controllers/games_controller.dart';
import 'package:new_mini_casino/models/menu_game_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart' as badges;

class AllGames extends StatefulWidget {
  const AllGames({super.key});

  static Map<String, String> items = {
    '/leader-board': 'Лидеры',
    '/promocode': 'Промокод',
  };

  @override
  State<AllGames> createState() => _AllGamesState();
}

class _AllGamesState extends State<AllGames> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.beamToNamed('/bank');
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.blue.shade700,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0, bottom: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.buildingColumns,
                            color: Colors.white,
                            size: 22.0,
                          ),
                          const SizedBox(width: 10.0),
                          AutoSizeText(
                            'Банк',
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
                      StoreManager.showOnlyBuyedItems = false;
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
                      padding: const EdgeInsets.only(top: 18.0, bottom: 18.0),
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
                  context.beamToNamed('/profile');
                },
                icon: FaIcon(
                  FontAwesomeIcons.solidUser,
                  color: Theme.of(context).appBarTheme.iconTheme!.color,
                  size: Theme.of(context)
                      .appBarTheme
                      .iconTheme!
                      .copyWith(size: 28.0)
                      .size,
                )),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                'Игры',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Consumer<Balance>(builder: (ctx, balance, _) {
                  return AutoSizeText(
                    balance.currentBalanceString,
                    style: Theme.of(context).textTheme.displaySmall,
                  );
                }),
              ),
            ],
          ),
          actions: [
            IconButton(
                splashRadius: 25.0,
                padding: EdgeInsets.zero,
                onPressed: () => context.beamToNamed('/notifications'),
                icon: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('notifications')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int count = snapshot.data?.docs
                              .where((element) =>
                                  element.get('uid') ==
                                      FirebaseAuth.instance.currentUser!.uid ||
                                  element.get('uid') == 'all')
                              .length ??
                          0;

                      return count > 0
                          ? badges.Badge(
                              badgeContent: Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: AutoSizeText(
                                  count > 9 ? '9+' : count.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontSize: 12.0),
                                ),
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.solidBell,
                                color: Theme.of(context)
                                    .appBarTheme
                                    .iconTheme!
                                    .color,
                                size: Theme.of(context)
                                    .appBarTheme
                                    .iconTheme!
                                    .copyWith(size: 25.0)
                                    .size,
                              ))
                          : FaIcon(
                              FontAwesomeIcons.solidBell,
                              color: Theme.of(context)
                                  .appBarTheme
                                  .iconTheme!
                                  .color,
                              size: Theme.of(context)
                                  .appBarTheme
                                  .iconTheme!
                                  .copyWith(size: 25.0)
                                  .size,
                            );
                    })),
            const SizedBox(width: 15.0),
            Padding(
              padding:
                  const EdgeInsets.only(right: 15.0, top: 15.0, bottom: 15.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  customButton: Center(
                    child: FaIcon(
                      FontAwesomeIcons.bars,
                      color: Theme.of(context).appBarTheme.iconTheme!.color,
                      size: Theme.of(context).appBarTheme.iconTheme!.size,
                    ),
                  ),
                  items: AllGames.items.values
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontSize: 14.0)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    context.beamToNamed(AllGames.items.entries
                        .where((element) => element.value == value)
                        .first
                        .key);
                  },
                  buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0)),
                      height: 30.0,
                      padding: const EdgeInsets.all(15.0)),
                  style: GoogleFonts.roboto(
                      color: Colors.black87,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700),
                  dropdownStyleData: DropdownStyleData(
                      width: 160,
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
        body: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: !Provider.of<TaxManager>(context, listen: true).isCanPlay
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.lock,
                          color: Colors.white,
                          size: 80.0,
                        ),
                        const SizedBox(height: 10.0),
                        AutoSizeText(
                          'Заплатите налог',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        AutoSizeText(
                          'Заплатите налог, чтобы продолжить играть',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                    shadowColor:
                                        Colors.redAccent.withOpacity(0.8),
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                color: Colors.black
                                                    .withOpacity(0.3),
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15),
                            childrenDelegate: SliverChildBuilderDelegate(
                              childCount: GamesController.games.length.isEven
                                  ? GamesController.games.length
                                  : GamesController.games.length + 1,
                              (context, index) => GamesController
                                      .games.length.isEven
                                  ? gameButtonModel(
                                      gameLogo:
                                          GamesController.games[index].gameLogo,
                                      isSoon:
                                          GamesController.games[index].isSoon,
                                      isNew: GamesController.games[index].isNew,
                                      buttonTitle:
                                          GamesController.games[index].title,
                                      onTap: () {
                                        context.beamToNamed(GamesController
                                            .games[index].nextScreen);
                                      },
                                      buttonColor: GamesController
                                          .games[index].buttonColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25.0)))
                                  : index == GamesController.games.length
                                      ? Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                      .appBarTheme
                                                      .iconTheme!
                                                      .color!,
                                                  width: 2.0)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.lock,
                                                  color: Theme.of(context)
                                                      .appBarTheme
                                                      .iconTheme!
                                                      .color,
                                                  size: 30.0,
                                                ),
                                                const SizedBox(height: 10.0),
                                                Text(
                                                    'Скоро здесь будет новая игра!',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall),
                                              ],
                                            ),
                                          ),
                                        )
                                      : gameButtonModel(
                                          gameLogo: GamesController
                                              .games[index].gameLogo,
                                          isSoon: GamesController
                                              .games[index].isSoon,
                                          isNew: GamesController
                                              .games[index].isNew,
                                          buttonTitle: GamesController
                                              .games[index].title,
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
                                    color:
                                        const Color.fromARGB(255, 42, 171, 238),
                                    width: 2.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Telegram',
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 22.0)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                        'Подписывайтесь на наш телеграм канал, чтобы не пропускать новости и обновления!',
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
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
                                          backgroundColor: const Color.fromARGB(
                                              255, 42, 171, 238),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0)),
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
          ),
        ));
  }
}
