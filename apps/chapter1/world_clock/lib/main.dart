import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

void paintHand(Canvas c, double radius, double value, double startOffset, double endOffset, double width, Color color, double elevation) {
  Path hand = new Path();
  hand.moveTo(radius * startOffset, 0.0);
  hand.lineTo(0.0, -radius * width);
  hand.lineTo(radius * endOffset, 0.0);
  hand.lineTo(0.0, radius * width);

  double rotation = math.PI * 2.0 * value - math.PI / 2.0;

  Paint shadowPaint = new Paint()
    ..color = const Color(0xFF111111)
    ..maskFilter = new MaskFilter.blur(BlurStyle.normal, elevation);

  c.save();
  c.translate(0.0, radius * 0.01);
  c.rotate(rotation);
  c.drawPath(hand, shadowPaint);
  c.restore();

  Paint handPaint = new Paint()
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

  Paint insidePaint = new Paint()
    ..color = const Color(0xFFEEFBF0)
    ..style = PaintingStyle.fill;
  c.drawCircle(Point.origin, radius, insidePaint);

  Color textColor = const Color(0xFF123177);

  // Clock label
  ParagraphBuilder p = new ParagraphBuilder();
  p.pushStyle(new TextStyle(
    color: textColor,
    fontSize: radius * 0.15,
    fontWeight: FontWeight.w900
  ));
  p.addText(label);
  Paragraph title = p.build(new ParagraphStyle(
    textAlign: TextAlign.center
  ));
  title.maxWidth = radius * 2.0;
  title.layout();
  c.drawParagraph(title, new Offset(-radius, radius * 0.4));

  Paint markerPaint = new Paint()
    ..color = textColor
    ..style = PaintingStyle.fill;
  c.drawCircle(new Point(0.0, -radius * 0.95), radius * 0.02, markerPaint);

  // Rim
  Paint rimPaint = new Paint()
    ..color = const Color(0xFF108EB9)
    ..strokeWidth = radius * 0.02
    ..style = PaintingStyle.stroke;
  c.drawCircle(Point.origin, radius, rimPaint);

  // Hands
  paintHand(c, radius, (hour.toDouble() + minute.toDouble() / 60.0 + second.toDouble() / 3600.0) / 12.0, -0.2, 0.6, 0.08, const Color(0xFF254162), 0.6);
  paintHand(c, radius, (minute.toDouble() + second.toDouble() / 60.0) / 60.0, -0.2, 0.95, 0.04, const Color(0xFF497184), 0.8);
  paintHand(c, radius, second.toDouble() / 60.0, -0.3, 0.975, 0.01, const Color(0xFF52A1B2), 1.0);

  Paint centerPaint = new Paint()
    ..color = const Color(0xFF000000)
    ..style = PaintingStyle.fill;
  c.drawCircle(Point.origin, radius * 0.01, centerPaint);

  c.restore();
}

Timer nextTickTimer;

void render(Duration duration) {
  nextTickTimer?.cancel();
  nextTickTimer = null;

  // Background
  Rect bounds = Point.origin & window.size;
  PictureRecorder recorder = new PictureRecorder();
  Canvas c = new Canvas(recorder, bounds);
  Paint background = new Paint()
    ..color = const Color(0xFF211231);
  c.drawPaint(background);

  // Application caption
  ParagraphBuilder p = new ParagraphBuilder();
  final double captionSize = 64.0;
  p.pushStyle(new TextStyle(
    fontSize: captionSize
  ));
  p.addText('World Clock');
  Paragraph title = p.build(new ParagraphStyle(
    textAlign: TextAlign.center
  ));
  title.maxWidth = window.size.width - window.padding.left - window.padding.right;
  title.layout();
  c.drawParagraph(title, new Offset(window.padding.left, window.padding.top));

  // Clocks
  final double screenWidth = window.size.width - window.padding.left - window.padding.right;
  final double gutter = screenWidth / 20.0;
  final double radius = (screenWidth - gutter * 3) / 4.0;
  final double top = window.padding.top + captionSize + gutter;
  final double left = window.padding.left + gutter;
  DateTime now = new DateTime.now().toUtc();
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
  SceneBuilder builder = new SceneBuilder();
  builder.pushTransform(new Float64List.fromList(
    <double>[window.devicePixelRatio, 0.0, 0.0, 0.0,
             0.0, window.devicePixelRatio, 0.0, 0.0,
             0.0, 0.0, 1.0, 0.0,
             0.0, 0.0, 0.0, 1.0]
  ));
  builder.addPicture(Offset.zero, picture);
  // builder.addPerformanceOverlay(0x0F, new Rect.fromLTWH(60.0, 260.0, 275.0, 180.0));
  Scene scene = builder.build();
  window.render(scene);

  DateTime nextSecond = new DateTime.utc(now.year, now.month, now.day, now.hour, now.minute, now.second + 1);
  nextTickTimer = new Timer(nextSecond.difference(now), window.scheduleFrame);
}

void main() { 
  window.onBeginFrame = render;
  window.onMetricsChanged = window.scheduleFrame;
  window.scheduleFrame();
}
