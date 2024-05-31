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

  String format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

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

    showLoading(true);

    bool isExist = await provider.Provider.of<Balance>(context, listen: false)
        .checkOnExistSpecificAmount(amountWithComission);

    if (context.mounted) {
      if (!isExist) {
        showLoading(false);

        await showErrorAlertNoBalance(context);

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

        showLoading(false);

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

        showLoading(false);

        return;
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime dateTimeNow = await NTP.now();
    DateTime dateTime = await NTP.now();

    dateTime = dateTime.toUtc();
    dateTimeNow = dateTimeNow.toUtc();

    double currentSum = 0.0;

    showLoading(true);

    try {
      DateTime ntpTime = await NTP.now();
      DateTime utcTime = ntpTime.toUtc().add(ntpTime.timeZoneOffset);

      Duration difference = utcTime
          .difference(DateTime(utcTime.year, utcTime.month, utcTime.day + 1))
          .abs();

      String timeToNextTransfer =
          'Вы можете осуществить следующий перевод через ${difference.inHours}ч ${difference.inMinutes % 60}м';

      await SupabaseController.supabase!
          .from('transactions')
          .select('*')
          .eq('sender', SupabaseController.supabase!.auth.currentUser!.id)
          .then((value) async {
        List<dynamic> list = value as List<dynamic>;

        double currentDayAmount = 0.0;

        for (int i = 0; i < list.length; i++) {
          Map<dynamic, dynamic> map = list[i];

          DateTime transactionDateTime =
              DateTime.parse(map['created_at'].toString()).toLocal();

          if (transactionDateTime.year == utcTime.year &&
              transactionDateTime.month == utcTime.month &&
              transactionDateTime.day == utcTime.day) {
            currentDayAmount += double.parse(map['amount'].toString());
          }
        }

        if (currentDayAmount >= 5000000 || 5000000 - currentDayAmount < 1000) {
          if (context.mounted) {
            alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text:
                  'Вы достигли дневного лимита переводов. $timeToNextTransfer',
            );
          }

          showLoading(false);
          return;
        }

        if (currentDayAmount + amount > 5000000) {
          if (context.mounted) {
            alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text:
                  'Вы можете перевести максимум еще ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(5000000 - currentDayAmount)}!',
            );
          }

          showLoading(false);
          return;
        }

        await SupabaseController()
            .checkNameOnAvailability(name: name)
            .then((isExist) async {
          if (isExist) {
            String recipientId = '';

            await SupabaseController.supabase!
                .from('users')
                .select('*')
                .eq('name', name)
                .single()
                .then((value) {
              recipientId = value['uid'];
            });

            await SupabaseController.supabase!.from('transactions').insert({
              'amount': amount,
              'recipient': recipientId,
              'senderName': ProfileController.profileModel.nickname,
            });

            await balance.subtractMoney(amountWithComission);

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
