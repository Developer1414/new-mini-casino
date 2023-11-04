import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart' as provider;
import 'dart:io' as ui;

import 'package:supabase_flutter/supabase_flutter.dart';

class TransferMoneysManager extends ChangeNotifier {
  bool isLoading = false;

  String currentAmount =
      NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(0.0);

  void changeAmount(double amount) {
    currentAmount = NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .format(SupabaseController.isPremium
            ? amount
            : amount + (amount * 6 / 100));

    notifyListeners();
  }

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  void transfer(
      {required BuildContext context,
      required String username,
      required amount}) async {
    final balance = provider.Provider.of<Balance>(context, listen: false);

    double amountWithComission =
        SupabaseController.isPremium ? amount : amount + (amount * 60 / 100);

    if (username.isEmpty) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Вы не вписали никнейм!',
      );

      return;
    }

    if (username == ProfileController.profileModel.nickname) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Вы не можете перевести деньги себе!',
      );

      return;
    }

    if (balance.currentBalance < amountWithComission) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Недостаточно средств на балансе!',
      );

      return;
    }

    if (amount < 1000) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Перевод возможен от ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(1000)}!',
      );

      return;
    }

    showLoading(true);

    try {
      SupabaseController()
          .checkNameOnAvailability(name: username)
          .then((isExist) async {
        if (isExist) {
          DateTime dateTimeNow = await NTP.now();

          await SupabaseController.supabase!.from('notifications').insert({
            'amount': amount,
            'to': username,
            'action': 'transfer_moneys',
            'date': dateTimeNow.toIso8601String(),
          });

          balance.placeBet(amountWithComission);

          showLoading(false);

          if (context.mounted) {
            alertDialogSuccess(
              context: context,
              title: 'Успех',
              confirmBtnText: 'Спасибо',
              text:
                  '${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(amount)} успешно переведены!',
            );

            AdService.showInterstitialAd(
                context: context, func: () {}, isBet: false);
          }
        } else {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: 'Игрок с таким никнеймом не найден!',
          );

          showLoading(false);
        }
      });
    } on PostgrestException catch (e) {
      showLoading(false);

      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: e.message,
      );

      if (kDebugMode) {
        print('createUserDates: $e');
      }
    }
  }
}
