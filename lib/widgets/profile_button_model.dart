import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

Widget profileButton(
    {required IconData icon,
    required String text,
    required BuildContext context,
    required Function() onPressed}) {
  return SizedBox(
    height: 112.0,
    child: ElevatedButton(
      onPressed: () {
        onPressed.call();
      },
      style: ElevatedButton.styleFrom(
        elevation: 5,
        backgroundColor: Theme.of(context).buttonTheme.colorScheme!.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: Colors.white,
              size: 35.0,
            ),
            const SizedBox(height: 10.0),
            AutoSizeText(
              text,
              maxLines: 1,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800),
            )
          ],
        ),
      ),
    ),
  );
}
