import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/premium_badge.dart';

Widget gameButtonModel(
    {required String buttonTitle,
    required String gameLogo,
    required Function onTap,
    required BuildContext context,
    bool forPremium = false,
    bool isNew = false,
    required BorderRadiusGeometry borderRadius,
    required Color buttonColor}) {
  return Material(
    clipBehavior: Clip.antiAlias,
    borderRadius: BorderRadius.circular(15.0),
    color: buttonColor,
    child: InkWell(
      onTap: () async {
        if (!forPremium) {
          await onTap.call();
        } else {
          if (SupabaseController.isPremium) {
            await onTap.call();
          } else {
            alertDialogError(
              context: context,
              title: 'Ошибка',
              text: 'Эта игра доступна только Premium-подписчикам!',
            );
          }
        }
      },
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/games_logo/$gameLogo.png'),
                height: 130.0,
              ),
            ),
          ),
          Container(
            //height: 80.0,
            //alignment: Alignment.bottomCenter,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5)
                    ])),
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Center(
                child: SizedBox(
                  height: 30.0,
                  child: AutoSizeText(
                    buttonTitle,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 15.0)
                        ]),
                  ),
                ),
              ),
            ),
          ),
          !forPremium
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                  child: premiumBadge(),
                )
        ],
      ),
    ),
  );
}
