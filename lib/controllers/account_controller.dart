import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/money_storage_manager.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/screens/banned_user.dart';
import 'package:new_mini_casino/screens/login.dart';
import 'package:new_mini_casino/screens/menu.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/business/local_promocodes_service.dart';
import 'package:new_mini_casino/services/freerasp_service.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
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
    DateTime dateTimeNow = await NTP.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey('premium')) {
        expiredSubscriptionDate = (value.get('premium') as Timestamp).toDate();

        if (expiredSubscriptionDate.difference(dateTimeNow).inDays <= 0 &&
            expiredSubscriptionDate.difference(dateTimeNow).inHours <= 0 &&
            expiredSubscriptionDate.difference(dateTimeNow).inMinutes <= 0) {
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

      await checkBanAccount().then((value) async {
        if (value.isNotEmpty) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (ctx) => BannedUser(
                      isBannedAccount: true,
                      reason: value[0].toString(),
                      date: (value[1] as Timestamp).toDate())),
              (route) => false);
        } else {
          await checkPremium();

          AdService.loadCountBet();

          // ignore: use_build_context_synchronously
          alertDialogSuccess(
              context: context,
              title: 'Уведомление',
              confirmBtnText: 'Окей',
              text: 'Для обновления настроек игры, пожалуйста, перезайдите!',
              onConfirmBtnTap: () => exit(0));
        }
      });
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      // ignore: use_build_context_synchronously
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

  Future sendLinkToEmailToVerifyAccount(
      {required String name, String referalCode = ''}) async {
    loadingText =
        'Перейдите по ссылке, отправленной на Вашу электронную почту, чтобы подтвердить свою учетную запись. Если Вы не нашли письмо, проверьте папку «Спам».';
    notifyListeners();

    await FirebaseAuth.instance.currentUser?.sendEmailVerification();

    timer = Timer.periodic(const Duration(seconds: 3),
        (_) => checkEmailVerified(name: name, referalCode: referalCode));
  }

  checkEmailVerified({required String name, String referalCode = ''}) async {
    await FirebaseAuth.instance.currentUser?.reload();

    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      setDataToDatabase(name, referalCode);

      timer?.cancel();
    }

    notifyListeners();
  }

  Future upLevel() async {
    double value = ProfileController.profileModel.level +
        1.0 / (log(ProfileController.profileModel.level + 2) / log(2) * 10);

    ProfileController.profileModel.level = value;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'level': value});
  }

  Future setDataToDatabase(String name, String signedCode) async {
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
      context.beamToReplacementNamed('/welcome');
    });

    notifyListeners();
  }

  Future register(
      {required String email,
      required String password,
      String? referalCode,
      required String name}) async {
    isLoading = true;
    notifyListeners();

    /*if (referalCode != null) {
      await checkOnExistReferalCode(
          email: email,
          password: password,
          referalCode: referalCode,
          name: name);
    } else {
      await createUser(email: email, password: password, name: name);
    }*/

    await createUser(email: email, password: password, name: name);
  }

  Future checkOnExistReferalCode(
      {required String email,
      required String password,
      required referalCode,
      required String name}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: referalCode)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        isLoading = false;
        notifyListeners();

        AccountExceptionController.showException(
            context: context, code: 'referal_code_not_found');
        return;
      } else {
        await createUser(email: email, password: password, name: name);
      }
    });
  }

  Future createUser(
      {required String email,
      required String password,
      String referalCode = '',
      required String name}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await sendLinkToEmailToVerifyAccount(
          name: name, referalCode: referalCode);
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();

      // ignore: use_build_context_synchronously
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

  Future<Widget> initUserData(BuildContext context) async {
    Widget? newScreen;

    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.emailVerified) {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        AdService.loadCountBet();

        await checkBanAccount().then((value) async {
          if (value.isNotEmpty) {
            newScreen = BannedUser(
                isBannedAccount: true,
                reason: value[0].toString(),
                date: (value[1] as Timestamp).toDate());
          } else {
            if (!kDebugMode) {
              // ignore: use_build_context_synchronously
              await FreeraspService().initSecurityState(context);
            }

            await checkPremium();
            await LocalPromocodes().initializeMyPromocodes();
            // ignore: use_build_context_synchronously
            await Provider.of<Balance>(context, listen: false).loadBalance();
            // ignore: use_build_context_synchronously
            await Provider.of<MoneyStorageManager>(context, listen: false)
                .loadBalance();

            // ignore: use_build_context_synchronously
            await Provider.of<TaxManager>(context, listen: false).getTax();

            await ProfileController.getUserProfile();

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
