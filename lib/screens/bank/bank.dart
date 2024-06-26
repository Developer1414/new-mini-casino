import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/bonus_manager.dart';
import 'package:new_mini_casino/business/rakeback_manager.dart';
import 'package:new_mini_casino/business/tax_manager.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:provider/provider.dart';

class Bank extends StatelessWidget {
  const Bank({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 76.0,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
                splashRadius: 25.0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Theme.of(context).appBarTheme.iconTheme!.color,
                  size: Theme.of(context).appBarTheme.iconTheme!.size,
                )),
          ),
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.buildingColumns,
                        color: Colors.white,
                        size: 80.0,
                      ),
                      const SizedBox(height: 10.0),
                      AutoSizeText(
                        'Банк',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Column(
                    children: [
                      buttonModel(
                          context: context,
                          icon: FontAwesomeIcons.landmark,
                          buttonName: 'Заплатить налог',
                          color: Theme.of(context).canvasColor,
                          onPressed: () {
                            Provider.of<TaxManager>(context, listen: false)
                                .loadTax();

                            Navigator.of(context).pushNamed('/tax');
                          }),
                      const SizedBox(height: 15.0),
                      buttonModel(
                          context: context,
                          icon: FontAwesomeIcons.moneyBillTransfer,
                          buttonName: 'Перевести игроку',
                          color: Theme.of(context).canvasColor,
                          onPressed: () {
                            Navigator.of(context).pushNamed('/transfer-moneys');
                          }),
                      const SizedBox(height: 15.0),
                      buttonModel(
                          context: context,
                          icon: FontAwesomeIcons.coins,
                          buttonName: 'Получить рейкбек',
                          color: Theme.of(context).canvasColor,
                          onPressed: () {
                            Provider.of<RakebackManager>(context, listen: false)
                                .loadRakeback();

                            Navigator.of(context).pushNamed('/rakeback');
                          }),
                      const SizedBox(height: 15.0),
                      Consumer<BonusManager>(
                        builder: (context, value, child) {
                          return value.isLoadingBonus
                              ? Container(
                                  height: 60.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color:
                                          const Color.fromRGBO(103, 58, 183, 1),
                                      borderRadius: BorderRadius.circular(15.0),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.deepPurple
                                                .withOpacity(0.8),
                                            blurRadius: 5.0)
                                      ]),
                                  child: const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(18.0),
                                      child: SizedBox(
                                        width: 26.0,
                                        height: 26.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : buttonModel(
                                  context: context,
                                  icon: FontAwesomeIcons.rectangleAd,
                                  buttonName: 'Бесплатный бонус',
                                  color:
                                      const Color.fromARGB(255, 147, 31, 242),
                                  onPressed: () {
                                    value.getFreeBonus(context);
                                  });
                        },
                      ),
                      const SizedBox(height: 15.0),
                      buttonModel(
                          context: context,
                          buttonName: 'Покупка игровой валюты',
                          color: const Color.fromARGB(255, 179, 242, 31),
                          textColor: const Color.fromARGB(255, 5, 2, 1),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/purchasing-game-currency');
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
