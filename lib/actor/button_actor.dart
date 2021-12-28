import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'abstract_actor.dart';

class ButtonActor extends AbstractActor {

  late Sprite _sprUnpressed;

  late Sprite _sprPressed;

  late Sprite _sprActiveUnpressed;

  late Sprite _sprActivePressed;

  bool pressed = false;

  bool active = false;

  ButtonActor({ required SpriteComponent component, required Sprite sprUnpressed, required Sprite sprPressed,
    required Sprite sprActiveUnpressed, required Sprite sprActivePressed, required Paint? paint }) : super(component, paint) {
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