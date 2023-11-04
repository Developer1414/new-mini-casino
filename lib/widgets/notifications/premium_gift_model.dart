import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/notification_controller.dart';
import 'dart:io' as ui;
import 'package:new_mini_casino/widgets/button_model.dart';

Widget premiumGiftModel(
    {required BuildContext context,
    required NotificationController notificationController,
    required Map<dynamic, dynamic> docs}) {
  String from = docs['from'];

  DateTime expiredDate = DateTime.parse(docs['expiredDate']);
  DateTime date = DateTime.parse(docs['date']);

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(left: 15.0, right: 15.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: const Color.fromARGB(255, 179, 242, 31),
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
              const FaIcon(
                FontAwesomeIcons.solidStar,
                color: Color.fromARGB(255, 5, 2, 1),
                size: 23.0,
              ),
              const SizedBox(width: 8.0),
              AutoSizeText(
                'MINI CASINO',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 5, 2, 1),
                  fontSize: 22.0,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 5.0),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.black87),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  child: AutoSizeText(
                    'PREMIUM',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 22.0,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          AutoSizeText(
              '$from подарил вам Premium-версию игры на ${DateTime.now().difference(expiredDate).inDays.abs() > 32 ? 'год' : 'месяц'}!',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: const Color.fromARGB(255, 5, 2, 1))),
          const SizedBox(height: 8.0),
          AutoSizeText(
              '${DateFormat.MMMMd(ui.Platform.localeName).format(date)} в ${DateFormat.jm(ui.Platform.localeName).format(date)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: const Color.fromARGB(180, 5, 2, 1))),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: buttonModel(
                context: context,
                buttonName: 'Подключить',
                onPressed: () async {
                  await notificationController.connectGiftPremium(
                      context: context,
                      expiredDate: expiredDate,
                      docId: docs['id']);
                },
                color: const Color.fromARGB(255, 5, 2, 1)),
          )
        ],
      ),
    ),
  );
}
