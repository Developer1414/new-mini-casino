import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/notification_controller.dart';
import 'package:new_mini_casino/models/button_model.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, notificationController, child) {
        return notificationController.isLoading
            ? loading(context: context)
            : Scaffold(
                appBar: AppBar(
                  toolbarHeight: 76.0,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  title: AutoSizeText(
                    'Уведомления',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: IconButton(
                          splashRadius: 25.0,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Beamer.of(context).beamBack();
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.xmark,
                            color: Colors.redAccent,
                            size: 30.0,
                          )),
                    ),
                  ],
                ),
                body: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('notifications')
                      /*.where('uid',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)*/
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loading(context: context);
                    }

                    List<QueryDocumentSnapshot<Map<String, dynamic>>>? list =
                        snapshot.data?.docs
                            .where((element) =>
                                element.get('uid') ==
                                    FirebaseAuth.instance.currentUser!.uid ||
                                element.get('uid') == 'all')
                            .toList()
                            .reversed
                            .toList();

                    //var reversedList = list!.reversed.toList();

                    return list!.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0),
                              child: AutoSizeText(
                                'Новых уведомлений нет',
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return transferMoneysModel(
                                  notificationController:
                                      notificationController,
                                  context: context,
                                  docs: list[index]);
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 15.0),
                          );
                  },
                ),
              );
      },
    );
  }

  Widget transferMoneysModel(
      {required BuildContext context,
      required NotificationController notificationController,
      required QueryDocumentSnapshot<Map<String, dynamic>> docs}) {
    String action = docs.get('action');
    String from = action != 'news' ? docs.get('from') : '';

    DateTime date = docs.get('date').toDate();

    notificationController.saveNotificationsId(docs.id);

    double moneysAmount =
        action != 'news' ? double.parse(docs.get('amount').toString()) : 0.0;

    String news = action == 'news' ? docs.get('news') : '';
    String title = action == 'news' ? docs.get('title') : '';

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
                  action == 'news'
                      ? FontAwesomeIcons.newspaper
                      : FontAwesomeIcons.moneyBillTransfer,
                  color: Theme.of(context).appBarTheme.iconTheme!.color,
                  size: 23.0,
                ),
                const SizedBox(width: 8.0),
                AutoSizeText(
                  action == 'news' ? title : 'Перевод',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            AutoSizeText(
                action == 'news'
                    ? news.replaceAll('\\n', '\n')
                    : '$from перевёл вам ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(moneysAmount)}',
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
            action == 'news'
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: buttonModel(
                        context: context,
                        icon: FontAwesomeIcons.coins,
                        buttonName: 'Получить',
                        onPressed: () async {
                          await notificationController.getMoneys(
                              context: context,
                              amount: moneysAmount,
                              docId: docs.id);
                        },
                        color: Colors.green),
                  )
          ],
        ),
      ),
    );
  }
}
