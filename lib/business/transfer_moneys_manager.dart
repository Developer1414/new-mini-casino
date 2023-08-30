import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class TransferMoneysManager extends ChangeNotifier {
  bool isLoading = false;

  String currentAmount =
      NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(0.0);

  void changeAmount(double amount) {
    currentAmount = NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .format(
            AccountController.isPremium ? amount : amount + (amount * 5 / 100));

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
    final balance = Provider.of<Balance>(context, listen: false);

    double amountWithComission =
        AccountController.isPremium ? amount : amount + (amount * 5 / 100);

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

    await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: 'Игрок с таким никнеймом не найден!',
        );

        showLoading(false);
      } else {
        DateTime dateTimeNow = await NTP.now();

        await FirebaseFirestore.instance.collection('notifications').doc().set({
          'amount': amount,
          'from': ProfileController.profileModel.nickname,
          'uid': value.docs.first.get('uid'),
          'action': 'transfer_moneys',
          'date': dateTimeNow,
        }).whenComplete(() async {});

        balance.placeBet(amountWithComission);

        showLoading(false);

        // ignore: use_build_context_synchronously
        alertDialogSuccess(
          context: context,
          title: 'Успех',
          confirmBtnText: 'Спасибо',
          text:
              '${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(amount)} успешно переведены!',
        );

        // ignore: use_build_context_synchronously
        AdService.showInterstitialAd(
            context: context, func: () {}, isBet: false);
      }
    });
  }
}
