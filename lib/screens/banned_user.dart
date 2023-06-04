import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannedUser extends StatelessWidget {
  const BannedUser({super.key, required this.couse, required this.date});

  final String couse;
  final String date;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => exit(0),
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Вы заблокированны до $date\nПричина: $couse',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 22.0,
                        height: 1.3,
                        fontWeight: FontWeight.w900,
                      ))),
                ],
              ),
            ),
          ),
        ));
  }
}
