import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_mini_casino/business/raffle_manager.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RaffleInfo extends StatelessWidget {
  const RaffleInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RaffleManager>(
      builder: (context, raffleManager, child) {
        return raffleManager.isLoading
            ? loading(context: context)
            : Stack(
                alignment: Alignment.topCenter,
                children: [
                  Scaffold(
                    extendBody: true,
                    bottomNavigationBar: !raffleManager.isRaffleStarted ||
                            raffleManager.imAlreadyParticipant
                        ? null
                        : Padding(
                            padding: const EdgeInsets.all(
                              10.0,
                            ),
                            child: ElevatedButton(
                              onPressed: () =>
                                  raffleManager.participate(context),
                              style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor: const Color(0xff5e60ce),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: AutoSizeText(
                                  'Участвовать!',
                                  maxLines: 1,
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                    appBar: AppBar(
                      toolbarHeight: 76.0,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      title: AutoSizeText(
                        'Розыгрыш',
                        maxLines: 1,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: IconButton(
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
                        ),
                      ],
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                margin: const EdgeInsets.only(bottom: 15.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15.0),
                                  // color: Theme.of(context).cardColor,
                                  border: Border.all(
                                      color: Colors.redAccent, width: 3.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10.0),
                                          topLeft: Radius.circular(10.0),
                                        ),
                                        color: Colors.redAccent,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: !raffleManager.isRaffleStarted
                                            ? AutoSizeText(
                                                !raffleManager.isSummarized
                                                    ? 'ПОДВЕДЕНИЕ ИТОГОВ...'
                                                    : 'ПОБЕДИТЕЛИ',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 30.0,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const FaIcon(
                                                    FontAwesomeIcons.gift,
                                                    color: Colors.white,
                                                    size: 45.0,
                                                  ),
                                                  const SizedBox(width: 15.0),
                                                  Column(
                                                    children: [
                                                      AutoSizeText(
                                                        RaffleManager.format(
                                                            raffleManager
                                                                .lastTime),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.roboto(
                                                          color: Colors.white,
                                                          fontSize: 30.0,
                                                          letterSpacing: 0.5,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                      ),
                                                      AutoSizeText(
                                                          'до итогов (по МСК)',
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                  fontSize:
                                                                      12.0,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodySmall!
                                                                      .color!
                                                                      .withOpacity(
                                                                          0.8))),
                                                      const SizedBox(
                                                          height: 5.0),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            !raffleManager.isRaffleStarted &&
                                                    raffleManager.isSummarized
                                                ? 10.0
                                                : 5.0),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              !raffleManager.isRaffleStarted &&
                                                      raffleManager.isSummarized
                                                  ? 10.0
                                                  : 15.0),
                                      child: Column(
                                        children: [
                                          !raffleManager.isRaffleStarted &&
                                                  raffleManager.isSummarized
                                              ? Container()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10.0),
                                                  child: Text(
                                                      'Уважаемые игроки!',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              fontSize: 22.0)),
                                                ),
                                          !raffleManager.isRaffleStarted &&
                                                  raffleManager.isSummarized
                                              ? Column(
                                                  children: [
                                                    for (int i = 0;
                                                        i <
                                                            raffleManager
                                                                .winningUsers
                                                                .length;
                                                        i++)
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: i + 1 ==
                                                                    raffleManager
                                                                        .winningUsers
                                                                        .length
                                                                ? 0.0
                                                                : 10.0),
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Text(
                                                            raffleManager
                                                                    .winningUsers[
                                                                i],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium!
                                                                .copyWith(
                                                                    fontSize:
                                                                        20.0)),
                                                      ),
                                                  ],
                                                )
                                              : Column(
                                                  children: [
                                                    AutoSizeText(
                                                        !raffleManager
                                                                    .isSummarized &&
                                                                !raffleManager
                                                                    .isRaffleStarted
                                                            ? "Пожалуйста, подождите. В данный момент мы подводим итоги. Скоро результаты розыгрыша будут известны!"
                                                            : """Сегодня ваша удача может принести Вам невероятные призы! У нас стартует розыгрыш, в котором будет разыграно несколько ценных мест:\n""",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                fontSize:
                                                                    13.0)),
                                                    !raffleManager
                                                                .isSummarized &&
                                                            !raffleManager
                                                                .isRaffleStarted
                                                        ? Container()
                                                        : Column(
                                                            children: [
                                                              AutoSizeText(
                                                                raffleManager
                                                                    .raffleText,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            13.0),
                                                              ),
                                                              RichText(
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                text: TextSpan(
                                                                  text:
                                                                      '\nТак-же, видео как выбирались победители будет в нашем ',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13.0),
                                                                  children: [
                                                                    TextSpan(
                                                                      recognizer:
                                                                          TapGestureRecognizer()
                                                                            ..onTap =
                                                                                () async {
                                                                              if (!await launchUrl(Uri.parse('https://t.me/mini_casino_info'), mode: LaunchMode.externalNonBrowserApplication)) {
                                                                                throw Exception('Could not launch ${Uri.parse('https://t.me/mini_casino_info')}');
                                                                              }
                                                                            },
                                                                      text:
                                                                          'телеграм канале.',
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                            fontSize:
                                                                                13.0,
                                                                            decorationColor:
                                                                                Colors.blue,
                                                                            decoration:
                                                                                TextDecoration.underline,
                                                                            color:
                                                                                Colors.blue,
                                                                          ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              AutoSizeText(
                                                                  '\nУспейте принять участие до окончания времени!\n\nЖелаем всем удачи!',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          fontSize:
                                                                              13.0)),
                                                            ],
                                                          ),
                                                    const SizedBox(height: 5.0),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              !raffleManager.isRaffleStarted &&
                                      raffleManager.isSummarized
                                  ? Container()
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        border: Border.all(
                                            color: Colors.redAccent,
                                            width: 3.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: raffleManager
                                                        .participateUsers
                                                        .isEmpty
                                                    ? 0.0
                                                    : 10.0),
                                            child: Text(
                                                'Участники (${raffleManager.participateUsers.length})',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(fontSize: 22.0)),
                                          ),
                                          for (int i = 0;
                                              i <
                                                  raffleManager
                                                      .participateUsers.length;
                                              i++)
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom: i + 1 ==
                                                          raffleManager
                                                              .participateUsers
                                                              .length
                                                      ? 0.0
                                                      : 10.0),
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Text(
                                                  raffleManager
                                                      .participateUsers[i],
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                          fontSize: 20.0)),
                                            ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          // Padding(
                          //   padding: const EdgeInsets.all(15.0),
                          //   child: RichText(
                          //     textAlign: TextAlign.center,
                          //     text: TextSpan(
                          //       text:
                          //           'Привет! Мы запустили первый тестовый розыгрыш для 50 участников на реальные ',
                          //       style: Theme.of(context).textTheme.displaySmall,
                          //       children: [
                          //         TextSpan(
                          //             text: '15 USDT (15\$)',
                          //             style: GoogleFonts.roboto(
                          //                 textStyle: const TextStyle(
                          //               color: Color.fromARGB(255, 252, 41, 71),
                          //               fontSize: 18,
                          //               fontWeight: FontWeight.w900,
                          //             ))),
                          //         TextSpan(
                          //           text:
                          //               ', который будет длиться до времени указанном в нашем ',
                          //           style: Theme.of(context).textTheme.displaySmall,
                          //         ),
                          //         TextSpan(
                          //           recognizer: TapGestureRecognizer()
                          //             ..onTap = () async {
                          //               if (!await launchUrl(
                          //                   Uri.parse(
                          //                       'https://t.me/mini_casino_info'),
                          //                   mode: LaunchMode
                          //                       .externalNonBrowserApplication)) {
                          //                 throw Exception(
                          //                     'Could not launch ${Uri.parse('https://t.me/mini_casino_info')}');
                          //               }
                          //             },
                          //           text: 'телеграм канале.',
                          //           style: GoogleFonts.roboto(
                          //               textStyle: const TextStyle(
                          //             fontSize: 18,
                          //             fontWeight: FontWeight.w700,
                          //             color: Colors.blue,
                          //           )),
                          //         )
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       top: 5.0, bottom: 15.0, left: 15.0, right: 15.0),
                          //   child: Text(
                          //     'Да, Вы всё правильно поняли! Просто играя некоторое время Вы можете испытать удачу и выиграть денежный приз.',
                          //     textAlign: TextAlign.center,
                          //     style: Theme.of(context).textTheme.displaySmall,
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       top: 5.0, bottom: 15.0, left: 15.0, right: 15.0),
                          //   child: Text(
                          //     'P.S. Розыгрыш будет считаться начавшимся при достижении минимум 20 участников. Так что скорее расскажи своим друзьям и знакомым об этой игре и розыгрыше! 😊',
                          //     textAlign: TextAlign.center,
                          //     style: Theme.of(context).textTheme.displaySmall,
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                          //   child: Divider(
                          //     thickness: 2.0,
                          //     color: Colors.grey.withOpacity(0.5),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                          //   child: Text(
                          //     'Вопросы и ответы:',
                          //     textAlign: TextAlign.left,
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .displaySmall!
                          //         .copyWith(fontSize: 22.0),
                          //   ),
                          // ),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion: '1. Что нужно для участия?',
                          //     content:
                          //         'Чтобы принять участие, Вы должны иметь Premium-подписку.'),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion:
                          //         '2. Что произойдёт после нажатия на кнопку «Участвовать»?',
                          //     content:
                          //         'Вы будете автоматически добавлены в список участников. А чтобы всё было по-честному, Ваш баланс будет списан до 500 рублей. Далее читайте пункт 3.'),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion: '3. Что я должен делать?',
                          //     content:
                          //         'Просто играйте в различные режимы этой игры.'),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion: '4. Кто может выиграть?',
                          //     content:
                          //         'Победителем станет случайный игрок, выбранный через сервис random.org. (доказательства будут в телеграм-канале в день окончания розыгрыша)'),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion: '5. Как я могу получить выигрыш?',
                          //     content:
                          //         //'В случае выигрыша Вас попросят отправить название криптовалюты, на которую Вы хотите получить выигрыш (а также ее сеть, если необходимо) и адрес кошелька. Если Вы ошибётесь в адресе или сети, деньги Вам не будут зачислены. Мы зачисляем выигрыши только в эти криптовалюты: Litecoin, Ripple, Tether, TRON. После отправки Вам вашего выигрыша мы уведомим всех в нашем телеграм-канале о том, что Вы выиграли в розыгрыше, а также опубликуем адрес Вашего кошелька, чтобы все могли отследить платеж.'),
                          //         'Если Вы выиграете, Вас попросят прислать адрес Вашего криптокошелька Tether (USDT), туда мы и отправим Ваш выигрыш!'),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion:
                          //         '6. Если я выиграл в прошлый раз, смогу ли я выиграть в следующий?',
                          //     content:
                          //         'Нет. Один и тот же игрок не может выиграть дважды подряд. Пожалуйста, не нарушайте это правило. Если мы узнаем, что Вы выиграли второй раз подряд, то Вы не получите денежный приз, а также будете заблокированы и больше никогда не сможете участвовать.',
                          //     isImportant: true),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion: '7. Как я узнаю что я выиграл?',
                          //     content:
                          //         'В день окончания розыгрыша на нашем телеграм-канале будет опубликовано видео, как выбирается победитель. Если на видео победил Ваш ник, то в течение 24 часов с Вами свяжутся по адресу электронной почты указанной при регистрации. После того, как мы Вам написали, у Вас также будет 24 часа, чтобы ответить нам!',
                          //     isImportant: true),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion:
                          //         '8. С какого адреса электронной почты мне напишут?',
                          //     content:
                          //         'Это наш единственный адрес электронной почты для связи с победителями:\n\nmini.casino.cash.prize@gmail.com.',
                          //     isImportant: true),
                          // helpsText(
                          //     context: context,
                          //     titleQuestion: 'ВНИМАНИЕ!',
                          //     content:
                          //         'Мы оставляем за собой право изменять/дополнять информацию на этой странице. Советуем перед каждым участием полностью читать всё, что здесь написано!',
                          //     isImportant: true),
                          // const SizedBox(height: 15.0),
                          // Container(
                          //   margin: const EdgeInsets.only(
                          //       bottom: 15.0, left: 15.0, right: 15.0),
                          //   decoration: BoxDecoration(
                          //       color: const Color.fromARGB(80, 42, 171, 238),
                          //       borderRadius: BorderRadius.circular(15.0),
                          //       border: Border.all(
                          //           color: const Color.fromARGB(255, 42, 171, 238),
                          //           width: 2.0)),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(15.0),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         Text('Telegram',
                          //             textAlign: TextAlign.left,
                          //             style: Theme.of(context)
                          //                 .textTheme
                          //                 .titleMedium!
                          //                 .copyWith(fontSize: 22.0)),
                          //         Padding(
                          //           padding: const EdgeInsets.only(top: 5.0),
                          //           child: Text(
                          //               'Подписывайтесь на наш телеграм канал, чтобы не пропускать новости и обновления!',
                          //               textAlign: TextAlign.left,
                          //               style: Theme.of(context).textTheme.bodySmall),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.only(top: 15.0),
                          //           child: SizedBox(
                          //             height: 60.0,
                          //             width: double.infinity,
                          //             child: ElevatedButton(
                          //               onPressed: () async {
                          //                 if (!await launchUrl(
                          //                     Uri.parse(
                          //                         'https://t.me/mini_casino_info'),
                          //                     mode: LaunchMode
                          //                         .externalNonBrowserApplication)) {
                          //                   throw Exception(
                          //                       'Could not launch ${Uri.parse('https://t.me/mini_casino_info')}');
                          //                 }
                          //               },
                          //               style: ElevatedButton.styleFrom(
                          //                 elevation: 5,
                          //                 backgroundColor:
                          //                     const Color.fromARGB(255, 42, 171, 238),
                          //                 shape: RoundedRectangleBorder(
                          //                     borderRadius:
                          //                         BorderRadius.circular(15.0)),
                          //               ),
                          //               child: Row(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 children: [
                          //                   const FaIcon(
                          //                     FontAwesomeIcons.telegram,
                          //                     color: Colors.white,
                          //                     size: 30.0,
                          //                   ),
                          //                   const SizedBox(width: 10.0),
                          //                   AutoSizeText(
                          //                     'Mini Casino',
                          //                     textAlign: TextAlign.center,
                          //                     style: GoogleFonts.roboto(
                          //                       color: Colors.white,
                          //                       fontSize: 25.0,
                          //                       fontWeight: FontWeight.w700,
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                          //   child: Divider(
                          //     thickness: 2.0,
                          //     color: Colors.grey.withOpacity(0.5),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.all(15.0),
                          //   child: SizedBox(
                          //     height: 60.0,
                          //     width: double.infinity,
                          //     child: ElevatedButton(
                          //       onPressed: () async {
                          //         await value.participate(context);
                          //       },
                          //       style: ElevatedButton.styleFrom(
                          //         elevation: 5,
                          //         backgroundColor: Colors.green,
                          //         shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(15.0)),
                          //       ),
                          //       child: Padding(
                          //         padding:
                          //             const EdgeInsets.only(left: 10.0, right: 12.0),
                          //         child: AutoSizeText(
                          //           'Участвовать',
                          //           textAlign: TextAlign.center,
                          //           style: GoogleFonts.roboto(
                          //             color: Colors.white,
                          //             fontSize: 25.0,
                          //             fontWeight: FontWeight.w700,
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       bottom: 15.0, left: 15.0, right: 15.0),
                          //   child: Text(
                          //       'Нажимая на кнопку «Участвовать» Вы соглашаетесь со всем, что написано выше.',
                          //       textAlign: TextAlign.center,
                          //       style:
                          //           Theme.of(context).textTheme.bodyMedium!.copyWith(
                          //                 fontSize: 12.0,
                          //                 color: Colors.white.withOpacity(0.7),
                          //               )),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  ConfettiWidget(
                      confettiController: confettiController,
                      numberOfParticles: 15,
                      emissionFrequency: 0.1,
                      gravity: 0.1,
                      blastDirectionality: BlastDirectionality.explosive)
                ],
              );
      },
    );
  }

  Widget helpsText(
      {required String titleQuestion,
      required String content,
      required BuildContext context,
      bool isImportant = false}) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
      decoration: BoxDecoration(
          color: isImportant
              ? Colors.redAccent.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
              color: isImportant ? Colors.redAccent : Colors.orangeAccent,
              width: 2.0)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titleQuestion,
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontSize: 22.0)),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(content,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .color!
                          .withOpacity(0.8))),
            ),
          ],
        ),
      ),
    );
  }
}
