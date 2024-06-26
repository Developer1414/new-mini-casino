// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/business/raffle_manager.dart';
import 'package:new_mini_casino/controllers/account_exception_controller.dart';
import 'package:new_mini_casino/controllers/audio_controller.dart';
import 'package:new_mini_casino/controllers/friend_code_controller.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/secret/api_keys_constant.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/google_sign_in_service.dart';
import 'package:new_mini_casino/services/notification_service.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/src/provider.dart' as provider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/local_bonuse_manager.dart';
import 'package:new_mini_casino/business/money_storage_manager.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:new_mini_casino/widgets/engineering_works_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

enum AuthorizationAction { login, register }

class SupabaseController extends ChangeNotifier {
  static SupabaseClient? supabase;

  bool isLoading = false;

  static bool isPremium = false;
  static DateTime expiredSubscriptionDate = DateTime.now();

  static String userName = '';
  static String friendCode = '';

  String loadingText = 'Пожалуйста, подождите...';

  Timer? timer;

  //static late BuildContext context;

  AuthorizationAction authorizationAction = AuthorizationAction.register;

  static Future initialize() async {
    await Supabase.initialize(
      url: APIKeys.supabaseUrl,
      anonKey: APIKeys.supabaseKey,
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
      String friendCode = '',
      required String name}) async {
    bool isFriendCodeFinded = false;

    loading(true);

    if (friendCode.isNotEmpty) {
      await FriendCodeController().findFriendCode(friendCode).then((isFinded) {
        isFriendCodeFinded = isFinded;

        if (!isFinded) {
          alertDialogError(
              context: navigatorKey.currentContext!,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text: 'Код друга не найден!');

          loading(false);
          return;
        } else {
          SupabaseController.friendCode = friendCode;
        }
      });
    }

    if (friendCode.isNotEmpty && !isFriendCodeFinded) {
      return;
    }

    await checkNameOnAvailability(name: name).then((isExist) async {
      if (!isExist) {
        try {
          userName = name;

          await SupabaseController.supabase!.auth.signUp(
            email: email.trim(),
            password: password,
          );

          Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(
              '/verify-email', (route) => false,
              arguments: [email, false]);
        } on AuthException catch (e) {
          loading(false);

          if (kDebugMode) {
            print('signUp: ${e.message}');
          }

          if (e.statusCode == '409') {
            alertDialogError(
                context: navigatorKey.currentContext!,
                title: 'Ошибка',
                confirmBtnText: 'Окей',
                text: 'Адрес электронной почты уже существует!');
          }

          if (e.statusCode == '429') {
            alertDialogError(
                context: navigatorKey.currentContext!,
                title: 'Ошибка',
                confirmBtnText: 'Окей',
                text:
                    'Вы превысили лимит отправки электронных писем. Пожалуйста, подождите некоторое время, прежде чем отправить новое письмо.');
          }
        }
      } else {
        loading(false);

        AccountExceptionController.showException(
            context: navigatorKey.currentContext!,
            code: 'nickname_already_exist');
      }
    });
  }

  Future signInWithGoogle() async {
    loading(true);

    try {
      await GoogleSignInService.signInWithGoogle();

      final res = await SupabaseController.supabase!
          .from('users')
          .select(
            'uid',
            const FetchOptions(
              count: CountOption.exact,
            ),
          )
          .eq('uid', supabase!.auth.currentUser!.id);

      int count = res.count;

      if (count == 1) {
        alertDialogSuccess(
            context: navigatorKey.currentContext!,
            title: 'Уведомление',
            confirmBtnText: 'Перезайти',
            text: 'Для обновления настроек игры, пожалуйста, перезайдите!',
            onConfirmBtnTap: () => Restart.restartApp());
      } else {
        await supabase!.auth.signOut();

        alertDialogError(
          context: navigatorKey.currentContext!,
          title: 'Ошибка',
          text:
              'Вы не можете войти в этот аккаунт, т.к. он ещё не зарегистрирован!',
        );
      }
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('GoogleAuthExcexption: ${e.message}');
      }
    }

