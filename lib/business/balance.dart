import 'dart:io' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';

class Balance extends ChangeNotifier {
  double _balance = 500.0;

  double get currentBalance => _balance;

  String get currentBalanceString =>
      NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
          .format(_balance);

  void placeBet(double bet) {
    if (_balance >= bet) {
      _balance -= bet;
      updateBalance();
    }

    notifyListeners();
  }

  void cashout(double profit) {
    _balance += profit;
    updateBalance();

    notifyListeners();
  }

  Future loadBalance() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      _balance = double.parse(value.get('balance').toString());
    });
  }

  void updateBalance() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'balance': _balance,
    });
  }

  void getReward({required BuildContext context, required double rewardCount}) {
    cashout(rewardCount);

    alertDialogSuccess(
      context: context,
      title: 'Поздравляем!',
      confirmBtnText: 'Спасибо!',
      text:
          'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(rewardCount)}!',
    );
  }
}
