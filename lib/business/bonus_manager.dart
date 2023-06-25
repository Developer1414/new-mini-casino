import 'dart:math';
import 'dart:io' as ui;
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class BonusManager extends ChangeNotifier {
  bool isLoadingBonus = false;

  int freeBonusCount = 0;

  void shoowLoading(bool isActive) {
    isLoadingBonus = isActive;
    notifyListeners();
  }

  Future getFreeBonus(BuildContext context) async {
    if (isLoadingBonus) return;

    shoowLoading(true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey('freeBonusInfo')) {
        List freeBonusInfo = value.get('freeBonusInfo') as List;

        DateTime dateTimeNow = await NTP.now();

        if ((freeBonusInfo[1] as Timestamp).toDate().day == dateTimeNow.day) {
          if (int.parse(freeBonusInfo[0].toString()) >=
              (AccountController.isPremium ? 10 : 5)) {
            if (AccountController.isPremium) {
              // ignore: use_build_context_synchronously
              alertDialogError(
                  context: context,
                  title: 'Ошибка',
                  text:
                      'Вы превысили лимит бесплатного бонуса (10 использований в день). Попробуйте на следующий день.');
              return;
            } else {
              // ignore: use_build_context_synchronously
              await QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  title: 'Ошибка',
                  text:
                      'Вы превысили лимит бесплатного бонуса (5 использований в день). Хотите приобрести Mini Casino Premium с доступом к 10 бесплатным бонусам в день и другим возможностям всего за 99 рублей?',
                  confirmBtnText: 'Да',
                  cancelBtnText: 'Нет',
                  confirmBtnColor: Colors.green,
                  animType: QuickAlertAnimType.slideInDown,
                  onCancelBtnTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  onConfirmBtnTap: () {
                    Navigator.of(context, rootNavigator: true).pop();

                    context.beamToNamed('/premium');
                  });
            }
            return;
          }
        }
      }

      // ignore: use_build_context_synchronously
      await AdService.showRewardedAd(
          context: context,
          func: () async {
            getReward(
                context: context,
                rewardCount: double.parse(
                    (Random().nextInt(AccountController.isPremium ? 900 : 200) +
                            100)
                        .toString()));
          });
    });

    shoowLoading(false);
  }

  void getReward(
      {required BuildContext context, required double rewardCount}) async {
    Provider.of<Balance>(context, listen: false).cashout(rewardCount);

    alertDialogSuccess(
      context: context,
      title: 'Поздравляем!',
      confirmBtnText: 'Спасибо!',
      text:
          'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(rewardCount)}!',
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      DateTime dateTimeNow = await NTP.now();

      List freeBonusInfo = [0, dateTimeNow];

      if (value.data()!.containsKey('freeBonusInfo')) {
        List recievedBonusInfo = value.get('freeBonusInfo') as List;

        DateTime loadedDate = (recievedBonusInfo[1] as Timestamp).toDate();

        if (loadedDate.day != dateTimeNow.day ||
            loadedDate.month != dateTimeNow.month) {
          freeBonusInfo[0] = 1;
        } else {
          freeBonusInfo[0] = recievedBonusInfo[0] + 1;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'freeBonusInfo': freeBonusInfo});

      freeBonusCount = (AccountController.isPremium ? 10 : 5) -
          int.parse(freeBonusInfo[0].toString());
      notifyListeners();
    });
  }

  Future loadFreeBonusCount() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return 0;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey('freeBonusInfo')) {
        DateTime dateTimeNow = await NTP.now();

        List recievedBonusInfo = value.get('freeBonusInfo') as List;

        DateTime loadedDate = (recievedBonusInfo[1] as Timestamp).toDate();

        if (loadedDate.day != dateTimeNow.day ||
            loadedDate.month != dateTimeNow.month) {
          freeBonusCount = AccountController.isPremium ? 10 : 5;
        } else {
          freeBonusCount = (AccountController.isPremium ? 10 : 5) -
              int.parse((value.get('freeBonusInfo') as List)[0].toString());
        }
      }
    });

    notifyListeners();
  }
}
