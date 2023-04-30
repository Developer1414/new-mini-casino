import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthorizationAction { login, register }

class AccountController extends ChangeNotifier {
  bool isLoading = false;

  String loadingText = 'Пожалуйста, подождите...';

  Timer? timer;

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

  Future sendLinkToEmailToVerifyAccount({required String name}) async {
    loadingText =
        'Перейдите по ссылке, отправленной на вашу электронную почту, чтобы подтвердить свою учетную запись. Если вы не нашли письмо, проверьте папку «Спам».';
    notifyListeners();

    await FirebaseAuth.instance.currentUser?.sendEmailVerification();

    timer = Timer.periodic(
        const Duration(seconds: 3), (_) => checkEmailVerified(name: name));
  }

  checkEmailVerified({required String name}) async {
    await FirebaseAuth.instance.currentUser?.reload();

    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      loadingText = 'Пожалуйста, подождите...';
      isLoading = false;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'name': name,
        'balance': 500,
        'totalGames': 0
      }).whenComplete(() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isFirstGameStarted', true);

        authorizationAction = AuthorizationAction.register;

        // ignore: use_build_context_synchronously
        context.beamToReplacementNamed('/games');
      });

      timer?.cancel();
    }

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

      await sendLinkToEmailToVerifyAccount(name: name);
    } on FirebaseAuthException catch (e) {
      AccountExceptionController.showException(context: context, code: e.code);
    }
  }

  Future<bool> checkOnExistNickname(String name) async {
    isLoading = true;
    notifyListeners();

    bool result = false;

    await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        result = false;
      } else {
        result = true;
      }
    });

    isLoading = false;
    notifyListeners();

    return result;
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
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        AdService.loadCountBet();
        return const AllGames();
      } else {
        FirebaseAuth.instance.signOut();
        return const Login();
      }
    } else {
      return const Login();
    }
  }
}
