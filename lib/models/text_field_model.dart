import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customTextField(
    {required String hintText,
    required TextEditingController controller,
    bool isBetInput = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    required TextInputFormatter textInputFormatter,
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
