import 'package:flutter/material.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';

class AccountExceptionController {
  static void showException(
      {required BuildContext context, required String code}) {
    switch (code) {
      case 'invalid-email':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'Адрес электронной почты недействителен!',
          confirmBtnText: 'Окей',
        );
        break;
      case 'user-disabled':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text:
              'Пользователь, соответствующий данному адресу электронной почты, отключен!',
          confirmBtnText: 'Окей',
        );
        break;
      case 'user-not-found':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text:
              'Пользователь, соответствующий данному адресу электронной почты, не найден!',
          confirmBtnText: 'Окей',
        );
        break;
      case 'wrong-password':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'Пароль недействителен для данного адреса электронной почты!',
          confirmBtnText: 'Окей',
        );
        break;
      case 'email-already-in-use':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text:
              'Учетная запись с данным адресом электронной почты уже существует!',
          confirmBtnText: 'Окей',
        );
        break;
      case 'weak-password':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'Пароль недостаточно надежный!',
          confirmBtnText: 'Окей',
        );
        break;
      case 'too-many-requests':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'Слишком много запросов, пожалуйста, попробуйте позже!',
          confirmBtnText: 'Окей',
        );
        break;
      case 'nickname_already_exist':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'Такой никнейм уже существует!',
          confirmBtnText: 'Окей',
        );
        break;
      case 'nickname_too_short':
        alertDialogError(
          context: context,
          title: 'Ошибка',
          text: 'Слишком короткий никнейм. Минимум 4 символа!',
          confirmBtnText: 'Окей',
        );
        break;
    }
  }
}
