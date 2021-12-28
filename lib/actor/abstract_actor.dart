import 'package:flame/components.dart';
import 'package:flutter/material.dart';

abstract class AbstractActor {

  late SpriteComponent _component;

  AbstractActor(SpriteComponent component, Paint? paint) {
    _component = component;

    if (paint != null) {
      _component.paint = paint;
    }
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