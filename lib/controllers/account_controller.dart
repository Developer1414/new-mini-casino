import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/menu.dart';

enum AuthorizationAction { login, register }

class AccountController extends ChangeNotifier {
  bool isLoading = false;

  static late BuildContext context;

  AuthorizationAction authorizationAction = AuthorizationAction.register;

  Future login({required String email, required String password}) async {
    isLoading = true;

    notifyListeners();

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      authorizationAction = AuthorizationAction.register;

      if (context.mounted) context.beamToReplacementNamed('/games');
    } on FirebaseAuthException catch (e) {
      AccountExceptionController.showException(context: context, code: e.code);
    }

    isLoading = false;

    notifyListeners();
  }

  void changeAuthorizationAction(int index) {
    authorizationAction =
        index == 0 ? AuthorizationAction.register : AuthorizationAction.login;
    notifyListeners();
  }

  Future register(
      {required String email,
      required String password,
      required String name}) async {
    isLoading = true;

    notifyListeners();

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'name': name,
        'balance': 100000,
        'totalGames': 0
      });

      authorizationAction = AuthorizationAction.register;

// ignore: use_build_context_synchronously
      context.beamToReplacementNamed('/games');
    } on FirebaseAuthException catch (e) {
      AccountExceptionController.showException(context: context, code: e.code);
    }

    isLoading = false;

    notifyListeners();
  }

  Future signOut() async {
    isLoading = true;
    notifyListeners();

    await FirebaseAuth.instance.signOut();

    isLoading = false;
    notifyListeners();
  }

  static Future<Widget> checkAuthState() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return const AllGames();
    } else {
      return const Login();
    }
  }
}
