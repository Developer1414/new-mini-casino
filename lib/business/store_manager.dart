import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/models/store/cars_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:provider/provider.dart';

class StoreItemModel {
  String title = '';
  double price = 0.0;
  int imageId = 0;
  bool premium = false;
  Color color = Colors.grey.shade300;

  StoreItemModel(
      {required this.title,
      required this.price,
      this.premium = false,
      required this.imageId,
      required this.color});

  StoreItemModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        price = json['price'],
        premium = json['premium'],
        color = Color(
            int.parse(json['color'].split('(0x')[1].split(')')[0], radix: 16)),
        imageId = json['imageId'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'premium': premium,
        'color': color.toString(),
        'imageId': imageId,
      };
}

class StoreItemButtonModel {
  String title;
  String pathTitle;
  IconData icon;
  Color buttonColor;
  bool isSoon;
  int imagesCount;
  List<StoreItemModel> models;

  StoreItemButtonModel(
      {required this.title,
      required this.pathTitle,
      required this.icon,
      required this.buttonColor,
      required this.imagesCount,
      required this.models,
      this.isSoon = false});
}

class StoreManager extends ChangeNotifier {
  bool isLoading = false;

  static bool showOnlyMyItems = false;

  int selectedStore = 0;
  int selectedProduct = 0;
  String selectedPath = '';

  static double scrollOffset = 0.0;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  List<StoreItemButtonModel> stores = [
    StoreItemButtonModel(
        title: 'Автомобили',
        pathTitle: 'cars',
        imagesCount: 20,
        models: carModels,
        icon: FontAwesomeIcons.car,
        buttonColor: Colors.blueAccent),
    StoreItemButtonModel(
        title: 'Пины (скоро)',
        pathTitle: 'pins',
        imagesCount: 0,
        models: [],
        icon: FontAwesomeIcons.icons,
        buttonColor: Colors.purpleAccent,
        isSoon: true),
  ];

  void selectStore({required int id, required String path}) {
    selectedStore = id;
    selectedPath = path;
  }

  void selectStoreProduct(int id) => selectedProduct = id;

  Future buyProduct(
      {required BuildContext context,
      required String carName,
      required int carId,
      required double price}) async {
    final balance = Provider.of<Balance>(context, listen: false);

    if (balance.currentBalance < price) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Недостаточно средст на балансе!',
      );
      return;
    }

    showLoading(true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey('cars')) {
        List list = value.get('cars') as List;
        list.add(carId);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'cars': list});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'cars': [carId]
        });
      }
    });

    balance.placeBet(price);

    // ignore: use_build_context_synchronously
    alertDialogSuccess(
      context: context,
      title: 'Поздравляем',
      confirmBtnText: 'Спасибо!',
      text: 'Вы успешно приобрели $carName!',
    );

    // ignore: use_build_context_synchronously
    AdService.showInterstitialAd(context: context, func: () {}, isBet: false);

    showLoading(false);
  }

  Future sellProduct(
      {required BuildContext context,
      required String carName,
      required int carId,
      required double price}) async {
    showLoading(true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey('cars')) {
        List list = value.get('cars') as List;
        list.remove(carId);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'cars': list}).whenComplete(() {
          // ignore: use_build_context_synchronously
          Provider.of<Balance>(context, listen: false).cashout(price / 2);
        });
      }
    });

    // ignore: use_build_context_synchronously
    alertDialogSuccess(
      context: context,
      title: 'Поздравляем',
      confirmBtnText: 'Спасибо!',
      text: 'Вы успешно продали $carName!',
    );

    // ignore: use_build_context_synchronously
    AdService.showInterstitialAd(context: context, func: () {}, isBet: false);

    showLoading(false);
  }

  Future<bool> checkCarOnMine(int carId) async {
    bool result = false;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey('cars')) {
        List list = value.get('cars') as List;

        if (list.contains(carId)) {
          result = true;
        }
      } else {
        result = false;
      }
    });

    return result;
  }

  Future<List<int>> loadMyItems(String path) async {
    List<int> result = [];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey(path)) {
        List<int> list = List<int>.from(value.get(path));

        result = list;
      } else {
        result = [];
      }
    });

    return result;
  }
}
