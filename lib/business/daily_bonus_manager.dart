import 'dart:convert';
import 'dart:io' as ui;
import 'package:beamer/beamer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/bonus_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyBonusManager extends ChangeNotifier {
  bool isLoading = false;
  List<double> bonuses = [1000, 2000, 3000, 4000, 5000, 6000, 7000];

  double currentBonus = 0.0;
  int currentBonusIndex = 0;

  void shoowLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future checkDailyBonus(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    DateTime dateTimeNow = await NTP.now();
    DateTime lastBonusDate = await NTP.now();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('dailyBonus')) {
      var data = jsonDecode(prefs.getString('dailyBonus').toString());
      lastBonusDate = DateTime.parse(data[0]);
    }

    if (dateTimeNow.day != lastBonusDate.day ||
        !prefs.containsKey('dailyBonus')) {
      // ignore: use_build_context_synchronously
      context.beamToNamed('/daily-bonus');
    }

    // ignore: use_build_context_synchronously
    Provider.of<BonusManager>(context, listen: false).loadFreeBonusCount();
  }

  Future<String> showCurrentBonus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    double bonus = bonuses[0] * (AccountController.isPremium ? 2 : 1);

    if (prefs.containsKey('dailyBonus')) {
      var data = jsonDecode(prefs.getString('dailyBonus').toString());
      currentBonusIndex = int.parse(data[1].toString());
      bonus = bonuses[currentBonusIndex];
    }

    currentBonus = bonus * (AccountController.isPremium ? 2 : 1);

    return NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .format(currentBonus);
  }

  Future<String> showNextBonus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double bonus = bonuses[1] * (AccountController.isPremium ? 2 : 1);

    if (prefs.containsKey('dailyBonus')) {
      var data = jsonDecode(prefs.getString('dailyBonus').toString());
      int nextBonusIndex = int.parse(data[1].toString());

      if (int.parse(data[1].toString()) < 6) {
        nextBonusIndex++;
      } else {
        nextBonusIndex = 0;
      }

      bonus = bonuses[nextBonusIndex];
    }

    return NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .format(bonus * (AccountController.isPremium ? 2 : 1));
  }

  Future getBonus(BuildContext context) async {
    shoowLoading(true);

    DateTime dateTimeNow = await NTP.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ignore: use_build_context_synchronously
    Provider.of<Balance>(context, listen: false).cashout(currentBonus);

    if (currentBonusIndex < 6) {
      currentBonusIndex++;
    } else {
      currentBonusIndex = 0;
    }

    prefs.setString(
        'dailyBonus', jsonEncode([dateTimeNow.toString(), currentBonusIndex]));

    // ignore: use_build_context_synchronously
    alertDialogSuccess(
        context: context,
        barrierDismissible: false,
        title: 'Поздравляем!',
        confirmBtnText: 'Спасибо!',
        text:
            'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(currentBonus)}!',
        onConfirmBtnTap: () {
          // ignore: use_build_context_synchronously
          context.beamBack();
        });

    shoowLoading(false);
  }
}
