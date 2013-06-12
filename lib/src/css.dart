library anim8.css;

import 'dart:html';
import 'dart:async';
import 'package:anim8/anim8.dart';

class CssAnimation implements Animation {

  CssKeyframesRule keyframes;
  String _name;
  final List<CssFrame> _frames = <CssFrame>[];

  static StyleElement _style;
  static int _uniqueNameIndex = 0;
  static bool _supported;

  CssAnimation({String name}) {
    if (_style == null) {
      _style = new StyleElement();
      document.head.append(_style);
    }
    _name = name;

    if (_name == null) {
      var index = _uniqueNameIndex++;
      _name = 'CssAnimation$index';
    }

    CssStyleSheet cssSheet = _style.sheet;
    keyframes = _createRule(cssSheet);
  }

  static bool get supported {
    if (_supported == null) {
      var style = new StyleElement();

      try {
        var rule = _createRule(style.sheet);
        _supported = rule != null;
      } catch () {
        _supported = false;
      }
    }
    return _supported;
  }

  CssKeyframesRule _createRule(CssStyleSheet cssSheet) {
    var rulePrefix = '';
    if (window.navigator.userAgent.contains('Firefox/')) {
      rulePrefix = '-moz-';
    } else if (window.navigator.userAgent.contains('Chrome/')) {
      rulePrefix = '-webkit-';
    }
    var ruleIndex = cssSheet.insertRule('@${rulePrefix}keyframes $_name {}', 0);

    return cssSheet.cssRules[ruleIndex];
  }

  CssFrame addFrame(double percent) {
    keyframes.appendRule('${percent * 100}% {}');
    var frame = new CssFrame(keyframes.cssRules.last, percent);
    _frames.add(frame);
    _frames.sort();
    return frame;
  }

  CssAnimationWatcher start(Element target, Duration duration,
      {TimingFunction easing,
      bool holdEnd: false,
      Anim8Event handoffFrom,
      num iterationCount: 1,
      Duration delay: Duration.ZERO}) {

    if (easing == null) {
      easing = TimingFunction.ease;
    }

    var animationsText = target.style.animation;
    var animations;
    if (animationsText.length > 0) {
      animations = animationsText.split(',');
    } else {
      animations = [];
    }

    if (holdEnd == true) {
      _frames.last.apply(target.style);
    }

    var iterations = '$iterationCount';
    if (iterationCount.isInfinite) {
      iterations = 'infinite';
    }

    animations.add('$_name'
        ' ${duration.inMilliseconds / 1000}s'
        ' ${easing.cssName}'
        ' ${delay.inMilliseconds / 1000}s'
        ' $iterations');

    target.style.animation = animations.join(', ');

    return new CssAnimationWatcher(target, _name);
  }
}

class CssFrame implements Frame, Comparable<CssFrame> {
  final CssKeyframeRule rule;
  final double time;

  num _tx = 0;
  num _ty = 0;
  num _sx = 1;
  num _sy = 1;
  num _r = 0;


  CssFrame(this.rule, this.time) {
  }

  num get translateX => _tx;
  void set translateX(num value) {
    _tx = value;
    _updateTransform();
  }

  num get translateY => _ty;
  void set translateY(num value) {
    _ty = value;
    _updateTransform();
  }

  num get scaleX => _sx;
  void set scaleX(num value) {
    _sx = value;
    _updateTransform();
  }

  num get scaleY => _sy;
  void set scaleY(num value) {
    _sy = value;
    _updateTransform();
  }

  num get rotateZ => _r;
  void set rotateZ(num value) {
    _r = value;
    _updateTransform();
  }

  num get opacity => double.parse(rule.style.opacity);
  void set opacity(num value) {
    rule.style.opacity = value.toString();
  }

  void _updateTransform() {
    _applyTransform(rule.style);
  }

  void _applyTransform(CssStyleDeclaration style) {
    style.transform =
        'scaleX($_sx) scaleY($_sy) rotate(${_r}deg) translateX(${_tx}px) translateY(${_ty}px)';
  }

  void apply(CssStyleDeclaration style) {
    _applyTransform(style);
    style.opacity = rule.style.opacity;
  }

  CssStyleDeclaration get style => rule.style;

  int compareTo(CssFrame other) {
    return time.compareTo(other.time);
  }
}

class CssAnimationWatcher implements Watcher {
  final Element target;
  final String animationName;

  CssAnimationWatcher(Element target, String animationName):
      this.target = target,
      this.animationName = animationName {

    // Automatically clear out the style so the animation can be restarted.
    this.onEnd.then((_) {
      //this.stop();
    });
  }

  Future<AnimationEvent> get onStart {
    return Window.animationStartEvent.forTarget(target).where((e) => e.animationName == animationName).first;
  }

  Future<Anim8Event> get onEnd {
    return Window.animationEndEvent.forTarget(target).where((e) => e.animationName == animationName).first.then((_) {
      return new CssAnimationEndEvent();
    });
  }

  Stream<AnimationEvent> get onIteration {
    return Window.animationIterationEvent.forTarget(target).where((e) => e.animationName == animationName);
  }

  void stop() {
    var animationsText = target.style.animation;
    var animations;
    if (animationsText.length > 0) {
      animations = animationsText.split(',');
      var animName = '$animationName ';

      animations.removeWhere((animation) => animation.startsWith(animName));

      target.style.animation = animations.join(', ');
    }
  }
}

class CssAnimationEndEvent implements Anim8Event {
  CssAnimationEndEvent();
}
