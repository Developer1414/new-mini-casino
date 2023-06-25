import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';

class DailyBonus extends StatelessWidget {
  const DailyBonus({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Consumer<DailyBonusManager>(builder: (context, value, child) {
        return value.isLoading
            ? loading()
            : Scaffold(
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        value.getBonus(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Colors.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0)),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: AutoSizeText(
                          'Забрать',
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
                body: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: 'Ежедневный\n',
                              style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                color: Colors.black87,
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                              )),
                              children: [
                                TextSpan(
                                    text: 'бонус',
                                    style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                    ))),
                              ],
                            ),
                          ),
                          // Expanded(child: Container()),
                          const SizedBox(height: 15.0),
                          FutureBuilder(
                              future: value.showCurrentBonus(),
                              builder: (context, snapshot) {
                                return Text(
                                  '+${snapshot.data}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w700,
                                  )),
                                );
                              }),
                          const SizedBox(height: 15.0),
                          FutureBuilder(
                              future: value.showNextBonus(),
                              builder: (context, snapshot) {
                                return Text(
                                  'Следующий бонус: ${snapshot.data}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                  )),
                                );
                              }),
                          const SizedBox(height: 15.0),
                          !AccountController.isPremium
                              ? Text(
                                  'P.S. В Mini Casino Premium ежедневные бонусы увеличены в 2 раза!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                      textStyle: TextStyle(
                                    color: Colors.black87.withOpacity(0.7),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                  )),
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      }),
    );
  }
}
