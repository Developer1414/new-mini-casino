import 'dart:async';
import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';

class Balance extends ChangeNotifier {
  double balance = 500.0;

  bool isLoading = false;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  double get currentBalance => balance;

  String get currentBalanceString =>
      NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
          .format(balance);

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

  Future subtractMoney(double amount) async {
    showLoading(true);

    await SupabaseController.supabase!
        .from('users')
        .select()
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      double currentServerBalance = double.parse(map['balance'].toString());

      if (amount > currentServerBalance) {
        showLoading(false);
        return;
      } else {
        currentServerBalance -= amount;

        await updateBalance(currentServerBalance);
      }
    });

    notifyListeners();
  }

  Future addMoney(double amount) async {
    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      double currentServerBalance = double.parse(map['balance'].toString());

      currentServerBalance += amount;

      await updateBalance(currentServerBalance);
    });

    notifyListeners();
  }

  Future startListenBalance(BuildContext context) async {
    SupabaseController.supabase!
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .listen((List<Map<String, dynamic>> data) {
          balance = double.parse(data.first['balance'].toString());
          notifyListeners();
        });
  }

  Future updateBalance(double value) async {
    await SupabaseController.supabase!
        .from('users')
        .update({'balance': value}).eq(
            'uid', SupabaseController.supabase?.auth.currentUser!.id);

    //balance = value;

    showLoading(false);

    notifyListeners();
  }
}
