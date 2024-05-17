import 'package:flutter/material.dart';
import 'package:new_mini_casino/screens/bank/bank.dart';
import 'package:new_mini_casino/screens/bank/loan_moneys.dart';
import 'package:new_mini_casino/screens/bank/purchasing_game_currency.dart';
import 'package:new_mini_casino/screens/bank/rakeback.dart';
import 'package:new_mini_casino/screens/bank/tax.dart';
import 'package:new_mini_casino/screens/bank/transfer_moneys.dart';
import 'package:new_mini_casino/screens/banned_user.dart';
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
import 'package:new_mini_casino/screens/leader_board.dart';
import 'package:new_mini_casino/screens/local_bonuses.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/screens/money_storage.dart';
import 'package:new_mini_casino/screens/no_internet_connection.dart';
import 'package:new_mini_casino/screens/notifications.dart';
import 'package:new_mini_casino/screens/own_promocode.dart';
import 'package:new_mini_casino/screens/premium.dart';
import 'package:new_mini_casino/screens/privacy_policy.dart';
import 'package:new_mini_casino/screens/profile.dart';
import 'package:new_mini_casino/screens/promocode.dart';
import 'package:new_mini_casino/screens/raffle_info.dart';
import 'package:new_mini_casino/screens/settings.dart';
import 'package:new_mini_casino/screens/store/store_items.dart';
import 'package:new_mini_casino/screens/store/store_product_review.dart';
import 'package:new_mini_casino/screens/user_agreement.dart';
import 'package:new_mini_casino/screens/verify_email.dart';
import 'package:new_mini_casino/screens/welcome.dart';
import 'package:new_mini_casino/widgets/background_model.dart';

class RouteController {
  static Widget buildScreen(Widget screen) {
    return Stack(
      children: [
        backgroundModel(),
        screen,
      ],
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => buildScreen(const Home()));
      case '/login':
        return MaterialPageRoute(builder: (_) => buildScreen(const Login()));
      case '/games':
        return MaterialPageRoute(builder: (_) => buildScreen(const AllGames()));
      case '/notifications':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const Notifications()));
      case '/limbo':
        return MaterialPageRoute(builder: (_) => buildScreen(const Limbo()));
      case '/dice-classic':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const DiceClassic()));
      case '/trading':
        return MaterialPageRoute(builder: (_) => buildScreen(const Trading()));
      case '/settings':
        return MaterialPageRoute(builder: (_) => buildScreen(const Settings()));
      case '/transfer-moneys':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const TransferMoneys()));
      case '/tax':
        return MaterialPageRoute(builder: (_) => buildScreen(const Tax()));
      case '/loan-moneys':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const LoanMoneys()));
      case '/no-internet':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const NoInternetConnection()));
      case '/premium':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const PremiumInfo()));
      case '/local-bonuses':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const LocalBonuses()));
      case '/own-promocode':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const OwnPromocode()));
      case '/welcome':
        return MaterialPageRoute(builder: (_) => buildScreen(const Welcome()));
      case '/daily-bonus':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const DailyBonus()));
      case '/bank':
        return MaterialPageRoute(builder: (_) => buildScreen(const Bank()));
      case '/store-items':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const StoreItems()));
      case '/profile':
        return MaterialPageRoute(builder: (_) => buildScreen(const Profile()));
      case '/raffle-info':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const RaffleInfo()));
      case '/mines':
        return MaterialPageRoute(builder: (_) => buildScreen(const Mines()));
      case '/dice':
        return MaterialPageRoute(builder: (_) => buildScreen(const Dice()));
      case '/blackjack':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const Blackjack()));
      case '/promocode':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const Promocode()));
      case '/crash':
        return MaterialPageRoute(builder: (_) => buildScreen(const Crash()));
      case '/roulette-wheel':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const RouletteWheel()));
      case '/stairs':
        return MaterialPageRoute(builder: (_) => buildScreen(const Stairs()));
      case '/jackpot':
        return MaterialPageRoute(builder: (_) => buildScreen(const Jackpot()));
      case '/plinko':
        return MaterialPageRoute(builder: (_) => buildScreen(const Plinko()));
      case '/keno':
        return MaterialPageRoute(builder: (_) => buildScreen(const Keno()));
      case '/slots':
        return MaterialPageRoute(builder: (_) => buildScreen(const Slots()));
      case '/coinflip':
        return MaterialPageRoute(builder: (_) => buildScreen(const Coinflip()));
      case '/purchasing-game-currency':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const PurchasingGameCurrency()));
      case '/product-review':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const StoreProductReview()));
      case '/money-storage':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const MoneyStorage()));
      case '/latest-max-wins':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const LatestMaxWins()));
      case '/fortuneWheel':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const FortuneWheel()));
      case '/privacy-policy':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const PrivacyPolicy()));
      case '/user-agreement':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const UserAgreement()));
      case '/leader-board':
        return MaterialPageRoute(
            builder: (_) => buildScreen(const LeaderBoard()));
      case '/rakeback':
        return MaterialPageRoute(builder: (_) => buildScreen(const Rakeback()));
      case '/ban':
        List<dynamic> args = (settings.arguments as List<dynamic>);

        return MaterialPageRoute(
            builder: (_) => buildScreen(BannedUser(
                  reason: args[0].toString(),
                  date: args[1],
                )));
      case '/game-statistic':
        return MaterialPageRoute(
            builder: (_) => buildScreen(GameStatistic(
                  game: settings.arguments.toString(),
                )));
      case '/verify-email':
        List<dynamic> args = (settings.arguments as List<dynamic>);

        return MaterialPageRoute(
            builder: (_) => buildScreen(VerifyPhoneNumber(
                  email: args[0].toString(),
                  isResetPassword: (args[1] as bool),
                )));
      default:
        return MaterialPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) => buildScreen(const Login()));
    }
  }
}
