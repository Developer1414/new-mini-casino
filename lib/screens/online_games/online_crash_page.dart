import 'dart:io' as ui;
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/online_games_controller.dart';
import 'package:new_mini_casino/controllers/online_games_logic/online_crash_logic.dart';
import 'package:new_mini_casino/controllers/supabase_controller.dart';
import 'package:new_mini_casino/custom_painters/crash_line_custom_painter.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/alert_dialog_model.dart';
import 'package:new_mini_casino/widgets/check_online_game_widget.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:new_mini_casino/widgets/game_bet_count_widget.dart';
import 'package:new_mini_casino/widgets/last_bets_widget.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:new_mini_casino/widgets/small_helper_panel_model.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class OnlineCrashPage extends StatefulWidget {
  const OnlineCrashPage({super.key});

  static TextEditingController targetCoefficient =
      TextEditingController(text: '2.0');

  static TextEditingController chatController = TextEditingController();

  @override
  State<OnlineCrashPage> createState() => _OnlineCrashPageState();
}

class _OnlineCrashPageState extends State<OnlineCrashPage>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  bool showChat = false;
  bool isSuccessfullyHashCopied = false;

  @override
  void initState() {
    super.initState();

    final crashLogic = Provider.of<OnlineCrashLogic>(context, listen: false);

    crashLogic.animationController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _animationController = crashLogic.animationController!;

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
        if (context.mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.stop();
    _animationController.dispose();
  }

  /*

       chatWidget()
                              .animate(
                                target: showChat ? 1 : 0,
                              )
                              .fade(
                                duration: 100.ms,
                                begin: 0.0,
                                end: 1.0,
                              ),

  */

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !context.read<OnlineCrashLogic>().isGameOn,
      child: Consumer<OnlineCrashLogic>(
        builder: (context, crashLogic, child) {
          return crashLogic.isLoading
              ? loading(context: context)
              : Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Scaffold(
                      bottomNavigationBar: !crashLogic.isGameWork
                          ? Container(height: 0.0)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText('Прибыль:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(fontSize: 12.0)),
                                      AutoSizeText(
                                          crashLogic.profit < 1000000
                                              ? NumberFormat.simpleCurrency(
                                                      locale: ui
                                                          .Platform.localeName)
                                                  .format(crashLogic.profit)
                                              : NumberFormat
                                                      .compactSimpleCurrency(
                                                          locale: ui.Platform
                                                              .localeName)
                                                  .format(crashLogic.profit),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(fontSize: 12.0)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: SizedBox(
                                    height: 50.0,
                                    child: TextField(
                                      controller:
                                          OnlineCrashPage.targetCoefficient,
                                      readOnly: crashLogic.isGameOn ||
                                          !crashLogic.isConnected,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onTap: () {
                                        OnlineCrashPage
                                                .targetCoefficient.selection =
                                            TextSelection(
                                                baseOffset: 0,
                                                extentOffset: OnlineCrashPage
                                                    .targetCoefficient
                                                    .text
                                                    .length);
                                      },
                                      onTapOutside: (value) {
                                        if (double.parse(OnlineCrashPage
                                                .targetCoefficient.text) <
                                            1.1) {
                                          OnlineCrashPage
                                              .targetCoefficient.text = '1.1';
                                        }

                                        FocusScope.of(context).unfocus();
                                      },
                                      onSubmitted: (value) {
                                        if (double.parse(value) < 1.1) {
                                          OnlineCrashPage
                                              .targetCoefficient.text = '1.1';
                                        }
                                      },
                                      decoration: InputDecoration(
                                          suffix: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 5.0),
                                            child: Text(
                                              'X',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall!
                                                  .copyWith(fontSize: 20.0),
                                            ),
                                          ),
                                          hintText: 'Целевой коэффициент...',
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall!
                                                      .color!
                                                      .withOpacity(0.5)),
                                          enabledBorder: Theme.of(context)
                                              .inputDecorationTheme
                                              .enabledBorder,
                                          focusedBorder: Theme.of(context)
                                              .inputDecorationTheme
                                              .focusedBorder),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(fontSize: 20.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: gameBetCount(
                                    context: context,
                                    gameLogic: crashLogic,
                                    bet: crashLogic.bet,
                                    isBlockBetPanel: !crashLogic.isGameWork ||
                                        !crashLogic.isConnected ||
                                        crashLogic.isMakedBet,
                                  ),
                                ),
                                const SizedBox(height: 15.0),
                                SizedBox(
                                  height: 60.0,
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5.0)
                                    ], color: Theme.of(context).cardColor),
                                    child: ElevatedButton(
                                      onPressed: crashLogic.isMakedBet &&
                                                  !crashLogic.isGameOn ||
                                              !crashLogic.isConnected ||
                                              crashLogic.isWin ||
                                              crashLogic.isStoppedTimer
                                          ? null
                                          : !crashLogic.isMakedBet &&
                                                      crashLogic.isGameOn ||
                                                  crashLogic.isTakedEarly
                                              ? null
                                              : () async {
                                                  if (crashLogic.isMakedBet) {
                                                    crashLogic.getEarly();
                                                    return;
                                                  }

                                                  if (!crashLogic.isGameOn) {
                                                    if (OnlineCrashPage
                                                            .targetCoefficient
                                                            .text
                                                            .isEmpty ||
                                                        double.parse(OnlineCrashPage
                                                                .targetCoefficient
                                                                .text)
                                                            .isNegative ||
                                                        double.parse(OnlineCrashPage
                                                                .targetCoefficient
                                                                .text) <
                                                            1) {
                                                      return;
                                                    }

                                                    if (double.parse(
                                                            OnlineCrashPage
                                                                .targetCoefficient
                                                                .text) <
                                                        1.1) {
                                                      alertDialogError(
                                                        context: context,
                                                        title: 'Ошибка',
                                                        text:
                                                            'Минимальный коэффициент: 1.1',
                                                        confirmBtnText: 'Окей',
                                                      );

                                                      return;
                                                    }

                                                    if (Provider.of<Balance>(
                                                            context,
                                                            listen: false)
                                                        .isLoading) {
                                                      return;
                                                    }

                                                    crashLogic.startGame(
                                                        context: context,
                                                        targetCoefficient: double
                                                            .parse(OnlineCrashPage
                                                                .targetCoefficient
                                                                .text));
                                                  }
                                                },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor:
                                            crashLogic.isMakedBet &&
                                                    crashLogic.isGameOn
                                                ? Colors.blueAccent
                                                : Colors.green,
                                        shape: const RoundedRectangleBorder(),
                                      ),
                                      child: Provider.of<Balance>(context,
                                                  listen: true)
                                              .isLoading
                                          ? const SizedBox(
                                              width: 30.0,
                                              height: 30.0,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 5.0,
                                                color: Colors.white,
                                                strokeCap: StrokeCap.round,
                                              ),
                                            )
                                          : AutoSizeText(
                                              crashLogic.isMakedBet &&
                                                      crashLogic.isGameOn
                                                  ? 'ЗАБРАТЬ'
                                                  : 'СТАВКА',
                                              maxLines: 1,
                                              style: GoogleFonts.roboto(
                                                  color: crashLogic.isMakedBet &&
                                                          !crashLogic.isGameOn
                                                      ? Colors.white
                                                          .withOpacity(0.4)
                                                      : !crashLogic.isMakedBet &&
                                                                  crashLogic
                                                                      .isGameOn ||
                                                              !crashLogic
                                                                  .isConnected ||
                                                              crashLogic
                                                                  .isTakedEarly ||
                                                              crashLogic
                                                                  .isWin ||
                                                              crashLogic
                                                                  .isStoppedTimer
                                                          ? Colors.white
                                                              .withOpacity(0.4)
                                                          : Colors.white,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      appBar: gameAppBarWidget(
                        context: context,
                        isGameOn: context.watch<OnlineCrashLogic>().isGameOn,
                        isShowActions: crashLogic.isGameWork,
                        onPressed: () => context
                            .read<OnlineCrashLogic>()
                            .disconnect(context),
                        gameName: 'Crash',
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String hash = '';
                                    String check = '';

                                    if (crashLogic.currentGameHash.isEmpty) {
                                      String temp =
                                          '${double.parse(crashLogic.lastCoefficients.last.toString()).toStringAsFixed(2)}_${SupabaseController.supabase!.auth.currentUser!.id}';

                                      hash = generateHash(temp);
                                      check = temp;
                                    } else {
                                      hash = crashLogic.currentGameHash;
                                      check = crashLogic.currentGameCheck;
                                    }

                                    return checkGameMobalBottomSheet(
                                        hash: hash,
                                        check: check,
                                        isGameOn: crashLogic.isGameOn,
                                        coefficient: !crashLogic.isGameOn
                                            ? double.parse(crashLogic
                                                    .lastCoefficients.last
                                                    .toString())
                                                .toStringAsFixed(2)
                                            : null);
                                  },
                                );
                              },
                              child: AutoSizeText(
                                'Проверить игру',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w100,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      body: !crashLogic.isGameWork
                          ? Center(
                              child: smallHelperPanel(
                                  icon: FontAwesomeIcons.triangleExclamation,
                                  context: context,
                                  isCenter: true,
                                  text: 'Игра временно отключена'),
                            )
                          : Screenshot(
                              controller: screenshotController,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0, bottom: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    lastBetsWidget(
                                      context: context,
                                      list: crashLogic.lastCoefficients,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            List<dynamic> value = crashLogic
                                                .lastCoefficients.reversed
                                                .toList();

                                            double minValue = value
                                                .reduce((value, min) =>
                                                    value < min ? value : min)
                                                .toDouble();
                                            double maxValue = value
                                                .reduce((value, max) =>
                                                    value > max ? value : max)
                                                .toDouble();

                                            double coefficient = double.parse(
                                                value[index].toString());

                                            double normalizedCoefficient =
                                                (coefficient - minValue) /
                                                    (maxValue - minValue);

                                            Color? color;

                                            if (normalizedCoefficient <= 0.5) {
                                              color = ColorTween(
                                                begin: Colors.blue,
                                                end: const Color.fromARGB(
                                                    255, 233, 157, 57),
                                              ).lerp(
                                                  normalizedCoefficient * 4.0);
                                            } else {
                                              color = ColorTween(
                                                begin: const Color.fromARGB(
                                                    255, 233, 157, 57),
                                                end: Colors.red,
                                              ).lerp((normalizedCoefficient -
                                                      0.5) *
                                                  2);
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return checkGameMobalBottomSheet(
                                                      hash: generateHash(
                                                          '${coefficient.toStringAsFixed(2)}_${SupabaseController.supabase!.auth.currentUser!.id}'),
                                                      check:
                                                          '${coefficient.toStringAsFixed(2)}_${SupabaseController.supabase!.auth.currentUser!.id}',
                                                      isGameOn: false,
                                                      coefficient: coefficient
                                                          .toStringAsFixed(2),
                                                    );
                                                  },
                                                );
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                margin: EdgeInsets.only(
                                                  top: 5.0,
                                                  bottom: 5.0,
                                                  left: index == 0 ? 5.0 : 0.0,
                                                  right: index + 1 ==
                                                          crashLogic
                                                              .lastCoefficients
                                                              .length
                                                      ? 5.0
                                                      : 0.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  color: color,
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5.0),
                                                    child: AutoSizeText(
                                                      '${coefficient.toStringAsFixed(2)}x',
                                                      style: GoogleFonts.roboto(
                                                        color: Colors.white,
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(width: 5.0),
                                          itemCount: crashLogic
                                              .lastCoefficients.length,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15.0),
                                    Container(
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        color: Colors.grey.shade50
                                            .withOpacity(0.08),
                                        border: Border.all(
                                            color: Colors.grey.shade100
                                                .withOpacity(0.4),
                                            width: 2.0),
                                      ),
                                      child: crashLogic.usersList.isEmpty
                                          ? Center(
                                              child: AutoSizeText(
                                                  'Игроков ещё нет',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleSmall!
                                                                  .color!
                                                                  .withOpacity(
                                                                      0.4))),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: ListView.separated(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index) {
                                                    List<dynamic> value =
                                                        crashLogic
                                                            .usersList.reversed
                                                            .toList();

                                                    return AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 200),
                                                      margin: EdgeInsets.only(
                                                          top: 5.0,
                                                          bottom: 5.0,
                                                          left: index == 0
                                                              ? 5.0
                                                              : 0.0,
                                                          right: index + 1 ==
                                                                  crashLogic
                                                                      .usersList
                                                                      .length
                                                              ? 5.0
                                                              : 0.0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: value[index][
                                                                          'status']
                                                                      .toString() ==
                                                                  'win'
                                                              ? const Color.fromARGB(
                                                                  255,
                                                                  109,
                                                                  250,
                                                                  114)
                                                              : value[index]['status']
                                                                          .toString() ==
                                                                      'loss'
                                                                  ? const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      250,
                                                                      109,
                                                                      109)
                                                                  : Colors
                                                                      .white60,
                                                          width: 2.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        color: Theme.of(context)
                                                            .cardColor,
                                                      ),
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: AutoSizeText(
                                                            '${value[index]['name']}\n${double.parse(value[index]['bet'].toString()) < 100000 ? NumberFormat.simpleCurrency(locale: ui.Platform.localeName).format(value[index]['bet']) : NumberFormat.compactSimpleCurrency(locale: ui.Platform.localeName).format(value[index]['bet'])}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.roboto(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          const SizedBox(
                                                              width: 5.0),
                                                  itemCount: crashLogic
                                                      .usersList.length),
                                            ),
                                    ),
                                    const SizedBox(height: 15.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const FaIcon(
                                                FontAwesomeIcons.coins,
                                                color: Colors.white,
                                                size: 16.0,
                                              ),
                                              const SizedBox(width: 5.0),
                                              AutoSizeText(
                                                NumberFormat.simpleCurrency(
                                                        locale: ui.Platform
                                                            .localeName)
                                                    .format(crashLogic
                                                        .totalBalance),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              AutoSizeText(
                                                crashLogic.usersList.length
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall,
                                              ),
                                              const SizedBox(width: 5.0),
                                              const FaIcon(
                                                FontAwesomeIcons.solidUser,
                                                color: Colors.white,
                                                size: 16.0,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0,
                                                    right: 15.0,
                                                    top: 15.0),
                                                child: CustomPaint(
                                                  painter:
                                                      CrashLineCustomPainter(
                                                    _animation.value,
                                                    color: Colors.redAccent,
                                                  ),
                                                  size: Size.infinite,
                                                ))
                                            .animate(
                                              target:
                                                  crashLogic.isStoppedTimer &&
                                                          crashLogic.isGameOn
                                                      ? 1
                                                      : 0,
                                            )
                                            .blurXY(
                                              delay: 100.ms,
                                              begin: 0.0,
                                              end: 8.0,
                                            ),
                                        crashLogic.isLoading ||
                                                crashLogic.pause > -1 ||
                                                !crashLogic.isConnected
                                            ? crashLogic.pause > -1 &&
                                                    crashLogic.isConnected
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      AnimatedFlipCounter(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          value:
                                                              crashLogic.pause,
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        40.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  )),
                                                      AutoSizeText(
                                                          'Ожидание ставок',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        20.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  )),
                                                    ],
                                                  )
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10.0),
                                                        child:
                                                            const CircularProgressIndicator(
                                                          strokeWidth: 6.0,
                                                          strokeCap:
                                                              StrokeCap.round,
                                                          color: Color.fromARGB(
                                                              255,
                                                              179,
                                                              242,
                                                              31),
                                                        ),
                                                      ),
                                                      AutoSizeText(
                                                          'Подключение...',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        20.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  )),
                                                    ],
                                                  )
                                            : AutoSizeText(
                                                '${crashLogic.currentMultiplier.toStringAsFixed(2)}x',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 60.0,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              )
                                                .animate(
                                                  target: crashLogic
                                                              .userGameStatus !=
                                                          UserGameStatus.nothing
                                                      ? 1
                                                      : 0,
                                                )
                                                .tint(
                                                  color: crashLogic
                                                              .userGameStatus ==
                                                          UserGameStatus.win
                                                      ? Colors.green
                                                      : crashLogic.userGameStatus ==
                                                              UserGameStatus
                                                                  .loss
                                                          ? Colors.redAccent
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .displayLarge!
                                                              .color,
                                                )
                                                .animate(
                                                  target: crashLogic
                                                              .isStoppedTimer &&
                                                          crashLogic.isGameOn
                                                      ? 1
                                                      : 0,
                                                )
                                                .shake()
                                                .scaleXY(
                                                  delay: 100.ms,
                                                  begin: 1.0,
                                                  end: 1.3,
                                                ),
                                      ],
                                    )),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    ConfettiWidget(
                        confettiController: confettiController,
                        blastDirectionality: BlastDirectionality.explosive)
                  ],
                );
        },
      ),
    );
  }

  TextField customTextField() {
    return TextField(
      controller: OnlineCrashPage.chatController,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Сообщение...',
        hintStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Theme.of(context)
                .textTheme
                .displaySmall!
                .color!
                .withOpacity(0.5)),
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
      ),
      style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 20.0),
    );
  }

  Widget chatWidget() {
    OnlineCrashLogic crashLogic =
        Provider.of<OnlineCrashLogic>(context, listen: true);

    List<dynamic> list = crashLogic.chatList.reversed.toList();

    return Container(
      height: 500,
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
                      'Чат',
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    IconButton(
                        splashRadius: 25.0,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            showChat = false;
                          });
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
              const SizedBox(height: 12.0),
              Expanded(
                child: ListView.separated(
                  reverse: true,
                  itemBuilder: (context, index) {
                    return AutoSizeText(list[index],
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 15.0));
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12.0),
                  itemCount: list.length,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: customTextField()),
                  const SizedBox(width: 12.0),
                  SizedBox(
                    height: 55.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              width: 2.0,
                              color: Colors.blueAccent,
                            )),
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.solidPaperPlane,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        if (OnlineCrashPage.chatController.text
                            .trim()
                            .isEmpty) {
                          OnlineCrashPage.chatController.clear();
                          return;
                        }

                        crashLogic.sendNewMessage(
                            OnlineCrashPage.chatController.text);

                        OnlineCrashPage.chatController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
