import 'dart:async' as timer;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'actor/button_actor.dart';
import 'actor/dice_actor.dart';
import 'actor/player_actor.dart';
import 'component/stoppable_sprite_animation_component.dart';
import 'model/player.dart';
import 'util/constants.dart';

List<List<int>> _dicesValuesTestMode = [];
late bool _testMode;
late int _playsDelayTestMode;

void main() {
  // TEST MODE
  // Habilita ou desabilita o TEST MODE.
  _testMode = false;

  // TEST MODE
  // Tempo em Segundos que se esperará entre cada jogada de teste.
  // Este valor deve ser informado em MILISSEGUNDOS.
  _playsDelayTestMode = 700;

  // TEST MODE
  // Caso estes valores sejam informados, o jogo vai usar estes valores como
  // valores dos dados. Caso contrário os valores serão definidos
  // aleatoriamente quando o jogador clicar no botão "JOGAR".
  _dicesValuesTestMode
    ..add([1, 1])
    ..add([2, 1])
    ..add([1, 1])
    ..add([5, 5])
    ..add([3, 2])
    ..add([5, 4])
    ..add([6, 6])
    ..add([1, 2])
    ..add([4, 5])
    ..add([2, 2])
    ..add([5, 5])
    ..add([2, 1])
    ..add([6, 1])
    ..add([1, 5])
    ..add([6, 3])
    ..add([4, 1])
    ..add([6, 5])
    ..add([1, 2])
    ..add([3, 4])
    ..add([6, 6])
    ..add([5, 6])
    ..add([2, 1])
    ..add([5, 4])
    ..add([1, 1])
    ..add([3, 2]);

  runApp(
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Container(
            child: SafeArea(
                child: GameWidget(
                    game: CobrasEscadas()
                )
            ),
          )
      )
  );
}

class CobrasEscadas extends BaseGame with TapDetector {

  late TextComponent _txtMessage;

  late TextComponent _txtExtraMessage;

  late PlayerActor _playerActor1;

  late ButtonActor _buttonActor1;

  late PlayerActor _playerActor2;

  late ButtonActor _buttonActor2;

  late DiceActor _diceActor1;

  late DiceActor _diceActor2;

  bool _dicesLauched = false;

  bool _gameFinished = false;

  bool _autoPlay = false;

  int _playerInTurn = 1;

  @override
  Future<void> onLoad() async {
    SystemChrome.setEnabledSystemUIOverlays([]);

    viewport = FixedResolutionViewport(Vector2(screenWidth, screenHeight));
    camera.setRelativeOffset(Anchor.topLeft);

    await _createBoard();
    await _createPlayers();
    await _createUI();

    // TEST MODE
    // Se verdadeiro usará os valores dos dados informados, caso contrário
    // usará valores de dados gerados aleatoriamente ao clicar nos botões.
    if (_testMode && _dicesValuesTestMode.isNotEmpty) {
      _test();
    }
  }

  // TEST MODE
  // Testa o jogo usando os valores informados em _dicesValuesTestMode como
  // valores para os dados.
  void _test() async {
    _autoPlay = true;

    int index = 0;
    await _jogar(_dicesValuesTestMode[index][0], _dicesValuesTestMode[index][1]);
    index++;

    timer.Timer t = timer.Timer.periodic(Duration(milliseconds: _playsDelayTestMode), (timer) async {
      if (!_gameFinished) {
        if (index < _dicesValuesTestMode.length) {
          await _jogar(_dicesValuesTestMode[index][0], _dicesValuesTestMode[index][1]);
          index++;
        } else {
          _autoPlay = false;
          timer.cancel();
        }
      } else {
        _txtExtraMessage.text = 'O jogo acabou!';
        print('O jogo acabou!');
        _dicesLauched = false;

        if (index < _dicesValuesTestMode.length) {
          index++;
        } else {
          timer.cancel();
        }
      }
    });
  }

  Future<void> _createBoard() async {
    add(
        SpriteComponent(
            position: Vector2.zero(),
            size: Vector2(screenWidth, screenHeight),
            sprite: await loadSprite('background.png'),
            overridePaint: paintWithAntiAlias
        )
    );

    add(
        SpriteComponent(
            position: Vector2.zero(),
            size: Vector2(boardSize, boardSize),
            sprite: await loadSprite('board.png'),
            overridePaint: paintWithAntiAlias
        )
    );
  }

