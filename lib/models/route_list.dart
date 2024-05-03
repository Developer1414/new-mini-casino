import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/widgets/background_model.dart';
import 'dart:convert';
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
import 'package:new_mini_casino/screens/games/dice_classic.dart';
import 'package:new_mini_casino/screens/games/fortune_wheel.dart';
import 'package:new_mini_casino/screens/games/jackpot.dart';
import 'package:new_mini_casino/screens/games/keno.dart';
import 'package:new_mini_casino/screens/games/limbo.dart';
import 'package:new_mini_casino/screens/games/mines.dart';
import 'package:new_mini_casino/screens/games/plinko.dart';
import 'package:new_mini_casino/screens/games/roulette_wheel.dart';
import 'package:new_mini_casino/screens/games/slots.dart';
import 'package:new_mini_casino/screens/games/stairs.dart';
import 'package:new_mini_casino/screens/games/trading.dart';
import 'package:new_mini_casino/screens/home.dart';
import 'package:new_mini_casino/screens/latest_max_wins.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/leader_board.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/screens/money_storage.dart';
import 'package:new_mini_casino/screens/local_bonuses.dart';
import 'package:new_mini_casino/screens/no_internet_connection.dart';
import 'package:new_mini_casino/screens/notifications.dart';
import 'package:new_mini_casino/screens/other_user_profile.dart';
import 'package:new_mini_casino/screens/own_promocode.dart';
import 'package:new_mini_casino/screens/premium.dart';
import 'package:new_mini_casino/screens/privacy_policy.dart';
import 'package:new_mini_casino/screens/profile.dart';
import 'package:new_mini_casino/screens/promocode.dart';
import 'package:new_mini_casino/screens/raffle_info.dart';
import 'package:new_mini_casino/screens/settings.dart';
import 'package:new_mini_casino/screens/store/store.dart';
import 'package:new_mini_casino/screens/store/store_items.dart';
import 'package:new_mini_casino/screens/store/store_product_review.dart';
import 'package:new_mini_casino/screens/user_agreement.dart';
import 'package:new_mini_casino/screens/verify_number.dart';
import 'package:new_mini_casino/screens/welcome.dart';
import 'package:new_mini_casino/business/store_manager.dart';

Map<Pattern, dynamic Function(BuildContext, BeamState, Object?)> routeList = {
  '/': (context, state, data) => const Home(),
  '/games': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const AllGames(),
        ],
      ),
  '/notifications': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const Notifications(),
        ],
      ),
  '/limbo': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const Limbo(),
        ],
      ),
  '/dice-classic': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const DiceClassic(),
        ],
      ),
  '/trading': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const Trading(),
        ],
      ),
  '/settings': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const Settings(),
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
  '/local-bonuses': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const LocalBonuses(),
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
  '/raffle-info': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const RaffleInfo(),
        ],
      ),
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
  '/roulette-wheel': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const RouletteWheel(),
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
  '/latest-max-wins': (context, state, data) => Stack(
        children: [
          backgroundModel(),
          const LatestMaxWins(),
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
    List<StoreItemModel> models = (jsonDecode(state.pathParameters['models']!)
            as List)
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
  '/verify-email/:email/:isResetPassword': (context, state, data) {
    final email = state.pathParameters['email']!;
    bool isResetPassword =
        state.pathParameters['isResetPassword']! == 'true' ? true : false;
    return BeamPage(
      child: Stack(
        children: [
          backgroundModel(),
          VerifyPhoneNumber(email: email, isResetPassword: isResetPassword),
        ],
      ),
    );
  },
};
