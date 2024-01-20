import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

Widget importantUserProfileInfo(
    {required BuildContext context,
    required String content,
    required String title}) {
  return GlassContainer(
    width: double.infinity,
    blur: 8,
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(10.0),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
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
    ),
  );
}
