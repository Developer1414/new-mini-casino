import 'dart:io' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Balance extends ChangeNotifier {
  double balance = 500.0;

  double get currentBalance => balance;

  String get currentBalanceString =>
      NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
          .format(balance);

  void placeBet(double bet) {
    if (balance >= bet) {
      balance -= bet;
      updateBalance();
    }

    notifyListeners();
  }

  void cashout(double profit) {
    balance += profit;
    updateBalance();

    notifyListeners();
  }

  Future loadBalance() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
          .format(0.0);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      balance = double.parse(value.get('balance').toString());
    });
  }

  void updateBalance() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'balance': balance,
    });
  }
}
