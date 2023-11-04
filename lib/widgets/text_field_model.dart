import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
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
      controller.selection =
          TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    },
    onChanged: (value) {
      if (isBetInput) {
        if (!SupabaseController.isPremium) {
          if (double.parse(
                  currencyTextInputFormatter.getUnformattedValue().toString()) >
              1000000) {
            controller.text = currencyTextInputFormatter.format('100000000');
            controller.selection = TextSelection(
                baseOffset: 0, extentOffset: controller.text.length);
          }
        } else {
          if (double.parse(
                  currencyTextInputFormatter.getUnformattedValue().toString()) >
              10000000) {
            controller.text = currencyTextInputFormatter.format('1000000000');
            controller.selection = TextSelection(
                baseOffset: 0, extentOffset: controller.text.length);
          }
        }
      }
    },
    inputFormatters: [textInputFormatter],
    decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: !isBetInput
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        splashRadius: 18.0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (readOnly) return;

                          double num = 0.0;

                          if (!SupabaseController.isPremium) {
                            if (currencyTextInputFormatter
                                    .getUnformattedValue()
                                    .toDouble() >=
                                1000000) {
                              num = currencyTextInputFormatter
                                  .getUnformattedValue()
                                  .toDouble();
                            } else {
                              if (currencyTextInputFormatter
                                          .getUnformattedValue() *
                                      2 >
                                  1000000) {
                                num = currencyTextInputFormatter
                                    .getUnformattedValue()
                                    .toDouble();
                              } else {
                                num = currencyTextInputFormatter
                                        .getUnformattedValue() *
                                    2;
                              }
                            }
                          } else {
                            if (currencyTextInputFormatter
                                    .getUnformattedValue()
                                    .toDouble() >=
                                10000000) {
                              num = currencyTextInputFormatter
                                  .getUnformattedValue()
                                  .toDouble();
                            } else {
                              if (currencyTextInputFormatter
                                          .getUnformattedValue() *
                                      2 >
                                  10000000) {
                                num = currencyTextInputFormatter
                                    .getUnformattedValue()
                                    .toDouble();
                              } else {
                                num = currencyTextInputFormatter
                                        .getUnformattedValue() *
                                    2;
                              }
                            }
                          }

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
                              currencyTextInputFormatter.getUnformattedValue() /
                                  2;

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
                        double result = 0.0;

                        if (!SupabaseController.isPremium) {
                          if (balance.currentBalance.truncate() > 1000000) {
                            result = 1000000;
                          } else {
                            result =
                                balance.currentBalance.truncate().toDouble();
                          }
                        } else {
                          if (balance.currentBalance.truncate() > 10000000) {
                            result = 10000000;
                          } else {
                            result =
                                balance.currentBalance.truncate().toDouble();
                          }
                        }

                        controller.text = currencyTextInputFormatter.format(
                            NumberFormat.simpleCurrency(
                                    locale: ui.Platform.localeName)
                                .format(result));
                      },
                      icon: Text('max',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
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
