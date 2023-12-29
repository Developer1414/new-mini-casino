import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

Widget smallHelperPanel(
    {required BuildContext context,
    required String text,
    Color? borderColor,
    TextStyle? textStyle,
    Color? color}) {
  return Container(
    padding: const EdgeInsets.all(15.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15.0),
      color: color ?? Theme.of(context).cardColor,
      border: Border.all(
          color: borderColor ??
              Theme.of(context).buttonTheme.colorScheme!.background,
          width: 3.0),
    ),
    child: AutoSizeText(text,
        textAlign: TextAlign.center,
        style: textStyle ??
            Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12.0,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .color!
                    .withOpacity(0.7))),
  );
}
