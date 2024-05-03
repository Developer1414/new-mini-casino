import 'dart:async';
import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';

class Balance extends ChangeNotifier {
  double balance = 500.0;

  double get currentBalance => balance;

  String get currentBalanceString =>
      NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
          .format(balance);

  Future subtractMoney(double bet) async {
    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      double currentServerBalance = double.parse(map['balance'].toString());

      if (bet > currentServerBalance) {
        return;
      } else {
        currentServerBalance -= bet;

        await updateBalance(currentServerBalance);
      }
    });

    notifyListeners();
  }

  Future<bool> checkOnExistSpecificAmount(double amount) async {
    double currentServerBalance = 0.0;

    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;
      currentServerBalance = double.parse(map['balance'].toString());
    });

    return amount <= currentServerBalance;
  }

  Future addMoney(double profit) async {
    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      double currentServerBalance = double.parse(map['balance'].toString());

      currentServerBalance += profit;

      await updateBalance(currentServerBalance);
    });

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
    });

    notifyListeners();
  }

  Future updateBalance(double value) async {
    await SupabaseController.supabase!
        .from('users')
        .update({'balance': value}).eq(
            'uid', SupabaseController.supabase?.auth.currentUser!.id);

    balance = value;

    notifyListeners();
  }
}
