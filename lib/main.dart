import 'package:beamer/beamer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/games_logic/dice_logic.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:new_mini_casino/screens/game_statistic.dart';
import 'package:new_mini_casino/screens/games/dice.dart';
import 'package:new_mini_casino/screens/games/mines.dart';
import 'package:new_mini_casino/screens/home.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/leader_board.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/screens/privacy_policy.dart';
import 'package:new_mini_casino/screens/profile.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/mines_logic.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  // knyz.sasha.prince@yandex.ru
  MainApp({super.key});

  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state, data) => const Home(),
        '/games': (context, state, data) => const AllGames(),
        '/login': (context, state, data) => const Login(),
        '/profile': (context, state, data) => const Profile(),
        '/mines': (context, state, data) => const Mines(),
        '/dice': (context, state, data) => const Dice(),
        '/privacy-policy': (context, state, data) => const PrivacyPolicy(),
        '/leader-board': (context, state, data) => const LeaderBoard(),
        '/game-statistic/:game': (context, state, data) {
          final game = state.pathParameters['game']!;
          return BeamPage(
            child: GameStatistic(game: game),
          );
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => MinesLogic()),
        ChangeNotifierProvider(create: (ctx) => DiceLogic()),
        ChangeNotifierProvider(create: (ctx) => Balance()),
        ChangeNotifierProvider(create: (ctx) => AccountController()),
        ChangeNotifierProvider(create: (ctx) => GameStatisticController()),
      ],
      child: MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: routerDelegate,
        backButtonDispatcher:
            BeamerBackButtonDispatcher(delegate: routerDelegate),
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          }),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
