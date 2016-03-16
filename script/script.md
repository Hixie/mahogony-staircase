<!--
Copyright (c) 2016, the Flutter project authors.  Please see the AUTHORS file
for details. All rights reserved. Use of this source code is governed by a
BSD-style license that can be found in the LICENSE file.
-->

Flutter: A Walk Up A Mahogony Staircase
=======================================

Prologue
--------

This talk is intended to explain Flutter's design. As such, it starts
from first principles and slowly walks up to the full design. This
means that, especially early in the talk, the code presented will not
be very ergonomic. If you're looking for a tutorial on how to use
Flutter, this is not it. Nor is it a comprehensive API description.

   This is a tutorial: https://flutter.io/tutorial/

   These are our API docs: http://docs.flutter.io/

   This is our Web site with more information: https://flutter.io/


Chapter 1: Let's create an app!
-------------------------------

Let's write a trivial app. It'll just show a table with my wishlist of items I want from the Märklin 2016 model train catalogue.

```
$ flutter create trains
```

Type type type.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter1/trains/lib/main.dart>

```
$ flutter analyze
$ flutter run
```

Success!

Ok. Let's add a checkbox to the first cell of each row so that we can
track which one's I've preordered.
