import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightThemeData(BuildContext context) {
  return ThemeData(
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: Colors.transparent),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      scaffoldBackgroundColor: Colors.grey.shade50,
      textTheme: Theme.of(context).textTheme.copyWith(
            displaySmall: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 18.0,
                fontWeight: FontWeight.w900),
            displayMedium: GoogleFonts.roboto(
                color: Colors.black87.withOpacity(0.4),
                fontSize: 18.0,
                fontWeight: FontWeight.w700),
            displayLarge: GoogleFonts.roboto(
                textStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 50,
              fontWeight: FontWeight.w900,
            )),
            titleMedium: GoogleFonts.roboto(
                textStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            )),
            bodySmall: GoogleFonts.roboto(
                textStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            )),
            bodyMedium: GoogleFonts.roboto(
                color: Colors.black87.withOpacity(0.8),
                fontSize: 18.0,
                fontWeight: FontWeight.w900),
          ),
      buttonTheme: ButtonThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.grey.shade200,
          onPrimary: Colors.grey.shade200,
          secondary: Colors.grey.shade200,
          onSecondary: Colors.grey.shade200,
          error: Colors.grey.shade200,
          onError: Colors.grey.shade200,
          background: Colors.grey.shade200,
          onBackground: Colors.grey.shade200,
          surface: Colors.grey.shade200,
          onSurface: Colors.grey.shade200,
        ),
      ),
      cardColor: Colors.white,
      canvasColor: Colors.grey.shade300,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
          iconTheme: Theme.of(context).iconTheme.copyWith(
                color: Colors.black87,
                size: 30.0,
              ),
          titleTextStyle: GoogleFonts.roboto(
              color: Colors.black87,
              fontSize: 30.0,
              fontWeight: FontWeight.w900)),
      inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide(
                  width: 2.5, color: Colors.black87.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide(
                  width: 2.5, color: Colors.black87.withOpacity(0.5)))));
}
