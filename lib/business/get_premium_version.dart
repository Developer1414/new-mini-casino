import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:yookassa_payments_flutter/yookassa_payments_flutter.dart';

class Payment extends ChangeNotifier {
  bool isLoading = false;
  bool isPremium = false;
  bool isOpenURL = false;

  String loadingText = '';
  late Uri uri;

  void showLoading(bool isActive, {String text = ''}) {
    isLoading = isActive;
    loadingText = text;
    notifyListeners();
  }

  void openURL(bool isActive, Uri uri) {
    isOpenURL = isActive;
    this.uri = uri;

    notifyListeners();
  }

  Future getPremium({
    required BuildContext context,
  }) async {
    var clientApplicationKey =
        "live_OTgyMTMyd3WgKx6U_t_xHzTFWmt93Qp1Anns6ZErqWM";
    var amount = Amount(value: 1.0, currency: Currency.rub);
    var shopId = "982132";
    var moneyAuthClientId = "gganqqp7bvspn3g47ehqe2vtnut8hv59";

    var tokenizationModuleInputData = TokenizationModuleInputData(
        clientApplicationKey: clientApplicationKey,
        title: 'Mini Casino Premium',
        subtitle: 'Premium-версия',
        amount: amount,
        savePaymentMethod: SavePaymentMethod.userSelects,
        moneyAuthClientId: moneyAuthClientId,
        shopId: shopId,
        tokenizationSettings: const TokenizationSettings(PaymentMethodTypes([
          PaymentMethod.bankCard,
          PaymentMethod.yooMoney,
          PaymentMethod.sberbank,
        ])));

    var result =
        await YookassaPaymentsFlutter.tokenization(tokenizationModuleInputData);

    if (result is SuccessTokenizationResult) {
      showLoading(true);

      final http.Response response = await http.post(
          Uri.parse('https://api.yookassa.ru/v3/payments'),
          headers: <String, String>{
            'Authorization':
                'Basic ${base64Encode(utf8.encode('982132:live_qKe6dJ9dSnpPJTweNyvQLb5IjAi9PcPyDyKsVMslDHw'))}',
            'Idempotence-Key': DateTime.now().microsecondsSinceEpoch.toString(),
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, dynamic>{
              "payment_token": result.token,
              "amount": {
                "value": amount.value,
                "currency": amount.currency.value
              },
              "capture": true,
              "description": FirebaseAuth.instance.currentUser!.email,
              "receipt": {
                "customer": {"email": FirebaseAuth.instance.currentUser!.email},
                "items": [
                  {
                    "description": "MC Premium",
                    "quantity": "1",
                    "amount": {
                      "value": amount.value,
                      "currency": amount.currency.value
                    },
                    "vat_code": "1"
                  },
                ]
              },
            },
          ));

      Map<String, dynamic> json = jsonDecode(response.body);

      if (result.paymentMethodType == PaymentMethod.sberbank) {
        showLoading(true,
            text:
                'Вы должны получить push-уведомление от Сбербанка для подтверждения платежа. Если этого не произошло, зайдите в приложение или на сайт Сбербанка и проверьте подтверждение в уведомлениях.');
      } else if (result.paymentMethodType == PaymentMethod.bankCard ||
          result.paymentMethodType == PaymentMethod.yooMoney) {
        if (json['status'] == 'pending') {
          openURL(true, Uri.parse(json['confirmation']['confirmation_url']));
        }
      }

      // ignore: use_build_context_synchronously
      checkPayment(paymentId: json['id'], context: context);
    } else if (result is ErrorTokenizationResult) {
      // ignore: use_build_context_synchronously
      alertDialogError(context: context, title: 'Ошибка', text: result.error);

      showLoading(false);

      TokenizationResult.error(result.error);
      return;
    }
  }

  Future checkPayment(
      {String paymentId = '', required BuildContext context}) async {
    http.Response response;

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      response = await http.get(
          Uri.parse('https://api.yookassa.ru/v3/payments/$paymentId'),
          headers: <String, String>{
            'Authorization':
                'Basic ${base64Encode(utf8.encode('982132:live_qKe6dJ9dSnpPJTweNyvQLb5IjAi9PcPyDyKsVMslDHw'))}',
          });

      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['status'] == 'succeeded') {
          timer.cancel();

          AccountController.isPremium = true;

          openURL(false, Uri());

          DateTime subscriptionDate =
              DateTime.now().add(const Duration(days: 31));

          AccountController.expiredSubscriptionDate = subscriptionDate;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({'premium': subscriptionDate});

          showLoading(false);

          /*await LocalNoticeService().addNotification(
            id: Random().nextInt(100000000) +
                DateTime.now().year +
                DateTime.now().month +
                DateTime.now().day +
                DateTime.now().hour +
                DateTime.now().minute +
                DateTime.now().second +
                DateTime.now().millisecond,
            title: 'Homeworks',
            body: 'systemNotification_RemindAboutSubscriptionEnd'.tr,
            endTime: subscriptionDate
                .subtract(const Duration(hours: 24))
                .millisecondsSinceEpoch,
            channel: 'work-end',
          );*/

          //await UserAccount.checkSubscription();

          /* SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('subscription', subscriptionDate.toString());*/

          //SubcriptionOverview.isLoading.value = false;

          // ignore: use_build_context_synchronously
          alertDialogSuccess(
              context: context,
              title: 'Успех',
              text:
                  'Вы успешно приобрели Premium-версию Mini Casino на месяц!');
        } else if (json['status'] == 'canceled') {
          timer.cancel();

          // ignore: use_build_context_synchronously
          alertDialogError(
              context: context,
              title: 'Ошибка',
              text:
                  'Произошла ошибка! Возможно, у Вас недостаточно денег на балансе!');

          showLoading(false);
        }
      }
    });
  }
}
