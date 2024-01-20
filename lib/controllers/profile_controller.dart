import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/models/profile_model.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';

class ProfileController extends ChangeNotifier {
  bool isLoading = false;

  static ProfileModel profileModel = ProfileModel();

  static Future getUserProfile(BuildContext context) async {
    if (SupabaseController.supabase?.auth.currentUser == null) {
      return ProfileModel(nickname: 'null', totalGame: 0);
    }

    try {
      await SupabaseController.supabase!
          .from('users')
          .select('*')
          .eq('uid', SupabaseController.supabase?.auth.currentUser!.id)
          .then((value) {
        Map<dynamic, dynamic> map = (value as List<dynamic>).first;

        profileModel = ProfileModel(
          nickname: map['name'] ?? 'null',
          totalGame: int.parse(map['totalGames'].toString()),
          level: double.parse(map['level'].toString()),
        );
      });
    } on Exception catch (e) {
      if (context.mounted) {
        alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: '[LoadUserProfileError]: ${e.toString()}');
      }
    }
  }
}
