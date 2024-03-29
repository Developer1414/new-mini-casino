import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget buttonModel(
    {required BuildContext context,
    String? buttonName,
    String? subtitle,
    required Color color,
    Function()? onPressed,
    Color? textColor,
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
      child: Row(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buttonName == null
                  ? Container()
                  : AutoSizeText(buttonName,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 20.0,
                          color: textColor ??
                              Theme.of(context).textTheme.bodyMedium!.color)),
              subtitle == null
                  ? Container()
                  : AutoSizeText(subtitle,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 15.0,
                          color: textColor ??
                              Theme.of(context).textTheme.bodyMedium!.color)),
            ],
          ),
        ],
      ),
    ),
  );
}
