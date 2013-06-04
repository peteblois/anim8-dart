// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:anim8/anim8.dart';

main() {
  useHtmlConfiguration();

  var e = new DivElement();
  e.style.width = '100px';
  e.style.height = '100px';
  e.style.backgroundColor = 'red';

  document.body.append(e);

  var anim = new Animation();
  anim.addFrame(.5)
    ..marginLeft = '100px';
  anim.addFrame(1.0)
    ..marginLeft = '0px';

  anim.start(e, new Duration(seconds: 3)).onEnd.then((_) {
    print('done!');

    anim.start(e, new Duration(seconds: 2));
  });

  var anim2 = new Animation();
  anim2.addFrame(.5).opacity = '.2';
  anim2.addFrame(1.0).marginLeft = '1';
  anim2.start(e, new Duration(seconds: 5));
}
