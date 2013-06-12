library anim8;

import 'dart:html';
import 'dart:async';

import 'src/css.dart';
import 'src/script.dart';
import 'src/unit_bezier.dart';

abstract class Animation {
  factory Animation() {
    if (CssAnimation.supported) {
      return new CssAnimation();
    }
    return new ScriptAnimation();
  }

  Watcher start(Element target, Duration duration,
      {TimingFunction easing,
      bool holdEnd: false,
      Anim8Event handoffFrom,
      Duration delay: Duration.ZERO,
      num iterationCount});

  Frame addFrame(double percent);
}

abstract class Watcher {
  Future<Anim8Event> get onEnd;
  //Stream<AnimationEvent> get onIteration;

  void stop();
}

abstract class Frame {
  num translateX;
  num translateY;
  num scaleX;
  num scaleY;
  num opacity;
  num rotateZ;
}


class TimingFunction {
  // From: http://www.w3.org/TR/css3-transitions/#transition-timing-function-property
  static final TimingFunction ease = new TimingFunction(new UnitBezier(0.25, 0.1, 0.25, 1.0), 'ease');
  static final TimingFunction linear = new TimingFunction(new UnitBezier(0.0, 0.0, 1.0, 1.0), 'linear');
  static final TimingFunction easeIn = new TimingFunction(new UnitBezier(0.42, 0.0, 1.0, 1.0), 'ease-in');
  static final TimingFunction easeOut = new TimingFunction(new UnitBezier(0.0, 0.0, 0.58, 1.0), 'ease-out');
  static final TimingFunction easeInOut = new TimingFunction(new UnitBezier(0.42, 0.0, 0.58, 1.0), 'ease-in-out');

  final UnitBezier interpolator;
  final String cssName;

  TimingFunction(this.interpolator, this.cssName);
}

abstract class Anim8Event {}
