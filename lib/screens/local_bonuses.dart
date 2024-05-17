import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/business/promocode_manager.dart';
import 'package:new_mini_casino/business/local_bonuse_manager.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'dart:io' as ui;

import 'package:quickalert/widgets/quickalert_dialog.dart';

class LocalBonuses extends StatelessWidget {
  const LocalBonuses({super.key});

  String getBetsString(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return "$days ставка";
    } else if ((days % 10 >= 2 && days % 10 <= 4) &&
        (days % 100 < 10 || days % 100 >= 20)) {
      return "$days ставки";
    } else {
      return "$days ставок";
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, double>> sortedMap =
        LocalPromocodes.promocodes.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Consumer<PromocodeManager>(
      builder: (context, promocodeManager, child) {
        return promocodeManager.isLoading
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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
                        'Мои бонусы',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      Consumer<Balance>(
                        builder: (context, value, _) {
                          return currencyNormalFormat(
                              context: context, moneys: value.currentBalance);
                        },
                      )
                    ],
                  ),
                ),
                body: sortedMap.isEmpty
                    ? Center(
                        child: Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.coins,
                                      color: Colors.white60,
                                      size: 30.0,
                                    ),
                                    const SizedBox(height: 5.0),
                                    AutoSizeText(
                                      'У вас ещё нет бонусов.\nОни будут появляться здесь через каждые 350 ставок если у вас есть Premium подписка.${!SupabaseController.isPremium ? '' : '\n\nДо первого бонуса вам нужно сделать ещё ${getBetsString(350 - LocalPromocodes.betCount)}.'}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 15.0,
                                            letterSpacing: 0.1,
                                            color: Colors.white60,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: smallHelperPanel(
                                context: context,
                                text:
                                    'До следующего бонуса ${getBetsString(350 - LocalPromocodes.betCount)}.'),
                          ),
                          const SizedBox(height: 15.0),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: ListView.separated(
                                  itemBuilder: (ctx, index) {
                                    return Material(
                                      clipBehavior: Clip.antiAlias,
                                      color: Theme.of(ctx).canvasColor,
                                      borderRadius: BorderRadius.circular(15.0),
                                      shadowColor:
                                          Colors.black.withOpacity(0.3),
                                      elevation: 5.0,
                                      child: InkWell(
                                        onTap: () async {
                                          await QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.confirm,
                                              title:
                                                  sortedMap.toList()[index].key,
                                              text:
                                                  'Хотите использовать этот бонус?',
                                              confirmBtnText: 'Да',
                                              cancelBtnText: 'Нет',
                                              confirmBtnColor: Colors.green,
                                              animType: QuickAlertAnimType
                                                  .slideInDown,
                                              onCancelBtnTap: () =>
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop(),
                                              onConfirmBtnTap: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                                promocodeManager
                                                    .useLocalPromocode(
                                                        myPromocode: sortedMap
                                                            .toList()[index]
                                                            .key,
                                                        context: context);
                                              });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: SizedBox(
                                            height: 25.0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                AutoSizeText(
                                                  sortedMap.toList()[index].key,
                                                  style: Theme.of(ctx)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(fontSize: 20.0),
                                                ),
                                                AutoSizeText(
                                                  NumberFormat.simpleCurrency(
                                                          locale: ui.Platform
                                                              .localeName)
                                                      .format(sortedMap
                                                          .toList()[index]
                                                          .value),
                                                  style: Theme.of(ctx)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(fontSize: 20.0),
                                                ),
                                              ],
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
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: smallHelperPanel(
                                context: context,
                                icon: FontAwesomeIcons.circleInfo,
                                text:
                                    'Бонусы хранятся на вашем устройстве. Если вы удалите игру или очистите кеш, данные будут удалены.'),
                          ),
                        ],
                      ),
              );
      },
    );
  }
}
