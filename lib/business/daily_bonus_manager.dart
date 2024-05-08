import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as ui;

class DailyBonusManager extends ChangeNotifier {
  bool isLoading = false;

  int dailyCountBets = 0;
  int choosedIndex = -1;

  List<double> bonuses = [10000, 2000, 2000, 2000, 500, 500, 500, 500, 500];

  List<GlobalKey<ScratcherState>> scratchKeys =
      List.generate(9, (index) => GlobalKey<ScratcherState>());

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  void changeBonuses() {
    bonuses.shuffle();
    notifyListeners();
  }

  Future chooseIndex(int index) async {
    choosedIndex = index;
    notifyListeners();
  }

  Future spinAgain(
      {required BuildContext context,
      required VoidCallback voidCallback}) async {
    await AdService.showRewardedAd(context: context, func: voidCallback);
  }

  Future checkDailyBonus(BuildContext context) async {
    DateTime lastBonusDate = await NTP.now();
    DateTime dateTimeUTC = lastBonusDate.toUtc();

    changeBonuses();

    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase!.auth.currentUser!.id)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      if (map['bonusTime'] == null ||
          (DateTime.parse('${map['bonusTime']}'))
                  .difference(dateTimeUTC)
                  .inHours <=
              0) {
        DateTime lastBonusDate = await NTP.now();
        DateTime myTime = lastBonusDate.toUtc();

        await SupabaseController.supabase!
            .from('users')
            .update({
              'bonusTime':
                  myTime.add(const Duration(hours: 24)).toIso8601String(),
            })
            .eq('uid', SupabaseController.supabase!.auth.currentUser!.id)
            .whenComplete(() {
              Navigator.of(context).pushNamed('/daily-bonus');
            });
      }
    });
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
    double resultBonus = bonus * (SupabaseController.isPremium ? 2 : 1);

    if (!context.mounted) return;

    Provider.of<Balance>(context, listen: false).addMoney(resultBonus);

    bool isEnd = true;

    await alertDialogConfirm(
      context: context,
      barrierDismissible: false,
      title: 'Поздравляем',
      confirmBtnText: 'Спасибо',
      cancelBtnText: 'Ещё раз',
      text:
          'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(resultBonus)}!',
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      onCancelBtnTap: () async {
        await AdService.showRewardedAd(
            context: context,
            func: () {
              isEnd = false;

              Navigator.of(context, rootNavigator: true).pop();

              for (var element in scratchKeys) {
                element.currentState?.reset();
              }

              choosedIndex = -1;

              changeBonuses();
            });
      },
    ).whenComplete(() => isEnd ? Navigator.of(context).pop() : null);
  }
}
