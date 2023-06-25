import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/get_premium_version.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
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
                ? loading(text: paymentController.loadingText)
                : Scaffold(
                    resizeToAvoidBottomInset: false,
                    bottomSheet: AccountController.isPremium
                        ? Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: SizedBox(
                              height: 50.0,
                              child: Center(
                                child: Text(
                                  'Подписка активна до ${DateFormat.yMMMMd('ru_RU').format(AccountController.expiredSubscriptionDate)}\nОсталось дней: ${AccountController.expiredSubscriptionDate.difference(DateTime.now()).inDays}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700,
                                  )),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 124.0,
                            margin: const EdgeInsets.only(
                                bottom: 15.0, left: 15.0, right: 15.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, bottom: 15.0),
                                  child: SizedBox(
                                    height: 60.0,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        paymentController.getPremium(
                                            context: context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                      ),
                                      child: AutoSizeText(
                                        'Подключить',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: 'Подключаясь, Вы соглашаетесь с ',
                                        style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        )),
                                      ),
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
                    body: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: 'Mini Casino\n',
                                    style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 50,
                                      fontWeight: FontWeight.w900,
                                    )),
                                    children: [
                                      TextSpan(
                                          text: 'Premium',
                                          style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 40,
                                            fontWeight: FontWeight.w900,
                                          ))),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Text(
                                  'Попробуйте Mini Casino Premium всего за 99 рублей в месяц!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w700,
                                  )),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5.0,
                                      offset: const Offset(0, 3.0),
                                      spreadRadius: 0.5)
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Бесплатный план',
                                        style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w900,
                                        )),
                                      ),
                                      !AccountController.isPremium
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.blueGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.blueGrey
                                                            .withOpacity(0.5),
                                                        blurRadius: 3.0,
                                                        spreadRadius: 0.5)
                                                  ]),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: AutoSizeText(
                                                  'Текущий',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    '• Есть реклама\n• 5 бесплатных бонусов в день\n• Выигрыш в «Бесплатном бонусе» до ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(300)}',
                                    // \n• Участие в розыгрыше только после 5000 игр.
                                    style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5.0,
                                      offset: const Offset(0, 3.0),
                                      spreadRadius: 0.5)
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Premium план',
                                        style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w900,
                                        )),
                                      ),
                                      AccountController.isPremium
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.blueGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.blueGrey
                                                            .withOpacity(0.5),
                                                        blurRadius: 3.0,
                                                        spreadRadius: 0.5)
                                                  ]),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: AutoSizeText(
                                                  'Текущий',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    '• Нет рекламы\n• 10 бесплатных бонусов в день\n• Выигрыш в «Бесплатном бонусе» до ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(1000)}\n• Ежедневные бонусы увеличены в 2 раза.',
                                    // \n• Участие в розыгрыше в любое время
                                    style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    )),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(child: Container())
                        ],
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
