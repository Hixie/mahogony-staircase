import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

class Clock {
  Clock(this.offset, this.label);

  final Duration offset;
  final String label;

  void _prepareHand(double radius, double startOffset, double endOffset, double width, Color color, double elevation, Canvas handCanvas, Canvas shadowCanvas) {
    Path hand = Path();
    hand.moveTo(radius * startOffset, 0.0);
    hand.lineTo(0.0, -radius * width);
    hand.lineTo(radius * endOffset, 0.0);
    hand.lineTo(0.0, radius * width);

    Paint shadowPaint = Paint()
      ..color = const Color(0xFF111111)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, elevation);
    shadowCanvas.drawPath(hand, shadowPaint);

    Paint handPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    handCanvas.drawPath(hand, handPaint);
  }

  Picture _prepareFace(double radius) {
    PictureRecorder recorder = PictureRecorder();
    Canvas c = Canvas(recorder, Rect.fromCircle(center: Offset.zero, radius: radius));

    Paint insidePaint = Paint()
      ..color = const Color(0xFFEEFBF0)
      ..style = PaintingStyle.fill;
    c.drawCircle(Offset.zero, radius, insidePaint);

    Color textColor = const Color(0xFF123177);

    // Clock label
    ParagraphBuilder p = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.center
    ));
    p.pushStyle(TextStyle(
      color: textColor,
      fontSize: radius * 0.15,
      fontWeight: FontWeight.w900
    ));
    p.addText(label);
    Paragraph title = p.build();
    title.layout(ParagraphConstraints(width: radius * 2.0));
    c.drawParagraph(title, Offset(-radius, radius * 0.4));

    Paint markerPaint = Paint()
      ..color = textColor
      ..style = PaintingStyle.fill;
    c.drawCircle(Offset(0.0, -radius * 0.95), radius * 0.02, markerPaint);

    // Rim
    Paint rimPaint = Paint()
      ..color = const Color(0xFF108EB9)
      ..strokeWidth = radius * 0.02
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset.zero, radius, rimPaint);

    return recorder.endRecording();
  }

  double? lastRadius;
  Picture? face;
  Picture? hourHand;
  Picture? hourShadow;
  Picture? minuteHand;
  Picture? minuteShadow;
  Picture? secondHand;
  Picture? secondShadow;
  Picture? top;
  void _preparePictures(double radius) {
    if (lastRadius == radius) {
      return;
    }

    face = _prepareFace(radius);

    Rect bounds = Rect.fromCircle(center: Offset.zero, radius: radius);
    PictureRecorder recorder1, recorder2;

    recorder1 = PictureRecorder();
    recorder2 = PictureRecorder();
    _prepareHand(radius, -0.2, 0.6, 0.08, const Color(0xFF254162), 0.6, Canvas(recorder1, bounds), Canvas(recorder2, bounds));
    hourHand = recorder1.endRecording();
    hourShadow = recorder2.endRecording();

    recorder1 = PictureRecorder();
    recorder2 = PictureRecorder();
    _prepareHand(radius, -0.2, 0.95, 0.04, const Color(0xFF497184), 0.8, Canvas(recorder1, bounds), Canvas(recorder2, bounds));
    minuteHand = recorder1.endRecording();
    minuteShadow = recorder2.endRecording();

    recorder1 = PictureRecorder();
    recorder2 = PictureRecorder();
    _prepareHand(radius, -0.3, 0.975, 0.01, const Color(0xFF52A1B2), 1.0, Canvas(recorder1, bounds), Canvas(recorder2, bounds));
    secondHand = recorder1.endRecording();
    secondShadow = recorder2.endRecording();

    recorder1 = PictureRecorder();
    Canvas c = Canvas(recorder1, bounds);
    Paint centerPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;
    c.drawCircle(Offset.zero, radius * 0.01, centerPaint);
    top = recorder1.endRecording();
  }

  void _paintHand(Canvas c, double value, double radius, Picture hand, Picture shadow) {
    double rotation = math.pi * 2.0 * value - math.pi / 2.0;
    c.save();
    c.translate(0.0, radius * 0.01);
    c.rotate(rotation);
    c.drawPicture(shadow);
    c.restore();
    c.save();
    c.rotate(rotation);
    c.drawPicture(hand);
    c.restore();
  }

  void paint(Canvas c, Offset position, double radius, DateTime utc) {
    _preparePictures(radius);

    assert(face != null);
    assert(hourHand != null);
    assert(hourShadow != null);
    assert(minuteHand != null);
    assert(minuteShadow != null);
    assert(secondHand != null);
    assert(secondShadow != null);
    assert(top != null);

    DateTime time = utc.add(offset);
    int hour = time.hour;
    int minute = time.minute;
    int second = time.second;

    c.save();
    c.translate(position.dx, position.dy);
    c.drawPicture(face!);
    _paintHand(c, (hour.toDouble() + minute.toDouble() / 60.0 + second.toDouble() / 3600.0) / 12.0, radius, hourHand!, hourShadow!);
    _paintHand(c, (minute.toDouble() + second.toDouble() / 60.0) / 60.0, radius, minuteHand!, minuteShadow!);
    _paintHand(c, second.toDouble() / 60.0, radius, secondHand!, secondShadow!);
    c.drawPicture(top!);
    c.restore();
  }
}

