import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/notification_controller.dart';
import 'dart:io' as ui;

Widget transferMoneysModel(
    {required BuildContext context,
    required NotificationController notificationController,
    required Map<dynamic, dynamic> docs}) {
  String from = docs['from'] ?? '???';

  DateTime date = DateTime.parse('${docs['date']}Z').toLocal();

  double moneysAmount = double.parse(docs['amount'].toString());

  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.moneyBillTransfer,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: 18.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: AutoSizeText(
                            from,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 18.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  AutoSizeText(
                      '+${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(moneysAmount)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 15.0, color: Colors.green)),
                ],
              ),
              Text(
                  '${DateFormat.MMMd(ui.Platform.localeName).format(date)} в ${DateFormat.jm(ui.Platform.localeName).format(date)}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 12.0,
                        color: Colors.white60.withOpacity(0.5),
                      )),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: buttonModel(
                          context: context,
                          buttonName: 'Получить',
                          onPressed: () async {
                            await notificationController.getMoneys(
                                context: context,
                                amount: moneysAmount,
                                docId: docs['id']);
                          },
                          color: Colors.green),
                    ),
                    const SizedBox(width: 10.0),
                    buttonModel(
                        context: context,
                        icon: FontAwesomeIcons.xmark,
                        onPressed: () async {
                          await notificationController.cancelMoneys(docs['id']);
                        },
                        color: Colors.redAccent),
                  ],
                ),
              )
            ],
          ),
        ),
      ));
}

Widget buttonModel(
    {required BuildContext context,
    String? buttonName,
    String? subtitle,
    required Color color,
    Function()? onPressed,
    Color? textColor,
    Color? iconColor,
    IconData? icon}) {
  return SizedBox(
    height: 40.0,
    child: ElevatedButton(
      onPressed: () {
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        elevation: 5,
        shadowColor: color.withOpacity(0.8),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon == null
              ? Container()
              : FaIcon(
                  icon,
                  color: iconColor ?? Colors.grey.shade300,
                  size: 22.0,
                ),
          icon == null
              ? Container()
              : buttonName == null
                  ? Container()
                  : const SizedBox(width: 10.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buttonName == null
                  ? Container()
                  : AutoSizeText(
                      buttonName,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 18.0),
                    ),
              subtitle == null
                  ? Container()
                  : AutoSizeText(subtitle,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 15.0,
                          color: textColor ??
                              Theme.of(context).textTheme.bodyMedium!.color)),
            ],
          ),
        ],
      ),
    ),
  );
}
