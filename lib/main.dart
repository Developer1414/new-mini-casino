import 'dart:async';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:beamer/beamer.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/models/provider_list.dart';
import 'package:new_mini_casino/models/route_list.dart';
import 'package:new_mini_casino/secret/api_keys_constant.dart';
import 'package:new_mini_casino/themes/dark_theme.dart';
import 'package:new_mini_casino/themes/dark_theme_provider.dart';
import 'package:new_mini_casino/themes/light_theme.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

ScreenshotController screenshotController = ScreenshotController();
ConfettiController confettiController =
    ConfettiController(duration: const Duration(seconds: 1));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseController.initialize();

  Appodeal.initialize(
      appKey: APIKeys.appodealKey,
      adTypes: [
        AppodealAdType.Interstitial,
        AppodealAdType.Banner,
        AppodealAdType.RewardedVideo,
        AppodealAdType.MREC
      ],
      onInitializationFinished: (errors) => {});

  await AppMetrica.activate(AppMetricaConfig(APIKeys.appMetricaKey));
  AppMetrica.reportEvent('My first AppMetrica event!');

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
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
      setState(() async {
        _updateInfo = info;

        if (_updateInfo?.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          await alertDialogSuccess(
              context: context,
              title: 'Новая версия',
              confirmBtnText: 'Установить',
              barrierDismissible: false,
              text: 'Доступна новая версия игры!',
              onConfirmBtnTap: () async {
                if (!await launchUrl(
                    Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.revens.mini.casino'),
                    mode: LaunchMode.externalNonBrowserApplication)) {
                  throw Exception(
                      'Could not launch ${Uri.parse('https://play.google.com/store/apps/details?id=com.revens.mini.casino')}');
                }
              });

          await InAppUpdate.startFlexibleUpdate().then((_) {
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
      routes: routeList,
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
      providers: providerList,
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
