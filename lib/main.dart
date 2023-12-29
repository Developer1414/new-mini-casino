import 'dart:async';
import 'dart:convert';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/date_symbol_data_local.dart';
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
import 'package:new_mini_casino/business/store_manager.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/business/transfer_moneys_manager.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/controllers/notification_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/games_logic/blackjack_logic.dart';
import 'package:new_mini_casino/games_logic/coinflip_logic.dart';
import 'package:new_mini_casino/games_logic/crash_logic.dart';
import 'package:new_mini_casino/games_logic/dice_logic.dart';
import 'package:new_mini_casino/games_logic/fortune_wheel_logic.dart';
import 'package:new_mini_casino/games_logic/jackpot_logic.dart';
import 'package:new_mini_casino/games_logic/keno_logic.dart';
import 'package:new_mini_casino/games_logic/plinko_logic.dart';
import 'package:new_mini_casino/games_logic/stairs_logic.dart';
import 'package:new_mini_casino/screens/bank/bank.dart';
import 'package:new_mini_casino/screens/bank/loan_moneys.dart';
import 'package:new_mini_casino/screens/bank/purchasing_game_currency.dart';
import 'package:new_mini_casino/screens/bank/tax.dart';
import 'package:new_mini_casino/screens/bank/transfer_moneys.dart';
import 'package:new_mini_casino/screens/daily_bonus.dart';
import 'package:new_mini_casino/screens/game_statistic.dart';
import 'package:new_mini_casino/screens/games/blackjack.dart';
import 'package:new_mini_casino/screens/games/coinflip.dart';
import 'package:new_mini_casino/screens/games/crash.dart';
import 'package:new_mini_casino/screens/games/dice.dart';
import 'package:new_mini_casino/screens/games/fortune_wheel.dart';
import 'package:new_mini_casino/screens/games/jackpot.dart';
import 'package:new_mini_casino/screens/games/keno.dart';
import 'package:new_mini_casino/screens/games/mines.dart';
import 'package:new_mini_casino/screens/games/plinko.dart';
import 'package:new_mini_casino/screens/games/slots.dart';
import 'package:new_mini_casino/screens/games/stairs.dart';
import 'package:new_mini_casino/screens/home.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/leader_board.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/screens/money_storage.dart';
import 'package:new_mini_casino/screens/my_promocodes.dart';
import 'package:new_mini_casino/screens/no_internet_connection.dart';
import 'package:new_mini_casino/screens/notifications.dart';
import 'package:new_mini_casino/screens/other_user_profile.dart';
import 'package:new_mini_casino/screens/own_promocode.dart';
import 'package:new_mini_casino/screens/premium.dart';
import 'package:new_mini_casino/screens/privacy_policy.dart';
import 'package:new_mini_casino/screens/profile.dart';
import 'package:new_mini_casino/screens/promocode.dart';
import 'package:new_mini_casino/screens/raffle_info.dart';
import 'package:new_mini_casino/screens/store/store.dart';
import 'package:new_mini_casino/screens/store/store_items.dart';
import 'package:new_mini_casino/screens/store/store_product_review.dart';
import 'package:new_mini_casino/screens/user_agreement.dart';
import 'package:new_mini_casino/screens/verify_number.dart';
import 'package:new_mini_casino/screens/welcome.dart';
import 'package:new_mini_casino/themes/dark_theme.dart';
import 'package:new_mini_casino/themes/dark_theme_provider.dart';
import 'package:new_mini_casino/themes/light_theme.dart';
import 'package:new_mini_casino/widgets/auto_bets.dart';
import 'package:new_mini_casino/widgets/background_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/mines_logic.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseController.initialize();

  Appodeal.initialize(
      appKey: "c78a1ef351d23b50755c40ac6f29bbfd75d1296524830f25",
      adTypes: [
        AppodealAdType.Interstitial,
        AppodealAdType.Banner,
        AppodealAdType.RewardedVideo,
        AppodealAdType.MREC
      ],
      onInitializationFinished: (errors) => {});

  await AppMetrica.activate(
      const AppMetricaConfig("c7091f0c-996b-4764-a824-8b1570535fd6"));
  AppMetrica.reportEvent('My first AppMetrica event!');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    initializeDateFormatting('ru_RU', null)
        .then((value) => runApp(const MainApp()));
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  AppUpdateInfo? _updateInfo;

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;

        if (_updateInfo?.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          InAppUpdate.startFlexibleUpdate().then((_) {
            InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
              if (kDebugMode) {
                print(e.toString());
              }
            });
          }).catchError((e) {
            if (kDebugMode) {
              print(e.toString());
            }
          });
        }
      });
    }).catchError((e) {
      if (kDebugMode) {
        print(e.toString());
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final InAppReview inAppReview = InAppReview.instance;

    if (prefs.containsKey('isFirstGameStarted')) {
      if (!prefs.containsKey('requestReviewDate') ||
          DateTime.now()
                  .difference(
                      DateTime.parse(prefs.getString('requestReviewDate')!))
                  .inDays >=
              30) {
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview().whenComplete(() {
            prefs.setString('requestReviewDate', DateTime.now().toString());
          });
        }
      }
    }
  }

  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state, data) => const Home(),
        '/games': (context, state, data) => const AllGames(),
        '/notifications': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Notifications(),
              ],
            ),
        '/transfer-moneys': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const TransferMoneys(),
              ],
            ),
        '/tax': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Tax(),
              ],
            ),
        '/loan-moneys': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const LoanMoneys(),
              ],
            ),
        '/no-internet': (context, state, data) => const NoInternetConnection(),
        '/premium': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const PremiumInfo(),
              ],
            ),
        '/my-promocodes': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const MyPromocodes(),
              ],
            ),
        '/own-promocode': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const OwnPromocode(),
              ],
            ),
        '/welcome': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Welcome(),
              ],
            ),
        '/daily-bonus': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const DailyBonus(),
              ],
            ),
        '/login': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Login(),
              ],
            ),
        '/bank': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Bank(),
              ],
            ),
        '/store-items': (context, state, data) => const StoreItems(),
        '/profile': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Profile(),
              ],
            ),
        '/raffle-info': (context, state, data) => const RaffleInfo(),
        '/mines': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Mines(),
              ],
            ),
        '/dice': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Dice(),
              ],
            ),
        '/blackjack': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Blackjack(),
              ],
            ),
        '/promocode': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Promocode(),
              ],
            ),
        '/crash': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Crash(),
              ],
            ),
        '/stairs': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Stairs(),
              ],
            ),
        '/jackpot': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Jackpot(),
              ],
            ),
        '/plinko': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Plinko(),
              ],
            ),
        '/keno': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Keno(),
              ],
            ),
        '/slots': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Slots(),
              ],
            ),
        '/coinflip': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const Coinflip(),
              ],
            ),
        '/purchasing-game-currency': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const PurchasingGameCurrency(),
              ],
            ),
        '/product-review': (context, state, data) => const StoreProductReview(),
        '/money-storage': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const MoneyStorage(),
              ],
            ),
        '/fortuneWheel': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const FortuneWheel(),
              ],
            ),
        '/privacy-policy': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const PrivacyPolicy(),
              ],
            ),
        '/user-agreement': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const UserAgreement(),
              ],
            ),
        '/leader-board': (context, state, data) => Stack(
              children: [
                backgroundModel(),
                const LeaderBoard(),
              ],
            ),
        '/other-user-profile/:userName/:userid/:pinId': (context, state, data) {
          final userName = state.pathParameters['userName']!;
          final userid = state.pathParameters['userid']!;
          final pinId = state.pathParameters['pinId']!;

          return BeamPage(
            child: OtherUserProfile(
                userName: userName,
                userId: userid,
                pinId: int.parse(pinId.toString())),
          );
        },
        '/store/:storeName/:path/:models': (context, state, data) {
          final storeName = state.pathParameters['storeName']!;
          final path = state.pathParameters['path']!;
          List<StoreItemModel> models =
              (jsonDecode(state.pathParameters['models']!) as List)
                  .map((modelMap) => StoreItemModel.fromJson(modelMap))
                  .toList()
                ..sort((a, b) => a.price.compareTo(b.price));

          return BeamPage(
            child: Store(storeName: storeName, path: path, models: models),
          );
        },
        '/game-statistic/:game': (context, state, data) {
          final game = state.pathParameters['game']!;
          return BeamPage(
            child: Stack(
              children: [
                backgroundModel(),
                GameStatistic(game: game),
              ],
            ),
          );
        },
        '/verify-email/:email': (context, state, data) {
          final email = state.pathParameters['email']!;
          return BeamPage(
            child: Stack(
              children: [
                backgroundModel(),
                VerifyPhoneNumber(email: email),
              ],
            ),
          );
        },
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    getCurrentAppTheme();

    if (!kDebugMode) {
      checkForUpdate();
    }
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => DarkThemeProvider()),
        ChangeNotifierProvider(
            create: (ctx) => PurchasingGameCurrencyController()),
        ChangeNotifierProvider(create: (ctx) => SupabaseController()),
        ChangeNotifierProvider(create: (ctx) => LoanMoneysManager()),
        ChangeNotifierProvider(create: (ctx) => AutoBetsController()),
        ChangeNotifierProvider(create: (ctx) => TransferMoneysManager()),
        ChangeNotifierProvider(create: (ctx) => NotificationController()),
        ChangeNotifierProvider(create: (ctx) => TaxManager()),
        ChangeNotifierProvider(create: (ctx) => PlinkoLogic()),
        ChangeNotifierProvider(create: (ctx) => MinesLogic()),
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
      ],
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp.router(
            routeInformationParser: BeamerParser(),
            routerDelegate: routerDelegate,
            backButtonDispatcher:
                BeamerBackButtonDispatcher(delegate: routerDelegate),
            theme: value.darkTheme
                ? darkThemeData(context)
                : lightThemeData(context),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
