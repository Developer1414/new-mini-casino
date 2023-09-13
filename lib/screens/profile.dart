import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/models/profile_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late ProfileModel profileModel;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future loadUserInfo() async {
    setState(() {
      isLoading = true;
    });

    await ProfileController.getUserProfile().then((value) {
      profileModel = value;
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return Consumer<AccountController>(
      builder: (context, accountController, _) {
        return accountController.isLoading || isLoading
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
                  title: FutureBuilder(
                    future: ProfileController.getUserProfile(),
                    builder: (context, snapshot) {
                      return AutoSizeText(
                        profileModel.nickname,
                        maxLines: 1,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      );
                    },
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
                            value: profileModel.level -
                                profileModel.level.truncate(),
                            child: Center(
                                child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    profileModel.level
                                        .floor()
                                        .toStringAsFixed(0),
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
                        const SizedBox(width: 15.0),
                        Expanded(
                          child: Column(
                            children: [
                              importantUserInfo(
                                  content: balance.currentBalanceString,
                                  title: 'Баланс'),
                              const SizedBox(height: 15.0),
                              importantUserInfo(
                                  content: NumberFormat.compact(locale: 'ru_RU')
                                      .format(profileModel.totalGame),
                                  title: 'Игр'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      width: double.infinity,
                      height: 2.0,
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10.0)
                          ]),
                    ),
                    const SizedBox(height: 15.0),
                    Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: profileButton(
                                icon: FontAwesomeIcons.coins,
                                text: 'Хранилище',
                                onPressed: () => Beamer.of(context)
                                    .beamToNamed('/money-storage'),
                              ),
                            ),
                            const SizedBox(width: 15.0),
                            Expanded(
                              child: profileButton(
                                  icon: FontAwesomeIcons.car,
                                  text: 'Имущество',
                                  onPressed: () {
                                    StoreManager.showOnlyBuyedItems = true;
                                    Beamer.of(context)
                                        .beamToNamed('/store-items');
                                  }),
                            ),
                          ],
                        )),
                  ],
                ));
      },
    );
  }

  Widget importantUserInfo({required String content, required String title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      margin: const EdgeInsets.only(right: 15.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
          ]),
      child: Column(
        children: [
          AutoSizeText(
            content,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .appBarTheme
                .titleTextStyle!
                .copyWith(fontSize: 25.0),
          ),
          const SizedBox(height: 5.0),
          AutoSizeText(title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 12.0,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .color!
                      .withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget profileButton(
      {required IconData icon,
      required String text,
      required Function() onPressed}) {
    return SizedBox(
      height: 112.0,
      child: ElevatedButton(
        onPressed: () {
          onPressed.call();
        },
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor:
              Theme.of(context).buttonTheme.colorScheme!.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                color: Colors.white,
                size: 35.0,
              ),
              const SizedBox(height: 10.0),
              AutoSizeText(
                text,
                maxLines: 1,
                style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800),
              )
            ],
          ),
        ),
      ),
    );
  }
}
