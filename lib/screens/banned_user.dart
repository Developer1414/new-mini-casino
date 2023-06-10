import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BannedUser extends StatelessWidget {
  const BannedUser({super.key, required this.reason, required this.date});

  final String reason;
  final DateTime date;

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
                  const FaIcon(
                    FontAwesomeIcons.ban,
                    color: Colors.redAccent,
                    size: 80.0,
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                      'Вы заблокированны до ${DateFormat.yMMMMd('ru_RU').format(date)}\nПричина: $reason',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 22.0,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ))),
                ],
              ),
            ),
          ),
        ));
  }
}
