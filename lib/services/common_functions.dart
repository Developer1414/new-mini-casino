import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/business/local_promocodes_service.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/balance_secure.dart';
import 'package:new_mini_casino/widgets/no_internet_connection_dialog.dart';
import 'package:provider/provider.dart';

class CommonFunctions {
  static void call(
      {required BuildContext context,
      required double bet,
      required String gameName,
      bool isPlaceBet = true}) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    // ignore: use_build_context_synchronously
    final balance = Provider.of<Balance>(context, listen: false);

    if (connectivityResult == ConnectivityResult.none) {
      if (context.mounted) {
        showBadInternetConnectionDialog(context);
      }
    }

    if (balance.currentBalance.truncateToDouble() !=
        BalanceSecure().getLastBalance().truncateToDouble()) {
      // ignore: use_build_context_synchronously
      BalanceSecure().banUser(context);
      return;
    }

    if (context.mounted) {
      LocalPromocodes().getPromocode(context);
      Provider.of<TaxManager>(context, listen: false).addTax(bet);
    }

    SupabaseController().levelUp();
    DailyBonusManager().updateDailyBetsCount();

    GameStatisticController.updateGameStatistic(
        gameName: gameName,
        incrementTotalGames: true,
        gameStatisticModel: GameStatisticModel());

    if (isPlaceBet) {
      if (context.mounted) {
        balance.placeBet(bet);
      }
    }
  }
}
