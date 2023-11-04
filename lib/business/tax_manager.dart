import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaxManager extends ChangeNotifier {
  bool isLoading = false;
  bool isCanPlay = true;

  double currentTax = 0.0;

  DateTime taxPeriod = DateTime(2000);

  Future getTax() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime dateTimeNow = await NTP.now();

    if (prefs.containsKey('gamblingTax')) {
      taxPeriod = DateTime.parse(
          (jsonDecode(prefs.getString('gamblingTax').toString()) as List)[1]);

      currentTax = double.parse(
          jsonDecode(prefs.getString('gamblingTax').toString())[0].toString());

      if (currentTax <= 0.0) {
        prefs.remove('gamblingTax');
      }

      if (taxPeriod.difference(dateTimeNow).inHours <= 0) {
        isCanPlay = false;
      }
    }
  }

  void payTax(BuildContext context) async {
    if (currentTax <= 0) {
      return;
    }

    final balance = Provider.of<Balance>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (balance.currentBalance < currentTax) {
      if (context.mounted) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: 'Недостаточно средств на балансе!',
        );
      }

      return;
    }

    balance.placeBet(currentTax);
    prefs.remove('gamblingTax');

    if (context.mounted) {
      alertDialogSuccess(
          context: context, title: 'Успех', text: 'Налог успешно оплачен!');
    }

    currentTax = 0.0;
    isCanPlay = true;
    taxPeriod = DateTime(2000);

    notifyListeners();
  }

  void addTax(double bet) async {
    if (SupabaseController.isPremium) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime dateTimeNow = await NTP.now();

    await getTax();

    double tax = 0.0;

    if (prefs.containsKey('gamblingTax')) {
      tax = double.parse(
          jsonDecode(prefs.getString('gamblingTax').toString())[0].toString());

      dateTimeNow = DateTime.parse(
          (jsonDecode(prefs.getString('gamblingTax').toString()) as List)[1]);
    } else {
      dateTimeNow = dateTimeNow.add(const Duration(days: 8));
    }

    tax += bet * 1 / 100;

    prefs.setString('gamblingTax', jsonEncode([tax, dateTimeNow.toString()]));
  }
}
