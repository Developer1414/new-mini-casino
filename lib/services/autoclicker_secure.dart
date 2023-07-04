import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';

class AutoclickerSecure extends ChangeNotifier {
  static bool isCanPlay = true;
  static int clcksCount = 0;
  static int warningsCount = 0;

  Future checkAutoclicker() async {
    int counter = 3;
    clcksCount = 0;

    isCanPlay = false;

    // ignore: unused_local_variable
    Timer timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      counter--;
      if (counter == 0) {
        timer.cancel();
      }
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    isCanPlay = true;
  }

  Future checkClicksBeforeCanPlay(BuildContext context) async {
    AutoclickerSecure.clcksCount++;

    if (warningsCount < 3) {
      if (clcksCount >= 3) {
        warningsCount++;

        alertDialogError(
          context: context,
          title: 'Предупреждение',
          text:
              'Не делайте ставки слишком быстро, так как это может привести к автоматической блокировке аккаунта. Предупреждений: $warningsCount/3',
          confirmBtnText: 'Окей',
        );
      }
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'ban': [
          'Использование атвокликера',
          DateTime.now().add(const Duration(days: 5))
        ],
      }).whenComplete(() => exit(0));
    }
  }
}
