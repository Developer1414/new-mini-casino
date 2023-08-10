import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:provider/provider.dart';

Widget customTextField(
    {required String hintText,
    required TextEditingController controller,
    bool isBetInput = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    required BuildContext context,
    Widget? sufficIcon,
    required TextInputFormatter textInputFormatter,
    required CurrencyTextInputFormatter currencyTextInputFormatter,
    bool isPassword = false}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    obscureText: isPassword,
    keyboardType: keyboardType,
    textAlign: TextAlign.center,
    textInputAction: TextInputAction.done,
    onTap: () {
      if (isBetInput) {
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      }
    },
    inputFormatters: [textInputFormatter],
    decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  splashRadius: 18.0,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (readOnly) return;

                    double num =
                        currencyTextInputFormatter.getUnformattedValue() * 2;

                    controller.text = currencyTextInputFormatter
                        .format((((num).toStringAsFixed(2))).toString());
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.xmark,
                    color: Theme.of(context)
                        .appBarTheme
                        .iconTheme!
                        .color!
                        .withOpacity(0.8),
                    size: 18.0,
                  )),
              IconButton(
                  splashRadius: 18.0,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (readOnly) return;

                    double num =
                        currencyTextInputFormatter.getUnformattedValue() / 2;

                    controller.text = currencyTextInputFormatter
                        .format((((num).toStringAsFixed(2))).toString());
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.divide,
                    color: Theme.of(context)
                        .appBarTheme
                        .iconTheme!
                        .color!
                        .withOpacity(0.8),
                    size: 18.0,
                  )),
              IconButton(
                splashRadius: 20.0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (readOnly) return;

                  final balance = context.read<Balance>();

                  controller.text = currencyTextInputFormatter.format(
                      NumberFormat.simpleCurrency(
                              locale: ui.Platform.localeName)
                          .format(balance.currentBalance - 0.01));
                },
                icon: Text('max',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color!
                            .withOpacity(0.8))),
              ),
            ],
          ),
        ),
        hintStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Theme.of(context)
                .textTheme
                .displaySmall!
                .color!
                .withOpacity(0.5)),
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder),
    style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 20.0),
  );
}
