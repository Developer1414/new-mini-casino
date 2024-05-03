import 'dart:math';
import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:provider/provider.dart';

class BonusManager extends ChangeNotifier {
  bool isLoadingBonus = false;

  int freeBonusCount = 0;

  void showLoading(bool isActive) {
    isLoadingBonus = isActive;
    notifyListeners();
  }

  Future getFreeBonus(BuildContext context) async {
    if (isLoadingBonus) return;

    showLoading(true);

    await AdService.showRewardedAd(
        context: context,
        func: () async {
          getReward(
              context: context,
              rewardCount: double.parse(
                  (Random().nextInt(SupabaseController.isPremium ? 4501 : 701) +
                          (SupabaseController.isPremium ? 500 : 100))
                      .toString()));
        }).whenComplete(() => showLoading(false));
  }

  void getReward(
      {required BuildContext context, required double rewardCount}) async {
    Provider.of<Balance>(context, listen: false).addMoney(rewardCount);

    alertDialogSuccess(
      context: context,
      title: 'Поздравляем!',
      confirmBtnText: 'Спасибо!',
      text:
          'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(rewardCount)}!',
    );
  }
}
