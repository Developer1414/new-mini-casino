import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/get_premium_version.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/premium_period_alert.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

import 'package:webview_flutter/webview_flutter.dart';

class PremiumInfo extends StatelessWidget {
  const PremiumInfo({super.key, this.showCloseButton = true});

  final bool showCloseButton;

  String getDaysString(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return "$days ДЕНЬ";
    } else if ((days % 10 >= 2 && days % 10 <= 4) &&
        (days % 100 < 10 || days % 100 >= 20)) {
      return "$days ДНЯ";
    } else {
      return "$days ДНЕЙ";
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();

    return Consumer<Payment>(
      builder: (context, paymentController, _) {
        controller.addListener(() {
          paymentController.changeOffsetScrollController(controller.offset);
        });

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            paymentController.isLoading
                ? loading(context: context, text: paymentController.loadingText)
                : Scaffold(
                    extendBody: true,
                    resizeToAvoidBottomInset: false,
                    bottomNavigationBar: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SupabaseController.isPremium
                            ? Container(
                                height: 66.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 179, 242, 31),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10.0)
                                    ]),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            color: Colors.black87),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                          child: AutoSizeText(
                                            'PREMIUM',
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 22.0,
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5.0),
                                      Expanded(
                                        child: FutureBuilder(
                                            future: NTP.now(),
                                            builder: (context, snapshot) {
                                              return AutoSizeText(
                                                'АКТИВЕН ЕЩЁ ${getDaysString(SupabaseController.expiredSubscriptionDate.difference(snapshot.data ?? DateTime.now()).inDays)}',
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: const Color.fromARGB(
                                                      255, 5, 2, 1),
                                                  fontSize: 22.0,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: buttonModel(
                                  context: context,
                                  color:
                                      const Color.fromARGB(255, 179, 242, 31),
                                  icon: FontAwesomeIcons.crown,
                                  iconColor: const Color.fromARGB(255, 5, 2, 1),
                                  textColor: const Color.fromARGB(255, 5, 2, 1),
                                  buttonName: 'Подключить Premium',
                                  onPressed: () {
                                    periodPremiumAlert(
                                        mainContext: context,
                                        paymentController: paymentController);
                                  },
                                ),
                              ),
                      ],
                    ),
                    appBar: AppBar(
                      toolbarHeight: 76.0,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      title: Opacity(
                        opacity: paymentController.offsetScrollController >=
                                115.0
                            ? 1.0
                            : paymentController.offsetScrollController / 115.0,
                        child: Row(
                          children: [
                            AutoSizeText(
                              'Mini Casino',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: const Color.fromARGB(255, 179, 242, 31),
                                fontSize: 22.0,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: Colors.black87),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              child: AutoSizeText(
                                'PREMIUM',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        !showCloseButton
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: IconButton(
                                    splashRadius: 25.0,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      paymentController
                                          .changeOffsetScrollController(0.0);
                                      Navigator.of(context).pop();
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.xmark,
                                      color: Colors.redAccent,
                                      size: 30.0,
                                    )),
                              ),
                      ],
                    ),
                    body: GlowingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      color: const Color.fromARGB(50, 179, 242, 31),
                      child: SingleChildScrollView(
                        controller: controller,
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            color: Colors.black87),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 15.0),
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
                                    ],
                                  ),
                                  const SizedBox(height: 15.0),
                                  Container(
                                    padding: const EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15.0),
                                      // color: Theme.of(context).cardColor,
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 179, 242, 31),
                                          width: 3.0),
                                    ),
                                    child: AutoSizeText(
                                        'Попробуйте Premium всего за 59 рублей в неделю, 149 руб. в месяц или 1499 руб. в год!',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(fontSize: 12.0)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15.0),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
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
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              179,
                                                              242,
                                                              31))),
                                          const SizedBox(height: 5.0),
                                          Text(
                                              '• Нет рекламы\n• Нет налогов\n• Переводы игрокам без комиссии\n• Максимальная ставка - ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(100000000)}\n• Возможность установить кастомный фон\n• Ежедневные бонусы увеличены в 2 раза\n• Генерация бонусов на сумму до ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(10000)} через каждые 350 ставок\n• Создание промокодов без комиссии\n• Бесплатный бонус до ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(5000)}\n• Доступны игры с пометкой «Premium»\n• Доступны онлайн игры\n• Максимальная сумма рейкбека - ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(300000)}.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    height: 1.4,
                                                  )),
                                        ],
                                      ),
                                      !SupabaseController.isPremium
                                          ? Container()
                                          : Container(
                                              width: 80.0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10.0),
                                              decoration: const BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15.0),
                                                    topRight:
                                                        Radius.circular(12.0),
                                                    bottomRight:
                                                        Radius.circular(5.0),
                                                    topLeft:
                                                        Radius.circular(5.0),
                                                  )),
                                              child: Center(
                                                child: AutoSizeText(
                                                  'Текущий',
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                          fontSize: 12.0,
                                                          color: const Color
                                                              .fromARGB(255,
                                                              179, 242, 31)),
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
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .buttonTheme
                                            .colorScheme!
                                            .surface,
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
                                              '• Есть реклама\n• Переводы игрокам с 60% комиссии\n• Максимальная ставка - ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(1000000)}\n• Погашение кредита на 10% больше\n• Создание промокодов с 60% комиссии\n• Каждая ставка облагается налогом в размере 1% от ставки\n• Бесплатный бонус до ${NumberFormat.currency(locale: ui.Platform.localeName, symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName).currencySymbol).format(800)}\n• Игры с пометкой «Premium» не доступны\n• Онлайн игры не доступны\n• Максимальная сумма рейкбека - ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(50000)}.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    height: 1.4,
                                                  )),
                                        ],
                                      ),
                                      SupabaseController.isPremium
                                          ? Container()
                                          : Container(
                                              width: 80.0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10.0),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .buttonTheme
                                                      .colorScheme!
                                                      .surface,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15.0),
                                                    topRight:
                                                        Radius.circular(12.0),
                                                    bottomRight:
                                                        Radius.circular(5.0),
                                                    topLeft:
                                                        Radius.circular(5.0),
                                                  )),
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
                              const SizedBox(height: 12.0),
                              RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Подключаясь, Вы соглашаетесь с ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(fontSize: 12.0)),
                                    TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          paymentController
                                              .changeOffsetScrollController(
                                                  0.0);

                                          Navigator.of(context)
                                              .pushNamed('/user-agreement');
                                        },
                                      text: 'Пользовательским Соглашением',
                                      style: GoogleFonts.roboto(
                                          textStyle: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        letterSpacing: 0.5,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue,
                                      )),
                                    )
                                  ])),
                              const SizedBox(height: 70.0),
                            ],
                          ),
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
            ConfettiWidget(
              confettiController: confettiController,
              numberOfParticles: 15,
              emissionFrequency: 0.1,
              gravity: 0.1,
              blastDirectionality: BlastDirectionality.explosive,
            ),
          ],
        );
      },
    );
  }
}
