import 'dart:math';
import 'dart:io' as ui;
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

class BonusManager extends ChangeNotifier {
  bool isLoadingBonus = false;

  int freeBonusCount = 0;

  void showLoading(bool isActive) {
    isLoadingBonus = isActive;
    notifyListeners();
  }

  Future getFreeBonus(BuildContext context) async {
    if (isLoadingBonus) return;

    showLoading(true);

    await AdService.showRewardedAd(
        context: context,
        func: () async {
          getReward(
              context: context,
              rewardCount: double.parse(
                  (Random().nextInt(AccountController.isPremium ? 900 : 200) +
                          100)
                      .toString()));
        }).whenComplete(() => showLoading(false));
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
