import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class RakebackManager extends ChangeNotifier {
  bool isLoading = false;

  double currentRakeback = 0.0;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future loadRakeback() async {
    showLoading(true);

    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      currentRakeback = map['rakebackAmount'] == null
          ? 0.0
          : double.parse(map['rakebackAmount'].toString());
    });

    showLoading(false);
  }

  Future getRakeback(BuildContext context) async {
    showLoading(true);

    await Provider.of<Balance>(context, listen: false)
        .addMoney(currentRakeback);

    await SupabaseController.supabase!.from('users').update({
      'rakebackAmount': 0.0,
    }).eq('uid', SupabaseController.supabase?.auth.currentUser!.id);

    showLoading(false);

    if (context.mounted) {
      alertDialogSuccess(
        context: context,
        title: 'Успех',
        confirmBtnText: 'Спасибо',
        text:
            '${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(currentRakeback)} успешно получены!',
      );

      currentRakeback = 0.0;

      await AdService.showInterstitialAd(
          context: context, func: () {}, isBet: false);
    }
  }

  Future updateRakeback(double bet) async {
    double rakeback = 0.0;

    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      rakeback = map['rakebackAmount'] == null
          ? 0.0
          : double.parse(map['rakebackAmount'].toString());
    });

    if (!SupabaseController.isPremium && rakeback >= 50000) {
      return;
    }

    if (SupabaseController.isPremium && rakeback >= 300000) {
      return;
    }

    if (!SupabaseController.isPremium) {
      if (rakeback < 50000) {
        if (rakeback + (bet * 1.0 / 100.0) > 50000) {
          rakeback = 50000;
        } else {
          rakeback += (bet * 1.0 / 100.0);
        }
      }
    } else {
      if (rakeback < 300000) {
        if (rakeback + (bet * 1.0 / 100.0) > 300000) {
          rakeback = 300000;
        } else {
          rakeback += (bet * 1.0 / 100.0);
        }
      }
    }

    await SupabaseController.supabase!.from('users').update({
      'rakebackAmount': rakeback,
    }).eq('uid', SupabaseController.supabase?.auth.currentUser!.id);
  }
}
