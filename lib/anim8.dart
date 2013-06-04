library anim8;

import 'dart:html';
import 'dart:async';

import 'src/css.dart';

abstract class Animation {
  factory Animation() => new CssAnimation();

  Watcher start(Element target, Duration duration);
  CssStyleDeclaration addFrame(double percent);
}

abstract class Watcher {
  final Future<AnimationEvent> onStart;
  final Future<AnimationEvent> onEnd;
  final Stream<AnimationEvent> onIteration;

  void stop();
}

