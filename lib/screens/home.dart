import 'dart:async';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/widgets/background_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future showPremiumSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    if (SupabaseController.isPremium ||
        SupabaseController.supabase?.auth.currentUser == null) return;

    if (!prefs.containsKey('premiumSubscription')) {
      context.beamToNamed('/premium');

      prefs.setString('premiumSubscription', DateTime.now().toString());
    } else {
      if (DateTime.now()
              .difference(
                  DateTime.parse(prefs.getString('premiumSubscription')!))
              .inDays >=
          30) {
        context.beamToNamed('/premium');

        prefs.setString('premiumSubscription', DateTime.now().toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    redirect();
    //showPremiumSubscription();
  }

  Future<Widget> redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return const Login();
    }

    final session = SupabaseController.supabase?.auth.currentSession;

    if (session != null) {
      await SupabaseController().loadGameServices(context);

      return const AllGames();
    } else {
      return const Login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        backgroundModel(),
        PopScope(
            canPop: false,
            child: FutureBuilder(
              future: redirect(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return loading(context: context);
                }

                return snapshot.data!;
              },
            )),
      ],
    );
  }
}
