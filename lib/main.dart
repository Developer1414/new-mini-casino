import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/games_logic/coinflip_logic.dart';
import 'package:new_mini_casino/games_logic/crash_logic.dart';
import 'package:new_mini_casino/games_logic/dice_logic.dart';
import 'package:new_mini_casino/games_logic/fortune_wheel_logic.dart';
import 'package:new_mini_casino/games_logic/keno_logic.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/screens/game_statistic.dart';
import 'package:new_mini_casino/screens/games/coinflip.dart';
import 'package:new_mini_casino/screens/games/crash.dart';
import 'package:new_mini_casino/screens/games/dice.dart';
import 'package:new_mini_casino/screens/games/fortune_wheel.dart';
import 'package:new_mini_casino/screens/games/keno.dart';
import 'package:new_mini_casino/screens/games/mines.dart';
import 'package:new_mini_casino/screens/home.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/leader_board.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/screens/privacy_policy.dart';
import 'package:new_mini_casino/screens/profile.dart';
import 'package:new_mini_casino/screens/user_games_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/games_logic/mines_logic.dart';
import 'package:provider/provider.dart';
import 'package:freerasp/talsec_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Appodeal.initialize(
      appKey: "c78a1ef351d23b50755c40ac6f29bbfd75d1296524830f25",
      adTypes: [
        AppodealAdType.Interstitial,
        AppodealAdType.Banner,
        AppodealAdType.RewardedVideo,
        AppodealAdType.MREC
      ],
      onInitializationFinished: (errors) => {});

  //FirebaseAuth.instance.signOut();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  AppUpdateInfo? _updateInfo;

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
        '/login': (context, state, data) => const Login(),
        '/profile': (context, state, data) => const Profile(),
        '/mines': (context, state, data) => const Mines(),
        '/dice': (context, state, data) => const Dice(),
        '/crash': (context, state, data) => const Crash(),
        '/keno': (context, state, data) => const Keno(),
        '/coinflip': (context, state, data) => const Coinflip(),
        '/fortuneWheel': (context, state, data) => const FortuneWheel(),
        '/privacy-policy': (context, state, data) => const PrivacyPolicy(),
        '/leader-board': (context, state, data) => const LeaderBoard(),
        '/user-history/:userNickname/:userid': (context, state, data) {
          final userNickname = state.pathParameters['userNickname']!;
          final userid = state.pathParameters['userid']!;
          return BeamPage(
            child: UserGamesHistory(userNickname: userNickname, userid: userid),
          );
        },
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initSecurityState();

    checkForUpdate();
  }

  Future<void> initSecurityState() async {
    TalsecConfig config = TalsecConfig(
      androidConfig: AndroidConfig(
        expectedPackageName: 'com.revens.mini.casino',
        expectedSigningCertificateHashes: [
          'SmdUsJDwb6ZlkQS+B2iQKpRVeQsKsIgbO5uEA4tkiJU='
        ],
      ),
      watcherMail: 'develope14000@gmail.com',
    );

    TalsecCallback callback = TalsecCallback(
        androidCallback: AndroidCallback(
      onRootDetected: () {
        alertDialogError(
            context: context,
            title: 'Error',
            text: 'Root detected',
            onConfirmBtnTap: () => exit(0));
      },
      onEmulatorDetected: () {
        alertDialogError(
            context: context,
            title: 'Error',
            text: 'Emulator detected',
            onConfirmBtnTap: () => exit(0));
      },
      onHookDetected: () {
        alertDialogError(
            context: context,
            title: 'Error',
            text: 'Hook detected',
            onConfirmBtnTap: () => exit(0));
      },
      onTamperDetected: () {
        alertDialogError(
            context: context,
            title: 'Error',
            text: 'Tamper detected',
            onConfirmBtnTap: () => exit(0));
      },
      onDeviceBindingDetected: () {
        alertDialogError(
            context: context,
            title: 'Error',
            text: 'Device binding',
            onConfirmBtnTap: () => exit(0));
      },
      onUntrustedInstallationDetected: () {
        alertDialogError(
            context: context,
            title: 'Error',
            text: 'Untrusted install',
            onConfirmBtnTap: () => exit(0));
      },
    ));

    TalsecApp app = TalsecApp(
      config: config,
      callback: callback,
    );

    app.start();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => MinesLogic()),
        ChangeNotifierProvider(create: (ctx) => CoinflipLogic()),
        ChangeNotifierProvider(create: (ctx) => CrashLogic()),
        ChangeNotifierProvider(create: (ctx) => KenoLogic()),
        ChangeNotifierProvider(create: (ctx) => FortuneWheelLogic()),
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
