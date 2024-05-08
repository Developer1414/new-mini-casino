import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/get_premium_version.dart';
import 'package:new_mini_casino/widgets/button_model.dart';

void periodPremiumAlert(
    {required BuildContext mainContext, required Payment paymentController}) {
  void choosePeriod(SubscriptionPeriod period) {
    Navigator.of(mainContext).pop();

    paymentController.chooseSubscriptionDuration(period);

    paymentController.changeOffsetScrollController(0.0);

    paymentController.getPremium(context: mainContext);
  }

  Widget badge(String text) {
    return Transform.translate(
      offset: const Offset(5.0, -5.0),
      child: Container(
        height: 30.0,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: const Color(0xfff207bff),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  spreadRadius: 3.0)
            ]),
        child: Transform.translate(
          offset: const Offset(0, -1.5),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 11.0,
                fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  showDialog(
    context: mainContext,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black.withOpacity(0.2),
              body: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 12.0),
                          child: Stack(
                            alignment: AlignmentDirectional.topEnd,
                            children: [
                              IconButton(
                                  splashRadius: 25.0,
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Navigator.pop(context),
                                  icon: const FaIcon(
                                    FontAwesomeIcons.xmark,
                                    color: Colors.redAccent,
                                    size: 30.0,
                                  )),
                              Column(
                                children: [
                                  const SizedBox(height: 10.0),
                                  Text(
                                    'Выберите период',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  AutoSizeText(
                                    'На какой период Вы хотите приобрести Premium-подписку?',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 20.0),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 60.0,
                                        child: buttonModel(
                                          context: context,
                                          color: const Color.fromRGBO(
                                              0, 159, 183, 1),
                                          buttonName: 'Неделя - 59 руб.',
                                          titleFontSize: 18.0,
                                          onPressed: () => choosePeriod(
                                              SubscriptionPeriod.week),
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                      SizedBox(
                                        height: 60.0,
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            buttonModel(
                                              context: context,
                                              color: Color.fromARGB(255, 240, 190, 96),
                                              buttonName: 'Месяц - 149 руб.',
                                              titleFontSize: 18.0,
                                              onPressed: () => choosePeriod(
                                                  SubscriptionPeriod.month),
                                            ),
                                            badge('Популярно'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                      SizedBox(
                                        height: 60.0,
                                        child: Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            buttonModel(
                                              context: context,
                                              color: const Color.fromRGBO(
                                                  254, 74, 73, 1),
                                              buttonName: 'Год - 1499 руб.',
                                              titleFontSize: 18.0,
                                              onPressed: () => choosePeriod(
                                                  SubscriptionPeriod.year),
                                            ),
                                            badge('Выгодно'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
