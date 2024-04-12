import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:ntp/ntp.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LatestMaxWinsController {
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

    if (context.mounted) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: "Поздравляем! Вы попали в «Крупные выигрыши»!",
        ),
      );
    }
  }
}
