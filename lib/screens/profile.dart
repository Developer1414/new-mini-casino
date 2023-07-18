import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:new_mini_casino/services/generate_unique_bank_id.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AccountController>(
        builder: (context, accountController, _) {
          return accountController.isLoading
              ? loading()
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
                          icon: const FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            color: Colors.black87,
                            size: 30.0,
                          )),
                    ),
                    title: AutoSizeText(
                      'Профиль',
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

                                    accountController
                                        .signOut()
                                        .whenComplete(() {
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
                                      balance.currentBalanceString,
                                      style: GoogleFonts.roboto(
                                          color: Colors.grey.shade300,
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.w800),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 20.0),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  child: AutoSizeText(
                                    FirebaseAuth.instance.currentUser != null
                                        ? generateUniqueId(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        : 'null',
                                    maxLines: 1,
                                    style: GoogleFonts.shareTechMono(
                                        letterSpacing: 3.0,
                                        color: Colors.grey.shade300,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, bottom: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Profile.userNickname.isEmpty
                                      ? FutureBuilder(
                                          future: ProfileController
                                              .getUserProfile(),
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
                    ],
                  ),
                );
        },
      ),
    );
  }
}
