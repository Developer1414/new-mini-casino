import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';

class GameStatisticController extends ChangeNotifier {
  GameStatisticModel? gameStatisticModel = GameStatisticModel();

  Future loadStatistic({required String gameName}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('games')
        .doc(gameName)
        .get()
        .then((value) {
      if (!value.exists) {
        gameStatisticModel = null;
        return;
      }

      gameStatisticModel = GameStatisticModel(
        totalGames: int.parse(value.get('totalGames').toString()),
        winningsMoneys: double.parse(value.get('winningsMoneys').toString()),
        lossesMoneys: double.parse(value.get('lossesMoneys').toString()),
        maxWin: double.parse(value.get('maxWin').toString()),
        maxLoss: double.parse(value.get('maxLoss').toString()),
      );
    });
  }

  static Future updateGameStatistic(
      {required String gameName,
      bool incrementTotalGames = false,
      required GameStatisticModel gameStatisticModel}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('games')
        .doc(gameName)
        .get()
        .then((value) async {
      if (value.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('games')
            .doc(gameName)
            .update({
          'totalGames': FieldValue.increment(incrementTotalGames ? 1 : 0),
          'winningsMoneys':
              double.parse(value.get('winningsMoneys').toString()) +
                  gameStatisticModel.winningsMoneys,
          'lossesMoneys': double.parse(value.get('lossesMoneys').toString()) +
              gameStatisticModel.lossesMoneys,
          'maxWin': double.parse(value.get('maxWin').toString()) >
                  gameStatisticModel.maxWin
              ? double.parse(value.get('maxWin').toString())
              : gameStatisticModel.maxWin,
          'maxLoss': double.parse(value.get('maxLoss').toString()) >
                  gameStatisticModel.maxLoss
              ? double.parse(value.get('maxLoss').toString())
              : gameStatisticModel.maxLoss,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('games')
            .doc(gameName)
            .set({
          'totalGames': FieldValue.increment(incrementTotalGames ? 1 : 0),
          'winningsMoneys': gameStatisticModel.winningsMoneys,
          'lossesMoneys': gameStatisticModel.lossesMoneys,
          'maxWin': gameStatisticModel.maxWin,
          'maxLoss': gameStatisticModel.maxLoss,
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'totalGames': FieldValue.increment(incrementTotalGames ? 1 : 0)
      });
    });
  }
}
