import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/online_games_controller.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

enum UserGameStatus { win, loss, nothing }

class OnlineCrashLogic extends ChangeNotifier {
  String websocketUrl =
      //'http://10.0.2.2:9000';
      'https://mini-caino-online-game-crash-ddacf383e712.herokuapp.com';

  String currentGameHash = '';
  String currentGameCheck = '';

  bool isLoading = false;
  bool isGameOn = false;
  bool isGameWork = true;
  bool isConnected = false;
  bool isMakedBet = false;
  bool isTakedEarly = false;
  bool isStoppedTimer = false;
  bool isWin = false;

  UserGameStatus userGameStatus = UserGameStatus.nothing;

  AnimationController? animationController;

  double maxCoefficient = 0.0;
  double winCoefficient = 1.00;
  double targetCoefficient = 0.0;
  double takedEarlyCoefficient = 0.0;
  double profit = 0.0;
  double bet = 0.0;
  double currentMultiplier = 1.0;
  double totalBalance = 0.0;

  int pause = 1;

  List<dynamic> lastCoefficients = [];
  List<dynamic> chatList = [];
  List<dynamic> usersList = [];

  late Timer timerToConnect = Timer(const Duration(seconds: 1), () {});

  late BuildContext context;

  late StreamSubscription<List<Map<String, dynamic>>> crashGame;

  late Socket socket;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  void changeBet(double value) {
    bet = value;
    notifyListeners();
  }

  Future disconnect(BuildContext context) async {
    showLoading(true);

    socket.close();

    animationController!.stop();

    isConnected = false;

    await crashGame.cancel().whenComplete(() {
      Navigator.of(context).pop();
    });

    showLoading(false);
  }

  Future start() async {
    resetGameSettings();

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
      if (context.mounted) {
        showLoading(false);

        Navigator.of(context).pop();

        await alertDialogError(
            context: context, title: 'Ошибка', text: e.toString());
      }
    }

    showLoading(false);
  }

  void resetGameSettings() {
    isMakedBet = false;
    isTakedEarly = false;
    isStoppedTimer = false;
    isGameWork = true;
    isWin = false;

    userGameStatus = UserGameStatus.nothing;

    profit = 0.0;
    totalBalance = 0.0;
    takedEarlyCoefficient = 0.0;

    if (!animationController!.isDismissed) {
      animationController!
        ..stop()
        ..reset();
    }

    notifyListeners();
  }

  Future connectToGame() async {
    showLoading(true);

    socket = io(websocketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    crashGame = SupabaseController.supabase!
        .from('online_games')
        .stream(primaryKey: ['id'])
        .eq('game_name', 'crash')
        .listen((List<Map<String, dynamic>> data) {
          lastCoefficients = data.first['last_coefficients'] == null
              ? []
              : data.first['last_coefficients'] as List<dynamic>;

          notifyListeners();
        });

    socket.connect();

    socket.onConnect((_) async => await onConnect());

    socket.on('gameNotWorking', (data) {
      crashGame.cancel();
      socket.close();

      isGameOn = false;
      isLoading = false;
      isConnected = false;
      isGameWork = false;

      notifyListeners();
    });

    socket.on('pauseUpdate', (data) => onPause(data));

    socket.on(
        'generatedMultiplierUpdate', (data) => onTargetMultiplierUpdate(data));

    socket.on('chatListUpdate', (data) => onChatListUpdate(data));

    socket.on('multiplierUpdate', (data) => onMultiplierUpdate(data));

    socket.on('updateConnectedUsers', (data) => onConnectedUsersUpdate(data));

    socket.on('gameInProgress', (data) => onProgressGameUpdate(data));

    socket.on('stoppedTimer', (_) => onStoppedTimer());

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

  void onStoppedTimer() {
    isStoppedTimer = true;

    if (!isWin && isMakedBet) {
      userGameStatus = UserGameStatus.loss;
    }

    animationController!.stop();

    notifyListeners();
  }

  void onProgressGameUpdate(dynamic data) {
    isGameOn = data as bool;

    if (isGameOn) {
      animationController!.forward();
    }

    notifyListeners();
  }

  void onConnectedUsersUpdate(dynamic data) {
    usersList = data as List<dynamic>;

    if (usersList.isNotEmpty) {
      for (int i = 0; i < usersList.length; i++) {
        totalBalance = usersList.fold(
            0, (sum, user) => sum + (double.parse(user['bet'].toString())));

        if (usersList[i]['uid'] ==
                SupabaseController.supabase!.auth.currentUser!.id &&
            isGameOn) {
          isMakedBet = true;

          if (usersList[i]['status'].toString() == 'win') {
            isWin = true;
            userGameStatus = UserGameStatus.win;
          }
        }
      }
    } else {
      isMakedBet = false;
    }

    notifyListeners();
  }

  void onChatListUpdate(dynamic data) {
    chatList = data as List<dynamic>;
    notifyListeners();
  }

  void onTargetMultiplierUpdate(dynamic data) {
    String value =
        '${data}_${SupabaseController.supabase!.auth.currentUser!.id}';

    currentGameCheck = value;
    currentGameHash = generateHash(value);

    notifyListeners();
  }

  void onMultiplierUpdate(dynamic data) {
    currentMultiplier = double.parse(data['multiplier'].toString());

    profit = isWin && !isTakedEarly
        ? bet * targetCoefficient
        : isTakedEarly
            ? bet * takedEarlyCoefficient
            : bet * currentMultiplier;

    notifyListeners();
  }

  void onPause(dynamic data) {
    pause = int.parse(data['currentPause'].toString());

    isGameOn = pause <= -1;

    notifyListeners();
  }

  void getEarly() {
    socket.emit('getEarly', {
      'uid': SupabaseController.supabase!.auth.currentUser!.id,
      'bet': bet,
      'name': ProfileController.profileModel.nickname,
      'targetCoefficient': targetCoefficient,
      'status': 'win',
    });

    isTakedEarly = true;
    takedEarlyCoefficient = currentMultiplier;
    notifyListeners();
  }

  void sendNewMessage(String message) {
    socket.emit('newChatMessage',
        '${ProfileController.profileModel.nickname}: $message');

    notifyListeners();
  }

  void startGame(
      {required BuildContext context,
      required double targetCoefficient}) async {
    CommonFunctions.callOnStart(
        context: context,
        bet: bet,
        isSubstractMoneys: false,
        gameName: 'crash',
        callback: () {
          this.targetCoefficient = targetCoefficient;
          this.context = context;

          isMakedBet = true;
          notifyListeners();

          socket.emit('bet', {
            'uid': SupabaseController.supabase!.auth.currentUser!.id,
            'bet': bet,
            'name': ProfileController.profileModel.nickname,
            'targetCoefficient': targetCoefficient,
            'status': 'idle',
          });
        });
  }
}
