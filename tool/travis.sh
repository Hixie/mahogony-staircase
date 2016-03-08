#!/bin/bash

# Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

pushd ..
git clone https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:`pwd`/flutter/bin/cache/dart-sdk/bin:$PATH
flutter doctor
popd

(cd apps/chapter1/world_clock; pub get)
(cd apps/chapter1/world_clock; flutter analyze)
# (cd apps/chapter1/world_clock; flutter test)
