import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' as ui;

import 'package:intl/intl.dart';
import 'package:new_mini_casino/business/balance.dart';
import 'package:new_mini_casino/controllers/game_statistic_controller.dart';
import 'package:new_mini_casino/games_logic/plinko_logic.dart';
import 'package:new_mini_casino/main.dart';
import 'package:new_mini_casino/models/game_statistic_model.dart';
import 'package:new_mini_casino/services/autoclicker_secure.dart';
import 'package:new_mini_casino/services/common_functions.dart';
import 'package:new_mini_casino/widgets/auto_bets.dart';
import 'package:new_mini_casino/widgets/bottom_game_navigation.dart';
import 'package:new_mini_casino/widgets/game_app_bar_widget.dart';
import 'package:provider/provider.dart';

class Plinko extends StatelessWidget {
  const Plinko({super.key});

  void cashout(BuildContext context, double profit) {
    Provider.of<Balance>(context, listen: false).addMoney(profit);
  }

  void addCoefficient(BuildContext context, double coefficient) {
    Provider.of<PlinkoLogic>(context, listen: false)
        .addNewCoefficient(coefficient);
  }

  static MyGame myGame = MyGame();

  static CurrencyTextInputFormatter betFormatter = CurrencyTextInputFormatter.currency(
    locale: ui.Platform.localeName,
    enableNegative: false,
    symbol: NumberFormat.simpleCurrency(locale: ui.Platform.localeName)
        .currencySymbol,
  );

  static TextEditingController betController =
      TextEditingController(text: betFormatter.formatString('10000'));

  void makeBet(BuildContext context) {
    double bet = betFormatter.getUnformattedValue().toDouble();

    if (Provider.of<Balance>(context, listen: false).isLoading) {
      return;
    }

    CommonFunctions.callOnStart(
        context: context,
        bet: bet,
        gameName: 'Plinko',
        callback: () {
          if (MyGame.instance != null) {
            MyGame.instance!.createNewBall(context, bet);
            AutoclickerSecure().checkAutoclicker();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: bottomGameNavigation(
              context: context,
              betFormatter: Plinko.betFormatter,
              betController: Plinko.betController,
              isPlaying:
                  !Provider.of<AutoBetsController>(context, listen: false)
                      .exitGame(context),
              isCanSwitch: false,
              onPressed: () => makeBet(context)),
          appBar: gameAppBarWidget(
            context: context,
            isGameOn: Provider.of<AutoBetsController>(context, listen: false)
                .exitGame(context),
            gameName: 'Plinko',
          ),
          body: Column(
            children: [
              Expanded(child: GameWidget(game: MyGame())),
              Consumer<PlinkoLogic>(
                builder: (context, plinkoLogic, child) {
                  return Container(
                    margin: const EdgeInsets.all(15.0),
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.lightBlueAccent.withOpacity(0.1),
                      border:
                          Border.all(color: Colors.lightBlueAccent, width: 2.0),
                    ),
                    child: plinkoLogic.lastCoefficients.isEmpty
                        ? Center(
                            child: AutoSizeText('Ставок ещё нет',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .color!
                                            .withOpacity(0.4))),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  List<double> value = plinkoLogic
                                      .lastCoefficients.reversed
                                      .toList();

                                  Map<double, Color> coefficientsColor = {
                                    5.0: const Color.fromRGBO(233, 30, 70, 70),
                                    3.0: const Color.fromRGBO(244, 67, 70, 70),
                                    1.5: const Color.fromRGBO(255, 87, 70, 70),
                                    0.2: const Color.fromRGBO(255, 152, 70, 70),
                                    0.0: const Color.fromRGBO(255, 193, 70, 70),
                                  };

                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 5.0,
                                        bottom: 5.0,
                                        left: index == 0 ? 5.0 : 0.0,
                                        right: index + 1 ==
                                                context
                                                    .watch<PlinkoLogic>()
                                                    .lastCoefficients
                                                    .length
                                            ? 5.0
                                            : 0.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: coefficientsColor[value[index]]),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Center(
                                        child: AutoSizeText(
                                          '${value[index]}x',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 5.0),
                                itemCount: plinkoLogic.lastCoefficients.length),
                          ),
                  );
                },
              )
            ],
          ),
        ),
        ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive)
      ],
    );
  }
}

//Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)

class MyGame extends FlameGame with HasCollisionDetection, HasGameRef {
  static MyGame? instance;

  double screenWidth = 0.0;
  double screenHeight = 0.0;

  List<double> coefficients = [
    5.0,
    3.0,
    1.5,
    0.2,
    0.0,
    0.0,
    0.2,
    1.5,
    3.0,
    5.0
  ];

  List<Color> coefficientsColor = [
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.pink
  ];

  MyGame() {
    instance = this;
  }

  @override
  Color backgroundColor() =>
      Colors.transparent; //const Color.fromARGB(255, 35, 38, 51);

  List<RectangleCollidable> staticBalls = [];

  void createNewBall(BuildContext context, double bet) {
    double screenCenter = gameRef.size.x / 2;

    double temp = Random.secure().nextDouble() * 100;
    bool isLeft = Random.secure().nextBool();

    if (temp < 0.2) {
      // 20% шанс падения в центр
      screenCenter = gameRef.size.x / 2;
    } else {
      // 80% шанс случайного отклонения влево или вправо
      double deviation = 0.0;

      if (temp < 0.4) {
        // 20% шанс отклонения на 20 пикселей
        deviation = isLeft ? -20 : 20;
      } else if (temp < 0.7) {
        // 30% шанс отклонения на 15 пикселей
        deviation = isLeft ? -15 : 15;
      } else if (temp < 0.9) {
        // 20% шанс отклонения на 10 пикселей
        deviation = isLeft ? -10 : 10;
      } else {
        // 10% шанс отклонения на 5 пикселей
        deviation = isLeft ? -5 : 5;
      }

      screenCenter += deviation;
    }

    add(Ball(Vector2(screenCenter, gameRef.size.y / 7), context, bet));
  }

  @override
  Future<void> onLoad() async {
    double screenWidth = gameRef.size.x;
    double screenHeight = gameRef.size.y;

    double ballSize = screenWidth * 0.08;
    int rowCount = 9;
    double gap = 4;
    int staticBallCount = 3;

    for (int row = 0; row < rowCount; row++) {
      double startX = (size.x - staticBallCount * (ballSize + gap)) / 2;
      double y = size.y - (rowCount - row) * (ballSize + gap);

      for (int col = 0; col < staticBallCount; col++) {
        double x = startX + col * (ballSize + gap);
        final staticBall =
            RectangleCollidable(Vector2(x + (screenWidth * 0.01), y), row, col);
        add(staticBall);
        staticBalls.add(staticBall);
      }

      staticBallCount++;
    }

    for (int i = 0; i < coefficients.length; i++) {
      add(CoefficientBlock(
          Vector2(screenWidth * i * 0.091 + 40, screenHeight - 12),
          coefficients[i],
          coefficientsColor[i]));
    }
  }
}

class Ball extends PositionComponent with CollisionCallbacks, HasGameRef {
  double gravity = 700.0;
  double velocityX = 0;
  double velocityY = 0;
  double friction = 0.95;

  double bet = 0.0;
  Vector2 startPos = Vector2.zero();

  BuildContext context;

  late ShapeHitbox hitbox;

