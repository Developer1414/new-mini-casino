import 'dart:async';
import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/widgets/simple_alert_dialog.dart';
import 'package:provider/src/provider.dart' as provider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/local_promocodes_service.dart';
import 'package:new_mini_casino/business/money_storage_manager.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:restart_app/restart_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthorizationAction { login, register }

class SupabaseController extends ChangeNotifier {
  static SupabaseClient? supabase;

  bool isLoading = false;

  static bool isPremium = false;
  static DateTime expiredSubscriptionDate = DateTime.now();

  static String userName = '';

  String loadingText = 'Пожалуйста, подождите...';

  Timer? timer;

  static late BuildContext context;

  AuthorizationAction authorizationAction = AuthorizationAction.register;

  static Future initialize() async {
    await Supabase.initialize(
      url: 'https://ynlxqherxvlancmqppyp.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlubHhxaGVyeHZsYW5jbXFwcHlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTgyMzgzNjAsImV4cCI6MjAxMzgxNDM2MH0.gPqHebuUQnQPKB02wtq4XJIL9mbIZdOIf-Gu1TiM28w',
    );

    supabase = Supabase.instance.client;
  }

  void loading(bool value, {String? text}) {
    isLoading = value;
    loadingText = text ?? 'Пожалуйста, подождите...';
    notifyListeners();
  }

