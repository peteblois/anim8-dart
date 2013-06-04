library anim8.css;

import 'dart:html';
import 'dart:async';
import 'package:anim8/anim8.dart';


class CssAnimation implements Animation {

  CssKeyframesRule keyframes;
  String _name;

  static StyleElement _style;
  static int _uniqueNameIndex = 0;

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
    var ruleIndex = cssSheet.insertRule('@-webkit-keyframes $_name {}', 0);

    keyframes = cssSheet.cssRules[ruleIndex];
  }

  CssStyleDeclaration addFrame(double percent) {
    return new CssKeyframe(this, '${percent * 100}%').style;
  }

  CssAnimationWatcher start(Element target, Duration duration) {
    var animationsText = target.style.animation;
    var animations;
    if (animationsText.length > 0) {
      animations = animationsText.split(',');
    } else {
      animations = [];
    }

    animations.add('$_name ${duration.inSeconds}s');

    target.style.animation = animations.join(', ');

    return new CssAnimationWatcher(target, _name);
  }
}

class CssKeyframe {
  CssKeyframeRule frame;

  CssKeyframe(CssAnimation animation, String time) {
    animation.keyframes.insertRule('$time {}');
    frame = animation.keyframes.cssRules.last;
  }

  CssStyleDeclaration get style => frame.style;
}

class CssAnimationWatcher implements Watcher {
  final Element target;
  final String animationName;

  CssAnimationWatcher(Element target, String animationName):
      this.target = target,
      this.animationName = animationName {

    // Automatically clear out the style so the animation can be restarted.
    this.onEnd.then((_) {
      this.stop();
    });
  }

  Future<AnimationEvent> get onStart {
    return Window.animationStartEvent.forTarget(target).where((e) => e.animationName == animationName).first;
  }

  Future<AnimationEvent> get onEnd {
    return Window.animationEndEvent.forTarget(target).where((e) => e.animationName == animationName).first;
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
