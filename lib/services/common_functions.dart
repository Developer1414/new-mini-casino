// ignore_for_file: use_build_context_synchronously

import 'package:beamer/beamer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/business/local_bonuse_manager.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/latest_max_wins_controller.dart';
import 'package:new_mini_casino/controllers/leader_day_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/games_logic/blackjack_logic.dart';
import 'package:new_mini_casino/games_logic/coinflip_logic.dart';
import 'package:new_mini_casino/games_logic/crash_logic.dart';
import 'package:new_mini_casino/games_logic/dice_classic_logic.dart';
import 'package:new_mini_casino/games_logic/dice_logic.dart';
import 'package:new_mini_casino/games_logic/fortune_wheel_logic.dart';
import 'package:new_mini_casino/games_logic/jackpot_logic.dart';
import 'package:new_mini_casino/games_logic/keno_logic.dart';
import 'package:new_mini_casino/games_logic/limbo_logic.dart';
import 'package:new_mini_casino/games_logic/mines_logic.dart';
import 'package:new_mini_casino/games_logic/slots_logic.dart';
import 'package:new_mini_casino/games_logic/stairs_logic.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/no_internet_connection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';

class CommonFunctions {
  static bool isLoading = false;

  static Future showErrorAlertNoBalance(BuildContext context) async {
    await alertDialogConfirm(
      context: context,
      title: 'Ошибка',
      text: 'Недостаточно средств на балансе!',
      barrierDismissible: false,
      type: QuickAlertType.error,
      confirmBtnText: 'Купить',
      cancelBtnText: 'Отмена',
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        context.beamToNamed('/purchasing-game-currency');
      },
      onCancelBtnTap: () => Navigator.of(context, rootNavigator: true).pop(),
    );
  }

  static Future<ConnectivityResult> checkConnectivity() async {
    return await (Connectivity().checkConnectivity());
  }

  static Future<bool> checkOnExistSpecificAmount(
      BuildContext context, double bet) async {
    return await Provider.of<Balance>(context, listen: false)
        .checkOnExistSpecificAmount(bet);
  }

  static Future callOnStart(
      {required BuildContext context,
      required double bet,
      required String gameName,
      required VoidCallback callback,
      bool isPlaceBet = true}) async {
    final balance = Provider.of<Balance>(context, listen: false);

    balance.showLoading(true);

    bool isError = false;

    await Future.wait([
      checkConnectivity(),
      checkOnExistSpecificAmount(context, bet),
    ]).then((result) async {
      if (result[0] == ConnectivityResult.none) {
        isError = true;

        await showBadInternetConnectionDialog(context);

        return;
      }

      if (result[1] == false) {
        isError = true;

        balance.showLoading(false);

        Provider.of<Balance>(context, listen: false).loadBalance(context);

        await showErrorAlertNoBalance(context);

        return;
      }
    });

    if (isError) return;

    if (!isLoading) {
      isLoading = true;

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

      //AudioController.play(AudioType.bet);

      if (isPlaceBet) {
        if (context.mounted) {
          await balance.subtractMoney(bet);
          callback.call();
        }
      }

      isLoading = false;
    }
  }

  static void setDefaultGamesMinBet(
      {required BuildContext context, required double defaultMinBet}) {
    Provider.of<DiceClassicLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<LimboLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<BlackjackLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<StairsLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<JackpotLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<MinesLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<DiceLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<CoinflipLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<FortuneWheelLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<CrashLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<KenoLogic>(context, listen: false).bet = defaultMinBet;
    Provider.of<SlotsLogic>(context, listen: false).bet = defaultMinBet;
  }

  static void callOnProfit({
    required BuildContext context,
    required double bet,
    required double profit,
    required String gameName,
  }) async {
    await LeaderDayController.createNewLeader(
      context: context,
      bet: bet,
      profit: profit,
      gameName: gameName,
    );

    if ((profit / bet - 1) * 100 >= 700) {
      await LatestMaxWinsController.addMaxWin(
        context: context,
        bet: bet,
        profit: profit,
        gameName: gameName,
      );
    }
  }
}
