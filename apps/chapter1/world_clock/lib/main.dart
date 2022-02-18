import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

void paintHand(Canvas c, double radius, double value, double startOffset, double endOffset, double width, Color color, double elevation) {
  Path hand = Path();
  hand.moveTo(radius * startOffset, 0.0);
  hand.lineTo(0.0, -radius * width);
  hand.lineTo(radius * endOffset, 0.0);
  hand.lineTo(0.0, radius * width);

  double rotation = math.pi * 2.0 * value - math.pi / 2.0;

  Paint shadowPaint = Paint()
    ..color = const Color(0xFF111111)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, elevation);

  c.save();
  c.translate(0.0, radius * 0.01);
  c.rotate(rotation);
  c.drawPath(hand, shadowPaint);
  c.restore();

  Paint handPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  c.save();
  c.rotate(rotation);
  c.drawPath(hand, handPaint);
  c.restore();
}

void paintClock(Canvas c, double x, double y, double radius, DateTime utc, Duration offset, String label) {
  DateTime time = utc.add(offset);
  int hour = time.hour;
  int minute = time.minute;
  int second = time.second;

  c.save();
  c.translate(x, y);

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

  // Hands
  paintHand(c, radius, (hour.toDouble() + minute.toDouble() / 60.0 + second.toDouble() / 3600.0) / 12.0, -0.2, 0.6, 0.08, const Color(0xFF254162), 0.6);
  paintHand(c, radius, (minute.toDouble() + second.toDouble() / 60.0) / 60.0, -0.2, 0.95, 0.04, const Color(0xFF497184), 0.8);
  paintHand(c, radius, second.toDouble() / 60.0, -0.3, 0.975, 0.01, const Color(0xFF52A1B2), 1.0);

  Paint centerPaint = Paint()
    ..color = const Color(0xFF000000)
    ..style = PaintingStyle.fill;
  c.drawCircle(Offset.zero, radius * 0.01, centerPaint);

  c.restore();
}

Timer? nextTickTimer;

void render(Duration duration) {
  nextTickTimer?.cancel();
  nextTickTimer = null;

  final windowSize = window.physicalSize / window.devicePixelRatio;
  final leftPadding = window.padding.left / window.devicePixelRatio;
  final rightPadding = window.padding.right / window.devicePixelRatio;
  final topPadding = window.padding.top / window.devicePixelRatio;

  // Background
  Rect bounds = Offset.zero & windowSize;
  PictureRecorder recorder = PictureRecorder();
  Canvas c = Canvas(recorder, bounds);
  Paint background = Paint()
    ..color = const Color(0xFF211231);
  c.drawPaint(background);

  // Application caption
  ParagraphBuilder p = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.center
  ));
  const double captionSize = 64.0;
  p.pushStyle(TextStyle(
    fontSize: captionSize
  ));
  p.addText('World Clock');
  Paragraph title = p.build();
  final maxWidth = windowSize.width - leftPadding - topPadding;
  title.layout(ParagraphConstraints(width: maxWidth));
  c.drawParagraph(title, Offset(leftPadding, topPadding));

  // Clocks
  final double screenWidth = windowSize.width - leftPadding - rightPadding;
  final double gutter = screenWidth / 20.0;
  final double radius = (screenWidth - gutter * 3) / 4.0;
  final double top = topPadding + captionSize + gutter;
  final double left = leftPadding + gutter;
  DateTime now = DateTime.now().toUtc();
  double y = top + radius;
  paintClock(c, left + radius, y, radius, now, const Duration(hours: 0), 'UTC');
  paintClock(c, left + radius + radius + gutter + radius, y, radius, now, const Duration(hours: -7), 'MTV');
  y += radius + gutter + radius;
  paintClock(c, left + radius, y, radius, now, const Duration(hours: -4), 'NYC');
  paintClock(c, left + radius + radius + gutter + radius, y, radius, now, const Duration(hours: 1), 'ZRH');
  y += radius + gutter + radius;
  paintClock(c, left + radius, y, radius, now, const Duration(hours: 11), 'SYD');
  paintClock(c, left + radius + radius + gutter + radius, y, radius, now, const Duration(hours: 9), 'TOK');

  // Send to GPU
  Picture picture = recorder.endRecording();
  SceneBuilder builder = SceneBuilder();
  builder.pushTransform(Float64List.fromList(
    <double>[window.devicePixelRatio, 0.0, 0.0, 0.0,
             0.0, window.devicePixelRatio, 0.0, 0.0,
             0.0, 0.0, 1.0, 0.0,
             0.0, 0.0, 0.0, 1.0]
  ));
  builder.addPicture(Offset.zero, picture);
  // builder.addPerformanceOverlay(0x0F, Rect.fromLTWH(60.0, 260.0, 275.0, 180.0));
  Scene scene = builder.build();
  window.render(scene);

  DateTime nextSecond = DateTime.utc(now.year, now.month, now.day, now.hour, now.minute, now.second + 1);
  nextTickTimer = Timer(nextSecond.difference(now), window.scheduleFrame);
}

void main() { 
  window.onBeginFrame = render;
  window.onMetricsChanged = window.scheduleFrame;
  window.scheduleFrame();
}
