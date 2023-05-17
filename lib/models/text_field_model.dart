import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    double num =
                        currencyTextInputFormatter.getUnformattedValue() * 2;

                    controller.text = currencyTextInputFormatter
                        .format((((num).toStringAsFixed(2))).toString());
                  },
                  icon: FaIcon(
                    // ignore: deprecated_member_use
                    FontAwesomeIcons.multiply,
                    color: Colors.black87.withOpacity(0.8),
                    size: 18.0,
                  )),
              IconButton(
                  splashRadius: 18.0,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    double num =
                        currencyTextInputFormatter.getUnformattedValue() / 2;

                    controller.text = currencyTextInputFormatter
                        .format((((num).toStringAsFixed(2))).toString());
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.divide,
                    color: Colors.black87.withOpacity(0.8),
                    size: 18.0,
                  )),
              IconButton(
                splashRadius: 20.0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  final balance = context.read<Balance>();

                  controller.text = currencyTextInputFormatter.format(
                      NumberFormat.simpleCurrency(
                              locale: ui.Platform.localeName)
                          .format(balance.currentBalance - 0.01));
                },
                icon: Text(
                  'max',
                  style: GoogleFonts.roboto(
                      color: Colors.black87.withOpacity(0.8),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        hintStyle: GoogleFonts.roboto(
            color: Colors.black87.withOpacity(0.5),
            fontSize: 18,
            fontWeight: FontWeight.w700),
        enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            borderSide:
                BorderSide(width: 2.5, color: Colors.black87.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            borderSide: BorderSide(
                width: 2.5, color: Colors.black87.withOpacity(0.5)))),
    style: GoogleFonts.roboto(
        color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w900),
  );
}
