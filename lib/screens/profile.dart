import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:new_mini_casino/models/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

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
                                  confirmBtnText: 'Да',
                                  cancelBtnText: 'Нет',
                                  showCancelBtn: true,
                                  confirmBtnColor: Colors.green,
                                  animType: QuickAlertAnimType.slideInDown,
                                  onCancelBtnTap: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  onConfirmBtnTap: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();

                                    accountController
                                        .signOut()
                                        .whenComplete(() {
                                      context.beamToReplacementNamed('/login');
                                    });
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
                  body: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 180.0,
                          height: 180.0,
                          margin:
                              const EdgeInsets.only(top: 15.0, bottom: 15.0),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(100.0)),
                          child: Icon(
                            Icons.person_rounded,
                            size: 80.0,
                            color: Colors.grey.shade500.withOpacity(0.7),
                          ),
                        ),
                        FutureBuilder<ProfileModel>(
                            future: ProfileController.getUserProfile(),
                            builder: (context, snapshot) {
                              return AutoSizeText(
                                snapshot.data?.nickname ?? '',
                                style: GoogleFonts.roboto(
                                    color: Colors.black87,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700),
                              );
                            }),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
