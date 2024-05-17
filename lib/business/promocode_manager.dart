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

  Future useLocalPromocode(
      {required String myPromocode, required BuildContext context}) async {
    String promocode = LocalPromocodes.promocodes.entries
        .where((element) => element.key == myPromocode)
        .first
        .key;

    double prize = LocalPromocodes.promocodes.entries
        .where((element) => element.key == myPromocode)
        .first
        .value;

    showLoading(true);

    await provider.Provider.of<Balance>(context, listen: false).addMoney(prize);

    showLoading(false);

    if (context.mounted) {
      alertDialogSuccess(
        context: context,
        title: 'Поздравляем!',
        confirmBtnText: 'Спасибо!',
        text:
            'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(prize)}!',
      );
    }

    LocalPromocodes().removePromocode(promocode);

    notifyListeners();
  }

  Future usePromocode(
      {required BuildContext context, required String title}) async {
    if (LocalPromocodes.promocodes.containsKey(title)) {
      useLocalPromocode(myPromocode: title, context: context);
      return;
    }

    if (ProfileController.profileModel.totalGame < 500) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text:
            'Промокоды можно использовать от 500 игр! У вас: ${ProfileController.profileModel.totalGame}',
      );

      return;
    }

    showLoading(true);

    final res = await SupabaseController.supabase!
        .from('all_promocodes')
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
        .from('all_promocodes')
        .select('*')
        .eq('title', title)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      int activationCount = int.parse(map['activationCount'].toString());
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
          .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
          .then((value) async {
        Map<dynamic, dynamic> map = (value as List<dynamic>).first;

        String usedPromocodesString = map['usedPromocodes'].toString();

        List<String> usedPromocodesList =
            usedPromocodesString.isEmpty ? [] : usedPromocodesString.split(',');

        if (usedPromocodesList.contains(title)) {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: 'Вы уже использовали этот промокод!',
          );

          return;
        } else {
          usedPromocodesString += ',$title';

          await SupabaseController.supabase!
              .from('users')
              .update({'usedPromocodes': usedPromocodesString}).eq(
                  'uid', SupabaseController.supabase?.auth.currentUser!.id);

          if (activationCount <= 1) {
            await SupabaseController.supabase!
                .from('all_promocodes')
                .delete()
                .eq('title', title);
          } else {
            activationCount -= 1;

            await SupabaseController.supabase!
                .from('all_promocodes')
                .update({'activationCount': activationCount}).eq('title', title);
          }

          if (context.mounted) {
            provider.Provider.of<Balance>(context, listen: false)
                .addMoney(prize);

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
