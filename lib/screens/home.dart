import 'dart:async';
import 'package:beamer/beamer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void dispose() {
    super.dispose();

    _connectivitySubscription.cancel();
  }

  Future showPremiumSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (AccountController.isPremium ||
        FirebaseAuth.instance.currentUser?.uid == null) return;

    if (!prefs.containsKey('premiumSubscription')) {
      // ignore: use_build_context_synchronously
      context.beamToNamed('/premium');

      prefs.setString('premiumSubscription', DateTime.now().toString());
    } else {
      if (DateTime.now()
              .difference(
                  DateTime.parse(prefs.getString('premiumSubscription')!))
              .inDays >=
          30) {
        // ignore: use_build_context_synchronously
        context.beamToNamed('/premium');

        prefs.setString('premiumSubscription', DateTime.now().toString());
      }
    }
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Couldn\'t check connectivity status: ${e.message}');
      }
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;

      if (_connectionStatus == ConnectivityResult.none) {
        Beamer.of(context).beamToNamed('/no-internet');
      }
    });
  }

  Future checkDailyBonus() async {
    await DailyBonusManager().checkDailyBonus().then((value) {
      if (value) {
        Beamer.of(context).beamToNamed('/daily-bonus');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    showPremiumSubscription();
    initConnectivity();
    checkDailyBonus();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: FutureBuilder(
        future: AccountController().initUserData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loading(context: context);
          }

          return snapshot.data!;
        },
      ),
    );
  }
}
