import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/balance_secure.dart';

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

  Future loadBalance(BuildContext context) async {
    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      balance = double.parse(map['balance'].toString());
      BalanceSecure().setLastBalance(balance);
    });
  }

  void updateBalance() async {
    BalanceSecure().setLastBalance(balance);

    await SupabaseController.supabase!
        .from('users')
        .update({'balance': balance}).eq(
            'uid', SupabaseController.supabase?.auth.currentUser!.id);
  }
}
