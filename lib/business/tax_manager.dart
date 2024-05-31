import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/services/notification_service.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';

class TaxManager extends ChangeNotifier {
  bool isLoading = false;
  bool isCanPlay = true;

  double currentTax = 0.0;

  DateTime lastDayPaymentDate = DateTime(2000);

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future loadTax() async {
    showLoading(true);

    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      currentTax = map['taxAmount'] == null
          ? 0.0
          : double.parse(map['taxAmount'].toString());

      if (currentTax > 0.0) {
        lastDayPaymentDate = map['taxLastDate'] == null
            ? DateTime(2000)
            : DateTime.parse(map['taxLastDate'].toString()).toLocal();
      }
    });

    showLoading(false);
  }

  Future checkTax() async {
    if (SupabaseController.isPremium) return;

    await loadTax();

    DateTime ntpDate = await NTP.now();

    Duration difference = lastDayPaymentDate.difference(ntpDate);

    print(difference.inHours);
    print(difference.inMinutes);

    if (difference.inDays <= 0 && currentTax > 0.0) {
      if (difference.inHours > 0 || difference.inMinutes > 0) {
        NotificationService.showInAppNotification(
          context: navigatorKey.currentContext!,
          title: 'Налог',
          content:
              'Вы должны оплатить налог в течение ${difference.inHours}ч. ${difference.inMinutes % 60}м., иначе Вы не сможете продолжить играть!',
          notificationType: NotificationType.warning,
        );
      } else {
        isCanPlay = false;
        notifyListeners();
      }
    }
  }

  Future payTax(BuildContext context) async {
    final balance = Provider.of<Balance>(context, listen: false);

    showLoading(true);

    await balance.checkOnExistSpecificAmount(currentTax).then((isExist) async {
      if (isExist) {
        await balance.subtractMoney(currentTax);

        await SupabaseController.supabase!.from('users').update({
          'taxAmount': 0.0,
        }).eq('uid', SupabaseController.supabase?.auth.currentUser!.id);

        if (context.mounted) {
          alertDialogSuccess(
              context: context, title: 'Успех', text: 'Налог успешно оплачен!');

          await AdService.showInterstitialAd(
              context: context, func: () {}, isBet: false);
        }
      } else {
        await showErrorAlertNoBalance(context);
      }
    });

    currentTax = 0.0;
    isCanPlay = true;

    showLoading(false);
  }

  Future addTax(double bet) async {
    if (SupabaseController.isPremium) return;

    await SupabaseController.supabase!
        .from('users')
        .select('*')
        .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
        .then((value) async {
      Map<dynamic, dynamic> map = (value as List<dynamic>).first;

      DateTime ntpDate = DateTime(2000);

      double tax = map['taxAmount'] == null
          ? 0.0
          : double.parse(map['taxAmount'].toString());

      if (tax == 0.0) {
        ntpDate = await NTP.now();
      }

      DateTime date = tax == 0.0
          ? ntpDate.add(const Duration(days: 7))
          : DateTime.parse(map['taxLastDate'].toString());

      tax += bet * 1.2 / 100;

      await SupabaseController.supabase!.from('users').update({
        'taxAmount': tax,
        'taxLastDate': date.toIso8601String(),
      }).eq('uid', SupabaseController.supabase?.auth.currentUser!.id);
    });
  }
}