Timer? nextTickTimer;
List<Clock> clocks = <Clock>[
  Clock(const Duration(hours: 0), 'UTC'),
  Clock(const Duration(hours: -7), 'MTV'),
  Clock(const Duration(hours: -4), 'NYC'),
  Clock(const Duration(hours: 1), 'ZRH'),
  Clock(const Duration(hours: 11), 'SYD'),
  Clock(const Duration(hours: 9), 'TOK'),
];

Picture? background;

const double captionSize = 64.0;

void render(Duration duration) {
  nextTickTimer?.cancel();
  nextTickTimer = null;

  SceneBuilder builder = SceneBuilder();
  builder.pushTransform(Float64List.fromList(
    <double>[window.devicePixelRatio, 0.0, 0.0, 0.0,
             0.0, window.devicePixelRatio, 0.0, 0.0,
             0.0, 0.0, 1.0, 0.0,
             0.0, 0.0, 0.0, 1.0]
  ));

  final windowSize = (window.physicalSize / window.devicePixelRatio);
  final topPadding = window.padding.top / window.devicePixelRatio;
  final leftPadding = window.padding.left / window.devicePixelRatio;
  final rightPadding = window.padding.right / window.devicePixelRatio;
  Rect bounds = Offset.zero & windowSize;

  if (background == null) {
    // Background
    PictureRecorder recorder = PictureRecorder();
    Canvas c = Canvas(recorder, bounds);
    Paint paint = Paint()
      ..color = const Color(0xFF211231);
    c.drawPaint(paint);

    // Application caption
    ParagraphBuilder p = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.center
    ));
    p.pushStyle(TextStyle(
      fontSize: captionSize
    ));
    p.addText('World Clock');
    Paragraph title = p.build();
    final maxWidth = windowSize.width - leftPadding - rightPadding;
    title.layout(ParagraphConstraints(width: maxWidth));
    c.drawParagraph(title, Offset(leftPadding, topPadding));

    // Save the image
    background = recorder.endRecording();
  }
  builder.addPicture(Offset.zero, background!);

  PictureRecorder recorder = PictureRecorder();
  Canvas c = Canvas(recorder, bounds);

  // Clocks
  final double screenWidth = windowSize.width - leftPadding - rightPadding;
  final double gutter = screenWidth / 20.0;
  final double radius = (screenWidth - gutter * 3) / 4.0;
  final double top = topPadding + captionSize + gutter;
  final double left = leftPadding + gutter;
  DateTime now = DateTime.now().toUtc();
  double y = top + radius;
  clocks[0].paint(c, Offset(left + radius, y), radius, now);
  clocks[1].paint(c, Offset(left + radius + radius + gutter + radius, y), radius, now);
  y += radius + gutter + radius;
  clocks[2].paint(c, Offset(left + radius, y), radius, now);
  clocks[3].paint(c, Offset(left + radius + radius + gutter + radius, y), radius, now);
  y += radius + gutter + radius;
  clocks[4].paint(c, Offset(left + radius, y), radius, now);
  clocks[5].paint(c, Offset(left + radius + radius + gutter + radius, y), radius, now);

  builder.addPicture(Offset.zero, recorder.endRecording());
  builder.addPerformanceOverlay(0x0F, const Rect.fromLTWH(60.0, 260.0, 275.0, 180.0));
  Scene scene = builder.build();
  window.render(scene);

  DateTime nextSecond = DateTime.utc(now.year, now.month, now.day, now.hour, now.minute, now.second + 1);
  nextTickTimer = Timer(nextSecond.difference(now), window.scheduleFrame);
}

void main() { 
  window.onBeginFrame = render;
  window.onMetricsChanged = () {
    background = null;
    window.scheduleFrame();
  };
  window.scheduleFrame();
}
