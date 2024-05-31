import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/loading.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  Future redirect() async {
    await Future.delayed(Duration.zero);

    if (!mounted) {
      return;
    }

    final session = SupabaseController.supabase?.auth.currentSession;

    if (session != null) {
      await SupabaseController().loadGameServices();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading(context: context);
  }
}
