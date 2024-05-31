import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';

Widget checkGameMobalBottomSheet({
  required String hash,
  required String check,
  String? coefficient,
  required bool isGameOn,
}) {
  bool isSuccessfullyHashCopied = false;

  return StatefulBuilder(builder: (context, setState) {
    return Container(
      height: 405,
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          )),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      'Проверка игры${coefficient != null ? ' (${coefficient}x)' : ''}',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.xmark,
                          color: Colors.redAccent,
                          size: 30.0,
                        )),
                  ],
                ),
              ),
              const Divider(
                thickness: 2.0,
                color: Colors.white10,
              ),
              const SizedBox(height: 8.0),
              AutoSizeText(
                'Хеш игры:',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12.0),
              smallHelperPanel(
                context: context,
                fontSize: 15.0,
                text: hash,
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    'Проверка:',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  isGameOn
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              isSuccessfullyHashCopied = true;
                            });

                            Clipboard.setData(ClipboardData(text: check));
                          },
                          child: AutoSizeText(
                            isSuccessfullyHashCopied
                                ? 'Скопировано!'
                                : 'Скопировать',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w100,
                                ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 12.0),
              isGameOn
                  ? smallHelperPanel(
                      context: context,
                      fontSize: 15.0,
                      text: 'Проверка не доступна во время игры!',
                    )
                  : Column(
                      children: [
                        smallHelperPanel(
                          context: context,
                          fontSize: 15.0,
                          text: check,
                        ),
                        const SizedBox(height: 24.0),
                        AutoSizeText(
                          'Для проверки найдите в Интернете любой сервис генерации SHA-256 и вставьте туда текст из проверки. Если сгенерированный хэш идентичен хешу игры, то игра была честной!',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                color: Colors.white60,
                                fontWeight: FontWeight.w100,
                              ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  });
}
