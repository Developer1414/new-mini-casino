import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/widgets/autoclicker_detect_screen.dart';

class AutoclickerSecure extends ChangeNotifier {
  static bool isCanPlay = true;
  static int clcksCount = 0;
  static int warningsCount = 0;

  Future checkAutoclicker() async {
    int counter = 3;
    clcksCount = 0;

    isCanPlay = false;

    // ignore: unused_local_variable
    Timer timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      counter--;
      if (counter == 0) {
        timer.cancel();
      }
    });

    await Future.delayed(const Duration(milliseconds: 500));

    isCanPlay = true;
  }

  Future checkClicksBeforeCanPlay(BuildContext context) async {
    clcksCount++;

    if (clcksCount >= 3) {
      autoClickerDetected(context: context);
    }
  }
}
