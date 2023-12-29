import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

Widget importantUserProfileInfo(
    {required BuildContext context,
    required String content,
    required String title}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
            color: Colors.lightBlueAccent.withOpacity(0.7), width: 3.0)),
    child: Column(
      children: [
        AutoSizeText(
          content,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .appBarTheme
              .titleTextStyle!
              .copyWith(fontSize: 25.0),
        ),
        const SizedBox(height: 5.0),
        AutoSizeText(title,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12.0,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .color!
                    .withOpacity(0.7))),
      ],
    ),
  );
}
