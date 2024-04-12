import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

Widget loading({required BuildContext context, String text = ''}) {
  return PopScope(
    canPop: false,
    child: Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40.0,
              height: 40.0,
              child: CircularProgressIndicator(
                strokeWidth: 6.0,
                color: Color.fromARGB(255, 179, 242, 31),
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 3.0),
              child:
                  AutoSizeText(text.isEmpty ? 'Пожалуйста, подождите...' : text,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          )),
            ),
            AutoSizeText('Иногда загрузка может быть дольше обычного',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 12.0,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .color!
                        .withOpacity(0.4))),
          ],
        ),
      ),
    ),
  );
}
