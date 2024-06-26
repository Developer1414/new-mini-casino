import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart' as provider;
import 'dart:io' as ui;

import 'package:supabase_flutter/supabase_flutter.dart';

class OwnPromocodeManager extends ChangeNotifier {
  bool isLoading = false;

  double countActivation = 1;
  double existenceHours = 1;
  double prize = 0.0;
  double totalPrize = 0.0;

  void onPromocodeChanged() {
    double temp =
        SupabaseController.isPremium ? prize : (prize + (prize * 40 / 100));

    totalPrize = temp * countActivation + ((prize * 20 / 100) * existenceHours);
    notifyListeners();
  }

  void onCountActivationChanged(double value) {
    countActivation = value;
    onPromocodeChanged();
    notifyListeners();
  }

  void onExistenceHoursChanged(double value) {
    existenceHours = value;
    onPromocodeChanged();
    notifyListeners();
  }

  void loading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void create({required BuildContext context, required String name}) async {
    if (prize > 100000) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Промокод не может быть больше ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(100000)}!',
      );

      return;
    }

    if (prize < 1000) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Промокод не может быть меньше ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(1000)}!',
      );

      return;
    }

    final balance = provider.Provider.of<Balance>(context, listen: false);

    if (balance.currentBalance < totalPrize) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Недостаточно средств на балансе!',
      );

      return;
    }

    if (ProfileController.profileModel.totalGame < 1000) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Промокод можно создать от 1000 игр! У вас: ${ProfileController.profileModel.totalGame}',
      );

      return;
    }

    if (name.trim().length < 4) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Промокод не может быть меньше 4 символов!',
      );

      return;
    }

    loading(true);

    try {
      final res = await SupabaseController.supabase!
          .from('all_promocodes')
          .select(
            'title',
            const FetchOptions(
              count: CountOption.exact,
            ),
          )
          .eq('title', name);

      if (res.count == 0) {
        try {
          await SupabaseController.supabase!.from('all_promocodes').insert({
            'prize': prize,
            'title': name,
            'userName': ProfileController.profileModel.nickname,
            'activationCount': countActivation.round(),
          });

          await SupabaseController.supabase!
              .from('users')
              .select('*')
              .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
              .then((value) async {
            Map<dynamic, dynamic> map = (value as List<dynamic>).first;

            String usedPromocodesString = map['usedPromocodes'].toString();

            usedPromocodesString += ',$name';

            await SupabaseController.supabase!
                .from('users')
                .update({'usedPromocodes': usedPromocodesString}).eq(
                    'uid', SupabaseController.supabase?.auth.currentUser!.id);
          });

          balance.subtractMoney(totalPrize);

          loading(false);

          if (context.mounted) {
            AdService.showInterstitialAd(
                context: context, func: () {}, isBet: false);

            alertDialogSuccess(
              context: context,
              title: 'Успех',
              confirmBtnText: 'Спасибо!',
              text: 'Промокод успешно создан!',
            );
          }
        } on PostgrestException catch (e) {
          loading(false);

          if (context.mounted) {
            alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text: e.message,
            );
          }

          if (kDebugMode) {
            print('createUserDates: $e');
          }
        }
      } else {
        loading(false);

        if (context.mounted) {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: 'Такой промокод уже существует!',
          );
        }
      }
    } on PostgrestException catch (e) {
      loading(false);

      if (kDebugMode) {
        print('checkPromocdeOnExist: $e');
      }
    }
  }
}
