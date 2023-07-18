import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/own_promocode_manager.dart';
import 'package:new_mini_casino/controllers/account_controller.dart';
import 'package:new_mini_casino/models/loading.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class OwnPromocode extends StatelessWidget {
  const OwnPromocode({super.key});

  static TextEditingController promocodeController = TextEditingController();
  static TextEditingController prizeController = TextEditingController();
  static TextEditingController countController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void unfocus() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }

    return GestureDetector(
      onTap: () => unfocus(),
      child: Consumer<OwnPromocodeManager>(
        builder: (context, value, child) {
          return value.isLoading
              ? loading()
              : Scaffold(
                  bottomSheet: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: SizedBox(
                      height: 119.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText(
                                  'Итого',
                                  style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w900),
                                ),
                                AutoSizeText(
                                  NumberFormat.simpleCurrency(
                                          locale: ui.Platform.localeName)
                                      .format(value.totalPrize),
                                  style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 60.0,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                unfocus();

                                if (promocodeController.text.isEmpty ||
                                    prizeController.text.isEmpty) {
                                  return;
                                }

                                value.create(
                                    context: context,
                                    name: promocodeController.text);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor:
                                    const Color.fromARGB(255, 100, 34, 255),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25.0),
                                      topRight: Radius.circular(25.0)),
                                ),
                              ),
                              child: AutoSizeText(
                                'Создать',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20.0,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                            Beamer.of(context).beamBack();
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            color: Colors.black87,
                            size: 30.0,
                          )),
                    ),
                    title: AutoSizeText(
                      'Новый промокод',
                      style: GoogleFonts.roboto(
                          color: Colors.black87,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          controller: promocodeController,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-z A-Z 0-9]'))
                          ],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: 'Название...',
                              hintStyle: GoogleFonts.roboto(
                                  color: Colors.black87.withOpacity(0.5),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  borderSide: BorderSide(
                                      width: 2.5,
                                      color: Colors.black87.withOpacity(0.3))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  borderSide: BorderSide(
                                      width: 2.5,
                                      color: Colors.black87.withOpacity(0.5)))),
                          style: GoogleFonts.roboto(
                              color: Colors.black87.withOpacity(0.7),
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 15.0),
                        TextField(
                          controller: prizeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (prize) {
                            value.prize =
                                double.parse(prize.isEmpty ? '0' : prize);
                            value.onPromocodeChanged();
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ],
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              hintText: 'Приз...',
                              hintStyle: GoogleFonts.roboto(
                                  color: Colors.black87.withOpacity(0.5),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  borderSide: BorderSide(
                                      width: 2.5,
                                      color: Colors.black87.withOpacity(0.3))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  borderSide: BorderSide(
                                      width: 2.5,
                                      color: Colors.black87.withOpacity(0.5)))),
                          style: GoogleFonts.roboto(
                              color: Colors.black87.withOpacity(0.7),
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                                'Кол. активаций: (+${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(50)})',
                                style: GoogleFonts.roboto(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                )),
                            AutoSizeText(
                                value.countActivation.round().toString(),
                                style: GoogleFonts.roboto(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                )),
                          ],
                        ),
                        Slider(
                          value: value.countActivation,
                          max: 50,
                          min: 1,
                          divisions: 49,
                          onChanged: (double v) {
                            value.onCountActivationChanged(v);
                          },
                        ),
                        AccountController.isPremium
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: AutoSizeText(
                                  'Комиссия 50%.\nP.S. в Mini Casino Premium комиссии нет.',
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                      color: Colors.black54,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: AutoSizeText(
                            'Внимание! Свой промокод вы использовать не сможете!',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                                color: Colors.black54,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
