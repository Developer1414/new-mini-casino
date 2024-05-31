import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/services/animated_currency_service.dart';
import 'package:provider/provider.dart';

PreferredSizeWidget gameAppBarWidget({
  required BuildContext context,
  required bool isGameOn,
  bool isShowActions = true,
  IconData? actionButtonIcon,
  List<Widget>? actions,
  required String gameName,
  Function()? onPressed,
  Function()? actionButtonOnPressed,
}) {
  return AppBar(
    toolbarHeight: 76.0,
    elevation: 0,
    backgroundColor: Colors.transparent,
    leading: Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: IconButton(
          splashRadius: 25.0,
          padding: EdgeInsets.zero,
          onPressed: onPressed != null
              ? () => onPressed.call()
              : isGameOn
                  ? null
                  : () {
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
          gameName,
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
    actions: !isShowActions
        ? null
        : actions ??
            [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: IconButton(
                    splashRadius: 25.0,
                    padding: EdgeInsets.zero,
                    onPressed: isGameOn
                        ? null
                        : actionButtonOnPressed != null
                            ? () => actionButtonOnPressed.call()
                            : () => Navigator.of(context).pushNamed(
                                '/game-statistic',
                                arguments: gameName
                                    .toLowerCase()
                                    .replaceAll(' ', '-')),
                    icon: FaIcon(
                      actionButtonIcon ?? FontAwesomeIcons.chartSimple,
                      color: Theme.of(context).appBarTheme.iconTheme!.color,
                      size: Theme.of(context).appBarTheme.iconTheme!.size,
                    )),
              ),
            ],
  );
}
