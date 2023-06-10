import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StreamSubscription internetCheckerSubscription;

  @override
  void dispose() {
    super.dispose();
    internetCheckerSubscription.cancel();
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

  @override
  void initState() {
    super.initState();

    showPremiumSubscription();

    internetCheckerSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result.index == 0) {
        Beamer.of(context).beamToNamed('/no_internet');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: AccountController().checkAuthState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loading();
          }

          return snapshot.data!;
        },
      ),
    );
  }
}
