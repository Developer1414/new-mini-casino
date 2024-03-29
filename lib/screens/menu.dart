import 'dart:io' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/controllers/games_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/engineering_works_alert_dialog.dart';
import 'package:new_mini_casino/widgets/menu_game_button.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart' as provider;

class AllGames extends StatefulWidget {
  const AllGames({super.key});

  static Map<String, String> items = {
    '/leader-board': 'Лидер дня',
    '/promocode': 'Промокод',
    '/local-bonuses': 'Мои бонусы',
  };

  @override
  State<AllGames> createState() => _AllGamesState();
}

class _AllGamesState extends State<AllGames> {
  Future checkDailyBonus() async {
    await DailyBonusManager().checkDailyBonus().then((value) {
      if (value) {
        Beamer.of(context).beamToNamed('/daily-bonus');
      }
    });
  }

  Future checkOnEngineeringWorks() async {
    await SupabaseController.supabase!
        .from('settings')
        .select('*')
        .eq('setting', 'engineeringWorks')
        .then((value) {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      if (map['value'] as bool) {
        showEngineeringWorksAlertDialog(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkDailyBonus();
    checkOnEngineeringWorks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.buildingColumns,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color,
                            size: Theme.of(context).appBarTheme.iconTheme!.size,
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
                  size: Theme.of(context).appBarTheme.iconTheme!.size,
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
                    stream: SupabaseController.supabase
                        ?.from('notifications')
                        .stream(primaryKey: ['id']).inFilter('to',
                            [ProfileController.profileModel.nickname, 'all']),
                    builder: (context, snapshot) {
                      int count = snapshot.data?.length ?? 0;

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
            child: !provider.Provider.of<TaxManager>(context, listen: true)
                        .isCanPlay &&
                    !SupabaseController.isPremium
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        premiumButton(),
                        Column(
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
                        AutoSizeText(
                          'P.S. а с Premium платить налоги не нужно :)',
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
                          premiumButton(),
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
                                      context: context,
                                      gameLogo:
                                          GamesController.games[index].gameLogo,
                                      forPremium: GamesController
                                          .games[index].forPremium,
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
                                              color: const Color.fromARGB(
                                                  80, 42, 171, 238),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 42, 171, 238),
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
                                                Text('Здесь будет новая игра!',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall),
                                              ],
                                            ),
                                          ),
                                        )
                                      : gameButtonModel(
                                          context: context,
                                          gameLogo: GamesController
                                              .games[index].gameLogo,
                                          forPremium: GamesController
                                              .games[index].forPremium,
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
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: GlassContainer(
                              blur: 8,
                              color: const Color.fromARGB(80, 42, 171, 238)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    //color: const Color.fromARGB(80, 42, 171, 238),
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 42, 171, 238),
                                        width: 2.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Telegram',
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 22.0)),
                                      Text(
                                          'Подписывайтесь на наш телеграм канал, чтобы не пропускать новости и обновления!\n\nP.S. Раз в месяц там проходит розыгрыш на Premium!',
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      const SizedBox(height: 15.0),
                                      buttonModel(
                                        context: context,
                                        icon: FontAwesomeIcons.telegram,
                                        buttonName: 'Mini Casino',
                                        color: const Color.fromARGB(
                                            255, 42, 171, 238),
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: GlassContainer(
                              blur: 8,
                              color: const Color.fromARGB(80, 238, 104, 42)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    //color: const Color.fromARGB(80, 238, 104, 42),
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 238, 104, 42),
                                        width: 2.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Приведите друга',
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(fontSize: 22.0)),
                                      Text(
                                          'Вы и ваш друг, зарегистрировавшийся по вашему коду, получите вознаграждение! Вы до ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(100000)}, а друг до ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(20000)}',
                                          textAlign: TextAlign.left,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      const SizedBox(height: 15.0),
                                      buttonModel(
                                        context: context,
                                        icon: FontAwesomeIcons.share,
                                        buttonName: 'Поделиться',
                                        color: const Color.fromARGB(
                                            255, 238, 104, 42),
                                        onPressed: () async {
                                          await Share.share(
                                              'Привет! Скачивай игру Mini Casino (https://play.google.com/store/apps/details?id=com.revens.mini.casino), регистрируйся по моему коду (${SupabaseController.supabase?.auth.currentUser!.id}) и получай вознаграждение!');
                                        },
                                      ),
                                      const SizedBox(height: 15.0),
                                      buttonModel(
                                        context: context,
                                        icon: FontAwesomeIcons.solidCopy,
                                        buttonName: 'Скопировать код',
                                        color: const Color.fromARGB(
                                            255, 238, 104, 42),
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text: SupabaseController.supabase!
                                                  .auth.currentUser!.id));

                                          if (context.mounted) {
                                            alertDialogSuccess(
                                              context: context,
                                              title: 'Поздравляем',
                                              confirmBtnText: 'Окей!',
                                              text:
                                                  'Код скопирован! Теперь вы можете поделиться им с другом, и как только ваш друг зарегистрируется, вы оба получите награду!',
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SupabaseController.isPremium
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: const AppodealBanner(
                                        adSize: AppodealBannerSize.BANNER,
                                        placement: "default"),
                                  ),
                                )
                        ]),
                  ),
          ),
        ));
  }

  Widget premiumButton() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          height: 60.0,
          child: ElevatedButton(
            onPressed: () async {
              context.beamToNamed('/premium'); // premium // raffle-info

              /* showSimpleAlertDialog(
                  context: context,
                  text: 'Покупка Premium временно недоступна!');*/
            },
            style: ElevatedButton.styleFrom(
              elevation: 5,
              shadowColor:
                  const Color.fromARGB(255, 179, 242, 31).withOpacity(0.8),
              backgroundColor: const Color.fromARGB(255, 179, 242, 31),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  'MINI CASINO',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: const Color.fromARGB(255, 5, 2, 1),
                    fontSize: 22.0,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5.0),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.black87),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    child: AutoSizeText(
                      'PREMIUM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 22.0,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
