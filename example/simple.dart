// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:anim8/anim8.dart';
import 'package:anim8/src/script.dart';
import 'package:anim8/src/css.dart';

main() {
  useHtmlConfiguration();

  var e2 = new DivElement();
  e2.style.width = '20px';
  e2.style.height = '100px';
  e2.style.backgroundColor = 'blue';
  document.body.append(e2);

  var anim2 = new ScriptAnimation();
  animate(e2, anim2);

  var e1 = new DivElement();
  e1.style.width = '20px';
  e1.style.height = '100px';
  e1.style.backgroundColor = 'red';
  document.body.append(e1);

  var anim1 = new CssAnimation();
  animate(e1, anim1);
}

void animate(Element target, Animation anim) {
  anim.addFrame(.5)
    ..translateX = 500
    ..opacity = .5;
  anim.addFrame(1.0)
    ..translateX = 0
    ..opacity = 1;


  void start(e) {
    anim.start(target,
        new Duration(seconds: 5),
        iterationCount: 1.5);//.onEnd.then(start);
  }
  start(null);
}
