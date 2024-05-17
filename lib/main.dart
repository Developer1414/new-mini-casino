import 'package:confetti/confetti.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:new_mini_casino/controllers/route_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/firebase_options.dart';
import 'package:new_mini_casino/models/provider_list.dart';
import 'package:new_mini_casino/secret/api_keys_constant.dart';
import 'package:new_mini_casino/themes/dark_theme.dart';
import 'package:new_mini_casino/themes/dark_theme_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

ScreenshotController screenshotController = ScreenshotController();
ConfettiController confettiController =
    ConfettiController(duration: const Duration(seconds: 1));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseController.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Appodeal.initialize(
      appKey: APIKeys.appodealKey,
      adTypes: [
        AppodealAdType.Interstitial,
        AppodealAdType.Banner,
        AppodealAdType.RewardedVideo,
        AppodealAdType.MREC
      ],
      onInitializationFinished: (errors) => {});

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
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providerList,
      child: InAppNotification(
        child: MaterialApp(
          initialRoute: '/',
          onGenerateRoute: (settings) => RouteController.generateRoute(settings),
          theme: darkThemeData(context),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
