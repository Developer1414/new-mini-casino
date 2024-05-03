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
    bool barrierDismissible = true,
    QuickAlertType? type,
    required Function onConfirmBtnTap,
    required Function onCancelBtnTap}) async {
  await QuickAlert.show(
      context: context,
      type: type ?? QuickAlertType.confirm,
      barrierDismissible: barrierDismissible,
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
    String? confirmBtnText,
    Function? onConfirmBtnTap}) async {
  await QuickAlert.show(
      context: context,
      barrierDismissible: false,
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
    bool? barrierDismissible,
    Function? onConfirmBtnTap}) async {
  await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      barrierDismissible: barrierDismissible ?? true,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText ?? 'Окей',
      confirmBtnColor: Colors.green,
      animType: QuickAlertAnimType.slideInDown,
      onConfirmBtnTap: () =>
          onConfirmBtnTap?.call() ??
          Navigator.of(context, rootNavigator: true).pop());
}
