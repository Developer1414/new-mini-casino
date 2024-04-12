import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

Widget smallHelperPanel(
    {required BuildContext context,
    required String text,
    IconData? icon,
    Color? borderColor,
    Color? iconColor,
    double? iconSize,
    TextStyle? textStyle,
    Color? color}) {
  return GlassContainer(
    width: double.infinity,
    blur: 8,
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12.0),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: borderColor ?? Colors.orange.withOpacity(0.5), width: 2.0),
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
                    Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 12.0,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color!
                            .withOpacity(0.7))),
          ],
        ),
      ),
    ),
  );
}
