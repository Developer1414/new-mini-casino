import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      color: Colors.white.withOpacity(0.1),
      border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.5), width: 2.3),
      borderRadius: BorderRadius.circular(12.0),
    ),
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, bottom: 15.0),
                  child: FaIcon(
                    icon,
                    color: iconColor ??
                        Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!
                            .withOpacity(0.7),
                    size: iconSize ?? 50.0,
                  ),
                ),
          AutoSizeText(text,
              textAlign: TextAlign.center,
              style: textStyle ??
                  Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontSize: 12.0,
                      letterSpacing: 0.1,
                      color: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .color!
                          .withOpacity(0.7))),
        ],
      ),
    ),
  );
}
