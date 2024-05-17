import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/notification_service.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';

class LatestMaxWinsController extends ChangeNotifier {
  bool isLoading = false;

  int choosedUser = -1;

  void chooseUser(int index) {
    choosedUser = choosedUser == index ? -1 : index;
    notifyListeners();
  }

  void loading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  static Future addMaxWin({
    required BuildContext context,
    required double bet,
    required double profit,
    required String gameName,
  }) async {
    DateTime dateTimeNow = await NTP.now();
    dateTimeNow = dateTimeNow.toUtc();

    await SupabaseController.supabase!.from('latest_max_wins').insert({
      'name': ProfileController.profileModel.nickname,
      'win': profit,
      'bet': bet,
      'game': gameName,
      'date': dateTimeNow.toIso8601String(),
    });

    if (context.mounted &&
        Provider.of<SettingsController>(context, listen: false)
            .isEnabledMaxWinNotification) {
      NotificationService.showInAppNotification(
        context: context,
        title: 'Поздравляем!',
        notificationType: NotificationType.success,
        content: 'Вы попали в «Крупные выигрыши»!',
      );
    }
  }
}
