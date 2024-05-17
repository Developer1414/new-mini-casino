import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum NotificationType {
  error,
  transfer,
  success,
  leader,
  warning,
}

class NotificationService {
  static Future setToken(BuildContext context) async {
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.getAPNSToken();

    var fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      await getFCMToken(fcmToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await getFCMToken(fcmToken);
    });
  }

  static Future getFCMToken(String fcmToken) async {
    try {
      await SupabaseController.supabase!.from('users').update({
        'fcmToken': fcmToken,
      }).eq('uid', SupabaseController.supabase!.auth.currentUser!.id);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('TOKEN_ERROR: ${e.message}');
      }
    }
  }

  static Future listenNotifications(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((payload) async {
      final notification = payload.notification;

      if (notification != null) {
        NotificationService.showInAppNotification(
          context: context,
          title: 'Пополнение',
          notificationType: NotificationType.transfer,
          content: notification.body!,
        );
      }
    });
  }

  static void showInAppNotification({
    required BuildContext context,
    required String title,
    required String content,
    required NotificationType notificationType,
  }) {
    InAppNotification.show(
      child: notificationBody(
        context: context,
        notificationType: notificationType,
        title: title,
        content: content,
      ),
      context: context,
    );
  }

  static Widget notificationBody({
    required BuildContext context,
    required String title,
    required String content,
    required NotificationType notificationType,
  }) {
    IconData icon;
    Color color;
    Color backgroundColor;

    switch (notificationType) {
      case NotificationType.success:
        color = Colors.green;
        backgroundColor = const Color.fromRGBO(216, 243, 220, 1);
        icon = FontAwesomeIcons.circleCheck;
        break;
      case NotificationType.error:
        color = Colors.redAccent;
        backgroundColor = const Color.fromARGB(255, 243, 216, 216);
        icon = FontAwesomeIcons.circleXmark;
        break;
      case NotificationType.transfer:
        color = Colors.green;
        backgroundColor = const Color.fromRGBO(216, 243, 220, 1);
        icon = FontAwesomeIcons.moneyBill;
        break;
      case NotificationType.leader:
        color = Colors.green;
        backgroundColor = const Color.fromRGBO(216, 243, 220, 1);
        icon = FontAwesomeIcons.crown;
        break;
      case NotificationType.warning:
        color = Colors.orange;
        backgroundColor = const Color.fromARGB(255, 243, 232, 216);
        icon = FontAwesomeIcons.triangleExclamation;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 12,
            blurRadius: 16,
          ),
        ],
        borderRadius: BorderRadius.circular(12.0),
        color: backgroundColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: FaIcon(
                  icon,
                  color: color,
                  size: 40.0,
                ),
              ),
              SizedBox(
                width: 300.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .appBarTheme
                          .titleTextStyle!
                          .copyWith(color: Colors.black, fontSize: 20.0),
                    ),
                    AutoSizeText(
                      content,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(color: color, fontSize: 15.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