  Ball(Vector2 position, this.context, this.bet)
      : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  FutureOr<void> onLoad() async {
    startPos = position;

    size = Vector2.all(12);

    final defaultPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
    hitbox = CircleHitbox()
      ..paint = defaultPaint
      ..renderShape = true
      ..radius = 10;

    add(hitbox);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is RectangleCollidable) {
      final collisionPoint = intersectionPoints.first;

      final ballCenterX = position.x + size.x / 2;
      final ballCenterY = position.y + size.y / 2;
      final rectCenterX = other.position.x + other.size.x / 2;

      // Проверяем, с какой стороны столкновение
      if (collisionPoint.y < ballCenterY) {
        // Сверху

        if (collisionPoint.x < ballCenterX) {
          // Слева
          velocityY = -velocityY / 2;
          velocityX = (ballCenterX - rectCenterX) * 5; // Отправьте мяч влево
        } else {
          // Справа
          velocityY = -velocityY / 2;
          velocityX = -(ballCenterX - rectCenterX) * 5; // Отправьте мяч вправо
        }

        position.y = other.position.y - size.y / 2 - other.size.y / 2 - 1;
      } else if (collisionPoint.x < ballCenterX) {
        // Сбоку слева
        // Ничего не делаем, мяч продолжает падать
        velocityY = gravity;
        velocityX = 0;
      } else if (collisionPoint.x > ballCenterX) {
        // Сбоку справа
        // Ничего не делаем, мяч продолжает падать
        velocityY = gravity;
        velocityX = 0;
      } else {
        // Мяч посередине на RectangleCollidable
        // Отправьте мяч влево или вправо случайным образом
        if (Random().nextBool()) {
          velocityY = -velocityY / 2;
          velocityX = (ballCenterX - rectCenterX) * 5; // Отправьте мяч влево
        } else {
          velocityY = -velocityY / 2;
          velocityX = -(ballCenterX - rectCenterX) * 5; // Отправьте мяч вправо
        }
        position.y = other.position.y - size.y / 2 - other.size.y / 2 - 1;
      }

      //velocityY = -velocityY / 2 - 10.0; // Увеличьте вертикальное движение вниз
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is CoefficientBlock) {
      double profit = other.coefficient * bet;

      const Plinko().cashout(context, profit);
      const Plinko().addCoefficient(context, other.coefficient);

      if (other.coefficient < 2.0) {
        GameStatisticController.updateGameStatistic(
            gameName: 'plinko',
            gameStatisticModel: GameStatisticModel(
              maxLoss: bet,
              lossesMoneys: bet,
            ));
      } else if (other.coefficient >= 2.0) {
        GameStatisticController.updateGameStatistic(
          gameName: 'plinko',
          gameStatisticModel: GameStatisticModel(
            winningsMoneys: profit,
            lossesMoneys: bet,
            maxWin: profit,
          ),
        );
      }

      gameRef.remove(this);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    velocityY += gravity * dt;
    velocityX *= friction;

    position.x += velocityX * dt;
    position.y += velocityY * dt;

    if (position.y > gameRef.size.y) {
      gameRef.remove(this);
    }
  }
}

class RectangleCollidable extends PositionComponent with CollisionCallbacks {
  final _collisionStartColor = Colors.amber;
  final _defaultColor = Colors.lightBlue;
  late ShapeHitbox hitbox;

  int col = 0;
  int row = 0;

  RectangleCollidable(Vector2 position, this.col, this.row)
      : super(
          position: Vector2(position.x + 15, position.y),
          size: Vector2.all(12.0),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.fill;
    hitbox = CircleHitbox()
      ..paint = defaultPaint
      ..renderShape = true
      ..radius = 12.5;
    add(hitbox);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    hitbox.paint.color = _collisionStartColor;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      hitbox.paint.color = _defaultColor;
    }
  }
}

class CoefficientBlock extends PositionComponent
    with CollisionCallbacks, HasGameRef {
  Color defaultColor;
  late ShapeHitbox hitbox;

  double coefficient = 0.0;

  CoefficientBlock(Vector2 position, this.coefficient, this.defaultColor)
      : super(
          position: Vector2(position.x, position.y),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    double screenWidth = gameRef.size.x;
    double screenHeight = gameRef.size.y;

    size = Vector2(screenWidth * 0.07, screenHeight * 0.03);

    final defaultPaint = Paint()
      ..color = defaultColor
      ..style = PaintingStyle.fill;
    hitbox = RectangleHitbox()
      ..paint = defaultPaint
      ..renderShape = true;
    add(hitbox);

    add(TextComponent(
        position: Vector2(size.x / 2, size.y / 2),
        text: '${coefficient.toStringAsFixed(1)}x',
        anchor: Anchor.center,
        textRenderer: TextPaint(
            style: TextStyle(
                fontSize: size.x * 0.35,
                color: BasicPalette.white.color,
                fontWeight: FontWeight.bold,
                shadows: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 4.0,
                  spreadRadius: 1.0)
            ]))));
  }
}
