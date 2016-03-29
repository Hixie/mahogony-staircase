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

Let's write a trivial app. It'll just show a table with my wishlist of
items I want from the Märklin 2016 model train catalogue.

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

Pros of this approach: There's only one code path.
Cons of this approach: You do a ton of work every frame.


Chapter 2: Adding more to the app
---------------------------------

Ok. Let's add a checkbox to the first cell of each row so that we can
track which one's I've preordered.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter2/trains/lib/main.dart>


Chapter 3: Rendering library
----------------------------

Having to do all these calculations is ridiculous.

Let's use a library that provides render objects.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter3/trains/lib/main.dart>

Side bar: Let's explain what's going on here.


Chapter 4: Adding more to the app
---------------------------------

Let's add the "checkbox" again.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter4/trains/lib/main.dart>


Chapter 5: Widgets
------------------

Having to first build the app and then poke at it is error-prone.
Let's use a library that provides an abstraction over the render
objects so that you just build the app each time and it efficiently
redoes the layout only as needed.

![This is the third time I've written this app, and I'm getting exceedingly efficient at it.](https://i.ytimg.com/vi/ZKpFFD7aX3c/maxresdefault.jpg)

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter5/trains/lib/main.dart>

Side bar: Let's explain what's going on here.


Chapter 6: Adding more to the app
---------------------------------

Let's add the "checkbox" again.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter6/trains/lib/main.dart>


Chapter 7: Stateful builder
---------------------------

We can move the state back into the tree using a StatefulBuilder.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter7/trains/lib/main.dart>


Chapter 8: Stateful widgets
---------------------------

Code reuse demands that we be able to extract these little bits out.

We want to have a State that lives longer than the Widgets, so we have
the Widget create a State the first time the tree is built, and then
we reuse it later.

Thus, NetworkImage!

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter8/trains/lib/main.dart>

Turns out that is one of our built-in components, so we can just
remove all this code.


Chapter 9: Stateless stateful widgets
-------------------------------------

One pattern we use a lot here is this padding + text pattern. Since we
now know how to create reusable components, let's make one for this
pattern.

We can even use this for the title, if we take out half the bottom
padding and put it after the title.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapter9/trains/lib/main.dart>


Chapter A: Stateless stateful widgets
-------------------------------------

We don't really need two classes here. We could put our build()
function on the Widget, and make a subclass of State that just always
calls it. That way, when the object has no state, we'd just use that
State and not need to create one ourselves.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapterA/trains/lib/main.dart>


Chapter B: Stateless stateful widgets
-------------------------------------

That's what StatelessWidget is.

<https://github.com/Hixie/mahogony-staircase/blob/master/apps/chapterB/trains/lib/main.dart>
