import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
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

    double prize = Random().nextInt(9001) + 1000;

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
    if (!SupabaseController.isPremium) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    betCount++;

    prefs.setInt('betCountLocalPromocodes', betCount);

    if (betCount < 350) return;

    promocodes.addAll(generatePromocode());

    betCount = 0;

    prefs.setString('myPromocodes', jsonEncode(promocodes));
    prefs.setInt('betCountLocalPromocodes', betCount);
  }
}