    loading(false);
  }

  Future signUpWithGoogle(String name) async {
    loading(true);

    await checkNameOnAvailability(name: name).then((isExist) async {
      if (!isExist) {
        try {
          userName = name;

          try {
            await GoogleSignInService.signInWithGoogle();
            await createUserDates(name: name);
          } on AuthException catch (e) {
            if (kDebugMode) {
              print('GoogleAuthExcexption: ${e.message}');
            }
          }
        } on AuthException catch (e) {
          loading(false);

          if (kDebugMode) {
            print('signUp: $e');
          }
        }
      } else {
        AccountExceptionController.showException(
            context: navigatorKey.currentContext!,
            code: 'nickname_already_exist');
      }
    });

    loading(false);
  }

  Future sendCodeToResetPassword(
      {required String email, required BuildContext context}) async {
    loading(true);

    try {
      await SupabaseController.supabase?.auth.resetPasswordForEmail(
        email,
      );
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

    loading(false);
  }

  Future resetPassword({
    required String verifyCode,
    required String email,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      await SupabaseController.supabase?.auth.verifyOTP(
        type: OtpType.email,
        token: verifyCode,
        email: email,
      );

      await SupabaseController.supabase?.auth
          .updateUser(UserAttributes(email: email, password: newPassword));

      if (context.mounted) {
        alertDialogSuccess(
            context: context,
            title: 'Уведомление',
            canCloseAlert: false,
            confirmBtnText: 'Перезайти',
            text: 'Для обновления настроек игры, пожалуйста, перезайдите!',
            onConfirmBtnTap: () => Restart.restartApp());
      }
    } on AuthException catch (e) {
      if (e.statusCode == '401') {
        if (context.mounted) {
          alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text: 'Неверный код!');
        }
      } else if (e.statusCode == '403') {
        if (context.mounted) {
          alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text:
                  'Срок действия токена истек или он недействителен! Отправьте код повторно!');
        }
      } else if (e.statusCode == '422') {
        if (context.mounted) {
          alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text: 'Новый пароль должен отличаться от старого!');
        }
      } else {
        if (context.mounted) {
          alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text: e.message);
        }

        if (kDebugMode) {
          print(e.message);
        }
      }
    }
  }

  Future signInWithPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    loading(true);

    try {
      await SupabaseController.supabase!.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      await alertDialogSuccess(
          context: context,
          title: 'Уведомление',
          confirmBtnText: 'Перезайти',
          text: 'Для обновления настроек игры, пожалуйста, перезайдите!',
          onConfirmBtnTap: () => Restart.restartApp());

      loading(false);
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

    return count > 0;
  }

  Future verifyEmail(
      {required String email,
      required String verifyCode,
      required BuildContext context}) async {
    try {
      await SupabaseController.supabase?.auth.verifyOTP(
        type: OtpType.email,
        token: verifyCode,
        email: email,
      );

      await createUserDates(name: userName);
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('ErrorVerifyEmail: ${e.message}. Code: ${e.statusCode}');
      }

      if (e.statusCode == '403') {
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
        alertDialogError(
            context: navigatorKey.currentContext!,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text:
                'Вы превысили лимит отправки электронных писем. Пожалуйста, подождите некоторое время, прежде чем отправить новое письмо.');
      }
    }
  }

  Future createUserDates({required String name}) async {
    try {
      loading(true);

      double startBalance = SupabaseController.friendCode.isEmpty
          ? 500
          : Random().nextInt(10000).toDouble() + 10000;

      await SupabaseController.supabase!.from('users').insert({
        'name': name,
        'balance': startBalance,
        'totalGames': 0,
        'level': 1.0,
        'premium': DateTime.now()
            .toUtc()
            .add(const Duration(days: 3))
            .toIso8601String(),
        'moneyStorage': 0.0,
        'usedPromocodes':
            SupabaseController.friendCode.isEmpty ? null : ',$friendCode'
      });

      if (SupabaseController.friendCode.isNotEmpty) {
        await SupabaseController.supabase!
            .from('users')
            .select('*')
            .eq('uid', friendCode)
            .then((value) async {
          Map<dynamic, dynamic> map = (value as List<dynamic>).first;

          String friendName = map['name'];

          await SupabaseController.supabase!.from('notifications').insert({
            'amount': Random().nextInt(50000).toDouble() + 50000,
            'to': friendName,
            'from': name,
            'action': 'friend_code_moneys',
            'date': DateTime.now().toLocal().toIso8601String(),
          });
        });
      }

      loading(false);
    } on PostgrestException catch (e) {
      loading(false);

      if (kDebugMode) {
        print('createUserDates: ${e.message} (Code: ${e.code})');
      }

      alertDialogError(
          context: navigatorKey.currentContext!,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: 'createUserDates: ${e.message} (Code: ${e.code})');
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
    double growthRate = 10.0;
    ProfileController.profileModel.level +=
        1 / (ProfileController.profileModel.level * growthRate);

    await SupabaseController.supabase!
        .from('users')
        .update({'totalGames': ProfileController.profileModel.totalGame++}).eq(
            'uid', SupabaseController.supabase?.auth.currentUser!.id);
  }

  Future checkPremiumAvailability(BuildContext context) async {
    DateTime dateTimeUTC = await NTP.now();
    dateTimeUTC = dateTimeUTC.toUtc();

    try {
      await SupabaseController.supabase!
          .from('users')
          .select('*')
          .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
          .then((value) {
        Map<dynamic, dynamic> map = (value as List<dynamic>).first;

        expiredSubscriptionDate =
            DateTime.parse('${map['premium']}Z').toLocal();

        DateTime expiredSubscriptionDateUTC = DateTime.parse(map['premium']);

        if (expiredSubscriptionDateUTC.difference(dateTimeUTC).inDays <= 0 &&
            expiredSubscriptionDateUTC.difference(dateTimeUTC).inHours <= 0 &&
            expiredSubscriptionDateUTC.difference(dateTimeUTC).inMinutes <= 0) {
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

  Future<List<dynamic>> checkOnBanned() async {
    List<dynamic> result = [];

    try {
      final res = await SupabaseController.supabase!
          .from('banned_users')
          .select(
            '*',
            const FetchOptions(
              count: CountOption.exact,
            ),
          )
          .eq('uid', SupabaseController.supabase?.auth.currentUser!.id);

      if (res != null) {
        PostgrestResponse<dynamic> resp = res as PostgrestResponse<dynamic>;

        if (resp.count! > 0) {
          result = [
            resp.data.first['reason'].toString(),
            DateTime.parse(resp.data.first['unblockDate']).toLocal()
          ];
        }
      }
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('checkAccountOnBlock: $e, ${e.code}');
      }

      alertDialogError(
          context: navigatorKey.currentContext!,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: '[checkAccountOnBlock]: ${e.toString()}');
    }

    return result;
  }

  Future<bool> checkOnEngineeringWorks() async {
    bool result = false;

    await SupabaseController.supabase!
        .from('settings')
        .select('*')
        .eq('setting', 'engineeringWorks')
        .then((value) {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;
      result = map['value'] as bool;
    });

    return result;
  }

  Future<bool> checkForUpdate() async {
    bool result = false;

    if (kDebugMode) {
      return false;
    }

    await InAppUpdate.checkForUpdate().then((info) async {
      result = info.updateAvailability == UpdateAvailability.updateAvailable;
    }).catchError((e) {
      if (kDebugMode) {
        print(e.toString());
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final InAppReview inAppReview = InAppReview.instance;

    if (prefs.containsKey('isFirstGameStarted')) {
      if (!prefs.containsKey('requestReviewDate') ||
          DateTime.now()
                  .difference(
                      DateTime.parse(prefs.getString('requestReviewDate')!))
                  .inDays >=
              30) {
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview().whenComplete(() {
            prefs.setString('requestReviewDate', DateTime.now().toString());
          });
        }
      }
    }

    return result;
  }

  Future showPremiumSubscription(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

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

  Future loadGameServices() async {
    BuildContext context = navigatorKey.currentContext!;

    await Connectivity()
        .checkConnectivity()
        .then((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        await alertDialogError(
            context: context,
            canCloseAlert: false,
            title: 'Ошибка',
            text: 'Проблемы с подключением к интернету!',
            confirmBtnText: 'Переподключиться',
            onConfirmBtnTap: () async {
              Navigator.of(context).pop();
              await loadGameServices();
            });
      } else {
        await checkOnBanned().then((blockValue) async {
          if (blockValue.isNotEmpty) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/ban', (value) => false,
                arguments: blockValue);
          } else {
            await checkForUpdate().then((isExistUpdate) async {
              if (isExistUpdate) {
                await alertDialogSuccess(
                    context: context,
                    title: 'Новая версия',
                    confirmBtnText: 'Установить',
                    canCloseAlert: false,
                    text: 'Доступна новая версия игры!',
                    onConfirmBtnTap: () async {
                      if (!await launchUrl(
                          Uri.parse(
                              'https://play.google.com/store/apps/details?id=com.revens.mini.casino'),
                          mode: LaunchMode.externalNonBrowserApplication)) {
                        throw Exception(
                            'Could not launch ${Uri.parse('https://play.google.com/store/apps/details?id=com.revens.mini.casino')}');
                      }
                    });
              } else {
                await checkOnEngineeringWorks()
                    .then((isEngineeringWorksEnabled) async {
                  if (isEngineeringWorksEnabled) {
                    showEngineeringWorksAlertDialog(context);
                  } else {
                    await checkPremiumAvailability(context);

                    await ProfileController.getUserProfile(context);

                    await provider.Provider.of<Balance>(context, listen: false)
                        .startListenBalance(context);

                    await provider.Provider.of<MoneyStorageManager>(context,
                            listen: false)
                        .loadBalance(context);

                    await provider.Provider.of<TaxManager>(context,
                            listen: false)
                        .checkTax();

                    await LocalPromocodes().initializeMyPromocodes();

                    await provider.Provider.of<SettingsController>(context,
                            listen: false)
                        .loadSettings(context);

                    await AdService.loadCountBet();

                    await AudioController.initializeAudios();

                    await NotificationService.setToken(context);

                    await NotificationService.listenNotifications(context);

                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/games', (route) => false);

                    await showPremiumSubscription(context);

                    await provider.Provider.of<DailyBonusManager>(context,
                            listen: false)
                        .checkDailyBonus(context);

                    await provider.Provider.of<RaffleManager>(context,
                            listen: false)
                        .checkOnExistRaffle();
                  }
                });
              }
            });
          }
        });
      }
    });
  }
}
