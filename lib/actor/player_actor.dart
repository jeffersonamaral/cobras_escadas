
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

import '../model/player.dart';
import '../util/constants.dart';
import 'abstract_actor.dart';

class PlayerActor extends AbstractActor {

  late Player _player;

  late TextComponent _nameComponent;

  late List<SpriteAnimationComponent> _animationComponents;

  late SpriteAnimationComponent _animationComponent;

  late double _animationPositionOffset;

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
    _animationComponent.position = Vector2(
        (_player.xCoord * boardCellSize) + ((boardCellSize - _animationComponent.width) / 2) + _animationPositionOffset,
        boardSize - ((_player.yCoord * boardCellSize) + boardCellSize)
    );
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