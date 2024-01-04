import 'dart:async';
import 'dart:io' as ui;
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyBonusManager extends ChangeNotifier {
  bool isLoading = false;
  bool isClickableButton = true;
  bool isActiveFortuneWheel = false;
  bool isCanSpinAgain = false;

  int dailyCountBets = 0;

  void spin(bool isActive) async {
    isActiveFortuneWheel = isActive;

    if (!isActive) {
      isCanSpinAgain = true;
    }

    DateTime dateTimeNow = await NTP.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('dailyBonus', dateTimeNow.toString());

    notifyListeners();
  }

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future spinAgain(
      {required BuildContext context,
      required VoidCallback voidCallback}) async {
    await AdService.showInterstitialAd(
        context: context, func: voidCallback, isDailyBonus: true);
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
      {required BuildContext context, required double bonus}) async {
    if (!isClickableButton) return;

    isActiveFortuneWheel = false;

    DateTime dateTimeNow = await NTP.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    notifyListeners();

    isClickableButton = false;

    double resultBonus = bonus * (SupabaseController.isPremium ? 2 : 1);

    notifyListeners();

    await prefs.setString('dailyBonus', dateTimeNow.toString());
    await prefs.remove('dailyCountBets');

    if (!context.mounted) return;

    Provider.of<Balance>(context, listen: false).cashout(resultBonus);

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
