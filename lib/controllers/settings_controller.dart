import 'dart:convert';
import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/models/background_model.dart';
import 'package:new_mini_casino/screens/settings.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  bool isLoading = false;
  bool isCutomBackground = false;

  bool isEnabledConfetti = true;
  bool isEnabledMaxWinNotification = true;

  int currentDefaultBackgrond = 0;

  File currentCustomBackgrond = File('');

  double customBackgroundBlur = 5.0;
  double defaultBackgroundBlur = 5.0;
  double minBet = 100.0;

  late SharedPreferences prefs;

  void loading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void changeCustomBackgroundBlur(double value) {
    if (currentCustomBackgrond.path.isEmpty) {
      return;
    }

    customBackgroundBlur = value;

    setBackground(BackgroundModel(
        isCustomBackground: true,
        customBackgroundPath: currentCustomBackgrond.path,
        blur: value));

    notifyListeners();
  }

  void changeDefaultBackgroundBlur(double value) {
    defaultBackgroundBlur = value;

    setBackground(BackgroundModel(
        isCustomBackground: false,
        defaultBackgroundIndex: currentDefaultBackgrond,
        blur: value));

    notifyListeners();
  }

  void changeConfettiSetting(bool value) async {
    isEnabledConfetti = value;

    prefs.setBool('isEnabledConfetti', isEnabledConfetti);

    notifyListeners();
  }

  void changeMaxWinNotificationSetting(bool value) async {
    isEnabledMaxWinNotification = value;

    prefs.setBool('isEnabledMaxWinNotification', isEnabledMaxWinNotification);

    notifyListeners();
  }

  void changeMinimumBet(
      {required double value, required BuildContext context}) async {
    minBet = value;

    prefs.setDouble('minBet', minBet);

    CommonFunctions.setDefaultGamesMinBet(
        context: context, defaultMinBet: minBet);

    Settings.minBetController.text =
        Settings.minBetFormatter.format(minBet.toStringAsFixed(2));

    notifyListeners();
  }

  Future getConfettiSetting() async {
    if (!prefs.containsKey('isEnabledConfetti')) {
      isEnabledConfetti = true;
    } else {
      isEnabledConfetti = prefs.getBool('isEnabledConfetti')!;
    }

    notifyListeners();
  }

  Future getMaxWinNotificationSetting() async {
    if (!prefs.containsKey('isEnabledMaxWinNotification')) {
      isEnabledMaxWinNotification = true;
    } else {
      isEnabledMaxWinNotification =
          prefs.getBool('isEnabledMaxWinNotification')!;
    }

    notifyListeners();
  }

  Future getMinimumBetSetting(BuildContext context) async {
    if (!prefs.containsKey('minBet')) {
      minBet = 100.0;
    } else {
      minBet = prefs.getDouble('minBet')! > 1000000
          ? SupabaseController.isPremium
              ? prefs.getDouble('minBet')!
              : 1000000
          : prefs.getDouble('minBet')!;
    }

    Settings.minBetController.text =
        Settings.minBetFormatter.format(minBet.toStringAsFixed(2));

    CommonFunctions.setDefaultGamesMinBet(
        context: context, defaultMinBet: minBet);

    notifyListeners();
  }

  Future loadSettings(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();

    await getBackground();
    await getConfettiSetting();
    await getMaxWinNotificationSetting();
    // ignore: use_build_context_synchronously
    await getMinimumBetSetting(context);
  }

  Future signOut(BuildContext context) async {
    alertDialogConfirm(
        context: context,
        title: 'Подтверждение',
        text: 'Вы уверены что хотите выйти из аккаунта?',
        confirmBtnText: 'Нет',
        cancelBtnText: 'Да',
        onConfirmBtnTap: () => Navigator.of(context, rootNavigator: true).pop(),
        onCancelBtnTap: () {
          Navigator.of(context, rootNavigator: true).pop();

          SupabaseController.supabase!.auth.signOut().whenComplete(() {
            Provider.of<Balance>(context, listen: false).balance = 0.0;
            context.beamToReplacementNamed('/login');
          });
        });
  }

  Future setCustomBackground(BuildContext context) async {
    if (!SupabaseController.isPremium) {
      alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: 'У вас нет Premium-подписки!');
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      isCutomBackground = true;
      currentCustomBackgrond = File(result.files.single.path!);

      await setBackground(BackgroundModel(
          isCustomBackground: true,
          customBackgroundPath: result.files.single.path!,
          blur: customBackgroundBlur));
    }

    notifyListeners();
  }

  Future setDefaultBackground(int index) async {
    await setBackground(BackgroundModel(
        isCustomBackground: false,
        defaultBackgroundIndex: index,
        blur: defaultBackgroundBlur));
  }

  Future setBackground(BackgroundModel backgroundModel) async {
    prefs.setString('background', jsonEncode(backgroundModel.toJson()));

    await getBackground();
  }

  Future getBackground() async {
    if (prefs.containsKey('background')) {
      Map<String, dynamic> json = jsonDecode(prefs.getString('background')!);

      bool isCustomBackground = json['isCustomBackground'] as bool;

      if (isCustomBackground == true && SupabaseController.isPremium) {
        isCutomBackground = true;

        customBackgroundBlur = double.parse(json['blur'].toString());

        currentCustomBackgrond = File(json['customBackgroundPath'].toString());
      } else {
        isCutomBackground = false;

        defaultBackgroundBlur = double.parse(json['blur'].toString());

        currentDefaultBackgrond = isCustomBackground
            ? 0
            : int.parse(json['defaultBackgroundIndex'].toString());
      }
    } else {
      isCutomBackground = false;

      defaultBackgroundBlur = 5.0;

      currentDefaultBackgrond = 0;
    }

    notifyListeners();
  }
}
