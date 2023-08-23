import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends ChangeNotifier {
  bool isLoading = false;

  static bool isChecked = false;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future<bool> getNotifications() async {
    int notificationsCount = 0;

    await FirebaseFirestore.instance
        .collection('notifications')
        .get()
        .then((value) {
      notificationsCount = value.docs
          .where((element) =>
              element.get('uid') == FirebaseAuth.instance.currentUser!.uid ||
              element.get('uid') == 'all')
          .length;
    });

    return notificationsCount > 0;
  }

  Future saveNotificationsId(String notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> ids = [];

    if (prefs.containsKey('notificationsId')) {
      ids = json
          .decode(prefs.getString('notificationsId').toString())
          .cast<String>()
          .toList();
    }

    ids.add(notificationId);

    prefs.setString('notificationsId', json.encode(ids));
  }

  Future getMoneys(
      {required BuildContext context,
      required double amount,
      required String docId}) async {
    showLoading(true);

    Provider.of<Balance>(context, listen: false).cashout(amount);

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .delete()
        .whenComplete(() {
      AdService.showInterstitialAd(context: context, func: () {}, isBet: false);
    });

    showLoading(false);
  }
}
