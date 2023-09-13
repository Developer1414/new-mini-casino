import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:provider/provider.dart';

class RaffleManager extends ChangeNotifier {
  bool isLoading = false;

  void showLoading(bool isActive) {
    isLoading = isActive;
    notifyListeners();
  }

  Future checkOnStartedRaffle() async {
    await FirebaseFirestore.instance
        .collection('developer')
        .doc('settings')
        .get()
        .then((value) async {
      if (value.get('isRaffleStarted') as bool == false) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({'participant': false});
      }
    });
  }

  Future participate(BuildContext context) async {
    showLoading(true);

    await FirebaseFirestore.instance
        .collection('users')
        .where('participant', isEqualTo: true)
        .get()
        .then((value) async {
      if (value.docs.length >= 50) {
        alertDialogError(
          context: context,
          title: 'Ошибка',
          confirmBtnText: 'Окей',
          text:
              'Количество участников превышено! Попробуйте в следующий раз. Чтобы не пропустить следующий розыгрыш, подписывайтесь на наш телеграм-канал!',
        );

        showLoading(false);
        return;
      } else {
        if (!AccountController.isPremium) {
          // ignore: use_build_context_synchronously
          alertDialogError(
            context: context,
            title: 'Ошибка',
            confirmBtnText: 'Окей',
            text: 'У Вас нет премиум подписки!',
          );

          showLoading(false);
          return;
        }

        await FirebaseFirestore.instance
            .collection('developer')
            .doc('settings')
            .get()
            .then((value) async {
          if (value.get('isRaffleStarted') as bool == false) {
            alertDialogError(
              context: context,
              title: 'Ошибка',
              confirmBtnText: 'Окей',
              text: 'Розыгрыш ещё не начался!',
            );

            showLoading(false);
            return;
          } else {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get()
                .then((value) async {
              if (!value.data()!.containsKey('participant')) return;

              if (value.get('participant') as bool == true) {
                alertDialogError(
                  context: context,
                  title: 'Ошибка',
                  confirmBtnText: 'Окей',
                  text: 'Вы уже участвуете в розыгрыше!',
                );

                showLoading(false);
                return;
              } else {
                Provider.of<Balance>(context, listen: false).cashout(
                    Balance().currentBalance < 500
                        ? 500
                        : -Balance().currentBalance -
                            (Balance().currentBalance - 500));

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .update({'participant': true, 'balance': 500}).then(
                        (value) async {
                  showLoading(false);

                  alertDialogSuccess(
                    context: context,
                    title: 'Поздравляем!',
                    confirmBtnText: 'Спасибо!',
                    text:
                        'Вы успешно приняли участие в розыгрыше! Желаем удачи!',
                  );
                });
              }
            });
          }
        });
      }
    });
  }
}
