import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/models/alert_dialog_model.dart';
import 'package:new_mini_casino/screens/premium.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 15.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                alertDialogSuccess(
                    context: context,
                    title: 'Уведомление',
                    confirmBtnText: 'Окей',
                    text:
                        'Для обновления настроек игры, пожалуйста, перезайдите!',
                    onConfirmBtnTap: () => exit(0));
              },
              style: ElevatedButton.styleFrom(
                elevation: 5,
                backgroundColor: Colors.redAccent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: AutoSizeText(
                  'Играть',
                  maxLines: 1,
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        body: PageView(
          controller: pageController,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Добро пожаловать в\n',
                      style: Theme.of(context).textTheme.displayLarge,
                      children: [
                        TextSpan(
                            text: 'Mini Casino!',
                            style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear);
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.arrowRight,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: 30.0,
                        )),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'Здесь Вы можете играть в различные игры, такие как:\n',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 28.0),
                      children: [
                        TextSpan(
                          text:
                              '\n Mines \n Dice \n Coinflip \n Keno \n Fortune Wheel \n Crash\n\n',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontSize: 28.0),
                        ),
                        TextSpan(
                            text: 'Игры будут пополняться с обновлениями.',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: IconButton(
                      splashRadius: 25.0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.linear);
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.arrowRight,
                        color: Theme.of(context).appBarTheme.iconTheme!.color,
                        size: 30.0,
                      )),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.redAccent, width: 2.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ВНИМАНИЕ!',
                            textAlign: TextAlign.left,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontSize: 22.0)),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                              'Желаем Вам удачи в выигрышах в Mini Casino! Однако, мы также хотим напомнить, что игра в казино должна быть развлечением, а не способом заработка денег. Настоящие казино могут быть опасными, поэтому мы не рекомендуем играть на настоящие деньги в казино. В Mini Casino Вы можете получать удовольствие от игры, не рискуя своими финансами. Играйте ответственно и получайте удовольствие от игры в Mini Casino!',
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .color!
                                          .withOpacity(0.7))),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                    splashRadius: 25.0,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linear);
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.arrowRight,
                      color: Theme.of(context).appBarTheme.iconTheme!.color,
                      size: 30.0,
                    )),
              ],
            ),
            const PremiumInfo(showCloseButton: false)
          ],
        ),
      ),
    );
  }
}
