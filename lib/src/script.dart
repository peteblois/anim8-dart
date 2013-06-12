library anim8.script;

import 'dart:html';
import 'dart:async';
import 'package:anim8/anim8.dart';
import 'unit_bezier.dart';


class ScriptAnimation implements Animation {
  final List<ScriptFrame> _frames = <ScriptFrame>[];
  ScriptAnimation() {
  }

  ScriptFrame addFrame(double percent) {
    var frame = new ScriptFrame(percent);
    _frames.add(frame);
    _frames.sort();
    return frame;
  }

  ScriptAnimationRunner start(Element target, Duration duration,
      {TimingFunction easing,
      bool holdEnd: false,
      Anim8Event handoffFrom,
      num iterationCount: 1,
      Duration delay: Duration.ZERO}) {

    if (easing == null) {
      easing = TimingFunction.ease;
    }

    var frames = _frames.toList();

    if (frames.first.time != 0) {
      if (handoffFrom != null) {
        ScriptAnimationEndEvent scriptHandoffFrom = handoffFrom;
        frames.insert(0, new ScriptFrame.fromFrame(0.0, scriptHandoffFrom.frame));
        scriptHandoffFrom.handedOff = true;
      } else {
        frames.insert(0, new ScriptFrame.fromStyle(0.0, target.style));
      }
    }

    return new ScriptAnimationRunner(frames, duration.inMilliseconds.toDouble(),
        easing.interpolator, holdEnd, target.style, iterationCount);
  }
}


class ScriptFrame implements Frame, Comparable<ScriptFrame> {
  final double time;
  num _tx = 0;
  num _ty = 0;
  num _sx = 1;
  num _sy = 1;
  num _r = 0;
  num _opacity = 1;

  ScriptFrame(this.time) {
  }

  factory ScriptFrame.fromStyle(double time, CssStyleDeclaration style) {
    var floats = '[-+]?[0-9]*\\.?[0-9]';
    var regex = new RegExp('scale\\(($floats), ($floats)\\) rotate\\((${floats})deg\\) translate\\((${floats})px, (${floats})px\\)');
    var match = regex.firstMatch(style.transform);

    ScriptFrame frame = new ScriptFrame(time);
    if (match != null) {
      frame.scaleX = double.parse(match.group(1));
      frame.scaleY = double.parse(match.group(2));
      frame.rotateZ = double.parse(match.group(3));
      frame.translateX = double.parse(match.group(4));
      frame.translateY = double.parse(match.group(5));
    }
    return frame;
  }

  factory ScriptFrame.fromFrame(double time, ScriptFrame other) {
    ScriptFrame frame = new ScriptFrame(time);
    frame.translateX = other.translateX;
    frame.translateY = other.translateY;
    frame.scaleX = other.scaleX;
    frame.scaleY = other.scaleY;
    frame.rotateZ = other.rotateZ;
    frame.opacity = other.opacity;

    return frame;
  }

  num get translateX => _tx;
  void set translateX(num value) {
    _tx = value;
  }

  num get translateY => _ty;
  void set translateY(num value) {
    _ty = value;
  }

  num get scaleX => _sx;
  void set scaleX(num value) {
    _sx = value;
  }

  num get scaleY => _sy;
  void set scaleY(num value) {
    _sy = value;
  }

  num get rotateZ => _r;
  void set rotateZ(num value) {
    _r = value;
  }

  num get opacity => _opacity;
  void set opacity(num value) {
    _opacity = value;
  }

  void interpolate(ScriptFrame next, double percent, CssStyleDeclaration style) {
    style.transform = transform(
      (next.translateX - translateX) * percent + translateX,
      (next.translateY - translateY) * percent + translateY,
      (next.scaleX - scaleX) * percent + scaleX,
      (next.scaleY - scaleY) * percent + scaleY,
      (next.rotateZ - rotateZ) * percent + rotateZ);

    style.opacity = ((next.opacity - opacity) * percent + opacity).toString();
  }

  String transform(num tx, num ty, num sx, num sy, num r) {
    return 'scale($sx, $sy) rotate(${r}deg) translate(${tx}px, ${ty}px)';
  }

  int compareTo(ScriptFrame other) {
    return time.compareTo(other.time);
  }
}

class ScriptAnimationRunner implements Watcher {
  final double duration;
  final List<ScriptFrame> frames;
  final bool holdEnd;
  double _startTime;
  final double _iterations;
  final CssStyleDeclaration style;
  final Completer<ScriptAnimationEndEvent> _endCompleter =
      new Completer<ScriptAnimationEndEvent>.sync();

  final UnitBezier easing;

  ScriptAnimationRunner(this.frames, this.duration, this.easing, this.holdEnd,
      this.style, this._iterations) {
    _startTime = window.performance.now();

    var ua = window.navigator.userAgent;
    if (ua.contains('Firefox/') || ua.contains('Trident/5')) {
      _startTime += window.performance.timing.navigationStart;
    }
    window.requestAnimationFrame(_tick);
  }

  void stop() {
    _end();
  }

  void _end() {
    var event = new ScriptAnimationEndEvent(frames.last);
    _endCompleter.complete(event);

    if (holdEnd || event.handedOff) {
      frames.last.interpolate(frames.last, 1.0, style);
    } else {
      frames.first.interpolate(frames.first, 0.0, style);
    }
  }

  void _tick(num time) {
    var iteration = (time - _startTime) / duration;
    if (iteration > _iterations) {
      _end();
    } else {
      var percent = iteration % 1;
      var next = frames[0];
      var prev = next;
      for (var frame in frames) {
        prev = next;
        next = frame;
        if (next.time >= percent) {
          break;
        }
      }
      var x = (percent - prev.time) / (next.time - prev.time);
      var y = easing.solve(x, 1e-6);
      prev.interpolate(next, y, style);

      window.requestAnimationFrame(_tick);
    }
  }

  Future<ScriptAnimationEndEvent> get onEnd {
    return _endCompleter.future;
  }
}

class ScriptAnimationEndEvent implements Anim8Event {
  final ScriptFrame frame;
  bool handedOff = false;

  ScriptAnimationEndEvent(this.frame);
}
