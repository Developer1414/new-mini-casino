import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void showEngineeringWorksAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.2),
          body: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.gears,
                            color:
                                Theme.of(context).appBarTheme.iconTheme?.color,
                            size: 60.0,
                          ),
                          const SizedBox(height: 10.0),
                          AutoSizeText(
                            'Временно проводятся технические работы!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          AutoSizeText(
                            'Попробуйте зайти позже',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
