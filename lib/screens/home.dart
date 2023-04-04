import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: AccountController.checkAuthState(),
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