  Future<void> _createPlayers() async {
    _playerActor1 = PlayerActor(
        player: Player('1'),
        component: SpriteComponent(
            position: Vector2(50, 900),
            size: Vector2(160, 160),
            sprite: await loadSprite('p1_avatar.png')
        )..renderFlipX = true,
        nameComponent: TextComponent('Jogador 1',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: BasicPalette.white.color,
                fontSize: 30,
              )
          ),
        ),
        animationComponents: await _createAnimations('p1.png'),
        animationPositionOffset: -10
    );

    add(_playerActor1.component);
    add(_playerActor1.nameComponent);
    add(_playerActor1.animationComponent);

    _playerActor2 = PlayerActor(
        player: Player('2'),
        component: SpriteComponent(
            position: Vector2(screenWidth - 160 - 50, 900),
            size: Vector2(160, 160),
            sprite: await loadSprite('p2_avatar.png')
        ),
        nameComponent: TextComponent('Jogador 2',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: BasicPalette.white.color,
                fontSize: 30,
              )
          ),
        ),
        animationComponents: await _createAnimations('p2.png'),
        animationPositionOffset: 10
    );

    add(_playerActor2.component);
    add(_playerActor2.nameComponent);
    add(_playerActor2.animationComponent);
  }

  Future<List<SpriteAnimationComponent>> _createAnimations(String spriteUrl) async {
    List<SpriteAnimationComponent> animations = [];

    return animations
      ..add(SpriteAnimationComponent(
        animation: await loadSpriteAnimation(
          spriteUrl,
          SpriteAnimationData.sequenced(
            amount: 3,
            textureSize: Vector2(48, 48),
            texturePosition: Vector2.zero(),
            stepTime: 0.3,
          ),
        ),
        position: Vector2.zero(),
        size: Vector2(64, 64),
      ))
      ..add(
          SpriteAnimationComponent(
            animation: await loadSpriteAnimation(
              spriteUrl,
              SpriteAnimationData.sequenced(
                amount: 3,
                textureSize: Vector2(48, 48),
                texturePosition: Vector2(0, 48),
                stepTime: 0.3,
              ),
            ),
            position: Vector2.zero(),
            size: Vector2(64, 64),
          )
      )
      ..add(
          SpriteAnimationComponent(
            animation: await loadSpriteAnimation(
              spriteUrl,
              SpriteAnimationData.sequenced(
                amount: 3,
                textureSize: Vector2(48, 48),
                texturePosition: Vector2(0, 96),
                stepTime: 0.3,
              ),
            ),
            position: Vector2.zero(),
            size: Vector2(64, 64),
          )
      )
      ..add(
          SpriteAnimationComponent(
            animation: await loadSpriteAnimation(
              spriteUrl,
              SpriteAnimationData.sequenced(
                amount: 3,
                textureSize: Vector2(48, 48),
                texturePosition: Vector2(0, 144),
                stepTime: 0.3,
              ),
            ),
            position: Vector2.zero(),
            size: Vector2(64, 64),
          )
      );
  }

  Future<void> _createUI() async {
    add(
        _txtMessage = TextComponent('VEZ DO JOGADOR ${_playerActor1.player.name}',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: Colors.white,
                fontSize: 40,
              )
          ),
        )
    );

    add(
        _txtExtraMessage = TextComponent('',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: Colors.white,
                fontSize: 35,
              )
          ),
        )
    );

    _buttonActor1 = ButtonActor(
      component: SpriteComponent(
          size: Vector2(160, 53)
      ),
      sprUnpressed: await loadSprite(
        'button.png',
        srcPosition: Vector2.zero(),
        srcSize: Vector2(120, 40),
      ),
      sprPressed: await loadSprite(
        'button.png',
        srcPosition: Vector2(0, 40),
        srcSize: Vector2(120, 40),
      ),
      sprActiveUnpressed: await loadSprite(
        'button_active.png',
        srcPosition: Vector2.zero(),
        srcSize: Vector2(120, 40),
      ),
      sprActivePressed: await loadSprite(
        'button_active.png',
        srcPosition: Vector2(0, 40),
        srcSize: Vector2(120, 40),
      ),
    )..active = true;

    _buttonActor1.component.position =
        Vector2(
            _playerActor1.position.x + ((_playerActor1.size.x - _buttonActor1.size.x) / 2),
            _playerActor1.nameComponent.y + 45
        );

    add(_buttonActor1.component);

    _buttonActor2 = ButtonActor(
      component: SpriteComponent(
          size: Vector2(160, 53)
      ),
      sprUnpressed: await loadSprite(
        'button.png',
        srcPosition: Vector2.zero(),
        srcSize: Vector2(120, 40),
      ),
      sprPressed: await loadSprite(
        'button.png',
        srcPosition: Vector2(0, 40),
        srcSize: Vector2(120, 40),
      ),
      sprActiveUnpressed: await loadSprite(
        'button_active.png',
        srcPosition: Vector2.zero(),
        srcSize: Vector2(120, 40),
      ),
      sprActivePressed: await loadSprite(
        'button_active.png',
        srcPosition: Vector2(0, 40),
        srcSize: Vector2(120, 40),
      ),
    );

    _buttonActor2.component.position =
        Vector2(
            _playerActor2.position.x + ((_playerActor2.size.x - _buttonActor2.size.x) / 2),
            _playerActor2.nameComponent.y + 45
        );

    add(_buttonActor2.component);

    _diceActor1 = DiceActor(
        animationComponent: StoppableSpriteAnimationComponent(
          animation: await loadSpriteAnimation(
            'dice.png',
            SpriteAnimationData.sequenced(
              amount: 6,
              amountPerRow: 3,
              textureSize: Vector2(120, 120),
              stepTime: 0.1,
            ),
          ),
          size: Vector2(120, 120),
          stopped: true,
        )..position = Vector2(250, 920)
    );

    add(_diceActor1.animationComponent);

    _diceActor2 = DiceActor(
        animationComponent: StoppableSpriteAnimationComponent(
          animation: await loadSpriteAnimation(
            'dice.png',
            SpriteAnimationData.sequenced(
              amount: 6,
              amountPerRow: 3,
              textureSize: Vector2(120, 120),
              stepTime: 0.1,
            ),
          ),
          size: Vector2(120, 120),
          stopped: true,
        )..position = Vector2(screenWidth - 250 - 120, 920)
    );

    add(_diceActor2.animationComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _txtMessage.position = Vector2((screenWidth - _txtMessage.width) / 2, 800);
    _txtExtraMessage.position = Vector2((screenWidth - _txtExtraMessage.width) / 2, 850);

    _buttonActor1.update(dt);
    _playerActor1.update(dt);
    _buttonActor2.update(dt);
    _playerActor2.update(dt);

    if (!_dicesLauched) {
      if (_buttonActor1.pressed || _buttonActor2.pressed) {
        _lauchDices();
      }
    }

    if (_diceActor1.pendingProccess && _diceActor2.pendingProccess) {
      _jogar(_diceActor1.currentValue, _diceActor2.currentValue, false);
    }
  }

  void _lauchDices() {
    if (!_gameFinished) {
      _diceActor1.lauch();
      _diceActor2.lauch();
      _dicesLauched = true;
      FlameAudio.audioCache.play('dice.mp3');
    } else {
      _txtExtraMessage.text = 'O jogo acabou!';
      print('O jogo acabou!');
      _dicesLauched = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  Color backgroundColor() => const Color(0xFF555555);

  // função criada conforme o descrito do enunciado do Teste Técnico 02
  Future<void> _jogar(int dice1Value, int dice2Value, [bool forced = true]) async {
    if (forced) {
      _diceActor1.currentValue = dice1Value;
      _diceActor2.currentValue = dice2Value;
    }

    if (_playerInTurn == 1) {
      _playerActor1.move(dice1Value + dice2Value);
    } else {
      _playerActor2.move(dice1Value + dice2Value);
    }

    String extraMessage;

    if (_playerInTurn == 1) {
      if (_playerActor1.player.positionInBoard == 100) {
        extraMessage = 'Jogador ${_playerActor1.player.name} venceu!';
        _gameFinished = true;
      } else {
        extraMessage = 'Jogador ${_playerActor1.player.name} está na casa ${_playerActor1.player.positionInBoard}';
      }
    } else {
      if (_playerActor2.player.positionInBoard == 100) {
        extraMessage = 'Jogador ${_playerActor2.player.name} venceu!';
        _gameFinished = true;
      } else {
        extraMessage = 'Jogador ${_playerActor2.player.name} está na casa ${_playerActor2.player.positionInBoard}';
      }
    }

    _txtExtraMessage.text = extraMessage;
    print(extraMessage);

    String message;

    if (!_gameFinished) {
      if (dice1Value == dice2Value) {
        if (_playerInTurn == 1) {
          message = 'JOGADOR ${_playerActor1.player.name} JOGA NOVAMENTE';
        } else {
          message = 'JOGADOR ${_playerActor2.player.name} JOGA NOVAMENTE';
        }
      } else {
        _playerInTurn = _playerInTurn == 1 ? 2 : 1;

        if (_playerInTurn == 1) {
          message = 'VEZ DO JOGADOR ${_playerActor1.player.name}';
          _buttonActor1.active = true;
          _buttonActor2.active = false;
        } else {
          message = 'VEZ DO JOGADOR ${_playerActor2.player.name}';
          _buttonActor1.active = false;
          _buttonActor2.active = true;
        }
      }
    } else {
      _buttonActor1.active = false;
      _buttonActor2.active = false;
      message = 'JOGO FINALIZADO';
    }

    _txtMessage.text = message;

    _diceActor1.clear();
    _diceActor2.clear();
    _dicesLauched = false;
    _buttonActor1.pressed = false;
    _buttonActor2.pressed = false;
  }

  @override
  void onTapDown(TapDownInfo event) {
    if (!_autoPlay) {
      if (!_dicesLauched) {
        if (_playerInTurn == 1) {
          _buttonActor1.pressed = _buttonActor1.area.contains(event.eventPosition.game.toOffset());
        } else {
          _buttonActor2.pressed = _buttonActor2.area.contains(event.eventPosition.game.toOffset());
        }
      }
    }

    if (_gameFinished) {
      _buttonActor1.pressed = _buttonActor1.area.contains(event.eventPosition.game.toOffset());
      _buttonActor2.pressed = _buttonActor2.area.contains(event.eventPosition.game.toOffset());
    }
  }

  @override
  void onTapUp(TapUpInfo event) {
    _buttonActor1.pressed = false;
    _buttonActor2.pressed = false;
  }

  @override
  void onTapCancel() {
    _buttonActor1.pressed = false;
    _buttonActor2.pressed = false;
  }

}