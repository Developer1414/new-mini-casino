import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget loading() {
  return Scaffold(
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40.0,
            height: 40.0,
            child: CircularProgressIndicator(
              strokeWidth: 6.0,
            ),
          ),
          const SizedBox(height: 10.0),
          AutoSizeText(
            'Пожалуйста, подождите...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: Colors.black87.withOpacity(0.7),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}
