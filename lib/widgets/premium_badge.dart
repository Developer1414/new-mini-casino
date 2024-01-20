import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget premiumBadge({bool isActive = true}) {
  return !isActive
      ? Container()
      : Container(
          height: 30.0,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 179, 242, 31),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                    color: const Color.fromARGB(255, 179, 242, 31)
                        .withOpacity(0.5),
                    blurRadius: 8.0,
                    spreadRadius: 1.5)
              ]),
          child: Transform.translate(
            offset: const Offset(0, -1.5),
            child: AutoSizeText(
              'PREMIUM',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w900),
            ),
          ),
        );
}
