import 'dart:async';

import 'package:flutter/material.dart';
import 'package:new_mini_casino/controllers/profile_controller.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RaffleManager extends ChangeNotifier {
  bool isLoading = false;
  bool isRaffleStarted = false;
  bool isRaffleExist = false;
  bool isSummarized = false;
  bool imAlreadyParticipant = false;

  String raffleText = '';

  List<String> participateUsers = [];
  List<String> winningUsers = [];

  DateTime timeBeforeRaffle = DateTime.now();
  Duration lastTime = const Duration();

  static String format(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0");

  DateTime getCurrentTimeInMoscow() {
    return DateTime.now().toUtc().add(const Duration(hours: 3));
  }

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future checkOnStartedRaffle() async {
    await SupabaseController.supabase!
        .from('raffle')
        .select('*')
        .limit(1)
        .single()
        .then((value) async {
      Map<dynamic, dynamic> map = value;

      timeBeforeRaffle = DateTime.parse(map['dateExpiredRaffle']);
      raffleText = map['raffleText'];

      lastTime = timeBeforeRaffle.difference(getCurrentTimeInMoscow());

      if (lastTime.inMinutes <= 0 &&
          lastTime.inHours <= 0 &&
          lastTime.inDays <= 0 &&
          lastTime.inSeconds <= 0) {
        isRaffleStarted = false;

        await checkOnSummarizing();
      } else {
        isRaffleStarted = true;
        getCurrentRaffleTime();
      }
    });
  }

  Future checkOnSummarizing() async {
    if (isRaffleStarted) return;

    await SupabaseController.supabase!
        .from('raffle')
        .select('*')
        .limit(1)
        .single()
        .then((value) {
      Map<dynamic, dynamic> map = value;

      isSummarized = map['summarizing'] as bool;
      notifyListeners();
    });
  }

  Future checkOnExistRaffle() async {
    final res = await SupabaseController.supabase!.from('raffle').select(
          '*',
          const FetchOptions(
            count: CountOption.exact,
          ),
        );

    int count = res.count;

    isRaffleExist = res.count > 0;
    notifyListeners();

    if (count > 0) {
      await checkOnStartedRaffle();
    }
  }

  void getCurrentRaffleTime() {
    lastTime = timeBeforeRaffle.difference(getCurrentTimeInMoscow());

    Timer.periodic(const Duration(seconds: 1), (timer) {
      lastTime = timeBeforeRaffle.difference(getCurrentTimeInMoscow());

      if (lastTime.inMinutes <= 0 &&
          lastTime.inHours <= 0 &&
          lastTime.inDays <= 0 &&
          lastTime.inSeconds <= 0) {
        isRaffleStarted = false;
        timer.cancel();
      }

      notifyListeners();
    });

    notifyListeners();
  }

  Future loadRaffleDates() async {
    showLoading(true);

    await checkOnStartedRaffle();
    await checkOnParticipate();
    await loadParticipateUsers();
    await loadWinningUsers();

    showLoading(false);
  }

  Future loadParticipateUsers() async {
    participateUsers.clear();

    final list =
        await SupabaseController.supabase!.from('raffle_users').select('*');

    for (int i = 0; i < list.length; i++) {
      participateUsers.add(list[i]['name']);
    }
  }

  Future loadWinningUsers() async {
    if (!isSummarized || isRaffleStarted) return;

    winningUsers.clear();

    final list = await SupabaseController.supabase!
        .from('raffle_users')
        .select('*')
        .eq('winner', true);

    for (int i = 0; i < list.length; i++) {
      winningUsers.add(list[i]['name']);
    }

    confettiController.play();

    notifyListeners();
  }

  Future checkOnParticipate() async {
    final res = await SupabaseController.supabase!
        .from('raffle_users')
        .select(
          'uid',
          const FetchOptions(
            count: CountOption.exact,
          ),
        )
        .eq('uid', SupabaseController.supabase!.auth.currentUser!.id);

    int count = res.count;

    imAlreadyParticipant = count > 0;
  }

  Future participate(BuildContext context) async {
    showLoading(true);

    await SupabaseController.supabase!.from('raffle_users').insert({
      'uid': SupabaseController.supabase!.auth.currentUser!.id,
      'name': ProfileController.profileModel.nickname,
    });

    await loadRaffleDates().whenComplete(() {
      imAlreadyParticipant = true;
      notifyListeners();

      confettiController.play();

      alertDialogSuccess(
          context: context,
          title: 'Успех',
          text: 'Вы успешно стали участником розыгрыша!\n\nЖелаем удачи!');
    });

    showLoading(false);
  }
}
