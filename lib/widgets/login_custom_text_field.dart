import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget loginCustomTextField(
    {required String hintText,
    required TextEditingController controller,
    required BuildContext context,
    bool isLastInput = false,
    bool readOnly = false,
    bool limitSymbols = false,
    TextInputType? keyboardType,
    bool isPassword = false}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    obscureText: isPassword,
    keyboardType: keyboardType,
    textAlign: TextAlign.center,
    onTapOutside: (event) {
      FocusScope.of(context).unfocus();
    },
    inputFormatters: limitSymbols
        ? [
            LengthLimitingTextInputFormatter(12),
            FilteringTextInputFormatter.allow(RegExp('[a-z A-Z 0-9]'))
          ]
        : null,
    textInputAction: isLastInput ? TextInputAction.done : TextInputAction.next,
    decoration: InputDecoration(
        hintText: hintText,
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
