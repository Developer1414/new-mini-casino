import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/get_premium_version.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/widgets/gift_premium_alert.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:webview_flutter/webview_flutter.dart';

class PremiumInfo extends StatelessWidget {
  const PremiumInfo({super.key, this.showCloseButton = true});

  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return Consumer<Payment>(
      builder: (context, paymentController, _) {
        return Stack(
          children: [
            paymentController.isLoading
                ? loading(context: context, text: paymentController.loadingText)
                : Scaffold(
                    resizeToAvoidBottomInset: false,
                    bottomNavigationBar: AccountController.isPremium
                        ? Container(
                            height: 92.0,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: FutureBuilder(
                                    future: NTP.now(),
                                    builder: (context, snapshot) {
                                      return Column(
                                        children: [
                                          AutoSizeText(
                                            'Подписка активна до ${DateFormat.yMMMMd(ui.Platform.localeName).format(AccountController.expiredSubscriptionDate)}',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium!
                                                        .color!
                                                        .withOpacity(0.8)),
                                          ),
                                          AutoSizeText(
                                            'Осталось дней: ${AccountController.expiredSubscriptionDate.difference(snapshot.data ?? DateTime.now()).inDays}',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium!
                                                        .color!
                                                        .withOpacity(0.8)),
                                          ),
                                        ],
                                      );
                                    }),
                              ),
                            ),
                          )
                        : Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            height: 178.0,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 15.0,
                                  left: 15.0,
                                  right: 15.0,
                                  top: 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      AutoSizeText('Месяц',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!),
                                      const SizedBox(width: 5.0),
                                      CupertinoSwitch(
                                        trackColor: Colors.blueAccent,
                                        value: paymentController
                                            .isYearSubscription,
                                        onChanged: (value) {
                                          paymentController
                                              .chooseSubscriptionDuration(
                                                  value);
                                        },
                                      ),
                                      const SizedBox(width: 5.0),
                                      AutoSizeText('Год',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!),
                                    ],
                                  ),
                                  const SizedBox(height: 6.0),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, bottom: 15.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: SizedBox(
                                            height: 60.0,
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                paymentController
                                                    .premiumForGift('');

                                                paymentController.getPremium(
                                                    context: context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                elevation: 5,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 179, 242, 31),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                              ),
                                              child: AutoSizeText(
                                                'Подключить',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: const Color.fromARGB(
                                                      255, 5, 2, 1),
                                                  fontSize: 25.0,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15.0),
                                        SizedBox(
                                          height: 60.0,
                                          width: 80.0,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                giftPremiumAlert(
                                                    mainContext: context,
                                                    paymentController:
                                                        paymentController);

                                                /*paymentController.getPremium(
                                                    context: context);*/
                                              },
                                              style: ElevatedButton.styleFrom(
                                                elevation: 5,
                                                backgroundColor:
                                                    Colors.redAccent,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                              ),
                                              child: const FaIcon(
                                                FontAwesomeIcons.gift,
                                                color: Colors.white,
                                                size: 30.0,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text:
                                                'Подключаясь, Вы соглашаетесь с ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(fontSize: 12.0)),
                                        TextSpan(
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => context
                                                .beamToNamed('/user-agreement'),
                                          text: 'Пользовательским Соглашением',
                                          style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                            letterSpacing: 0.5,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blue,
                                          )),
                                        )
                                      ])),
                                ],
                              ),
                            ),
                          ),
                    appBar: AppBar(
                      toolbarHeight: 76.0,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      actions: [
                        !showCloseButton
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: IconButton(
                                    splashRadius: 25.0,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Beamer.of(context).beamBack();
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.xmark,
                                      color: Colors.redAccent,
                                      size: 30.0,
                                    )),
                              ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                AutoSizeText('Mini Casino',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(
                                          color: const Color.fromARGB(
                                              255, 179, 242, 31),
                                        )),
                                const SizedBox(width: 5.0),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.black87),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10.0),
                                    child: AutoSizeText(
                                      'PREMIUM',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 35.0,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Text(
                                  'Попробуйте Premium всего за 149 руб. в месяц или 1499 руб. в год!',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .displayMedium!
                                              .color!
                                              .withOpacity(0.8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30.0),

                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 179, 242, 31),
                                      width: 3.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 5.0,
                                        offset: const Offset(0, 3.0),
                                        spreadRadius: 0.5)
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Premium план',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                    color: const Color.fromARGB(
                                                        255, 179, 242, 31))),
                                        const SizedBox(height: 5.0),
                                        Text(
                                            '• Нет рекламы\n• Нет налогов\n• Переводы игрокам без комиссии\n• Максимальная ставка - ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(10000000)}\n• -5% на погашение кредита\n• Ежедневные бонусы увеличены в 2 раза\n• Генерация промокодов на сумму до ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(10000)} через каждые 350 ставок\n• Создание промокодов без комиссии\n• Покупка в магазине с 20% скидкой на некоторое товары\n• Бесплатный бонус до ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(5000)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  height: 1.4,
                                                )),
                                      ],
                                    ),
                                    !AccountController.isPremium
                                        ? Container()
                                        : Container(
                                            width: 80.0,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .buttonTheme
                                                    .colorScheme!
                                                    .background,
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    bottomLeft:
                                                        Radius.circular(15.0),
                                                    topRight:
                                                        Radius.circular(12.0))),
                                            child: Center(
                                              child: AutoSizeText(
                                                'Текущий',
                                                maxLines: 1,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(fontSize: 12.0),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15.0),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .buttonTheme
                                          .colorScheme!
                                          .background,
                                      width: 3.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 5.0,
                                        offset: const Offset(0, 3.0),
                                        spreadRadius: 0.5)
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Бесплатный план',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(height: 5.0),
                                        Text(
                                            '• Есть реклама\n• Переводы игрокам с 60% комиссии\n• Максимальная ставка - ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(1000000)}\n• Погашение кредита на 10% больше\n• Создание промокодов с 60% комиссии\n• Каждая ставка облагается налогом в размере 5% от ставки\n• Бесплатный бонус до ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(800)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  height: 1.4,
                                                )),
                                      ],
                                    ),
                                    AccountController.isPremium
                                        ? Container()
                                        : Container(
                                            width: 80.0,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .buttonTheme
                                                    .colorScheme!
                                                    .background,
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    bottomLeft:
                                                        Radius.circular(15.0),
                                                    topRight:
                                                        Radius.circular(12.0))),
                                            child: Center(
                                              child: AutoSizeText(
                                                'Текущий',
                                                maxLines: 1,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(fontSize: 12.0),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),

                            //Expanded(child: Container())
                          ],
                        ),
                      ),
                    ),
                  ),
            paymentController.isOpenURL
                ? WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setBackgroundColor(const Color(0x00000000))
                      ..setNavigationDelegate(
                        NavigationDelegate(
                          onProgress: (int progress) {
                            // Update loading bar.
                          },
                          onPageStarted: (String url) {},
                          onPageFinished: (String url) {},
                          onWebResourceError: (WebResourceError error) {},
                        ),
                      )
                      ..loadRequest(paymentController.uri))
                : Container(),
          ],
        );
      },
    );
  }
}
