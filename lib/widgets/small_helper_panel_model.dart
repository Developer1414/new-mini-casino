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
    double? fontSize,
    TextStyle? textStyle,
    bool isCenter = false,
    Color? color}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: const Color(0xffffb300).withOpacity(0.1),
      border: Border.all(
        color: const Color(0xffffb300),
        width: 1.5,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: FaIcon(
                    icon,
                    color: iconColor ?? const Color(0xffffb300),
                    size: iconSize ?? 23.0,
                  ),
                ),
          Expanded(
            flex: isCenter ? 0 : 1,
            child: AutoSizeText(text,
                style: textStyle ??
                    GoogleFonts.roboto(
                      fontSize: fontSize ?? 12.0,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffffb300),
                    )),
          ),
        ],
      ),
    ),
  );
}
