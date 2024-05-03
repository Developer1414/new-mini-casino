import 'package:flutter/material.dart';
import 'dart:io' as ui;
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/ad_service.dart';
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

  Future<String> loadBalance(BuildContext context) async {
    try {
      await SupabaseController.supabase!
          .from('users')
          .select('*')
          .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
          .then((value) {
        Map<dynamic, dynamic> map = (value as List<dynamic>).first;

        balance = double.parse(map['moneyStorage'].toString());
      });
    } on Exception catch (e) {
      if (context.mounted) {
        alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: '[MoneyStorageLoadError]: ${e.toString()}');
      }
    }

    return NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .format(balance);
  }

  Future subtractFromStorage(double amount) async {
    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      double serverStorageBalance =
          double.parse(map['moneyStorage'].toString());

      serverStorageBalance -= amount;
      balance = serverStorageBalance;

      await updateStorageBalance(serverStorageBalance);
    });

    notifyListeners();
  }

  Future addToStorage(double amount) async {
    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      double serverStorageBalance =
          double.parse(map['moneyStorage'].toString());

      serverStorageBalance += amount;
      balance = serverStorageBalance;

      await updateStorageBalance(serverStorageBalance);
    });

    notifyListeners();
  }

  Future updateStorageBalance(double value) async {
    await SupabaseController.supabase!
        .from('users')
        .update({'moneyStorage': value}).eq(
            'uid', SupabaseController.supabase?.auth.currentUser!.id);
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

    showLoading(true);

    bool isCanTransfer = await mainBalance.checkOnExistSpecificAmount(amount);

    if (!isCanTransfer) {
      if (context.mounted) {
        alertDialogError(
            context: context,
            title: 'Ошибка',
            text: 'Сумма списания превышает сумму на основном счету!');
      }

      showLoading(false);

      return;
    }

    await mainBalance.subtractMoney(amount);
    await addToStorage(amount);

    showLoading(false);

    if (context.mounted) {
      alertDialogSuccess(
          context: context,
          title: 'Успех',
          text:
              'Вы успешно перевели ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(amount)} в хранилище!');
    }

    if (context.mounted) {
      AdService.showInterstitialAd(context: context, func: () {}, isBet: false);
    }
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

    showLoading(true);

    mainBalance.addMoney(amount);
    await subtractFromStorage(amount);

    if (context.mounted) {
      alertDialogSuccess(
          context: context,
          title: 'Успех',
          text:
              'Вы успешно перевели ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(amount)} на основной счёт!');
    }

    showLoading(false);

    if (context.mounted) {
      AdService.showInterstitialAd(context: context, func: () {}, isBet: false);
    }
  }
}
