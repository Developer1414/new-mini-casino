import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/screens/online_games/online_slide_page.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

class OnlineSlideLogic extends ChangeNotifier {
  String websocketUrl = //'http://10.0.2.2:9000';
  'https://mini-caino-online-game-slide-f5fb36bfc00a.herokuapp.com';

  bool isGameOn = false;
  bool isMakedBet = false;
  bool isLoading = false;
  bool isGameWork = true;
  bool isConnected = false;
  bool isStoppedTimer = false;
  bool isWaitingBets = true;
  bool isShowWinnerUser = false;

  double totalBalance = 0.0;
  double profit = 0.0;
  double bet = 0.0;

  int pause = 0;
  int currentWinnerIndex = 0;

  List<dynamic> usersList = [];
  List<dynamic> playingUserList = [];

  late Socket socket;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  void changeBet(double value) {
    bet = value;
    notifyListeners();
  }

  void scrollToIndex({
    required int index,
    required BuildContext context,
  }) async {
    if (index >= 0 && index < OnlineSlidePage.elements.length) {
      double itemWidth = 320.0;
      double screenWidth = MediaQuery.of(context).size.width;
      double centerPosition =
          (index * itemWidth) - (screenWidth / 2 - itemWidth / 2);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await OnlineSlidePage.scrollController.animateTo(
          centerPosition,
          duration: const Duration(milliseconds: 5000),
          curve: Curves.easeOutSine,
        );
      });
    }
  }

  void jumpToIndex(BuildContext context) async {
    double itemWidth = 320.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double centerPosition =
        (currentWinnerIndex * itemWidth) - (screenWidth / 2 - itemWidth / 2);

    OnlineSlidePage.scrollController.jumpTo(centerPosition);
  }

  Future disconnect(BuildContext context) async {
    showLoading(true);

    socket.close();

    //OnlineSlidePage.scrollController.dispose();

    isConnected = false;

    Navigator.of(context).pop();

    showLoading(false);
  }

  Future connectToGame() async {
    showLoading(true);

    socket = io(websocketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.connect();

    socket.onConnect((_) async => await onConnect());

    socket.on('gameNotWorking', (data) {
      socket.close();

      isGameOn = false;
      isLoading = false;
      isConnected = false;
      isGameWork = false;

      notifyListeners();
    });

    socket.on('pauseUpdate', (data) => onPause(data));

    socket.on('updateConnectedUsers', (data) => onConnectedUsersUpdate(data));

    socket.on('updatePlayingUserList', (data) => onUpdatePlayingUserList(data));

    socket.on('gameInProgress', (data) => onProgressGameUpdate(data));

    socket.on('showWinnerUser', (_) => onShowWinnerUser());

    socket.on('stoppedTimer', (_) => onStoppedTimer());

    socket.on('targetIndexUpdate',
        (data) => onTargetIndexUpdate(int.parse(data.toString())));

    socket.on('gameEnd', (_) => resetGameSettings());

    socket.on('disconnect', (_) => onDisconnect());

    socket.onConnectError((err) async {
      socket.close();

      if (kDebugMode) {
        print('onConnectError: $err');
      }

      showLoading(false);

      await alertDialogError(
          context: navigatorKey.currentContext!,
          title: 'Ошибка',
          text: 'onConnectError: $err');

      return;
    });

    socket.onError((err) async {
      socket.close();

      if (kDebugMode) {
        print('onError: $err');
      }

      showLoading(false);

      await alertDialogError(
          context: navigatorKey.currentContext!,
          title: 'Ошибка',
          text: 'onError: $err');
    });

    socket.onConnectTimeout((_) {
      socket.connect();

      if (kDebugMode) {
        print('timeout');
      }
    });
  }

  void onShowWinnerUser() {
    isShowWinnerUser = true;

    jumpToIndex(navigatorKey.currentContext!);

    notifyListeners();
  }

  void onTargetIndexUpdate(int winnerIndex) {
    currentWinnerIndex = winnerIndex;

    if (!isShowWinnerUser) {
      scrollToIndex(
        index: winnerIndex,
        context: navigatorKey.currentContext!,
      );
    } else {
      jumpToIndex(navigatorKey.currentContext!);
    }
  }

  void resetGameSettings() {
    isMakedBet = false;
    isStoppedTimer = false;
    isGameWork = true;
    isWaitingBets = true;
    isShowWinnerUser = false;

    profit = 0.0;
    totalBalance = 0.0;

    playingUserList.clear();

    notifyListeners();
  }

  void onConnectedUsersUpdate(dynamic data) {
    usersList = data as List<dynamic>;

    if (usersList.isNotEmpty) {
      for (int i = 0; i < usersList.length; i++) {
        totalBalance = usersList.fold(
            0, (sum, user) => sum + (double.parse(user['bet'].toString())));

        if (usersList[i]['uid'] ==
            SupabaseController.supabase!.auth.currentUser!.id) {
          isMakedBet = true;
        }
      }
    } else {
      isMakedBet = false;
    }

    notifyListeners();
  }

  void onUpdatePlayingUserList(dynamic data) {
    playingUserList = data as List<dynamic>;

    OnlineSlidePage.elements.clear();

    isWaitingBets = playingUserList.isEmpty;

    if (playingUserList.isNotEmpty) {
      for (int i = 0; i < playingUserList.length; i++) {
        OnlineSlidePage.elements.add({
          'name': playingUserList[i]['name'],
          'bet': playingUserList[i]['bet'],
          'winChance': playingUserList[i]['winChance'],
        });
      }
    } else {
      isMakedBet = false;
    }

    notifyListeners();
  }

  void onStoppedTimer() {
    isStoppedTimer = true;
    notifyListeners();
  }

  void onProgressGameUpdate(dynamic data) {
    isGameOn = data as bool;
    notifyListeners();
  }

  Future start() async {
    //resetGameSettings();

    try {
      final response = await http.get(Uri.parse(
        '$websocketUrl/start',
      ));

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Failed to start game: ${response.body}');
          showLoading(false);
        }
      }
    } on Exception catch (e) {
      showLoading(false);

      Navigator.of(navigatorKey.currentContext!).pop();

      await alertDialogError(
          context: navigatorKey.currentContext!,
          title: 'Ошибка',
          text: e.toString());
    }

    showLoading(false);
  }

  Future onConnect() async {
    isConnected = true;

    pause = -1;

    notifyListeners();

    await start();
  }

  void onDisconnect() {
    isConnected = false;
    notifyListeners();
  }

  void onPause(data) {
    pause = int.parse(data['currentPause'].toString());

    isGameOn = pause <= -1;

    notifyListeners();
  }

  void startGame({
    required BuildContext context,
  }) async {
    CommonFunctions.callOnStart(
        context: context,
        bet: bet,
        isSubstractMoneys: false,
        gameName: 'slide',
        callback: () {
          isMakedBet = true;
          notifyListeners();

          socket.emit('bet', {
            'uid': SupabaseController.supabase!.auth.currentUser!.id,
            'name': ProfileController.profileModel.nickname,
            'bet': bet,
          });
        });
  }
}
