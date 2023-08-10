import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                color: Theme.of(context).appBarTheme.iconTheme!.color,
                size: Theme.of(context).appBarTheme.iconTheme!.size,
              )),
        ),
        title: AutoSizeText(
          'Мои промокоды',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: sortedMap.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: AutoSizeText(
                  'У вас ещё нет промокодов.\nОни будут появляться здесь через каждые 350 ставок если у вас есть Premium подписка.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Material(
                            clipBehavior: Clip.antiAlias,
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.circular(15.0),
                            shadowColor: Colors.black.withOpacity(0.3),
                            elevation: 5.0,
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
                                    onCancelBtnTap: () => Navigator.of(context,
                                            rootNavigator: true)
                                        .pop(),
                                    onConfirmBtnTap: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      PromocodeManager().useLocalPromocode(
                                          myPromocode:
                                              sortedMap.toList()[index].key,
                                          context: context);

                                      setState(() {});
                                    });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: SizedBox(
                                  height: 25.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText(
                                        sortedMap.toList()[index].key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(fontSize: 20.0),
                                      ),
                                      AutoSizeText(
                                        NumberFormat.simpleCurrency(
                                                locale: ui.Platform.localeName)
                                            .format(sortedMap
                                                .toList()[index]
                                                .value),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(fontSize: 20.0),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: AutoSizeText(
                      'Промокоды хранятся на вашем устройстве. Если вы удалите игру или очистите кеш, данные будут удалены.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12.0,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .color!
                              .withOpacity(0.4))),
                ),
              ],
            ),
    );
  }
}
