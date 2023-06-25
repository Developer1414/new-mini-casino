/*import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class NotificationService {
  Future init() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future requestPermissionToSendNotifications(BuildContext context) async {
    /*await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: 'Push-уведомления',
        text:
            'Нам нужно Ваше разрешение на использование push-уведомлений. Обещаем, спамить не будем :)',
        confirmBtnText: 'Да',
        cancelBtnText: 'Нет',
        confirmBtnColor: Colors.green,
        animType: QuickAlertAnimType.slideInDown,
        onCancelBtnTap: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        onConfirmBtnTap: () {
          FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
              FlutterLocalNotificationsPlugin();
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestPermission();
        });*/
  }
}
*/