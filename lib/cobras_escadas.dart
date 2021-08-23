import 'dart:async' as timer;
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double screenWidth = 768;
const double screenHeight = 1366;
const double boardSize = 768;
const double boardCellSize = boardSize / 10;
final Paint paintWithAntiAlias = Paint()..isAntiAlias = true..filterQuality = FilterQuality.high;

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

  late TextComponent _txtDiceMessage;

  late TextComponent _txtWarningMessage;

  late TextComponent _txtInfo;

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
    String player1Avatar = Random().nextBool() == true ? 'p1' : 'p4';

    _playerActor1 = PlayerActor(
        player: Player('1'),
        component: SpriteComponent(
            position: Vector2(50, 900),
            size: Vector2(160, 160),
            sprite: await loadSprite('${player1Avatar}_avatar.png')
        )..renderFlipX = true,
        nameComponent: TextComponent('Jogador 1',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: BasicPalette.white.color,
                fontSize: 30,
              )
          ),
        ),
        animationComponents: await _createAnimations('$player1Avatar.png'),
        animationPositionOffset: -10
    );

    add(_playerActor1.component);
    add(_playerActor1.nameComponent);
    add(_playerActor1.animationComponent);

    String player2Avatar = Random().nextBool() == true ? 'p2' : 'p3';

    _playerActor2 = PlayerActor(
        player: Player('2'),
        component: SpriteComponent(
            position: Vector2(screenWidth - 160 - 50, 900),
            size: Vector2(160, 160),
            sprite: await loadSprite('${player2Avatar}_avatar.png')
        ),
        nameComponent: TextComponent('Jogador 2',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: BasicPalette.white.color,
                fontSize: 30,
              )
          ),
        ),
        animationComponents: await _createAnimations('$player2Avatar.png'),
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

    add(
        _txtDiceMessage = TextComponent('',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: Colors.white,
                fontSize: 30,
              )
          ),
        )
    );

    add(
        _txtWarningMessage = TextComponent('',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: Colors.yellow,
                fontSize: 35,
              )
          ),
        )
    );

    add(
        _txtInfo = TextComponent('Clique no botão JOGAR quando for a sua vez',
          textRenderer: TextPaint(
              config: TextPaintConfig(
                color: Colors.white,
                fontSize: 20,
              )
          ),
        )
    );

    _txtInfo.position = Vector2((screenWidth - _txtInfo.width) / 2, screenHeight - 30);

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
    _txtDiceMessage.position = Vector2((screenWidth - _txtDiceMessage.width) / 2, 1060);
    _txtWarningMessage.position = Vector2((screenWidth - _txtWarningMessage.width) / 2, 1200);

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
    _txtDiceMessage.text = 'Total dos dados: ${dice1Value + dice2Value}';
    print('Dado 1 = $dice1Value, Dado 2 = $dice2Value, Total = ${dice1Value + dice2Value}');

    if (forced) {
      _diceActor1.currentValue = dice1Value;
      _diceActor2.currentValue = dice2Value;
    }

    if (_playerInTurn == 1) {
      _txtWarningMessage.text = _playerActor1.move(dice1Value + dice2Value);
    } else {
      _txtWarningMessage.text = _playerActor2.move(dice1Value + dice2Value);
    }

    if (_txtWarningMessage.text.isNotEmpty) {
      print(_txtWarningMessage.text);
    }

    String extraMessage;

    if (_playerInTurn == 1) {
      if (_playerActor1.player.positionInBoard == 100) {
        extraMessage = 'Jogador ${_playerActor1.player.name} venceu!';
        _gameFinished = true;
        FlameAudio.audioCache.play('victory.mp3');
      } else {
        extraMessage = 'Jogador ${_playerActor1.player.name} está na casa ${_playerActor1.player.positionInBoard}';
      }
    } else {
      if (_playerActor2.player.positionInBoard == 100) {
        extraMessage = 'Jogador ${_playerActor2.player.name} venceu!';
        _gameFinished = true;
        FlameAudio.audioCache.play('victory.mp3');
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

abstract class AbstractActor {

  late SpriteComponent _component;

  AbstractActor(SpriteComponent component) {
    _component = component;
    _component.overridePaint = paintWithAntiAlias;
  }

  Vector2 get size => component.size;

  Vector2 get position => component.position;

  Rect get area => position & size;

  SpriteComponent get component => _component;

  @protected
  void init();

  @protected
  void update(double dt);

}

class ButtonActor extends AbstractActor {

  late Sprite _sprUnpressed;

  late Sprite _sprPressed;

  late Sprite _sprActiveUnpressed;

  late Sprite _sprActivePressed;

  bool pressed = false;

  bool active = false;

  ButtonActor({ required SpriteComponent component, required Sprite sprUnpressed, required Sprite sprPressed,
    required Sprite sprActiveUnpressed, required Sprite sprActivePressed }) : super(component) {
    this._sprUnpressed = sprUnpressed;
    this._sprPressed = sprPressed;
    this._sprActiveUnpressed = sprActiveUnpressed;
    this._sprActivePressed = sprActivePressed;

    init();
  }

  @override
  void init() {
    component.sprite = _sprUnpressed;
  }

  @override
  void update(double dt) {
    if (active) {
      if (pressed) {
        component.sprite = _sprActivePressed;
      } else {
        component.sprite = _sprActiveUnpressed;
      }
    } else {
      if (pressed) {
        component.sprite = _sprPressed;
      } else {
        component.sprite = _sprUnpressed;
      }
    }
  }

}

class DiceActor {

  late StoppableSpriteAnimationComponent _animationComponent;

  int _currentValue = 1;

  bool _launched = false;

  bool _pendingProccess = false;

  DiceActor({ required StoppableSpriteAnimationComponent animationComponent }) {
    this._animationComponent = animationComponent;
    this._animationComponent.overridePaint = paintWithAntiAlias;

    init();
  }

  void init() {
  }

  void lauch() {
    if (!_launched) {
      _launched = true;
      _animationComponent.animation?.currentIndex = Random().nextInt(6);
      _animationComponent.start();

      timer.Timer(Duration(seconds: 3), () {
        _animationComponent.stop();
        _currentValue = _animationComponent.currentValue;
        _launched = false;
        _pendingProccess = true;
      });
    }
  }

  void clear() {
    _pendingProccess = false;
  }

  StoppableSpriteAnimationComponent get animationComponent => _animationComponent;

  int get currentValue => _animationComponent.currentValue;

  set currentValue(int currentValue) => _animationComponent.currentValue = currentValue;

  bool get lauched => _launched;

  bool get pendingProccess => _pendingProccess;

}

class PlayerActor extends AbstractActor {

  late Player _player;

  late TextComponent _nameComponent;

  late List<SpriteAnimationComponent> _animationComponents;

  late SpriteAnimationComponent _animationComponent;

  late double _animationPositionOffset;

  bool _moved = false;

  PlayerActor({ required Player player, required SpriteComponent component, required TextComponent nameComponent,
    required List<SpriteAnimationComponent> animationComponents, double animationPositionOffset = 0 }) : super(component) {
    this._player = player;
    this._nameComponent = nameComponent;
    this._animationComponents = animationComponents;
    this._animationComponent = animationComponents[0];
    this._animationPositionOffset = animationPositionOffset;

    this._animationComponent.overridePaint = paintWithAntiAlias;

    init();
  }

  @override
  void init() {
    _nameComponent.position = Vector2(component.x + ((component.width - _nameComponent.width) / 2), component.y + component.height + 10);

    _animationComponent.position = Vector2(
        (_player.xCoord * boardCellSize) + ((boardCellSize - _animationComponent.width) / 2) + _animationPositionOffset,
        boardSize - ((_player.yCoord * boardCellSize) + boardCellSize)
    );
  }

  @override
  void update(double dt) {
    if (_moved) {
      _animationComponent.position = Vector2(
          (_player.xCoord * boardCellSize) + ((boardCellSize - _animationComponent.width) / 2) + _animationPositionOffset,
          boardSize - ((_player.yCoord * boardCellSize) + boardCellSize)
      );

      _moved = false;
    }
  }

  String move(int value) {
    bool reversed = false;
    String returnedMessage = '';

    for (int i = 0; i < value; i++) {
      if (_player.positionInBoard == 100) {
        reversed = true;
      }

      if (!reversed) {
        toNext();
      } else {
        toPrevious();
      }
    }

    returnedMessage = 'Jogador ${_player.name} caiu em uma casa com ESCADA!';

    // posições com escadas
    switch (_player.positionInBoard) {
      case 2:
        _player.positionInBoard = 38;
        break;
      case 7:
        _player.positionInBoard = 14;
        break;
      case 8:
        _player.positionInBoard = 31;
        break;
      case 15:
        _player.positionInBoard = 26;
        break;
      case 21:
        _player.positionInBoard = 42;
        break;
      case 28:
        _player.positionInBoard = 84;
        break;
      case 36:
        _player.positionInBoard = 44;
        break;
      case 51:
        _player.positionInBoard = 67;
        break;
      case 71:
        _player.positionInBoard = 91;
        break;
      case 78:
        _player.positionInBoard = 98;
        break;
      case 87:
        _player.positionInBoard = 94;
        break;
      default:
        returnedMessage = '';
    }

    if (returnedMessage.isNotEmpty) {
      FlameAudio.audioCache.play('stairs.mp3');
    }

    if (returnedMessage.isEmpty) {
      returnedMessage = 'Jogador ${_player.name} caiu em uma casa com COBRA!';

      // posições com cobras
      switch (_player.positionInBoard) {
        case 16:
          _player.positionInBoard = 6;
          break;
        case 46:
          _player.positionInBoard = 25;
          break;
        case 49:
          _player.positionInBoard = 11;
          break;
        case 62:
          _player.positionInBoard = 19;
          break;
        case 64:
          _player.positionInBoard = 60;
          break;
        case 74:
          _player.positionInBoard = 53;
          break;
        case 89:
          _player.positionInBoard = 68;
          break;
        case 92:
          _player.positionInBoard = 88;
          break;
        case 95:
          _player.positionInBoard = 75;
          break;
        case 99:
          _player.positionInBoard = 80;
          break;
        default:
          returnedMessage = '';
      }

      if (returnedMessage.isNotEmpty) {
        FlameAudio.audioCache.play('slip.mp3');
      }
    }

    _calcPositionCoords();

    _moved = true;

    return returnedMessage;
  }

  void toNext() {
    if (_player.yCoord % 2 == 0) {
      if (_player.xCoord < 9) {
        _player.xCoord++;
      } else {
        _player.yCoord++;
      }
    } else {
      if (_player.xCoord > 0) {
        _player.xCoord--;
      } else {
        _player.yCoord++;
      }
    }

    _calcPositionInBoard();
  }

  void toPrevious() {
    if (_player.yCoord % 2 == 0) {
      if (_player.xCoord > 0) {
        _player.xCoord--;
      } else {
        _player.yCoord--;
      }
    } else {
      if (_player.xCoord < 9) {
        _player.xCoord++;
      } else {
        _player.yCoord--;
      }
    }

    _calcPositionInBoard();
  }

  void _calcPositionInBoard() {
    int positionInBoard;

    positionInBoard = _player.yCoord * 10;

    if (_player.yCoord == 0 || _player.yCoord % 2 == 0) {
      positionInBoard += _player.xCoord + 1;
    } else {
      positionInBoard += 10 - _player.xCoord;
    }

    _player.positionInBoard = positionInBoard;
  }

  void _calcPositionCoords() {
    int xCoord;
    int yCoord;

    if (_player.positionInBoard < 11) {
      yCoord = 0;
    } else if (_player.positionInBoard >= 11 && _player.positionInBoard < 21) {
      yCoord = 1;
    } else if (_player.positionInBoard >= 21 && _player.positionInBoard < 31) {
      yCoord = 2;
    } else if (_player.positionInBoard >= 31 && _player.positionInBoard < 41) {
      yCoord = 3;
    } else if (_player.positionInBoard >= 41 && _player.positionInBoard < 51) {
      yCoord = 4;
    } else if (_player.positionInBoard >= 51 && _player.positionInBoard < 61) {
      yCoord = 5;
    } else if (_player.positionInBoard >= 61 && _player.positionInBoard < 71) {
      yCoord = 6;
    } else if (_player.positionInBoard >= 71 && _player.positionInBoard < 81) {
      yCoord = 7;
    } else if (_player.positionInBoard >= 81 && _player.positionInBoard < 91) {
      yCoord = 8;
    } else {
      yCoord = 9;
    }

    if (yCoord % 2 == 0) {
      xCoord = _player.positionInBoard - (yCoord * 10) - 1;
    } else {
      xCoord = 9 - (_player.positionInBoard - (yCoord * 10) - 1);
    }

    _player.xCoord = xCoord;
    _player.yCoord = yCoord;
  }

  Player get player => _player;

  TextComponent get nameComponent => _nameComponent;

  SpriteAnimationComponent get animationComponent => _animationComponent;

}

class StoppableSpriteAnimationComponent extends SpriteAnimationComponent {

  bool _stopped = false;

  StoppableSpriteAnimationComponent(
      { bool stopped = false,
        Vector2? position,
        Vector2? size,
        SpriteAnimation? animation,
        Paint? overridePaint })
      : super(position: position, size: size, animation: animation, overridePaint: overridePaint) {
    _stopped = stopped;
  }

  void stop() {
    _stopped = true;
  }

  void start() {
    _stopped = false;
  }

  @override
  void update(double dt) {
    if (!_stopped) {
      super.update(dt);
    }
  }

  int get currentValue => (animation?.currentIndex ?? 0) + 1;

  set currentValue(int currentValue) => animation?.currentIndex = currentValue - 1;

}

class Player {

  String name;

  int xCoord;

  int yCoord;

  int positionInBoard = 1;

  Player(this.name, [this.xCoord = 0, this.yCoord = 0]);

}