import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/screens/banned_user.dart';
import 'package:provider/provider.dart';

class BalanceSecure {
  static String lastBalance = '';
  static String lastMoneyStorageBalance = '';

  void setLastBalance(double balance, {bool isMoneyStorage = false}) {
    String result = '';

    for (int i = 0; i < balance.toString().length; i++) {
      result += '@${balance.toString()[i]}';
    }

    if (!isMoneyStorage) {
      lastBalance = result;
    } else {
      lastMoneyStorageBalance = result;
    }
  }

  void banUser(BuildContext context) {
    Provider.of<Balance>(context, listen: false)
        .placeBet(Provider.of<Balance>(context, listen: false).currentBalance);

    SupabaseController.supabase!.from('users').update({'moneyStorage': 0}).eq(
        'uid', SupabaseController.supabase?.auth.currentUser!.id);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BannedUser(reason: """Уведомление о нарушении правил

Мы обнаружили аномальные изменения в вашем игровом балансе, которые могут указывать на нарушение правил игры. По этому, ваш баланс был сброшен до 0. Мы придаем большое значение честности и интегритету игрового процесса, и внешние вмешательства могут навредить вашему опыту и опыту других игроков.

Если вы считаете, что это произошло по ошибке или у вас есть дополнительные вопросы, пожалуйста, свяжитесь с нашей поддержкой по адресу "develope14000@gmail.com". Мы готовы рассмотреть вашу ситуацию и предоставить разъяснения.

Чтобы продолжить игру, свяжитесь с нами и объясните ситуацию. Пожалуйста, помните, что соблюдение правил игры важно для поддержания честного и веселого опыта для всех игроков.

С уважением, 
Revens.""", date: DateTime.now(), isBannedAccount: false)));
  }

  double getLastBalance() {
    return double.parse(lastBalance.replaceAll('@', ''));
  }

  double getLastMoneyStorageBalance() {
    return double.parse(lastMoneyStorageBalance.replaceAll('@', ''));
  }
}
