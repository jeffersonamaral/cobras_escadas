import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../util/constants.dart';

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