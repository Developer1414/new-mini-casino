import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/profile_model.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';

class ProfileController extends ChangeNotifier {
  bool isLoading = false;

  static ProfileModel profileModel = ProfileModel();

  static Future getUserProfile(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return ProfileModel(nickname: 'null', totalGame: 0);
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((value) {
        profileModel = ProfileModel(
          nickname: value.get('name') ?? '',
          totalGame: int.parse(value.get('totalGames').toString()),
          level: value.data()!.containsKey('level')
              ? double.parse(value.get('level').toString())
              : 1.0,
        );
      });
    } on Exception catch (e) {
      // ignore: use_build_context_synchronously
      alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text: '[LoadUserProfileError]: ${e.toString()}');
    }
  }
}
