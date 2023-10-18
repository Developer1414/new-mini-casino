import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/notification_controller.dart';
import 'dart:io' as ui;

Widget newsModel(
    {required BuildContext context,
    required NotificationController notificationController,
    required QueryDocumentSnapshot<Map<String, dynamic>> docs}) {
  DateTime date = docs.get('date').toDate();

  String news = docs.get('news');
  String title = docs.get('title');

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
                FontAwesomeIcons.newspaper,
                color: Theme.of(context).appBarTheme.iconTheme!.color,
                size: 23.0,
              ),
              const SizedBox(width: 8.0),
              AutoSizeText(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          AutoSizeText(news.replaceAll('\\n', '\n'),
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
        ],
      ),
    ),
  );
}
