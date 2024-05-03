import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/models/store/cars_model.dart';
import 'package:new_mini_casino/models/store/houses_model.dart';
import 'package:new_mini_casino/models/store/pins_model.dart';
import 'package:new_mini_casino/services/ad_service.dart';
import 'package:new_mini_casino/widgets/no_internet_connection_dialog.dart';
import 'package:provider/provider.dart';

enum StoreViewer { my, otherUser, deafult }

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
  List<StoreItemModel> models;

  StoreItemButtonModel(
      {required this.title,
      required this.pathTitle,
      required this.icon,
      required this.buttonColor,
      required this.models,
      this.isSoon = false});
}

class StoreManager extends ChangeNotifier {
  bool isLoading = false;

  static StoreViewer storeViewer = StoreViewer.deafult;

  static String otherUserId = '';

  int selectedStore = 0;
  int selectedProduct = 0;
  String selectedPath = '';

  double storeScrollOffset = 0.0;
  static double scrollOffset = 0.0;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  List<StoreItemButtonModel> stores = [
    StoreItemButtonModel(
        title: 'Автомобили',
        pathTitle: 'cars',
        models: carModels,
        icon: FontAwesomeIcons.car,
        buttonColor: Colors.blueAccent),
    StoreItemButtonModel(
        title: 'Пины',
        pathTitle: 'pins',
        models: pinModels,
        icon: FontAwesomeIcons.icons,
        buttonColor: Colors.purpleAccent),
    StoreItemButtonModel(
        title: 'Дома',
        pathTitle: 'houses',
        models: housesModels,
        icon: FontAwesomeIcons.house,
        buttonColor: Colors.brown),
  ];

  void selectStore({required int id, required String path}) {
    selectedStore = id;
    selectedPath = path;
  }

  void selectStoreProduct(int id) => selectedProduct = id;

  Future buyProduct(
      {required BuildContext context,
      required String itemName,
      required int itemid,
      required double price}) async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        showBadInternetConnectionDialog(context);
        return;
      }
    });

    final balance = Provider.of<Balance>(context, listen: false);

    double realPrice = SupabaseController.isPremium &&
            stores[selectedStore].models[selectedProduct].premium
        ? price - (price * 20 / 100)
        : price;

    if (balance.currentBalance < realPrice) {
      alertDialogError(
        context: context,
        title: 'Ошибка',
        confirmBtnText: 'Окей',
        text: 'Недостаточно средст на балансе!',
      );
      return;
    }

    showLoading(true);

    balance.subtractMoney(realPrice);

    /* await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey(selectedPath)) {
        List list = value.get(selectedPath) as List;
        list.add(itemid);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({selectedPath: list});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          selectedPath: [itemid]
        });
      }
    });*/

    if (context.mounted) {
      alertDialogSuccess(
        context: context,
        title: 'Поздравляем',
        confirmBtnText: 'Спасибо!',
        text: 'Вы успешно приобрели $itemName!',
      );

      AdService.showInterstitialAd(context: context, func: () {}, isBet: false);
    }

    showLoading(false);
  }

  Future sellProduct(
      {required BuildContext context,
      required String itemName,
      required int itemId,
      required double price}) async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        showBadInternetConnectionDialog(context);
        return;
      }
    });

    showLoading(true);

    /* await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey(selectedPath)) {
        List list = value.get(selectedPath) as List;
        list.remove(itemId);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({selectedPath: list}).whenComplete(() {
          Provider.of<Balance>(context, listen: false)
              .cashout(price - (price * 20 / 100));
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get()
            .then((value) async {
          if (value.data()!.containsKey('selected$selectedPath')) {
            if (itemId == value.get('selected$selectedPath') as int) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({'selected$selectedPath': FieldValue.delete()});
            }
          }
        });
      }
    });*/

    // ignore: use_build_context_synchronously
    alertDialogSuccess(
      context: context,
      title: 'Поздравляем',
      confirmBtnText: 'Спасибо!',
      text: 'Вы успешно продали $itemName!',
    );

    // ignore: use_build_context_synchronously
    AdService.showInterstitialAd(context: context, func: () {}, isBet: false);

    showLoading(false);
  }

  Future<bool> checkItemOnMine(
      {required int itemId, required String path}) async {
    bool result = false;

    /*await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      if (value.data()!.containsKey(path)) {
        List list = value.get(path) as List;

        if (list.contains(itemId)) {
          result = true;
        }
      } else {
        result = false;
      }
    });*/

    return result;
  }

  Future<bool> checkItemOnSelected(
      {required int itemId, required String path}) async {
    bool result = false;

    await checkItemOnMine(itemId: itemId, path: path).then((value) async {
      if (!value) {
        result = true;
      } else {
        /* await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get()
            .then((value) async {
          if (value.data()!.containsKey('selected$path')) {
            if (itemId == value.get('selected$path') as int) {
              result = true;
            }
          } else {
            result = false;
          }
        });*/
      }
    });

    return result;
  }

  Future selectItem({required int itemId, required String path}) async {
    showLoading(true);

    /* await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'selected$path': itemId});*/

    showLoading(false);
  }

  Future<List<int>> loadMyItems(String path) async {
    List<int> result = [];

    /* await FirebaseFirestore.instance
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
    });*/

    return result;
  }

  Future<List<int>> loadOtherUserItems(
      {required String userId, required String path}) async {
    List<int> result = [];

    /* await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((value) async {
      if (value.data()!.containsKey(path)) {
        List<int> list = List<int>.from(value.get(path));

        result = list;
      } else {
        result = [];
      }
    });*/

    return result;
  }
}
