import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget gameButtonModel(
    {required String buttonTitle,
    required String gameLogo,
    required Function onTap,
    bool isSoon = false,
    required BorderRadiusGeometry borderRadius,
    required Color buttonColor}) {
  return ElevatedButton(
    onPressed: () {
      if (!isSoon) {
        onTap.call();
      }
    },
    style: ElevatedButton.styleFrom(
      elevation: 5,
      backgroundColor: buttonColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18.0),
      child: SizedBox(
        width: double.infinity,
        child: Stack(alignment: AlignmentDirectional.center, children: [
          Image(
            image: AssetImage('assets/games_logo/$gameLogo.png'),
            width: 140.0,
            height: 140.0,
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 4.0,
                sigmaY: 4.0,
              ),
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                buttonTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 12.0)
                    ]),
              ),
              !isSoon
                  ? Container()
                  : AutoSizeText(
                      'Скоро',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                                color: Colors.black.withOpacity(0.7),
                                blurRadius: 12.0)
                          ]),
                    ),
            ],
          ),
        ]),
      ),
    ),
  );
}
