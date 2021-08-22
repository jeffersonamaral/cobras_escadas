import 'dart:ui';

import 'package:flame/components.dart';

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