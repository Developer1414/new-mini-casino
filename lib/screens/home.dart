import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
 // static bool isLoaded = false;

  Future showPremiumSubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    if (SupabaseController.isPremium ||
        SupabaseController.supabase?.auth.currentUser == null) return;

    if (!prefs.containsKey('premiumSubscription')) {
      Navigator.of(context).pushNamed('/premium');

      prefs.setString('premiumSubscription', DateTime.now().toString());
    } else {
      if (DateTime.now()
              .difference(
                  DateTime.parse(prefs.getString('premiumSubscription')!))
              .inDays >=
          30) {
        Navigator.of(context).pushNamed('/premium');

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

  Future redirect() async {
    await Future.delayed(Duration.zero);

    if (!mounted) {
      return;
    }

    //if (!isLoaded) {
    final session = SupabaseController.supabase?.auth.currentSession;

    if (session != null) {
      await SupabaseController().loadGameServices(context).whenComplete(() {
        Navigator.of(context).pushNamed('/games');
      });

      //isLoaded = true;

      // return Stack(
      //   children: [
      //     backgroundModel(),
      //     const AllGames(),
      //   ],
      // );
    } else {
      Navigator.of(context).pushNamed('/login');

      // return Stack(
      //   children: [
      //     backgroundModel(),
      //     const Login(),
      //   ],
      // );
    }
    // } else {
    //   return Stack(
    //     children: [
    //       backgroundModel(),
    //       const AllGames(),
    //     ],
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return loading(context: context);

    // PopScope(
    //     canPop: false,
    //     child: FutureBuilder(
    //       future: redirect(),
    //       builder: (context, snapshot) {
    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return loading(context: context);
    //         }

    //         return snapshot.data ?? Container();
    //       },
    //     ));
  }
}
