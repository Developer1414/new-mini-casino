import 'dart:convert';
import 'dart:io' as ui;
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyBonusManager extends ChangeNotifier {
  bool isLoading = false;
  bool isClickableButton = true;
  List<double> bonuses = [550, 720, 900, 1100, 1500, 2000, 2800, 3900, 5000];
  List<Color> colors = [
    const Color.fromARGB(255, 29, 98, 216),
    Colors.blue,
    Colors.green,
    Colors.teal,
    Colors.purple,
    const Color.fromARGB(255, 230, 213, 60),
    Colors.pink,
    Colors.orange,
    Colors.red
  ];

  static double currentBonus = 0.0;
  static int currentBonusIndex = 0;
  static DateTime firstBonusDate = DateTime.now();

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
      var data = jsonDecode(prefs.getString('dailyBonus').toString());
      firstBonusDate = DateTime.parse(data[0]);
      currentBonusIndex = int.parse(data[1].toString());
      lastBonusDate = DateTime.parse(data[2]);
      currentBonus =
          bonuses[currentBonusIndex] * (AccountController.isPremium ? 2 : 1);
    } else {
      currentBonus = bonuses[0] * (AccountController.isPremium ? 2 : 1);
    }

    if (dateTimeNow.day != lastBonusDate.day ||
        !prefs.containsKey('dailyBonus')) {
      result = true;
    }

    notifyListeners();

    return result;
  }

  Future getBonus(BuildContext context) async {
    if (!isClickableButton) return;

    isClickableButton = false;

    showLoading(true);

    Provider.of<Balance>(context, listen: false).cashout(currentBonus);

    if (currentBonusIndex < 8) {
      currentBonusIndex++;
    } else {
      currentBonusIndex = 0;
    }

    DateTime firstBonus =
        currentBonusIndex == 0 ? await NTP.now() : firstBonusDate;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
        'dailyBonus',
        jsonEncode([
          firstBonus.toString(),
          currentBonusIndex,
          DateTime.now().toString()
        ]));

    // ignore: use_build_context_synchronously
    alertDialogSuccess(
        context: context,
        barrierDismissible: false,
        title: 'Поздравляем',
        confirmBtnText: 'Спасибо!',
        text:
            'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(currentBonus)}!',
        onConfirmBtnTap: () {
          context.beamToReplacementNamed('/games');
        });

    showLoading(false);
  }
}
