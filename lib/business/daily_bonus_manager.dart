import 'dart:async';
import 'dart:io' as ui;
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyBonusManager extends ChangeNotifier {
  bool isLoading = false;
  bool isClickableButton = true;

  List<Color> colors = [
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.lightGreen,
    Colors.lightBlue,
  ];

  List<int> coefficients = [5, 10, 2, 3];
  //List<int> bonuses = List.filled(4, 0);

  int dailyCountBets = 0;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future<bool> checkDailyBonus() async {
    bool result = false;

    DateTime lastBonusDate = await NTP.now();
    DateTime dateTimeNow = await NTP.now();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('dailyBonus')) {
      lastBonusDate = DateTime.parse(prefs.getString('dailyBonus').toString());
    }

    if (dateTimeNow.day != lastBonusDate.day ||
        !prefs.containsKey('dailyBonus')) {
      result = true;
    }

    notifyListeners();

    return result;
  }

  Future updateDailyBetsCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int dailyCountBets = 0;

    if (prefs.containsKey('dailyCountBets')) {
      dailyCountBets = prefs.getInt('dailyCountBets')! + 1;
      prefs.setInt('dailyCountBets', dailyCountBets);
    } else {
      prefs.setInt('dailyCountBets', 1);
    }
  }

  Future getBonus(
      {required BuildContext context, required int bonusIndex}) async {
    if (!isClickableButton) return;

    DateTime dateTimeNow = await NTP.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    dailyCountBets = prefs.getInt('dailyCountBets') ?? 500;

    coefficients.shuffle();
    notifyListeners();

    isClickableButton = false;

    int resultBonus = dailyCountBets *
        coefficients[bonusIndex] *
        (AccountController.isPremium ? 2 : 1);

    notifyListeners();

    // ignore: use_build_context_synchronously
    Provider.of<Balance>(context, listen: false)
        .cashout(double.parse(resultBonus.toString()));

    await prefs.setString('dailyBonus', dateTimeNow.toString());
    await prefs.remove('dailyCountBets');

    await Future.delayed(const Duration(seconds: 1));

    // ignore: use_build_context_synchronously
    alertDialogSuccess(
        context: context,
        barrierDismissible: false,
        title: 'Поздравляем',
        confirmBtnText: 'Спасибо',
        text:
            'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(resultBonus)}!',
        onConfirmBtnTap: () {
          context.beamBack();
        });
  }
}
