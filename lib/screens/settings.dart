import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/premium_badge.dart';
import 'package:provider/provider.dart';
import 'dart:io' as ui;

class Settings extends StatelessWidget {
  const Settings({super.key});

  static TextEditingController minBetController = TextEditingController();

  static CurrencyTextInputFormatter minBetFormatter =
      CurrencyTextInputFormatter(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  @override
  Widget build(BuildContext context) {
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
            'Настройки',
            maxLines: 1,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          )),
      body: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          return settingsController.isLoading
              ? loading(context: context)
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                                color: const Color.fromARGB(255, 179, 242, 31),
                                width: 3.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  AutoSizeText(
                                    'Кастомный фон',
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .appBarTheme
                                        .titleTextStyle!
                                        .copyWith(fontSize: 20.0),
                                  ),
                                  const SizedBox(width: 10.0),
                                  premiumBadge(),
                                ],
                              ),
                              const SizedBox(height: 15.0),
                              buttonModel(
                                  context: context,
                                  icon: FontAwesomeIcons.image,
                                  buttonName: 'Изменить фон',
                                  color: Colors.deepPurple,
                                  onPressed: () async =>
                                      await settingsController
                                          .setCustomBackground(context)),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  AutoSizeText('Блюр:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 12.0)),
                                  Expanded(
                                    child: Slider(
                                      value: settingsController
                                          .customBackgroundBlur,
                                      max: 10,
                                      min: 0,
                                      divisions: 10,
                                      onChanged: (double value) {
                                        settingsController
                                            .changeCustomBackgroundBlur(value);
                                      },
                                    ),
                                  ),
                                  AutoSizeText(
                                      settingsController.customBackgroundBlur
                                          .round()
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 12.0)),
                                ],
                              ),
                              const SizedBox(height: 5.0),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                        color: Colors.orangeAccent,
                                        width: 2.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                      'Не ставьте яркие фоны, интерфейс с ним будет сливаться!',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 12.0,
                                          )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                                color: Colors.blueAccent, width: 3.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                'Готовые фоны',
                                maxLines: 1,
                                style: Theme.of(context)
                                    .appBarTheme
                                    .titleTextStyle!
                                    .copyWith(fontSize: 20.0),
                              ),
                              const SizedBox(height: 15.0),
                              SizedBox(
                                height: 200.0,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 9,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(10.0),
                                      onTap: () {
                                        settingsController
                                            .setDefaultBackground(index);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: settingsController
                                                            .currentDefaultBackgrond !=
                                                        index ||
                                                    settingsController
                                                        .isCutomBackground
                                                ? null
                                                : Border.all(
                                                    width: 3.0,
                                                    color: Colors.redAccent)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            'assets/backgrounds/background_$index.png',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 10.0),
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  AutoSizeText('Блюр:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 12.0)),
                                  Expanded(
                                    child: Slider(
                                      value: settingsController
                                          .defaultBackgroundBlur,
                                      max: 10,
                                      min: 0,
                                      divisions: 10,
                                      onChanged: (double value) {
                                        settingsController
                                            .changeDefaultBackgroundBlur(value);
                                      },
                                    ),
                                  ),
                                  AutoSizeText(
                                      settingsController.defaultBackgroundBlur
                                          .round()
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 12.0)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Container(
                          height: 60.0,
                          width: double.infinity,
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                                color: Colors.blueAccent, width: 3.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText(
                                'Конфетти:',
                                maxLines: 1,
                                style: Theme.of(context)
                                    .appBarTheme
                                    .titleTextStyle!
                                    .copyWith(fontSize: 20.0),
                              ),
                              Switch(
                                value: settingsController.isEnabledConfetti,
                                onChanged: (value) {
                                  settingsController
                                      .changeConfettiSetting(value);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Container(
                          height: 60.0,
                          width: double.infinity,
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                                color: Colors.blueAccent, width: 3.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText(
                                'Мин. ставка:',
                                maxLines: 1,
                                style: Theme.of(context)
                                    .appBarTheme
                                    .titleTextStyle!
                                    .copyWith(fontSize: 20.0),
                              ),
                              const SizedBox(width: 50.0),
                              Expanded(
                                child: TextField(
                                  inputFormatters: [minBetFormatter],
                                  controller: minBetController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  onTapOutside: (event) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  onChanged: (value) {
                                    if (minBetFormatter
                                                .getUnformattedValue()
                                                .toDouble() <=
                                            0.0 ||
                                        minBetController.text.isEmpty) {
                                      settingsController.changeMinimumBet(
                                        value: 100.0,
                                        context: context,
                                      );

                                      return;
                                    }

                                    if (minBetFormatter
                                            .getUnformattedValue()
                                            .toDouble()
                                            .truncate() >
                                        100000000) {
                                      settingsController.changeMinimumBet(
                                        value: 100000000,
                                        context: context,
                                      );
                                    } else {
                                      settingsController.changeMinimumBet(
                                        value: minBetFormatter
                                            .getUnformattedValue()
                                            .toDouble(),
                                        context: context,
                                      );
                                    }
                                  },
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontSize: 15.0),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.only(bottom: 14.0),
                                      hintText: 'Ставка...',
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .color!
                                                  .withOpacity(0.5)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(0.0)),
                                          borderSide: BorderSide(
                                              width: 1.0,
                                              color: Colors.white
                                                  .withOpacity(0.3))),
                                      focusedBorder: UnderlineInputBorder(
                                          borderRadius:
                                              const BorderRadius.all(Radius.circular(0.0)),
                                          borderSide: BorderSide(width: 2.5, color: Colors.white.withOpacity(0.5)))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        buttonModel(
                            context: context,
                            icon: FontAwesomeIcons.rightFromBracket,
                            buttonName: 'Выйти из аккаунта',
                            color: Colors.redAccent,
                            onPressed: () async =>
                                await settingsController.signOut(context)),
                        const SizedBox(height: 15.0),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
