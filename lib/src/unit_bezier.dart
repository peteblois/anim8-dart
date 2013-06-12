library anim8.unit_bezier;

/// From:
/// http://opensource.apple.com/source/WebCore/WebCore-955.66/platform/graphics/UnitBezier.h
class UnitBezier {
  final double p1x;
  final double p1y;
  final double p2x;
  final double p2y;
  double _ax;
  double _ay;
  double _bx;
  double _by;
  double _cx;
  double _cy;

  UnitBezier(this.p1x, this.p1y, this.p2x, this.p2y) {
    _cx = 3 * p1x;
    _bx = 3 * (p2x - p1x) - _cx;
    _ax = 1 - _cx - _bx;
    _cy = 3 * p1y;
    _by = 3 * (p2y - p1y) - _cy;
    _ay = 1 - _cy - _by;
  }

  double _solveCurveX(double x, double epsilon) {
    var t0, t1, t2, x2, d2;
    // Newton's method
    for (var i = 0, t2 = x; i < 8; i++) {
      x2 = _sampleCurveX(t2) - x;
      if (x2.abs() < epsilon) {
        return t2;
      }
      d2 = _sampleCurveDerivativeX(t2);
      if (d2.abs() < 1e-6) {
        break;
      }
      t2 = t2 - x2 / d2;
    }
    // Fallback
    t0 = 0;
    t1 = 1;
    t2 = x;
    if (t2 < t0) {
      return t0;
    } else if (t2 > t1) {
      return t1;
    }
    while(t0 < t1) {
      x2 = _sampleCurveX(t2);
      if ((x2 - x).abs() < epsilon) {
        return t2;
      }
      if (x > x2) {
        t0 = t2;
      } else {
        t1 = t2;
      }
      t2 = (t1 - t0) * 0.5 + t0;
    }
    // Failed
    return t2;
  }

  double _sampleCurveDerivativeX(double t) {
    return (3.0 * _ax * t + 2.0 * _bx) * t + _cx;
  }

  double _sampleCurveX(double t) {
    // `_ax t^3 + _bx t^2 + _cx t' expanded using Horner's rule.
    return ((_ax * t + _bx) * t + _cx) * t;
  }

  double _sampleCurveY(double t) {
    return ((_ay * t + _by) * t + _cy) * t;
  }

  double solve(double x, double epsilon) {
    return _sampleCurveY(_solveCurveX(x, epsilon));
  }
}