  Future signUp(
      {required String email,
      required String password,
      required String name}) async {
    String? deviceId = await PlatformDeviceId.getDeviceId;

    loading(true);

    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('deviceId', deviceId)
        .then((value) {
      if (value.isNotEmpty) {
        Map<dynamic, dynamic> map = (value as List<dynamic>).first;

        loading(false);

        alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text:
                'Нельзя создавать несколько аккаунтов! Ваш прошлый аккаунт: ${map['name']}');
      } else {
        checkNameOnAvailability(name: name).then((isExist) async {
          if (!isExist) {
            try {
              userName = name;

              await SupabaseController.supabase!.auth
                  .signUp(
                email: email.trim(),
                password: password,
              )
                  .then((value) {
                loading(false);

                context.beamToReplacementNamed('/verify-email/$email');
              });
            } on AuthException catch (e) {
              loading(false);

              if (e.statusCode == '429') {
                if (context.mounted) {
                  alertDialogError(
                      context: context,
                      title: 'Ошибка',
                      confirmBtnText: 'Окей',
                      text:
                          'Вы превысили лимит отправки электронных писем. Пожалуйста, подождите некоторое время, прежде чем отправить новое письмо.');
                }
              }

              if (kDebugMode) {
                print('signUp: $e');
              }
            }
          } else {
            AccountExceptionController.showException(
                context: context, code: 'nickname_already_exist');
          }
        });
      }
    });
  }

  Future signInWithPassword(
      {required String email, required String password}) async {
    loading(true);

    try {
      await SupabaseController.supabase!.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      loading(false);

      if (context.mounted) {
        alertDialogSuccess(
            context: context,
            title: 'Уведомление',
            confirmBtnText: 'Окей',
            text: 'Для обновления настроек игры, пожалуйста, перезайдите!',
            onConfirmBtnTap: () => Restart.restartApp());
      }
    } on AuthException catch (e) {
      loading(false);

      if (e.statusCode == '400') {
        if (context.mounted) {
          alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text: 'Неверные логин или пароль!');
        }
      }

      if (kDebugMode) {
        print('signInWithPassword: $e');
      }
    }
  }

  Future signOut() async {
    loading(true);

    await SupabaseController.supabase?.auth.signOut();

    loading(false);
  }

  void changeAuthorizationAction(int index) {
    authorizationAction =
        index == 0 ? AuthorizationAction.register : AuthorizationAction.login;
    notifyListeners();
  }

  Future<bool> checkNameOnAvailability({required String name}) async {
    loading(true);

    int count = 0;

    try {
      final res = await SupabaseController.supabase!
          .from('users')
          .select(
            'name',
            const FetchOptions(
              count: CountOption.exact,
            ),
          )
          .eq('name', name);

      count = res.count;
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('checkNameOnExist: $e');
      }
    }

    loading(false);

    return count > 0;
  }

  Future verifyEmail(
      {required String email,
      required String code,
      required BuildContext context}) async {
    try {
      await SupabaseController.supabase?.auth.verifyOTP(
        type: OtpType.email,
        token: code,
        email: email,
      );

      await createUserDates(name: userName);
    } on AuthException catch (e) {
      if (e.statusCode == '401') {
        if (context.mounted) {
          alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text: 'Неверный код!');
        }
      }
    }
  }

  Future resendOTP(String email) async {
    try {
      await SupabaseController.supabase?.auth
          .resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      if (e.statusCode == '429') {
        if (context.mounted) {
          alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text:
                  'Вы превысили лимит отправки электронных писем. Пожалуйста, подождите некоторое время, прежде чем отправить новое письмо.');
        }
      }
    }
  }

  Future createUserDates({required String name}) async {
    try {
      loading(true);

      String? deviceId = await PlatformDeviceId.getDeviceId;

      DateTime ntpDate = await NTP.now();

      await SupabaseController.supabase!.from('users').insert({
        'name': name,
        'deviceId': deviceId,
        'balance': 500,
        'totalGames': 0,
        'level': 1.0,
        'premium': ntpDate.add(const Duration(days: 8)).toIso8601String(),
        'moneyStorage': 0.0,
      });

      if (context.mounted) {
        alertDialogSuccess(
            context: context,
            title: 'Уведомление',
            barrierDismissible: false,
            confirmBtnText: 'Окей',
            text: 'Для обновления настроек игры, пожалуйста, перезайдите!',
            onConfirmBtnTap: () => Restart.restartApp());
      }

      loading(false);
    } on PostgrestException catch (e) {
      loading(false);

      if (kDebugMode) {
        print('createUserDates: $e');
      }
    }
  }

  Future levelUp() async {
    double value = ProfileController.profileModel.level +
        1.0 / (log(ProfileController.profileModel.level + 2) / log(2) * 20);

    ProfileController.profileModel.level = value;

    await SupabaseController.supabase!
        .from('users')
        .update({'level': value}).eq(
            'uid', SupabaseController.supabase?.auth.currentUser!.id);
  }

  Future totalGamesUp() async {
    double value = ProfileController.profileModel.level +
        1.0 / (log(ProfileController.profileModel.level + 2) / log(2) * 10);

    ProfileController.profileModel.level = value;

    await SupabaseController.supabase!
        .from('users')
        .update({'totalGames': ProfileController.profileModel.totalGame++}).eq(
            'uid', SupabaseController.supabase?.auth.currentUser!.id);
  }

  Future checkPremiumAvailability(BuildContext context) async {
    DateTime dateTimeNow = await NTP.now();

    try {
      await SupabaseController.supabase!
          .from('users')
          .select('*')
          .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
          .then((value) {
        Map<dynamic, dynamic> map = (value as List<dynamic>).first;

        expiredSubscriptionDate = DateTime.parse(map['premium']);

        if (expiredSubscriptionDate.difference(dateTimeNow).inDays <= 0 &&
            expiredSubscriptionDate.difference(dateTimeNow).inHours <= 0 &&
            expiredSubscriptionDate.difference(dateTimeNow).inMinutes <= 0) {
          isPremium = false;
        } else {
          isPremium = true;
        }
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print('checkPremium: $e');
      }

      if (context.mounted) {
        alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: '[PremiumError]: ${e.toString()}');
      }
    }
  }

  Future<bool> checkAccountForFreezing(BuildContext context) async {
    bool result = false;

    try {
      await SupabaseController.supabase!
          .from('users')
          .select('*')
          .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
          .then((value) {
        Map<dynamic, dynamic> map = (value as List<dynamic>).first;

        result = map['freeze'] as bool;
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print('checkAccountForFreezing: $e');
      }

      if (context.mounted) {
        alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: '[checkAccountForFreezing]: ${e.toString()}');
      }
    }

    return result;
  }

  Future loadGameServices(BuildContext context) async {
    await checkAccountForFreezing(context).then((frozen) async {
      if (frozen) {
        showSimpleAlertDialog(
            context: context,
            text: 'Ваш аккаунт временно заморожен!',
            isCanPop: false);
      } else {
        // ignore: use_build_context_synchronously
        await checkPremiumAvailability(context);

        // ignore: use_build_context_synchronously
        await ProfileController.getUserProfile(context);

        // ignore: use_build_context_synchronously
        await provider.Provider.of<Balance>(context, listen: false)
            .loadBalance(context);

        // ignore: use_build_context_synchronously
        await provider.Provider.of<MoneyStorageManager>(context, listen: false)
            .loadBalance(context);

        // ignore: use_build_context_synchronously
        await provider.Provider.of<TaxManager>(context, listen: false).getTax();

        await LocalPromocodes().initializeMyPromocodes();

        await AdService.loadCountBet();
      }
    });
  }
}
