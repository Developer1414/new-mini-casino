import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:new_mini_casino/themes/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  static String userNickname = '';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();

    if (Profile.userNickname.isEmpty) {
      ProfileController.getUserProfile()
          .then((value) => Profile.userNickname = value.nickname);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountController>(
      builder: (context, accountController, _) {
        return accountController.isLoading
            ? loading(context: context)
            : Scaffold(
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
                    'Профиль',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  actions: [
                    /*Consumer<DarkThemeProvider>(
                        builder: (context, themeChange, _) {
                      return IconButton(
                          splashRadius: 25.0,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            themeChange.darkTheme = !themeChange.darkTheme;
                          },
                          icon: Icon(
                            themeChange.darkTheme
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: themeChange.darkTheme
                                ? Colors.white
                                : Colors.black87,
                            size: 30.0,
                          ));
                    }),
                    const SizedBox(width: 5.0),*/
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
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
                                    Provider.of<Balance>(context, listen: false)
                                        .balance = 0.0;
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
                  ],
                ),
                body: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 250.0,
                      margin: const EdgeInsets.only(
                          left: 15.0, right: 15.0, bottom: 15.0),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              right: 12.0,
                                              top: 20.0),
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
                                child: Consumer<Balance>(
                                    builder: (ctx, balance, _) {
                                  return AutoSizeText(
                                    'Баланс: ${balance.currentBalanceString}',
                                    style: GoogleFonts.roboto(
                                        color: Colors.grey.shade300,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w800),
                                  );
                                }),
                              ),
                              const SizedBox(height: 5.0),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: FutureBuilder(
                                    future: ProfileController.getUserProfile(),
                                    builder: (context, snapshot) {
                                      return AutoSizeText(
                                        'Игр: ${snapshot.data?.totalGame.toString() ?? '0'}',
                                        style: GoogleFonts.roboto(
                                            color: Colors.grey.shade300,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w700),
                                      );
                                    },
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
                                Profile.userNickname.isEmpty
                                    ? FutureBuilder(
                                        future:
                                            ProfileController.getUserProfile(),
                                        builder: (context, snapshot) {
                                          return AutoSizeText(
                                            snapshot.data?.nickname ?? '',
                                            style: GoogleFonts.shareTechMono(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w700),
                                          );
                                        },
                                      )
                                    : AutoSizeText(
                                        Profile.userNickname,
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
                    buttonModel(
                        buttonName: 'Хранилище',
                        uri: '/money-storage',
                        color: Colors.blue,
                        icon: FontAwesomeIcons.coins),
                    const SizedBox(height: 15.0),
                    buttonModel(
                        buttonName: 'Имущество',
                        uri: '/store-items',
                        onPressed: () {
                          StoreManager.showOnlyBuyedItems = true;
                        },
                        color: Colors.pink,
                        icon: FontAwesomeIcons.car),
                  ],
                ),
              );
      },
    );
  }

  Widget buttonModel(
      {required String buttonName,
      required String uri,
      required Color color,
      Function()? onPressed,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: SizedBox(
        height: 60.0,
        child: ElevatedButton(
          onPressed: () {
            onPressed?.call();
            context.beamToNamed(uri);
          },
          style: ElevatedButton.styleFrom(
            elevation: 5,
            shadowColor: color.withOpacity(0.8),
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  icon,
                  color: Colors.white,
                  size: 22.0,
                ),
                const SizedBox(width: 10.0),
                AutoSizeText(
                  buttonName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
