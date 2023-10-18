import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io' as ui;
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/balance_secure.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:provider/provider.dart';

class MoneyStorageManager extends ChangeNotifier {
  bool isLoading = false;

  double balance = 0.0;

  double get currentBalance => balance;

  String get currentBalanceString =>
      NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
          .format(balance);

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future loadBalance(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((value) {
        if (value.data()!.containsKey('moneyStorage')) {
          balance = double.parse(value.get('moneyStorage').toString());
          BalanceSecure().setLastBalance(balance, isMoneyStorage: true);
        }
      });
    } on Exception catch (e) {
      // ignore: use_build_context_synchronously
      alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: '[MoneyStorageLoadError]: ${e.toString()}');
    }
  }

  void removeFromStorage(double amount) {
    balance -= amount;

    updateStorageBalance();
    notifyListeners();
  }

  void addToStorage(double amount) {
    balance += amount;
    updateStorageBalance();
    notifyListeners();
  }

  void updateStorageBalance() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'moneyStorage': balance,
    });

    BalanceSecure().setLastBalance(balance, isMoneyStorage: true);
  }

  void transferToStorage(
      {required double amount, required BuildContext context}) async {
    final mainBalance = Provider.of<Balance>(context, listen: false);

    if (amount < 1000) {
      alertDialogError(
          context: context,
          title: 'Ошибка',
          text:
              'Перевод в хранилище доступен от ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(1000)}');
      return;
    }

    if (mainBalance.currentBalance < amount) {
      alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'Сумма списания превышает сумму на основном счету!');
      return;
    }

    mainBalance.placeBet(amount);
    addToStorage(amount);

    alertDialogSuccess(
        context: context,
        title: 'Успех',
        text:
            'Вы успешно перевели ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(amount)} в хранилище!');

    AdService.showInterstitialAd(context: context, func: () {}, isBet: false);
  }

  void transferToMainAccount(
      {required double amount, required BuildContext context}) async {
    final mainBalance = Provider.of<Balance>(context, listen: false);

    if (amount > balance) {
      alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'Сумма списания превышает сумму в хранилище!');
      return;
    }

    if (balance.truncateToDouble() !=
        BalanceSecure().getLastMoneyStorageBalance().truncateToDouble()) {
      BalanceSecure().banUser(context);
      return;
    }

    mainBalance.cashout(amount);
    removeFromStorage(amount);

    alertDialogSuccess(
        context: context,
        title: 'Успех',
        text:
            'Вы успешно перевели ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(amount)} на основной счёт!');

    AdService.showInterstitialAd(context: context, func: () {}, isBet: false);
  }
}
