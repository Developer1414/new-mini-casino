import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
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
    child: Stack(alignment: AlignmentDirectional.center, children: [
      Padding(
          padding: const EdgeInsets.only(top: 18.0, bottom: 18.0),
          child: Image(
            image: AssetImage('assets/games_logo/$gameLogo.png'),
            width: 130.0,
            height: 130.0,
          )),
      Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Container(
          decoration: BoxDecoration(borderRadius: borderRadius),
        ).blurred(colorOpacity: 0.0, blur: 4.0),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 12.0),
            child: AutoSizeText(
              buttonTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                        color: Colors.black.withOpacity(0.7), blurRadius: 12.0)
                  ]),
            ),
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
  );
}
