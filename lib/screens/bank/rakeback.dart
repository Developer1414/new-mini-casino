import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io' as ui;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/rakeback_manager.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';

class Rakeback extends StatelessWidget {
  const Rakeback({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RakebackManager>(
      builder: (context, rakebackManager, child) {
        return rakebackManager.isLoading
            ? loading(context: context)
            : Scaffold(
                appBar: AppBar(
                  toolbarHeight: 76.0,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: FaIcon(
                          FontAwesomeIcons.arrowLeft,
                          color: Theme.of(context).appBarTheme.iconTheme!.color,
                          size: Theme.of(context).appBarTheme.iconTheme!.size,
                        )),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        'Рейкбек',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      Consumer<Balance>(builder: (ctx, balance, _) {
                        return currencyNormalFormat(
                            context: context, moneys: balance.currentBalance);
                      })
                    ],
                  ),
                ),
                bottomNavigationBar: rakebackManager.currentRakeback <= 0.0
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: ElevatedButton(
                          onPressed: () => rakebackManager.getRakeback(context),
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
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: AutoSizeText(
                              'Получить',
                              maxLines: 1,
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        )),
                body: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Theme.of(context).cardColor,
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .buttonTheme
                                              .colorScheme!
                                              .surface,
                                          width: 3.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: AutoSizeText(
                                        NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(rakebackManager
                                                .currentRakeback),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .appBarTheme
                                            .titleTextStyle!
                                            .copyWith(fontSize: 25.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15.0),
                                  smallHelperPanel(
                                    context: context,
                                    icon: FontAwesomeIcons.circleInfo,
                                    text:
                                        'Рейкбек – это возврат комиссии с ваших ставок. Мы берем 1% с каждой ставки и возвращаем их Вам. Максимальная сумма рейкбека: ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(50000)} без Premium и ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(300000)} с Premium!',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
      },
    );
  }
}
