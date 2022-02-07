import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:http/http.dart' as http;

void fetchImage(String url, void Function(Image image) callback) async {
  final response = await http.get(Uri.parse(url));
  final buffer = await ImmutableBuffer.fromUint8List(response.bodyBytes);
  final imageDescriptor = await ImageDescriptor.encoded(buffer);
  final codec = await imageDescriptor.instantiateCodec();
  final frameInfo = await codec.getNextFrame();

  final image = frameInfo.image;

  codec.dispose();
  imageDescriptor.dispose();
  buffer.dispose();

  callback(image);
}

class Text {
  Text({ required String text, TextStyle? textStyle, ParagraphStyle? paragraphStyle }) {
    ParagraphBuilder p = ParagraphBuilder(paragraphStyle ?? ParagraphStyle());
    if (textStyle != null) {
      p.pushStyle(textStyle);
    }
    p.addText(text);
    _paragraph = p.build();
  }

  late Paragraph _paragraph;

  double? _currentWidth;
  void _layout(double width) {
    if (_currentWidth == width) {
      return;
    }
    _currentWidth = width;
    _paragraph.layout(ParagraphConstraints(width: width));
  }

  double? _naturalMaxWidth;
  double? _naturalMinWidth;
  void _ensureNaturalWidths() {
    if (_naturalMinWidth == null) {
      assert(_naturalMaxWidth == null);
      _layout(double.infinity);
      _naturalMinWidth = _paragraph.minIntrinsicWidth;
      _naturalMaxWidth = _paragraph.maxIntrinsicWidth;
    }
    assert(_naturalMinWidth != null);
    assert(_naturalMaxWidth != null);
  }
  double get naturalMaxWidth {
    _ensureNaturalWidths();
    return _naturalMaxWidth!.ceilToDouble();
  }
  double get naturalMinWidth {
    _ensureNaturalWidths();
    return _naturalMinWidth!.ceilToDouble();
  }

  double actualHeight(double width) {
    _layout(width);
    return _paragraph.height.ceilToDouble();
  }

  void paint(Canvas canvas, Rect rect) {
    _layout(rect.width);
    canvas.drawParagraph(_paragraph, rect.topLeft);
  }
}

const double captionSize = 24.0;
const double tableTextSize = 16.0;
const double margin = 4.0;

final TextStyle kCaptionTextStyle = TextStyle(
  fontSize: tableTextSize,
  fontWeight: FontWeight.bold,
  color: const Color(0xFF000000)
);
final TextStyle kCellTextStyle = TextStyle(
  fontSize: tableTextSize,
  color: const Color(0xFF004D40)
);

class Train {
  Train(
    String code,
    String imageUrl,
    String description
  ) : code = Text(
        text: code,
        textStyle: TextStyle(
          fontSize: tableTextSize,
          color: const Color(0xFF004D40)
        )
      ),
      description = Text(
        text: description,
        textStyle: kCellTextStyle
      ) {
    fetchImage(imageUrl, (Image resolvedImage) {
      image = resolvedImage;
      window.scheduleFrame();
    });
  }
  final Text code;
  Image? image;
  final Text description;
}

final List<Train> kTrainData = <Train>[
  Train('49954', 'https://static.maerklin.de/damcontent/bc/02/bc028d6e5f98ccaeb344118d64927edd1451859002.jpg', 'Type 100 crane car and type 817 boom tender car.'),
  Train('26602', 'https://static.maerklin.de/damcontent/cc/b9/ccb96e67093f188d67acb4ca97b407da1452597002.jpg', 'Class Köf II Diesel Locomotive with stake cars loaded with bricks and construction steel mats.'),
  Train('46925', 'https://static.maerklin.de/damcontent/24/1e/241eb14c3ba5f460a8b4b2ece797c77b1464794782.jpg', 'Set with of two stake cars transporting four brewery tanks (storage tanks).'),
  Train('46870', 'https://static.maerklin.de/damcontent/ed/36/ed365bf5b8c89cc63d54afa81db80df01451857433.jpg', 'Swiss Federal Railways (SBB) four-axle flat cars with telescoping covers loaded with coils.'),
  Train('47724', 'https://static.maerklin.de/damcontent/20/fe/20fe74d67d07417352fd08b164f271c41451859002.jpg', 'Swedish State Railways (SJ) two-axle container transport cars loaded with two "Inno freight" WoodTainer XXL containers, painted and lettered for "green cargo".'),
  Train('47319', 'https://static.maerklin.de/damcontent/6e/32/6e32c9c7153637b9e0d484a1958703191451859002.jpg', 'Four stake cars. One with two sets of short pipes, one with long pipes, one with steel bars, and one with I-beams.'),
];

final Text title = Text(
  text: 'My 2016 Märklin Trains Wishlist',
  textStyle: TextStyle(fontSize: captionSize, color: const Color(0xFF4CAF50)),
  paragraphStyle: ParagraphStyle(textAlign: TextAlign.center)
);

