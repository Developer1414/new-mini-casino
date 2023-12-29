import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/notification_controller.dart';
import 'dart:io' as ui;

import 'package:new_mini_casino/widgets/button_model.dart';

Widget friendCodeMoneysModel(
    {required BuildContext context,
    required NotificationController notificationController,
    required Map<dynamic, dynamic> docs}) {
  String from = docs['from'] ?? '???';

  DateTime date = DateTime.parse(docs['date']);

  double moneysAmount = double.parse(docs['amount'].toString());

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(left: 15.0, right: 15.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.0)
        ]),
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.moneyBillTransfer,
                color: Theme.of(context).appBarTheme.iconTheme!.color,
                size: 23.0,
              ),
              const SizedBox(width: 8.0),
              AutoSizeText(
                'Перевод',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          AutoSizeText(
              '$from зарегистрировался по вашему коду! Ваша награда: ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(moneysAmount)}',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .color!
                      .withOpacity(0.8))),
          const SizedBox(height: 8.0),
          AutoSizeText(
              '${DateFormat.MMMMd(ui.Platform.localeName).format(date)} в ${DateFormat.jm(ui.Platform.localeName).format(date)}',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .color!
                      .withOpacity(0.5))),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: buttonModel(
                      context: context,
                      icon: FontAwesomeIcons.coins,
                      buttonName: 'Получить',
                      onPressed: () async {
                        await notificationController.getMoneys(
                            expiredDate: DateTime(3000),
                            context: context,
                            amount: moneysAmount,
                            docId: docs['id']);
                      },
                      color: Colors.green),
                ),
                const SizedBox(width: 15.0),
                Expanded(
                  child: buttonModel(
                      context: context,
                      icon: FontAwesomeIcons.xmark,
                      onPressed: () async {
                        await notificationController.cancelMoneys(docs['id']);
                      },
                      color: Colors.redAccent),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
