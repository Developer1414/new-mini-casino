import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/business/local_bonuse_manager.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart' as provider;
import 'dart:io' as ui;

import 'package:supabase_flutter/supabase_flutter.dart';

class PromocodeManager extends ChangeNotifier {
  bool isLoading = false;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  void useLocalPromocode(
      {required String myPromocode, required BuildContext context}) {
    String promocode = LocalPromocodes.promocodes.entries
        .where((element) => element.key == myPromocode)
        .first
        .key;

    double prize = LocalPromocodes.promocodes.entries
        .where((element) => element.key == myPromocode)
        .first
        .value;

    provider.Provider.of<Balance>(context, listen: false).cashout(prize);

    alertDialogSuccess(
      context: context,
      title: 'Поздравляем!',
      confirmBtnText: 'Спасибо!',
      text:
          'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(prize)}!',
    );

    LocalPromocodes().removePromocode(promocode);

    notifyListeners();
  }

  Future usePromocode(
      {required BuildContext context, required String title}) async {
    if (LocalPromocodes.promocodes.containsKey(title)) {
      useLocalPromocode(myPromocode: title, context: context);
      return;
    }

    if (ProfileController.profileModel.totalGame < 2000) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Промокоды можно использовать от 2000 игр! У вас: ${ProfileController.profileModel.totalGame}',
      );

      return;
    }

    showLoading(true);

    final res = await SupabaseController.supabase!
        .from('promocodes')
        .select(
          'title',
          const FetchOptions(
            count: CountOption.exact,
          ),
        )
        .eq('title', title);

    if (res.count == 0) {
      if (context.mounted) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text:
              'Промокод не существует или количество использований исчерпано!',
        );
      }

      showLoading(false);

      return;
    }

    await SupabaseController.supabase!
        .from('promocodes')
        .select('*')
        .eq('title', title)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      int activationCount = int.parse(map['count'].toString());
      double prize = double.parse(map['prize'].toString());

      if (activationCount <= 0) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: 'Исчерпано количество использований!',
        );

        return;
      }

      await SupabaseController.supabase!
          .from('users')
          .select('*')
          .eq('uid',
              SupabaseController.supabase?.auth.currentUser!.id) // newyear
          .then((value) async {
        Map<String, dynamic> promocodes =
            jsonDecode((value as List<dynamic>).first['promocodes']);

        if (promocodes.containsKey(title)) {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: 'Вы уже использовали этот промокод!',
          );

          return;
        } else {
          promocodes.addAll({title: prize});

          await SupabaseController.supabase!
              .from('users')
              .update({'promocodes': jsonEncode(promocodes)}).eq(
                  'uid', SupabaseController.supabase?.auth.currentUser!.id);

          if (activationCount <= 1) {
            await SupabaseController.supabase!
                .from('promocodes')
                .delete()
                .eq('title', title);
          } else {
            activationCount -= 1;

            await SupabaseController.supabase!
                .from('promocodes')
                .update({'count': activationCount}).eq('title', title);
          }

          if (context.mounted) {
            provider.Provider.of<Balance>(context, listen: false)
                .cashout(prize);

            alertDialogSuccess(
              context: context,
              title: 'Поздравляем',
              confirmBtnText: 'Спасибо!',
              text:
                  'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(prize)}!',
            );

            AdService.showInterstitialAd(
                context: context, func: () {}, isBet: false);
          }
        }
      });
    });

    showLoading(false);
  }
}
