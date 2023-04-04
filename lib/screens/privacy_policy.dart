import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfx/pdfx.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfController(
      document: PdfDocument.openAsset('assets/PrivacyPolicyMiniCasino.pdf'),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 76.0,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
                splashRadius: 25.0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.black87,
                  size: 30.0,
                )),
          ),
          title: AutoSizeText(
            'Политика Конфиденциальности',
            maxLines: 1,
            style: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 30.0,
                fontWeight: FontWeight.w900),
          ),
        ),
        body: PdfView(
          controller: pdfController,
        ),
      ),
    );
  }
}
