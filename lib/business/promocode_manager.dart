import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class PromocodeManager extends ChangeNotifier {
  bool isLoading = false;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future usePromocode(
      {required BuildContext context, required String promocode}) async {
    showLoading(true);

    await FirebaseFirestore.instance
        .collection('promocodes')
        .doc(promocode)
        .get()
        .then((value) async {
      if (value.exists) {
        int activationCount = int.parse(value.get('count').toString());
        double prize = double.parse(value.get('prize').toString());

        if (activationCount <= 0) {
          alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: 'Исчерпано количество использований!',
          );
        } else {
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get()
              .then((value) async {
            if (value.data()!.containsKey('promocodes')) {
              List list = value.get('promocodes') as List;

              if (list.contains(promocode)) {
                alertDialogError(
                  context: context,
                  title: 'Ошибка',
                  confirmBtnText: 'Окей',
                  text: 'Вы уже использовали этот промокод!',
                );

                return;
              }

              list.add(promocode);

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({'promocodes': list});
            } else {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({
                'promocodes': [promocode]
              });
            }

            await FirebaseFirestore.instance
                .collection('promocodes')
                .doc(promocode)
                .update({'count': FieldValue.increment(-1)});

            // ignore: use_build_context_synchronously
            Provider.of<Balance>(context, listen: false).cashout(prize);

            if (activationCount <= 1) {
              await FirebaseFirestore.instance
                  .collection('promocodes')
                  .doc(promocode)
                  .delete();
            }

            // ignore: use_build_context_synchronously
            alertDialogSuccess(
              context: context,
              title: 'Поздравляем!',
              confirmBtnText: 'Спасибо!',
              text:
                  'Вам зачислено ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(prize)}!',
            );
          });
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

    showLoading(false);
  }
}
