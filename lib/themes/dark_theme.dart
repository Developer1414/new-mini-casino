import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkThemeData(BuildContext context) {
  return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      }),
      scaffoldBackgroundColor:
          Colors.transparent, //const Color.fromARGB(255, 35, 38, 51),
      textTheme: Theme.of(context).textTheme.copyWith(
            displaySmall: GoogleFonts.roboto(
                color: Colors.grey.shade100,
                fontSize: 15.0,
                fontWeight: FontWeight.w800),
            displayMedium: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.4),
                fontSize: 18.0,
                fontWeight: FontWeight.w700),
            displayLarge: GoogleFonts.roboto(
                textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.w900,
            )),
            titleMedium: GoogleFonts.roboto(
                textStyle: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            )),
            bodySmall: GoogleFonts.roboto(
                textStyle: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            )),
            bodyMedium: GoogleFonts.roboto(
                color: Colors.grey.shade100,
                fontSize: 18.0,
                fontWeight: FontWeight.w700),
          ),
      buttonTheme: const ButtonThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Color.fromARGB(255, 72, 79, 105),
          onPrimary: Color.fromARGB(255, 72, 79, 105),
          secondary: Color.fromARGB(255, 72, 79, 105),
          onSecondary: Color.fromARGB(255, 72, 79, 105),
          error: Color.fromARGB(255, 72, 79, 105),
          onError: Color.fromARGB(255, 72, 79, 105),
          background: Color.fromARGB(255, 72, 79, 105),
          onBackground: Color.fromARGB(255, 72, 79, 105),
          surface: Color.fromARGB(255, 72, 79, 105),
          onSurface: Color.fromARGB(255, 72, 79, 105),
        ),
      ),
      cardColor: const Color.fromARGB(255, 51, 56, 75),
      canvasColor: const Color.fromARGB(255, 51, 56, 75),
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
          iconTheme: Theme.of(context)
              .iconTheme
              .copyWith(color: Colors.grey.shade100, size: 25.0),
          titleTextStyle: GoogleFonts.roboto(
              color: Colors.grey.shade100,
              fontSize: 25.0,
              fontWeight: FontWeight.w800)),
      inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(0.0)),
              borderSide:
                  BorderSide(width: 2.5, color: Colors.white.withOpacity(0.3))),
          focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(0.0)),
              borderSide: BorderSide(
                  width: 2.5, color: Colors.white.withOpacity(0.5)))));
}
