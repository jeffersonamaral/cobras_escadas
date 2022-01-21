import 'package:flutter/material.dart';

import '../game.dart';

class GameOverOverlay extends StatelessWidget {

  final CobrasEscadas _cobrasEscadas;

  const GameOverOverlay(this._cobrasEscadas);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _cobrasEscadas.canvasSize.x * 0.85,
        height: _cobrasEscadas.canvasSize.y * 0.85,
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("JOGO FINALIZADO",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                    onPressed: _cobrasEscadas.reset,
                    child: Text(
                      'JOGAR NOVAMENTE',
                      style: TextStyle(
                        fontSize: 40
                      ),
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  static Widget create(BuildContext context, CobrasEscadas cobrasEscadas) {
    return GameOverOverlay(cobrasEscadas);
  }

}