final List<Text> captions = <Text>[
  Text(text: 'Code', textStyle: kCaptionTextStyle),
  Text(text: 'Image', textStyle: kCaptionTextStyle),
  Text(text: 'Description', textStyle: kCaptionTextStyle),
];

void render(Duration duration) {
  final windowSize = window.physicalSize / window.devicePixelRatio;
  final topPadding = window.padding.top / window.devicePixelRatio;
  final leftPadding = window.padding.left / window.devicePixelRatio;
  final rightPadding = window.padding.right / window.devicePixelRatio;

  final Rect bounds = Offset.zero & windowSize;
  final PictureRecorder recorder = PictureRecorder();
  final Canvas c = Canvas(recorder, bounds);
  Paint background = Paint()
    ..color = const Color(0xffffffff);
  c.drawPaint(background);

  final double width = windowSize.width - leftPadding - rightPadding;

  title.paint(c, Rect.fromLTWH(
    leftPadding,
    topPadding + margin,
    width,
    captionSize
  ));

  final List<double> columnWidths = captions.map((Text caption) => caption.naturalMaxWidth + margin * 2.0).toList();
  double imageWidths = 0.0;
  for (int index = 0; index < kTrainData.length; index += 1) {
    Train train = kTrainData[index];
    columnWidths[0] = math.max(columnWidths[0], train.code.naturalMaxWidth + margin * 2.0);
    if (train.image != null) {
      imageWidths = math.max(imageWidths, train.image!.width.toDouble());
    }
    columnWidths[2] = math.max(columnWidths[2], train.description.naturalMaxWidth + margin * 2.0);
  }
  // make the image column max 40% (and take into account the device pixel ratio)
  columnWidths[1] = math.max(columnWidths[1], math.min(imageWidths / window.devicePixelRatio, width * 0.4));
  columnWidths[2] = width - (columnWidths[0] + columnWidths[1]);

  final Path path = Path();

  final double tableTop = topPadding + margin + title.actualHeight(width) + margin * 2.0;
  double y = tableTop;
  double x = leftPadding;
  double rowHeight = 0.0;
  for (int index = 0; index < captions.length; index += 1) {
    final double cellInnerWidth = columnWidths[index] - margin * 2.0;
    rowHeight = math.max(rowHeight, captions[index].actualHeight(cellInnerWidth));
    captions[index].paint(c, Rect.fromLTWH(x + margin, y + margin, cellInnerWidth, rowHeight));
    x += columnWidths[index];
  }
  y += tableTextSize + margin * 2.0;
  for (int index = 0; index < kTrainData.length; index += 1) {
    final Train train = kTrainData[index];
    y += margin;
    x = leftPadding;
    path.moveTo(x, y);
    train.code.paint(c, Rect.fromLTWH(x + margin, y + margin, columnWidths[0] - margin * 2.0, tableTextSize));
    final double rowHeight = math.max(train.description.actualHeight(columnWidths[2] - margin * 2.0), tableTextSize);
    x += columnWidths[0];
    if (train.image != null) {
      final Rect destRect = Rect.fromLTWH(x, y, columnWidths[1], rowHeight + margin * 2.0);
      final double sourceHeight = train.image!.width.toDouble() * destRect.height / destRect.width;
      final Rect sourceRect = Rect.fromLTWH(
        0.0,
        (train.image!.height.toDouble() - sourceHeight) / 2.0,
        train.image!.width.toDouble(),
        sourceHeight
      );
      c.drawImageRect(train.image!, sourceRect, destRect, Paint());
    }
    x += columnWidths[1];
    train.description.paint(c, Rect.fromLTWH(x + margin, y + margin, columnWidths[2] - margin * 2.0, rowHeight));
    x += columnWidths[2];
    path.lineTo(x, y);
    y += rowHeight + margin;
  }
  final double tableBottom = y;

  path.moveTo(leftPadding + columnWidths[0], tableTop);
  path.lineTo(leftPadding + columnWidths[0], tableBottom);
  path.moveTo(leftPadding + columnWidths[0] + columnWidths[1], tableTop);
  path.lineTo(leftPadding + columnWidths[0] + columnWidths[1], tableBottom);

  Paint lines = Paint();
  lines.style = PaintingStyle.stroke;
  lines.strokeWidth = 0.0; // hairlines
  c.drawPath(path, lines);

  Picture picture = recorder.endRecording();
  SceneBuilder builder = SceneBuilder();
  builder.pushTransform(Float64List.fromList(
    <double>[window.devicePixelRatio, 0.0, 0.0, 0.0,
             0.0, window.devicePixelRatio, 0.0, 0.0,
             0.0, 0.0, 1.0, 0.0,
             0.0, 0.0, 0.0, 1.0]
  ));
  builder.addPicture(Offset.zero, picture);
  Scene scene = builder.build();
  window.render(scene);
}

void main() {
  window.onBeginFrame = render;
  window.onMetricsChanged = window.scheduleFrame;
  window.scheduleFrame();
}
