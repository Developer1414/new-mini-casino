import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BannedUser extends StatelessWidget {
  const BannedUser(
      {super.key,
      required this.reason,
      required this.date,
      required this.isBannedAccount});

  final String reason;
  final DateTime date;
  final bool isBannedAccount;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => exit(0),
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.ban,
                    color: Colors.redAccent,
                    size: 80.0,
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                      isBannedAccount
                          ? 'Вы заблокированы до ${DateFormat.yMMMMd('ru_RU').format(date)}\nПричина: $reason'
                          : reason,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(height: 1.3, fontSize: 22.0)),
                ],
              ),
            ),
          ),
        ));
  }
}
