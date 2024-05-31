import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

Future alertDialogConfirm(
    {required BuildContext context,
    required String title,
    required String text,
    required String confirmBtnText,
    required String cancelBtnText,
    bool canCloseAlert = true,
    QuickAlertType? type,
    required Function onConfirmBtnTap,
    required Function onCancelBtnTap}) async {
  await QuickAlert.show(
      context: context,
      type: type ?? QuickAlertType.confirm,
      barrierDismissible: canCloseAlert,
      disableBackBtn: !canCloseAlert,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText,
      cancelBtnText: cancelBtnText,
      showCancelBtn: true,
      confirmBtnColor: Colors.green,
      animType: QuickAlertAnimType.slideInDown,
      onCancelBtnTap: () => onCancelBtnTap.call(),
      onConfirmBtnTap: () => onConfirmBtnTap.call());
}

Future alertDialogError(
    {required BuildContext context,
    required String title,
    required String text,
    bool canCloseAlert = true,
    String? confirmBtnText,
    Function? onConfirmBtnTap}) async {
  await QuickAlert.show(
      context: context,
      barrierDismissible: canCloseAlert,
      disableBackBtn: !canCloseAlert,
      type: QuickAlertType.error,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText ?? 'Окей',
      confirmBtnColor: Colors.green,
      animType: QuickAlertAnimType.slideInDown,
      onConfirmBtnTap: () =>
          onConfirmBtnTap?.call() ??
          Navigator.of(context, rootNavigator: true).pop());
}

Future alertDialogSuccess(
    {required BuildContext context,
    required String title,
    required String text,
    String? confirmBtnText,
    bool canCloseAlert = true,
    Function? onConfirmBtnTap}) async {
  await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      barrierDismissible: canCloseAlert,
      disableBackBtn: !canCloseAlert,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText ?? 'Окей',
      confirmBtnColor: Colors.green,
      animType: QuickAlertAnimType.slideInDown,
      onConfirmBtnTap: () =>
          onConfirmBtnTap?.call() ??
          Navigator.of(context, rootNavigator: true).pop());
}

Future showErrorAlertNoBalance(BuildContext context) async {
  await alertDialogConfirm(
    context: context,
    title: 'Ошибка',
    text: 'Недостаточно средств на балансе!',
    canCloseAlert: true,
    type: QuickAlertType.error,
    confirmBtnText: 'Купить',
    cancelBtnText: 'Отмена',
    onConfirmBtnTap: () {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushNamed('/purchasing-game-currency');
    },
    onCancelBtnTap: () => Navigator.of(context, rootNavigator: true).pop(),
  );
}
