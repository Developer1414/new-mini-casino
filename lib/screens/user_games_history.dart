import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class UserGamesHistory extends StatelessWidget {
  const UserGamesHistory(
      {super.key, required this.userNickname, required this.userid});

  final String userNickname;
  final String userid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76.0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: IconButton(
              splashRadius: 25.0,
              padding: EdgeInsets.zero,
              onPressed: () async {
                Beamer.of(context).beamBack();
              },
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.black87,
                size: 30.0,
              )),
        ),
        title: AutoSizeText(
          userNickname,
          style: GoogleFonts.roboto(
              color: Colors.black87,
              fontSize: 30.0,
              fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
