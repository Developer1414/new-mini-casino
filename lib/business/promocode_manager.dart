import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/business/local_promocodes_service.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

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

    Provider.of<Balance>(context, listen: false).cashout(prize);

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
      {required BuildContext context, required String myPromocode}) async {
    if (LocalPromocodes.promocodes.containsKey(myPromocode)) {
      useLocalPromocode(myPromocode: myPromocode, context: context);
      return;
    }

    showLoading(true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      if (int.parse(value.get('totalGames').toString()) < 2000) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text:
              'Промокоды можно использовать от 2000 игр! У вас: ${int.parse(value.get('totalGames').toString())}',
        );
      } else {
        await FirebaseFirestore.instance
            .collection('promocodes')
            .doc(myPromocode)
            .get()
            .then((value) async {
          if (value.exists) {
            int activationCount = int.parse(value.get('count').toString());
            double prize = double.parse(value.get('prize').toString());
            DateTime expiredDate =
                (value.get('expiredDate') as Timestamp).toDate();

            DateTime dateTimeNow = await NTP.now();

            if (expiredDate.difference(dateTimeNow).inHours >= 5) {
              await FirebaseFirestore.instance
                  .collection('promocodes')
                  .doc(myPromocode)
                  .delete()
                  .whenComplete(() {
                alertDialogError(
                  context: context,
                  title: 'Ошибка',
                  confirmBtnText: 'Окей',
                  text: 'Время действия промокода исчерпано!',
                );
              });
            } else {
              if (activationCount <= 0) {
                // ignore: use_build_context_synchronously
                alertDialogError(
                  context: context,
                  title: 'Ошибка',
                  confirmBtnText: 'Окей',
                  text: 'Исчерпано количество использований!',
                );
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get()
                    .then((value) async {
                  if (value.data()!.containsKey('promocodes')) {
                    List list = value.get('promocodes') as List;

                    if (list.contains(myPromocode)) {
                      alertDialogError(
                        context: context,
                        title: 'Ошибка',
                        confirmBtnText: 'Окей',
                        text: 'Вы уже использовали этот промокод!',
                      );

                      return;
                    }

                    list.add(myPromocode);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .update({'promocodes': list});
                  } else {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .update({
                      'promocodes': [myPromocode]
                    });
                  }

                  await FirebaseFirestore.instance
                      .collection('promocodes')
                      .doc(myPromocode)
                      .update({'count': FieldValue.increment(-1)});

                  // ignore: use_build_context_synchronously
                  Provider.of<Balance>(context, listen: false).cashout(prize);

                  if (activationCount <= 1) {
                    await FirebaseFirestore.instance
                        .collection('promocodes')
                        .doc(myPromocode)
                        .delete();
                  }

                  // ignore: use_build_context_synchronously
                  alertDialogSuccess(
                    context: context,
                    title: 'Поздравляем',
                    confirmBtnText: 'Спасибо!',
                    text:
                        'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(prize)}!',
                  );

                  // ignore: use_build_context_synchronously
                  AdService.showInterstitialAd(
                      context: context, func: () {}, isBet: false);
                });
              }
            }
          } else {
            alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text:
                  'Промокод не существует или количество использований исчерпано!',
            );
          }
        });
      }
    });

    showLoading(false);
  }
}
