import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class OwnPromocodeManager extends ChangeNotifier {
  bool isLoading = false;

  double countActivation = 1;
  double prize = 0.0;
  double totalPrize = 0.0;

  void onPromocodeChanged() {
    totalPrize = AccountController.isPremium
        ? prize + (countActivation * 50)
        : (prize + (prize / 2)) + (countActivation * 50);
    notifyListeners();
  }

  void onCountActivationChanged(double value) {
    countActivation = value;
    onPromocodeChanged();
    notifyListeners();
  }

  void create({required BuildContext context, required String name}) async {
    if (prize > 500000) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Промокод не может быть больше ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(500000)}!',
      );

      return;
    }

    if (prize < 1000) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Промокод не может быть меньше ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(1000)}!',
      );

      return;
    }

    final balance = Provider.of<Balance>(context, listen: false);

    if (balance.currentBalance < totalPrize) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Недостаточно средст на балансе!',
      );

      return;
    }

    isLoading = true;
    notifyListeners();

    await FirebaseFirestore.instance
        .collection('promocodes')
        .doc(name)
        .get()
        .then((value) async {
      if (value.exists) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: 'Такой промокод уже существует!',
        );
      } else {
        await FirebaseFirestore.instance
            .collection('promocodes')
            .doc(name)
            .set({
          'prize': prize,
          'count': countActivation.round(),
          'uid': FirebaseAuth.instance.currentUser!.uid
        }).whenComplete(() async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get()
              .then((value) async {
            if (value.data()!.containsKey('promocodes')) {
              List list = value.get('promocodes') as List;
              list.add(name);

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({'promocodes': list});
            } else {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({
                'promocodes': [name]
              });
            }
          });
        });

        balance.placeBet(totalPrize);

        // ignore: use_build_context_synchronously
        AdService.showInterstitialAd(
            context: context, func: () {}, isBet: false);

        // ignore: use_build_context_synchronously
        alertDialogSuccess(
          context: context,
          title: 'Поздравляем!',
          confirmBtnText: 'Спасибо!',
          text: 'Промокод успешно создан!',
        );
      }
    });

    isLoading = false;
    notifyListeners();
  }
}
