import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/profile_model.dart';

class ProfileController extends ChangeNotifier {
  bool isLoading = false;

  static Future<ProfileModel> getUserProfile() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      return ProfileModel(nickname: value.get('name'));
    });
  }
}
