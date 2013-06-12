anim8-dart
==========

A procedural animation library which is a thin wrapper around CSS Animations when available with a pure-script fallback.

    import 'package:anim8/anim8.dart';
    
    void animate(Element element) {
      var anim = new Animation();
      anim.addFrame(.5)
        ..translateX = 500
        ..opacity = .5;
      anim.addFrame(1.0)
        ..translateX = 0
        ..opacity = 1;
        
      anim.start(element, new Duration(seconds: 1)).onEnd.then((_) {
        print('animation done!');
      });
    }
