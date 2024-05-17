import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io' as ui;

class BannedUser extends StatelessWidget {
  const BannedUser({
    super.key,
    required this.reason,
    required this.date,
  });

  final String reason;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.only(
              top: 30.0,
              right: 15.0,
              left: 15.0,
              bottom: 15.0,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.ban,
                      color: Colors.redAccent,
                      size: 80.0,
                    ),
                    const SizedBox(height: 15.0),
                    AutoSizeText(
                      'Аккаунт\nзаблокирован',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 35.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    const Divider(),
                    const SizedBox(height: 15.0),
                    AutoSizeText(
                      'Ваш аккаунт был заблокирован до ${DateFormat.yMd(ui.Platform.localeName).format(date)} по причине:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 20.0,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    AutoSizeText(
                      reason,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 20.0,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
