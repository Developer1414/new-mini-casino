import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesHelper {
  static Future<bool> saveData(
      {required String key, required Map<String, dynamic> data}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(data);
    return prefs.setString(key, jsonString);
  }

  static Future<Map<String, dynamic>?> loadData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString);
    }
    return null;
  }
}

class GameStatisticController extends ChangeNotifier {
  GameStatisticModel? gameStatisticModel = GameStatisticModel();

  Future loadStatistic(String gameName) async {
    SharedPreferencesHelper.loadData(gameName).then((loadedData) {
      if (loadedData != null) {
        gameStatisticModel = GameStatisticModel(
          totalGames: int.parse(loadedData['totalGames'].toString()),
          winGamesCount: int.parse(loadedData['winGamesCount'].toString()),
          winningsMoneys: double.parse(loadedData['winningsMoneys'].toString()),
          lossesMoneys: double.parse(loadedData['lossesMoneys'].toString()),
          maxWin: double.parse(loadedData['maxWin'].toString()),
          maxLoss: double.parse(loadedData['maxLoss'].toString()),
        );
      } else {
        gameStatisticModel = null;
        return;
      }
    });
  }

  static Future updateGameStatistic(
      {required String gameName,
      bool incrementTotalGames = false,
      required GameStatisticModel gameStatisticModel}) async {
    GameStatisticModel lastStat = GameStatisticModel();

    await SharedPreferencesHelper.loadData(gameName).then((loadedData) {
      if (loadedData != null) {
        lastStat = GameStatisticModel(
          totalGames: int.parse(loadedData['totalGames'].toString()),
          winGamesCount: int.parse(loadedData['winGamesCount'].toString()),
          winningsMoneys: double.parse(loadedData['winningsMoneys'].toString()),
          lossesMoneys: double.parse(loadedData['lossesMoneys'].toString()),
          maxWin: double.parse(loadedData['maxWin'].toString()),
          maxLoss: double.parse(loadedData['maxLoss'].toString()),
        );
      }

      if (incrementTotalGames) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'totalGames': FieldValue.increment(1)});
      }

      Map<String, dynamic> data = {
        'totalGames':
            incrementTotalGames ? lastStat.totalGames + 1 : lastStat.totalGames,
        'winGamesCount':
            gameStatisticModel.winningsMoneys > gameStatisticModel.lossesMoneys
                ? lastStat.winGamesCount + 1
                : lastStat.winGamesCount,
        'winningsMoneys':
            lastStat.winningsMoneys + gameStatisticModel.winningsMoneys,
        'lossesMoneys': lastStat.lossesMoneys + gameStatisticModel.lossesMoneys,
        'maxWin': lastStat.maxWin > gameStatisticModel.maxWin
            ? lastStat.maxWin
            : gameStatisticModel.maxWin,
        'maxLoss': lastStat.maxLoss > gameStatisticModel.maxLoss
            ? lastStat.maxLoss
            : gameStatisticModel.maxLoss,
      };

      SharedPreferencesHelper.saveData(key: gameName, data: data);
    });
  }
}
