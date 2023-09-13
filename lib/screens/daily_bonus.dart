import 'package:auto_size_text/auto_size_text.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'dart:io' as ui;
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:provider/provider.dart';

class DailyBonus extends StatefulWidget {
  const DailyBonus({super.key});

  @override
  State<DailyBonus> createState() => _DailyBonusState();
}

class _DailyBonusState extends State<DailyBonus> {
  List<FlipCardController> cardControllers =
      List<FlipCardController>.filled(4, FlipCardController());

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      cardControllers[i] = FlipCardController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Consumer<DailyBonusManager>(builder: (context, value, child) {
        return value.isLoading
            ? loading(context: context)
            : Scaffold(
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, bottom: 15.0),
                  child: AutoSizeText(
                      'Размер бонусов зависит от кол. ставок сделанных за день. Бонус рассчитывается так: кол. ставок за день * x2, x3, x5, x10${!AccountController.isPremium ? ' (с Premium в 2 раза больше).' : '.'}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12.0,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .color!
                              .withOpacity(0.4))),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Ежедневный\n',
                          style: Theme.of(context).textTheme.displayLarge,
                          children: [
                            TextSpan(
                              text: 'Бонус',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: AutoSizeText(
                          'Выберите один из бонусов:',
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(fontSize: 15.0),
                        ),
                      ),
                      GridView.custom(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15),
                        childrenDelegate: SliverChildBuilderDelegate(
                            childCount: 4,
                            (context, index) => item(
                                index: index,
                                dailyBonusManager: value,
                                controller: cardControllers[index],
                                context: context,
                                onTap: () {},
                                color: value.colors[index])),
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }

  Widget item({
    required BuildContext context,
    bool isOpened = false,
    required Color color,
    required int index,
    required Function onTap,
    required DailyBonusManager dailyBonusManager,
    required FlipCardController controller,
  }) {
    return FlipCard(
      controller: controller,
      fill: Fill.fillBack,
      direction: FlipDirection.HORIZONTAL,
      side: CardSide.FRONT,
      front: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(15.0),
        color: color,
        child: InkWell(
          onTap: () async {
            controller.toggleCard();
            dailyBonusManager.getBonus(context: context, bonusIndex: index);
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Align(
                  alignment: Alignment.center,
                  child: FaIcon(
                    FontAwesomeIcons.gift,
                    color: Colors.white,
                    size: 120.0,
                  ),

                  /*Image(
                    image: AssetImage('assets/games_logo/$gameLogo.png'),
                    height: 130.0,
                  ),*/
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0)),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5)
                        ])),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Center(
                    child: SizedBox(
                      height: 30.0,
                      child: AutoSizeText(
                        'Бонус',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 15.0)
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      back: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)])),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30.0,
                  child: AutoSizeText(
                    NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
                        .format(dailyBonusManager.dailyCountBets *
                            dailyBonusManager.coefficients[index] *
                            (AccountController.isPremium ? 2 : 1)),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 15.0)
                        ]),
                  ),
                ),
                const SizedBox(height: 5.0),
                SizedBox(
                  height: 30.0,
                  child: AutoSizeText(
                    'x${dailyBonusManager.coefficients[index] * (AccountController.isPremium ? 2 : 1)}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 15.0)
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
