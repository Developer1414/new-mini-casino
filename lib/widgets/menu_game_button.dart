import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget gameButtonModel(
    {required String buttonTitle,
    required String gameLogo,
    required Function onTap,
    bool isSoon = false,
    bool isNew = false,
    required BorderRadiusGeometry borderRadius,
    required Color buttonColor}) {
  return Material(
    clipBehavior: Clip.antiAlias,
    borderRadius: BorderRadius.circular(15.0),
    color: buttonColor,
    child: InkWell(
      onTap: () async {
        if (!isSoon) {
          await onTap.call();
        }
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
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
        ],
      ),
    ),
  );
}
