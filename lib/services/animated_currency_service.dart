import 'dart:io' as ui;
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget currencyNormalFormat(
    {required BuildContext context,
    required double moneys,
    TextStyle? textStyle}) {
  String suffix = '';
  String prefix = '';
  String thousandSeparator = '';
  String decimalSeparator = '';

  var currencyFormat =
      NumberFormat.simpleCurrency(locale: ui.Platform.localeName);

  if (ui.Platform.localeName == 'en_US') {
    suffix = '';
    prefix = currencyFormat.currencySymbol;
    thousandSeparator = ',';
    decimalSeparator = '.';
  } else if (ui.Platform.localeName == 'ru_RU') {
    suffix = ' ${currencyFormat.currencySymbol}';
    prefix = '';
    thousandSeparator = ' ';
    decimalSeparator = ',';
  } else {
    suffix = '';
    prefix = currencyFormat.currencySymbol;
    thousandSeparator = ',';
    decimalSeparator = '.';
  }

  return AnimatedFlipCounter(
      duration: const Duration(milliseconds: 500),
      fractionDigits: 2,
      thousandSeparator: thousandSeparator,
      decimalSeparator: decimalSeparator,
      suffix: suffix,
      prefix: prefix,
      value: moneys,
      textStyle: textStyle ??
          Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(letterSpacing: -0.4));
}
