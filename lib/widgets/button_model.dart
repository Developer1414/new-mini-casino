import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buttonModel(
    {required BuildContext context,
    String? buttonName,
    String? subtitle,
    required Color color,
    Function()? onPressed,
    double? titleFontSize,
    Color? textColor,
    Color? subtitleColor,
    Color? iconColor,
    IconData? icon}) {
  return SizedBox(
    height: 60.0,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        elevation: 5,
        shadowColor: color.withOpacity(0.8),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon == null
                  ? Container()
                  : FaIcon(
                      icon,
                      color: iconColor ?? Colors.grey.shade300,
                      size: 22.0,
                    ),
              icon == null
                  ? Container()
                  : buttonName == null
                      ? Container()
                      : const SizedBox(width: 10.0),
              buttonName == null
                  ? Container()
                  : AutoSizeText(buttonName,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: titleFontSize ?? 20.0,
                          color: textColor ??
                              Theme.of(context).textTheme.bodyMedium!.color)),
            ],
          ),
          subtitle == null
              ? Container()
              : Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: AutoSizeText(subtitle,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 12.0,
                        color: subtitleColor ??
                            Theme.of(context).textTheme.bodySmall!.color)),
              ),
        ],
      ),
    ),
  );
}
