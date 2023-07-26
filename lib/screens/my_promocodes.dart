import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/promocode_manager.dart';
import 'package:new_mini_casino/business/local_promocodes_service.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'dart:io' as ui;

import 'package:quickalert/widgets/quickalert_dialog.dart';

class MyPromocodes extends StatefulWidget {
  const MyPromocodes({super.key});

  @override
  State<MyPromocodes> createState() => _MyPromocodesState();
}

class _MyPromocodesState extends State<MyPromocodes> {
  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, double>> sortedMap =
        LocalPromocodes.promocodes.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      bottomSheet: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
        child: AutoSizeText(
          'Промокоды хранятся на вашем устройстве. Если вы удалите игру или очистите кеш, данные будут удалены.',
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            color: Colors.black87.withOpacity(0.4),
            fontSize: 12.0,
            fontWeight: FontWeight.w700,
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
          'Мои промокоды',
          style: GoogleFonts.roboto(
              color: Colors.black87,
              fontSize: 30.0,
              fontWeight: FontWeight.w900),
        ),
      ),
      body: sortedMap.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: AutoSizeText(
                  'У вас ещё нет промокодов.\nОни будут появляться здесь через каждые 350 ставок если у вас есть Premium подписка.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                      color: Colors.black87.withOpacity(0.4),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700),
                ),
              ),
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15.0),
                    child: InkWell(
                      onTap: () async {
                        await QuickAlert.show(
                            context: context,
                            type: QuickAlertType.confirm,
                            title: sortedMap.toList()[index].key,
                            text: 'Хотите использовать этот промокод?',
                            confirmBtnText: 'Да',
                            cancelBtnText: 'Нет',
                            confirmBtnColor: Colors.green,
                            animType: QuickAlertAnimType.slideInDown,
                            onCancelBtnTap: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .pop(),
                            onConfirmBtnTap: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              PromocodeManager().useLocalPromocode(
                                  myPromocode: sortedMap.toList()[index].key,
                                  context: context);

                              setState(() {});
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          height: 25.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText(
                                sortedMap.toList()[index].key,
                                style: GoogleFonts.roboto(
                                    color: Colors.black87.withOpacity(0.8),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w900),
                              ),
                              AutoSizeText(
                                NumberFormat.simpleCurrency(
                                        locale: ui.Platform.localeName)
                                    .format(sortedMap.toList()[index].value),
                                style: GoogleFonts.roboto(
                                    color: Colors.black87.withOpacity(0.8),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 15.0),
              itemCount: sortedMap.length),
    );
  }
}
