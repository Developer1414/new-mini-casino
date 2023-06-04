import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RaffleInfo extends StatelessWidget {
  const RaffleInfo({super.key});

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
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.black87,
                size: 30.0,
              )),
        ),
        title: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.sackDollar,
              color: Colors.black87,
              size: 25.0,
            ),
            const SizedBox(width: 10.0),
            AutoSizeText(
              'Розыгрыш',
              style: GoogleFonts.roboto(
                  color: Colors.black87,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          const Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 30.0),
              child: Image(
                  image: AssetImage('assets/other_images/logo.png'),
                  width: 280.0,
                  height: 280.0)),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Привет! Скоро мы запустим розыгрыш на ',
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                )),
                children: [
                  TextSpan(
                      text: '1000 ₽',
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                        color: Color.fromARGB(255, 252, 41, 71),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ))),
                  TextSpan(
                    text: ', который будет проходить каждый понедельник.',
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    )),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 5.0, bottom: 15.0, left: 15.0, right: 15.0),
            child: Text(
                'Да, Вы всё правильно поняли! Каждую неделю Вы можете испытать удачу и выиграть денежный приз.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ))),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 5.0, bottom: 15.0, left: 15.0, right: 15.0),
            child: Text(
                'P.S. Чем больше игроков, тем больше будет призовой фонд и призовых мест. Скорее расскажи своим друзьям и знакомым об этой игре! 😊',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Divider(
              thickness: 2.0,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 10.0),
            child: Text('Вопросы и ответы:',
                textAlign: TextAlign.left,
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w900,
                ))),
          ),
          helpsText(
              titleQuestion: '1. Как принять участие?',
              content:
                  'Чтобы принять участие, Вы должны сыграть 5000 игр или иметь Premium-подписку. Если один из пунктов Вы выполнили, то читайте все, что написано ниже. Если Вы со всем согласны, нажмите на кнопку «Участвовать».'),
          helpsText(
              titleQuestion:
                  '2. Что произойдёт после нажатия на кнопку «Участвовать»?',
              content:
                  'Ваш баланс спишется до 500 рублей, а так-же, если у Вас было 5000 или больше сыгранных игр, то количество игр спишется до 2000. Если было меньше 5000, то спишется до 0. Далее, читайте пункт 3.'),
          helpsText(
              titleQuestion: '3. Что я должен делать?',
              content:
                  'Просто играйте в различные режимы этой игры в течение недели и увеличивайте свой баланс.'),
          helpsText(
              titleQuestion: '4. Кто может выиграть?',
              content:
                  'Первый игрок в таблице лидеров (отсортированной по «Участники») будет побеждать каждый понедельник ровно в 00:00.'),
          helpsText(
              titleQuestion: '5. Как я могу получить выигрыш?',
              content:
                  'В случае выигрыша Вас попросят отправить название криптовалюты, на которую Вы хотите получить выигрыш (а также ее сеть, если необходимо) и адрес кошелька. Если Вы ошибётесь в адресе или сети, деньги Вам не будут зачислены. Мы зачисляем выигрыши только в эти криптовалюты: Litecoin, Ripple, Tether, TRON. После отправки Вам вашего выигрыша мы уведомим всех в нашем телеграм-канале о том, что Вы выиграли в розыгрыше, а также опубликуем адрес Вашего кошелька, чтобы все могли отследить платеж.'),
          helpsText(
              titleQuestion:
                  '6. Если я выиграл в прошлый понедельник, смогу ли я выиграть в следующий?',
              content:
                  'Нет. Один и тот же игрок не может выиграть дважды подряд. Пожалуйста, не нарушайте это правило. Если мы узнаем, что Вы выиграли второй раз подряд, то Вы не получите денежный приз, а также будете заблокированы и больше никогда не сможете участвовать.',
              isImportant: true),
          helpsText(
              titleQuestion: '7. Как я узнаю что я выиграл?',
              content:
                  '1. Вы всегда можете увидеть свое место в таблице лидеров;\n2. Если в понедельник в 00:00 Вы занимаете первое место в таблице лидеров, то в течение 24 часов с Вами свяжутся по адресу электронной почты указанной при регистрации.',
              isImportant: true),
          helpsText(
              titleQuestion:
                  '8. С какого адреса электронной почты мне напишут?',
              content:
                  'Это наш единственный адрес электронной почты для связи с победителями: mini.casino.cash.prize@gmail.com.',
              isImportant: true),
          helpsText(
              titleQuestion: 'ВНИМАНИЕ!',
              content:
                  'Мы оставляем за собой право изменять/дополнять информацию на этой странице. Советуем перед каждым участием полностью читать всё, что здесь написано!',
              isImportant: true),
          const SizedBox(height: 15.0),
          Container(
            margin:
                const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
            decoration: BoxDecoration(
                color: const Color.fromARGB(80, 42, 171, 238),
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                    color: const Color.fromARGB(255, 42, 171, 238),
                    width: 2.0)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Telegram',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w900,
                      ))),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                        'Подписывайтесь на наш телеграм канал, чтобы не пропускать новости и обновления!',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                          color: Colors.black87.withOpacity(0.7),
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                        ))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: SizedBox(
                      height: 60.0,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!await launchUrl(
                              Uri.parse('https://t.me/mini_casino_info'),
                              mode: LaunchMode.externalNonBrowserApplication)) {
                            throw Exception(
                                'Could not launch ${Uri.parse('https://t.me/mini_casino_info')}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor:
                              const Color.fromARGB(255, 42, 171, 238),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.telegram,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            const SizedBox(width: 10.0),
                            AutoSizeText(
                              'Mini Casino',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Divider(
              thickness: 2.0,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              height: 60.0,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: Colors.orange.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 12.0),
                  child: AutoSizeText(
                    'Участвовать',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
            child: Text(
                'Нажимая на кнопку «Участвовать» Вы соглашаетесь со всем, что написано выше.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                  color: Colors.black87.withOpacity(0.7),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                ))),
          ),
        ],
      ),
    );
  }

  Widget helpsText(
      {required String titleQuestion,
      required String content,
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
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w900,
                ))),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(content,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                    color: Colors.black87.withOpacity(0.7),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ))),
            ),
          ],
        ),
      ),
    );
  }
}
