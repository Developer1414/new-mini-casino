import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/custom_bet_alert_widget.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

Widget gameBetCount({
  required BuildContext context,
  required dynamic gameLogic,
  required double bet,
  bool isBlockBetPanel = false,
}) {
  isBlockBetPanel = isBlockBetPanel == true
      ? true
      : Provider.of<Balance>(context, listen: true).isLoading ||
          gameLogic.isGameOn;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      AutoSizeText(
          'Ставка: ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(gameLogic.bet)}',
          style:
              Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12.0)),
      Opacity(
        opacity: isBlockBetPanel ? 0.5 : 1.0,
        child: IgnorePointer(
          ignoring: isBlockBetPanel,
          child: SizedBox(
            height: 20.0,
            child: Row(
              children: [
                Container(
                  width: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    color:
                        const Color.fromARGB(255, 69, 216, 82).withOpacity(0.3),
                  ),
                  child: IconButton(
                      splashRadius: 20.0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (gameLogic.isGameOn) return;

                        double num = 0.0;

                        if (!SupabaseController.isPremium) {
                          if (gameLogic.bet >= 1000000) {
                            num = gameLogic.bet;

                            alertDialogError(
                              context: context,
                              title: 'Ошибка',
                              confirmBtnText: 'Окей',
                              text:
                                  'Ставки более ${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(1000000)} могут совершать только Premium-подписчики!',
                            );
                          } else {
                            if (gameLogic.bet * 2 > 1000000) {
                              num = gameLogic.bet;
                            } else {
                              num = gameLogic.bet * 2;
                            }
                          }
                        } else {
                          if (gameLogic.bet >= 100000000) {
                            num = gameLogic.bet;

                            alertDialogError(
                              context: context,
                              title: 'Ошибка',
                              confirmBtnText: 'Окей',
                              text:
                                  '${NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(100000000)} - максимальная ставка в игре!',
                            );
                          } else {
                            if (gameLogic.bet * 2 > 100000000) {
                              num = gameLogic.bet;
                            } else {
                              num = gameLogic.bet * 2;
                            }
                          }
                        }

                        gameLogic.changeBet(num);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.xmark,
                        color: Color.fromARGB(255, 69, 216, 82),
                        size: 12.0,
                      )),
                ),
                const SizedBox(width: 5.0),
                Container(
                  width: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    color: Colors.redAccent.withOpacity(0.3),
                  ),
                  child: IconButton(
                      splashRadius: 20.0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (gameLogic.isGameOn) return;

                        double num = gameLogic.bet / 2 < 10.0 ? gameLogic.bet : gameLogic.bet / 2;

                        gameLogic.changeBet(num);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.divide,
                        color: Colors.redAccent,
                        size: 12.0,
                      )),
                ),
                const SizedBox(width: 5.0),
                Container(
                  width: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    color: Colors.orange.withOpacity(0.3),
                  ),
                  child: IconButton(
                      splashRadius: 20.0,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (gameLogic.isGameOn) return;

                        final balance = context.read<Balance>();
                        double result = 0.0;

                        if (!SupabaseController.isPremium) {
                          if (balance.currentBalance.truncate() > 1000000) {
                            result = 1000000;
                          } else {
                            result =
                                balance.currentBalance.truncate().toDouble();
                          }
                        } else {
                          if (balance.currentBalance.truncate() > 100000000) {
                            result = 100000000;
                          } else {
                            result =
                                balance.currentBalance.truncate().toDouble();
                          }
                        }

                        gameLogic.changeBet(result);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.coins,
                        color: Colors.orange,
                        size: 12.0,
                      )),
                ),
                const SizedBox(width: 5.0),
                Container(
                  width: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    color: Colors.blueAccent.withOpacity(0.3),
                  ),
                  child: IconButton(
                      splashRadius: 20.0,
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        if (gameLogic.isGameOn) return;

                        double customBet = await getCustomBet(context);

                        if (customBet >= 10.0) {
                          gameLogic.changeBet(customBet);
                        }
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.pen,
                        color: Colors.blueAccent,
                        size: 12.0,
                      )),
                ),
              ],
            ),
          ),
        ),
      )
    ],
  );
}
