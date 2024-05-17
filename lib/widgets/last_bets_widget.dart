import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

Widget lastBetsWidget({
  required Widget child,
  required BuildContext context,
  required List<dynamic> list,
}) {
  return Container(
    height: 40.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.grey.shade50.withOpacity(0.08),
      border:
          Border.all(color: Colors.grey.shade100.withOpacity(0.4), width: 2.0),
    ),
    child: list.isEmpty
        ? Center(
            child: AutoSizeText('Ставок ещё нет',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .color!
                        .withOpacity(0.4))),
          )
        : child,
  );
}
