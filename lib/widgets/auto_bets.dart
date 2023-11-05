import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:provider/provider.dart';

class AutoBetsController extends ChangeNotifier {
  bool isAutoBetsEnabled = false;

  void change() {
    isAutoBetsEnabled = !isAutoBetsEnabled;
    notifyListeners();
  }

  bool exitGame(BuildContext context) {
    if (isAutoBetsEnabled) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Нельзя выйти из игры во время автоставок!',
      );

      return false;
    } else {
      return true;
    }
  }
}

Widget autoBetsModel(
    {required BuildContext context, required Function() function}) {
  bool isAutoBets = false;
  late Timer timer;

  return Padding(
    padding: const EdgeInsets.only(right: 5.0),
    child: StatefulBuilder(
      builder: (context, setState) {
        return IconButton(
            splashRadius: 25.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              Provider.of<AutoBetsController>(context, listen: false).change();

              setState(() {
                isAutoBets = !isAutoBets;
              });

              if (isAutoBets) {
                timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
                  function.call();
                });
              } else {
                timer.cancel();
              }
            },
            icon: FaIcon(
              isAutoBets
                  ? FontAwesomeIcons.circleStop
                  : FontAwesomeIcons.rotate,
              color: isAutoBets
                  ? Colors.redAccent
                  : Theme.of(context).appBarTheme.iconTheme!.color,
              size: Theme.of(context).appBarTheme.iconTheme!.size,
            ));
      },
    ),
  );
}
