import 'dart:convert';

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
import 'package:shared_preferences/shared_preferences.dart';
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
            : amount + (amount * 60 / 100));

    notifyListeners();
  }

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  void transfer(
      {required BuildContext context,
      required String name,
      required amount}) async {
    final balance = provider.Provider.of<Balance>(context, listen: false);

    double amountWithComission =
        SupabaseController.isPremium ? amount : amount + (amount * 60 / 100);

    if (name.isEmpty) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Вы не вписали никнейм!',
      );

      return;
    }

    if (name == ProfileController.profileModel.nickname) {
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

    if (amount > 5000000) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Перевод возможен до ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(5000000)}!',
      );

      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime dateTimeNow = await NTP.now();
    DateTime dateTime = await NTP.now();

    dateTime = dateTime.toUtc();
    dateTimeNow = dateTimeNow.toUtc();

    double currentSum = 0.0;

    if (prefs.containsKey('transfer')) {
      dateTime = DateTime.parse(
          (jsonDecode(prefs.getString('transfer').toString()) as List)[1]);

      currentSum = double.parse(
          jsonDecode(prefs.getString('transfer').toString())[0].toString());

      if (currentSum >= 5000000) {
        if (dateTime.difference(dateTimeNow).inHours > 0) {
          if (context.mounted) {
            alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text:
                  'Достигнут дневной лимит переводов. Вы сможете осуществить перевод через ${dateTime.difference(dateTimeNow).inHours}ч.',
            );
          }

          return;
        } else {
          prefs.remove('transfer');
        }
      } else {
        if (currentSum + amount > 5000000) {
          if (context.mounted) {
            alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text:
                  'Вы можете перевести максимум еще ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(5000000 - currentSum)}!',
            );
          }

          return;
        }
      }
    }

    showLoading(true);

    try {
      SupabaseController()
          .checkNameOnAvailability(name: name)
          .then((isExist) async {
        if (isExist) {
          await SupabaseController.supabase!.from('notifications').insert({
            'amount': amount,
            'to': name,
            'from': ProfileController.profileModel.nickname,
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

            if (prefs.containsKey('transfer')) {
              dateTime = DateTime.parse(
                  (jsonDecode(prefs.getString('transfer').toString())
                      as List)[1]);

              currentSum = double.parse(
                      jsonDecode(prefs.getString('transfer').toString())[0]
                          .toString()) +
                  amount;
            } else {
              currentSum = amount;
            }

            prefs.setString(
                'transfer',
                jsonEncode([
                  currentSum,
                  dateTimeNow.add(const Duration(hours: 12)).toString()
                ]));

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

      if (context.mounted) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: e.message,
        );
      }

      if (kDebugMode) {
        print('createUserDates: $e');
      }
    }
  }
}
