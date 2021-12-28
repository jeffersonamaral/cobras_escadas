
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game.dart';

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
                    game: CobrasEscadas(_testMode, _dicesValuesTestMode, _playsDelayTestMode)
                )
            ),
          )
      )
  );
}