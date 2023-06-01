import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
                text: 'Привет! В течении июня мы запустим разыгрыш на ',
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
                    text: ' который будет проводиться каждый понедельник.',
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
                """Да, Вы всё правильно поняли! Каждую неделю Вы сможете испытать свою удачю и выиграть денежный приз.""",
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
                """P.S. Чем больше будет игроков, тем больше будет призовой фонд и призовых мест. Так что рассказывайте об этой игре своим друзьям и знакомым! 😊""",
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
          helpsText(
              titleQuestion: '1. Как принять участие?',
              content:
                  'Чтобы принять участие, у Вас должно быть сыграно 5000 игр, либо оформлена Premium подписка. Если одно из пунктов у Вас выполнено, то прочитайте всё, что написано ниже. Если Вы со всем согласны, нажмите на кнопку «Участвовать».'),
          helpsText(
              titleQuestion:
                  '2. Что произойдёт после нажатия на кнопку «Участвовать»?',
              content:
                  'Ваш баланс спишется до 500 рублей, а так-же, если у Вас было 5000 или больше сыгранных игр, то количество игр спишется до 2000. Если было меньше 5000, то спишется до 0.'),
          helpsText(
              titleQuestion: '3. Что нужно делать?',
              content:
                  'Просто играйте в разные режимы этой игры в течении недели, и увеличивайте свой баланс.'),
          helpsText(
              titleQuestion: '4. Кто сможет выиграть?',
              content:
                  'Выиграет один игрок находящийся на первом месте в таблице лидеров (отсортированной по балансу) в каждый понедельник ровно в 00:00.'),
          helpsText(
              titleQuestion:
                  '5. Если я выиграл в прошлый понедельник, смогу ли я выиграть в следующий?',
              content:
                  'Нет. Один и тот-же игрок не может выиграть два раза подряд. Пожалйуста, не нарушайте это правило. Если мы узнаем что Вы выиграли второй раз подряд, то Вы не получите денежный приз, а так-же будете заблокированы и больше никогда не сможете принять участие.',
              isImportant: true),
          helpsText(
              titleQuestion: '6. Как я узнаю что я выиграл?',
              content:
                  '1. Вы всегда можете увидеть на каком Вы месте в таблице лидеров;\n2. Если сейчас понедельник, время 00:00 и Вы на первом месте в таблице лидеров, то в течении 24 часов с Вами свяжутся по вашей электронной почте указанной при регистрации.',
              isImportant: true),
          helpsText(
              titleQuestion: '7. Как я могу получить выигрыш?',
              content:
                  'Если Вы выиграли, Вас попросят прислать название криптовалюты на которую Вы хотите чтоб Вам зачислили деньги (а так-же её сеть, если понадобится) и адрес кошелька. Если Вы ошебётсь в адресе или сети, деньги Вам не зачислятся. Выигрыш мы зачисляем только на эти криптовалюты: Litecoin, Ripple, Tether, TRON.'),
          helpsText(
              titleQuestion:
                  '8. Как я узнаю что мне написали с оффициального адреса электронной почты?',
              content:
                  'Это наш единственный и оффициальный адрес электронной почты по которому мы пишем победителям: mini.casino.cash.prize@gmail.com',
              isImportant: true),
          const SizedBox(height: 15.0),
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
