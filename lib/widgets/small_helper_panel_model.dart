import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

Widget smallHelperPanel(
    {required BuildContext context,
    required String text,
    IconData? icon,
    Color? borderColor,
    Color? iconColor,
    double? iconSize,
    TextStyle? textStyle,
    Color? color}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: const Color(0xffffba08).withOpacity(0.1),
      border: Border.all(
        color: const Color(0xffffba08),
        width: 2.0,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: FaIcon(
                    icon,
                    color:
                        iconColor ?? const Color.fromARGB(255, 252, 237, 205),
                    size: iconSize ?? 25.0,
                  ),
                ),
          Expanded(
            child: AutoSizeText(text,
                textAlign: TextAlign.center,
                style: textStyle ??
                    GoogleFonts.roboto(
                        fontSize: 12.0,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 252, 237, 205))),
          ),
        ],
      ),
    ),
  );
}
