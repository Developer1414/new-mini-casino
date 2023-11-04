import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/change_nickname_alert.dart';
import 'package:new_mini_casino/widgets/imporant_user_profile_info_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/profile_button_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future loadUserInfo() async {
    await ProfileController.getUserProfile(context);
  }

  @override
  Widget build(BuildContext context) {
    final balance = Provider.of<Balance>(context, listen: false);

    return Consumer<SupabaseController>(
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
                  title: FutureBuilder(
                    future: ProfileController.getUserProfile(context),
                    builder: (context, snapshot) {
                      return AutoSizeText(
                        ProfileController.profileModel.nickname,
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

                    IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: () => changeNicknameAlert(context: context),
                        icon: const FaIcon(
                          FontAwesomeIcons.pen,
                          color: Colors.white,
                          size: 27.0,
                        )),
                    const SizedBox(width: 5.0),
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
                body: isLoading
                    ? loading(context: context)
                    : ListView(
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
                                  foregroundColor:
                                      const Color.fromARGB(255, 179, 242, 31),
                                  backgroundColor: Theme.of(context)
                                      .buttonTheme
                                      .colorScheme!
                                      .background,
                                  strokeWidth: 10.0,
                                  value: ProfileController.profileModel.level -
                                      ProfileController.profileModel.level
                                          .truncate(),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          ProfileController.profileModel.level
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
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 15.0),
                            child: Column(
                              children: [
                                importantUserProfileInfo(
                                    context: context,
                                    content: balance.currentBalanceString,
                                    title: 'Баланс'),
                                const SizedBox(height: 15.0),
                                importantUserProfileInfo(
                                    context: context,
                                    content:
                                        NumberFormat.compact(locale: 'ru_RU')
                                            .format(ProfileController
                                                .profileModel.totalGame),
                                    title: 'Игр'),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 2.0,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .background,
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: profileButton(
                                      context: context,
                                      icon: FontAwesomeIcons.coins,
                                      text: 'Хранилище',
                                      onPressed: () => Beamer.of(context)
                                          .beamToNamed('/money-storage'),
                                    ),
                                  ),
                                  const SizedBox(width: 15.0),
                                  Expanded(
                                    child: profileButton(
                                        context: context,
                                        icon: FontAwesomeIcons.car,
                                        text: 'Имущество',
                                        onPressed: () {
                                          StoreManager.storeViewer =
                                              StoreViewer.my;
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
}
