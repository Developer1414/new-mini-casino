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
              ? loading(context: context)
              : Scaffold(
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: SizedBox(
                      height: 133.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0, bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText('Итого',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                AutoSizeText(
                                    NumberFormat.simpleCurrency(
                                            locale: ui.Platform.localeName)
                                        .format(value.totalPrize),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontSize: 20.0)),
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
                          icon: FaIcon(
                            FontAwesomeIcons.arrowLeft,
                            color:
                                Theme.of(context).appBarTheme.iconTheme!.color,
                            size: Theme.of(context).appBarTheme.iconTheme!.size,
                          )),
                    ),
                    title: AutoSizeText(
                      'Новый промокод',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const Image(
                                image: AssetImage(
                                    'assets/other_images/PromocodeLogo.png'),
                                width: 300.0,
                                height: 200.0),
                            TextField(
                              controller: promocodeController,
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(12),
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                FilteringTextInputFormatter.allow(
                                    RegExp('[a-z 0-9]'))
                              ],
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  hintText: 'Название...',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .color!
                                              .withOpacity(0.5)),
                                  enabledBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .enabledBorder,
                                  focusedBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .focusedBorder),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(fontSize: 20.0),
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
                              /*inputFormatters: [
                                LengthLimitingTextInputFormatter(7),
                              ],*/
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                  hintText: 'Приз...',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .color!
                                              .withOpacity(0.5)),
                                  enabledBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .enabledBorder,
                                  focusedBorder: Theme.of(context)
                                      .inputDecorationTheme
                                      .focusedBorder),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(fontSize: 20.0),
                            ),
                            const SizedBox(height: 15.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText('Кол. активаций:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontSize: 18.0)),
                                AutoSizeText(
                                    value.countActivation.round().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontSize: 20.0)),
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
                            const SizedBox(height: 15.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AutoSizeText('Действителен (в часах):',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontSize: 18.0)),
                                AutoSizeText(
                                    value.existenceHours.round().toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontSize: 20.0)),
                              ],
                            ),
                            Slider(
                              value: value.existenceHours,
                              max: 5,
                              min: 1,
                              divisions: 4,
                              onChanged: (double v) {
                                value.onExistenceHoursChanged(v);
                              },
                            ),
                            AccountController.isPremium
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: AutoSizeText(
                                        'Комиссия 60%.\nP.S. c Premium комиссии нет.',
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: AutoSizeText(
                                  'Внимание:\nСвой промокод вы использовать не сможете!',
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontSize: 12.0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
