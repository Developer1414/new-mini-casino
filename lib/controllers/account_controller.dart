import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/screens/banned_user.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthorizationAction { login, register }

class AccountController extends ChangeNotifier {
  bool isLoading = false;

  static bool isPremium = false;
  static DateTime expiredSubscriptionDate = DateTime.now();

  String loadingText = 'Пожалуйста, подождите...';

  Timer? timer;

  static late BuildContext context;

  AuthorizationAction authorizationAction = AuthorizationAction.register;

  Future checkPremium() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey('premium')) {
        expiredSubscriptionDate = (value.get('premium') as Timestamp).toDate();

        if (expiredSubscriptionDate.difference(DateTime.now()).inDays <= 0 &&
            expiredSubscriptionDate.difference(DateTime.now()).inHours <= 0 &&
            expiredSubscriptionDate.difference(DateTime.now()).inMinutes <= 0) {
          isPremium = false;
        } else {
          isPremium = true;
        }
      }
    });

    notifyListeners();
  }

  Future<List> checkBanAccount() async {
    List list = [];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.data()!.containsKey('ban')) {
        list = value.get('ban') as List;

        DateTime expiredDate = (list[1] as Timestamp).toDate();

        if (expiredDate.difference(DateTime.now()).inDays <= 0 &&
            expiredDate.difference(DateTime.now()).inHours <= 0 &&
            expiredDate.difference(DateTime.now()).inMinutes <= 0) {
          list = [];
        }
      }
    });

    return list;
  }

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
      setDataToDatabase(name);

      timer?.cancel();
    }

    notifyListeners();
  }

  Future setDataToDatabase(String name) async {
    loadingText = 'Пожалуйста, подождите...';
    isLoading = false;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'name': name,
      'balance': 500,
      'totalGames': 0,
      'participant': false,
    }).whenComplete(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isFirstGameStarted', true);

      authorizationAction = AuthorizationAction.register;

      // ignore: use_build_context_synchronously
      context.beamToReplacementNamed('/games');
    });

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

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<Widget> checkAuthState() async {
    Widget? newScreen;

    if (FirebaseAuth.instance.currentUser != null) {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        await checkBanAccount().then((value) async {
          if (value.isNotEmpty) {
            newScreen = BannedUser(
                reason: value[0].toString(),
                date: (value[1] as Timestamp).toDate());
          } else {
            await checkPremium();

            AdService.loadCountBet();
            newScreen = const AllGames();
          }
        });

        return newScreen!;
      } else {
        FirebaseAuth.instance.signOut();
        return const Login();
      }
    } else {
      return const Login();
    }
  }
}
