import 'package:new_mini_casino/business/rakeback_manager.dart';
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/controllers/latest_max_wins_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/themes/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:new_mini_casino/games_logic/blackjack_logic.dart';
import 'package:new_mini_casino/games_logic/coinflip_logic.dart';
import 'package:new_mini_casino/games_logic/crash_logic.dart';
import 'package:new_mini_casino/games_logic/dice_classic_logic.dart';
import 'package:new_mini_casino/games_logic/dice_logic.dart';
import 'package:new_mini_casino/games_logic/fortune_wheel_logic.dart';
import 'package:new_mini_casino/games_logic/jackpot_logic.dart';
import 'package:new_mini_casino/games_logic/keno_logic.dart';
import 'package:new_mini_casino/games_logic/limbo_logic.dart';
import 'package:new_mini_casino/games_logic/plinko_logic.dart';
import 'package:new_mini_casino/games_logic/roulette_logic.dart';
import 'package:new_mini_casino/games_logic/slots_logic.dart';
import 'package:new_mini_casino/games_logic/stairs_logic.dart';
import 'package:new_mini_casino/games_logic/trading_logic.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/business/transfer_moneys_manager.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/notification_controller.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/business/bank_manager.dart';
import 'package:new_mini_casino/business/bonus_manager.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/business/get_premium_version.dart';
import 'package:new_mini_casino/business/loan_moneys_manager.dart';
import 'package:new_mini_casino/business/money_storage_manager.dart';
import 'package:new_mini_casino/business/own_promocode_manager.dart';
import 'package:new_mini_casino/business/promocode_manager.dart';
import 'package:new_mini_casino/business/purchasing_game_currency_controller.dart';
import 'package:new_mini_casino/business/raffle_manager.dart';
import 'package:new_mini_casino/widgets/auto_bets.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/mines_logic.dart';

List<SingleChildWidget> providerList = [
  ChangeNotifierProvider(create: (ctx) => DarkThemeProvider()),
  ChangeNotifierProvider(create: (ctx) => PurchasingGameCurrencyController()),
  ChangeNotifierProvider(create: (ctx) => SupabaseController()),
  ChangeNotifierProvider(create: (ctx) => LimboLogic()),
  ChangeNotifierProvider(create: (ctx) => SettingsController()),
  ChangeNotifierProvider(create: (ctx) => LoanMoneysManager()),
  ChangeNotifierProvider(create: (ctx) => AutoBetsController()),
  ChangeNotifierProvider(create: (ctx) => TransferMoneysManager()),
  ChangeNotifierProvider(create: (ctx) => NotificationController()),
  ChangeNotifierProvider(create: (ctx) => TaxManager()),
  ChangeNotifierProvider(create: (ctx) => DiceClassicLogic()),
  ChangeNotifierProvider(create: (ctx) => TradingLogic()),
  ChangeNotifierProvider(create: (ctx) => PlinkoLogic()),
  ChangeNotifierProvider(create: (ctx) => MinesLogic()),
  ChangeNotifierProvider(create: (ctx) => RouletteLogic()),
  ChangeNotifierProvider(create: (ctx) => BankManager()),
  ChangeNotifierProvider(create: (ctx) => BlackjackLogic()),
  ChangeNotifierProvider(create: (ctx) => Payment()),
  ChangeNotifierProvider(create: (ctx) => MoneyStorageManager()),
  ChangeNotifierProvider(create: (ctx) => RaffleManager()),
  ChangeNotifierProvider(create: (ctx) => DailyBonusManager()),
  ChangeNotifierProvider(create: (ctx) => PromocodeManager()),
  ChangeNotifierProvider(create: (ctx) => BonusManager()),
  ChangeNotifierProvider(create: (ctx) => OwnPromocodeManager()),
  ChangeNotifierProvider(create: (ctx) => CoinflipLogic()),
  ChangeNotifierProvider(create: (ctx) => StoreManager()),
  ChangeNotifierProvider(create: (ctx) => CrashLogic()),
  ChangeNotifierProvider(create: (ctx) => KenoLogic()),
  ChangeNotifierProvider(create: (ctx) => StairsLogic()),
  ChangeNotifierProvider(create: (ctx) => FortuneWheelLogic()),
  ChangeNotifierProvider(create: (ctx) => DiceLogic()),
  ChangeNotifierProvider(create: (ctx) => JackpotLogic()),
  ChangeNotifierProvider(create: (ctx) => Balance()),
  ChangeNotifierProvider(create: (ctx) => GameStatisticController()),
  ChangeNotifierProvider(create: (ctx) => SlotsLogic()),
  ChangeNotifierProvider(create: (ctx) => LatestMaxWinsController()),
  ChangeNotifierProvider(create: (ctx) => RakebackManager()),
];
