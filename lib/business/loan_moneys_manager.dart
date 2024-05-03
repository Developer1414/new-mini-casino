import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:shared_preferences/shared_preferences.dart';

class UserLoan {
  DateTime loanMaturity;
  DateTime paymentDelay;
  double amount;
  int percent;

  UserLoan(
      {required this.amount,
      required this.loanMaturity,
      required this.paymentDelay,
      required this.percent});

  UserLoan.fromJson(Map<String, dynamic> json)
      : loanMaturity = DateTime.parse(json['loanMaturity']),
        paymentDelay = DateTime.parse(json['paymentDelay']),
        amount = json['amount'],
        percent = json['percent'];

  Map<String, dynamic> toJson() => {
        'loanMaturity': loanMaturity.toString(),
        'paymentDelay': paymentDelay.toString(),
        'amount': amount,
        'percent': percent,
      };
}

class LoanMoneysManager extends ChangeNotifier {
  bool isLoading = false;

  UserLoan? userLoan;

  double maxLoan = 0.0;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  void takeLoan({required double amount, required BuildContext context}) async {
    final balance = Provider.of<Balance>(context, listen: false);

    if (amount > maxLoan) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Ваш максимально допустимый кредит - ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(maxLoan)}',
      );

      return;
    }

    if (amount > 1000000) {
      return;
    }

    balance.addMoney(amount);

    userLoan = UserLoan(
      percent: 10,
      amount: amount,
      loanMaturity: DateTime.now().add(const Duration(days: 8)),
      paymentDelay: DateTime.now().add(const Duration(days: 8)),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loan', jsonEncode(userLoan));

    if (context.mounted) {
      alertDialogSuccess(
          context: context,
          title: 'Успех',
          text:
              'Вы успешно взяли кредит в ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(amount)}!');

      AdService.showInterstitialAd(context: context, func: () {}, isBet: false);
    }

    notifyListeners();
  }

  Future<UserLoan?> getLoan(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (context.mounted) {
      await ProfileController.getUserProfile(context);
    }

    maxLoan = ProfileController.profileModel.totalGame >= 1000
        ? (10000 * (ProfileController.profileModel.totalGame / 1000))
                .floor()
                .toDouble() *
            (SupabaseController.isPremium ? 2 : 1)
        : 10000 * (SupabaseController.isPremium ? 2 : 1);

    if (prefs.containsKey('loan')) {
      userLoan =
          UserLoan.fromJson(jsonDecode(prefs.getString('loan').toString()));

      if (userLoan!.loanMaturity.difference(DateTime.now()).inHours <= 0 &&
          userLoan!.paymentDelay.difference(DateTime.now()).inHours <= 0) {
        userLoan!.percent += 3;
        userLoan!.paymentDelay = DateTime.now().add(const Duration(days: 1));
        prefs.setString('loan', jsonEncode(userLoan));
      }
    }

    return userLoan;
  }

  void repayLoan({required BuildContext context}) async {
    final balance = Provider.of<Balance>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    double loanAmount =
        userLoan!.amount + (userLoan!.amount * userLoan!.percent / 100);

    // if (balance.currentBalance < loanAmount) {
    //   if (context.mounted) {
    //     alertDialogError(
    //       context: context,
    //       title: 'Ошибка',
    //       confirmBtnText: 'Окей',
    //       text: 'Недостаточно средств на балансе!',
    //     );
    //   }

    //   return;
    // }

    balance.subtractMoney(loanAmount);
    prefs.remove('loan');

    userLoan = null;

    if (context.mounted) {
      alertDialogSuccess(
          context: context,
          title: 'Успех',
          text:
              'Вы успешно погасили кредит в ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(loanAmount)}!');

      AdService.showInterstitialAd(context: context, func: () {}, isBet: false);
    }

    notifyListeners();
  }
}
