import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/profile_model.dart';

class ProfileController extends ChangeNotifier {
  bool isLoading = false;

  static ProfileModel profileModel = ProfileModel();

  static Future<ProfileModel> getUserProfile() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return ProfileModel(nickname: 'null', totalGame: 0);
    }

    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) {
      profileModel = ProfileModel(
          nickname: value.get('name'),
          totalGame: int.parse(value.get('totalGames').toString()));
      return profileModel;
    });
  }
}
