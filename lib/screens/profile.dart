import 'package:auto_size_text/auto_size_text.dart';
import 'package:circle_progress_bar/circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/money_storage_manager.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/imporant_user_profile_info_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:provider/provider.dart';

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
                          Navigator.of(context).pop();
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
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: IconButton(
                          splashRadius: 25.0,
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/settings'),
                          icon: FaIcon(
                            FontAwesomeIcons.gear,
                            color: Colors.white,
                            size: Theme.of(context).appBarTheme.iconTheme!.size,
                          )),
                    ),
                  ],
                ),
                body: isLoading
                    ? loading(context: context)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: ListView(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 15.0),
                                Container(
                                  height: 180.0,
                                  decoration: ShapeDecoration(
                                    shape: const CircleBorder(),
                                    color:
                                        Colors.lightBlueAccent.withOpacity(0.1),
                                  ),
                                  child: CircleProgressBar(
                                    foregroundColor:
                                        const Color.fromARGB(255, 179, 242, 31),
                                    backgroundColor:
                                        Colors.lightBlueAccent.withOpacity(0.5),
                                    strokeWidth: 10.0,
                                    value:
                                        ProfileController.profileModel.level -
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
                            const SizedBox(height: 15.0),
                            Column(
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
                            const SizedBox(height: 15.0),
                            Container(
                              width: double.infinity,
                              height: 2.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            const SizedBox(height: 15.0),
                            buttonModel(
                                context: context,
                                icon: FontAwesomeIcons.coins,
                                buttonName: 'Хранилище',
                                color: const Color.fromARGB(255, 226, 153, 57),
                                onPressed: () async {
                                  Provider.of<MoneyStorageManager>(context,
                                          listen: false)
                                      .loadBalance(context);

                                  Navigator.of(context)
                                      .pushNamed('/money-storage');
                                }),
                            const SizedBox(height: 15.0),
                          ],
                        ),
                      ));
      },
    );
  }
}
