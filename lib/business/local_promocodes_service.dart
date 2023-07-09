import 'dart:convert';
import 'dart:math';
import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/promocode_manager.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPromocodes {
  static Map<String, double> promocodes = {};
  static int betCount = 0;

  Map<String, double> generatePromocode() {
    final code = List.generate(12, (_) {
      const characters =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final index = Random().nextInt(characters.length);
      return characters.codeUnitAt(index);
    });

    double prize = Random().nextInt(701) + 300;

    promocodes.addAll({utf8.decode(code): prize});

    return {utf8.decode(code): prize};
  }

  Future initializeMyPromocodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('myPromocodes')) {
      return;
    }

    Map<String, dynamic> originalMap =
        jsonDecode(prefs.getString('myPromocodes').toString());

    originalMap.forEach((key, value) {
      promocodes[key] = value.toDouble();
    });

    if (prefs.containsKey('betCountLocalPromocodes')) {
      betCount = int.parse(prefs.getInt('betCountLocalPromocodes').toString());
    }
  }

  Future removePromocode(String promocode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocalPromocodes.promocodes.remove(promocode);
    prefs.setString('myPromocodes', jsonEncode(promocodes));
  }

  Future getPromocode(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    betCount++;

    print('betCount: $betCount');

    prefs.setInt('betCountLocalPromocodes', betCount);

    if (betCount < 350) return;

    Map<String, double> newPromocode = generatePromocode();

    String promocode = newPromocode.entries.last.key;
    double prize = newPromocode.entries.last.value;

    betCount = 0;

    prefs.setString('myPromocodes', jsonEncode(promocodes));
    prefs.setInt('betCountLocalPromocodes', betCount);

    // ignore: use_build_context_synchronously
    await QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        barrierDismissible: false,
        title: 'Поздравляем',
        text:
            'Вы получили промокод на ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(prize)}. А вот и он: $promocode. Вы можете активировать его в любое время в разделе "Промокод -> Мои промокоды". Промокод доступен только вам! Хотите использовать его сейчас?',
        confirmBtnText: 'Да',
        cancelBtnText: 'Нет',
        confirmBtnColor: Colors.green,
        animType: QuickAlertAnimType.slideInDown,
        onCancelBtnTap: () => Navigator.of(context, rootNavigator: true).pop(),
        onConfirmBtnTap: () {
          Navigator.of(context, rootNavigator: true).pop();
          PromocodeManager().useLocalPromocode(
              myPromocode: LocalPromocodes.promocodes.entries.toList().last.key,
              context: context);
        });
  }
}
