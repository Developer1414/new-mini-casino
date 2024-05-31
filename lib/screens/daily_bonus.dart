import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/daily_bonus_manager.dart';
import 'package:provider/provider.dart';
import 'package:scratcher/scratcher.dart';
import 'dart:io' as ui;

class DailyBonus extends StatefulWidget {
  const DailyBonus({super.key});

  @override
  State<DailyBonus> createState() => _DailyBonusState();
}

class _DailyBonusState extends State<DailyBonus> {
  dynamic wheelResult = 0;

  double currentBonus = 0.0;

  @override
  Widget build(BuildContext context) {
    final dailyBonusManager =
        Provider.of<DailyBonusManager>(context, listen: true);

    return PopScope(
      canPop: false,
      child: Consumer<DailyBonusManager>(builder: (context, value, child) {
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(15.0),
            child: AutoSizeText(
              'Сотрите одну из ячеек',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 15.0,
                    letterSpacing: 0.1,
                    color: Colors.white60,
                  ),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        AutoSizeText('Ежедневный',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge),
                        const SizedBox(height: 5.0),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.redAccent),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 15.0),
                            child: AutoSizeText('БОНУС',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontSize: 42.0,
                                    )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30.0),
                    GridView.custom(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15),
                      childrenDelegate: SliverChildBuilderDelegate(
                        childCount: 9,
                        (context, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 100),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Scratcher(
                                key: dailyBonusManager.scratchKeys[index],
                                enabled: dailyBonusManager.choosedIndex == -1
                                    ? true
                                    : dailyBonusManager.choosedIndex == index,
                                brushSize: 20,
                                threshold: 70,
                                color: dailyBonusManager.choosedIndex == -1
                                    ? const Color(0xffe01e37)
                                    : dailyBonusManager.choosedIndex == index
                                        ? const Color(0xffda1e37)
                                        : const Color(0xffa71e34),
                                onChange: (value) {
                                  if (dailyBonusManager.choosedIndex == -1) {
                                    dailyBonusManager.chooseIndex(index);
                                  }
                                },
                                onThreshold: () => dailyBonusManager.getBonus(
                                    context: context,
                                    bonus: dailyBonusManager.bonuses[index]),
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: AutoSizeText(
                                      NumberFormat.simpleCurrency(
                                              locale: ui.Platform.localeName)
                                          .format(
                                              dailyBonusManager.bonuses[index]),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                            fontSize: 15.0,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
