import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:new_mini_casino/controllers/settings_controller.dart';
import 'package:new_mini_casino/widgets/button_model.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/premium_badge.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    int screenWidth = MediaQuery.of(context).size.width.toInt();
    int screenHeight = MediaQuery.of(context).size.height.toInt();

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
                        GlassContainer(
                            width: double.infinity,
                            blur: 8,
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.0),
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 179, 242, 31),
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
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                            color: Colors.orangeAccent,
                                            width: 3.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Text(
                                          'Размер: ${screenWidth}x$screenHeight\nФормат: PNG или JPG\n\nНе ставьте яркие фоны, интерфейс с ним будет сливаться!',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(fontSize: 12.0)),
                                    ),
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
                                  const SizedBox(height: 15.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText('Блюр:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(fontSize: 12.0)),
                                      AutoSizeText(
                                          settingsController
                                              .customBackgroundBlur
                                              .round()
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(fontSize: 12.0)),
                                    ],
                                  ),
                                  Slider(
                                    value:
                                        settingsController.customBackgroundBlur,
                                    max: 10,
                                    min: 0,
                                    divisions: 10,
                                    onChanged: (double value) {
                                      settingsController
                                          .changeCustomBackgroundBlur(value);
                                    },
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 15.0),
                        GlassContainer(
                            width: double.infinity,
                            blur: 8,
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.0),
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
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
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        return InkWell(
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
                                                        color:
                                                            Colors.redAccent)),
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
                                  const SizedBox(height: 15.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText('Блюр:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(fontSize: 12.0)),
                                      AutoSizeText(
                                          settingsController
                                              .defaultBackgroundBlur
                                              .round()
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(fontSize: 12.0)),
                                    ],
                                  ),
                                  Slider(
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
                                ],
                              ),
                            )),
                        const SizedBox(height: 15.0),
                        GlassContainer(
                            height: 60.0,
                            width: double.infinity,
                            blur: 8,
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.0),
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.blueAccent, width: 3.0),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            )),
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
