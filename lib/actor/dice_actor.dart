import 'dart:async' as timer;
import 'dart:math';

import 'package:cobras_escadas/component/stoppable_animation_component.dart';
import 'package:flutter/material.dart';

class DiceActor {

  late StoppableSpriteAnimationComponent _animationComponent;

  int _currentValue = 1;

  bool _launched = false;

  bool _pendingProccess = false;

  DiceActor({ required StoppableSpriteAnimationComponent animationComponent, Paint? paint }) {
    this._animationComponent = animationComponent;

    if (paint != null) {
      this._animationComponent.paint = paint;
    }

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