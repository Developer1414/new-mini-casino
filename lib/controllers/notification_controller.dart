import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as ui;
import 'package:provider/src/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationController extends ChangeNotifier {
  bool isLoading = false;

  static bool isChecked = false;

  late BuildContext mainContext;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future<bool> getNotifications() async {
    final res = await SupabaseController.supabase!
        .from('notifications')
        .select(
          'id',
          const FetchOptions(
            count: CountOption.exact,
          ),
        )
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id);

    return res.count > 0;
  }

  Future saveNotificationsId(String notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> ids = [];

    if (prefs.containsKey('notificationsId')) {
      ids = json
          .decode(prefs.getString('notificationsId').toString())
          .cast<String>()
          .toList();
    }

    ids.add(notificationId);

    prefs.setString('notificationsId', json.encode(ids));
  }

  Future getMoneys(
      {required BuildContext context,
      required double amount,
      required DateTime expiredDate,
      required int docId}) async {
    showLoading(true);

    final balance = provider.Provider.of<Balance>(mainContext, listen: false);

    if (expiredDate.difference(await NTP.now()).inMinutes <= 0) {
      await SupabaseController.supabase!
          .from('notifications')
          .delete()
          .eq('id', docId)
          .whenComplete(() {
        alertDialogError(
            context: mainContext, title: 'Ошибка', text: 'Вы опоздали!');
      });

      showLoading(false);

      return;
    } else {
      balance.cashout(amount);

      await SupabaseController.supabase!
          .from('notifications')
          .delete()
          .eq('id', docId)
          .whenComplete(() {
        alertDialogSuccess(
            context: mainContext,
            title: 'Успех',
            text:
                'На ваш счёт успешно зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(amount)}!');

        AdService.showInterstitialAd(
            context: mainContext, func: () {}, isBet: false);
      });

      showLoading(false);
    }
  }

  Future cancelMoneys(int docId) async {
    showLoading(true);

    await SupabaseController.supabase!
        .from('notifications')
        .delete()
        .eq('id', docId);

    showLoading(false);
  }

  Future connectGiftPremium(
      {required BuildContext context,
      required int docId,
      required DateTime expiredDate}) async {
    showLoading(true);

    SupabaseController.isPremium = true;
    SupabaseController.expiredSubscriptionDate = expiredDate;

    await SupabaseController.supabase!
        .from('notifications')
        .delete()
        .eq('id', docId)
        .whenComplete(() async {
      await SupabaseController.supabase!.from('users').update({
        'premium': expiredDate.toIso8601String(),
      }).eq('uid', SupabaseController.supabase?.auth.currentUser!.id);

      if (context.mounted) {
        alertDialogSuccess(
            context: mainContext,
            title: 'Успех',
            text:
                'Вы успешно подключили Premium-версию Mini Casino на ${DateTime.now().difference(expiredDate).inDays > 32 ? 'год' : 'месяц'}!');
      }
    });

    showLoading(false);
  }
}
