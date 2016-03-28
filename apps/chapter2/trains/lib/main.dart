import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:mojo/application.dart';
import 'package:mojo/bindings.dart' as mojo;
import 'package:mojo/core.dart' as mojo;
import 'package:mojo/mojo/service_provider.mojom.dart' as mojom;
import 'package:mojo/mojo/shell.mojom.dart' as mojom;
import 'package:mojo/mojo/url_request.mojom.dart' as mojom;
import 'package:mojo/mojo/url_response.mojom.dart' as mojom;
import 'package:mojo_services/mojo/network_service.mojom.dart' as mojom;
import 'package:mojo_services/mojo/url_loader.mojom.dart' as mojom;
import 'package:sky_services/pointer/pointer.mojom.dart' as mojom;

mojom.NetworkServiceProxy networkServiceProxy = _initNetworkServiceProxy();
mojom.NetworkServiceProxy _initNetworkServiceProxy() {
  mojom.Shell shell;
  mojo.MojoHandle shellHandle = new mojo.MojoHandle(MojoServices.takeShell());
  if (shellHandle.isValid)
    shell = new mojom.ShellProxy.fromHandle(shellHandle).ptr;

  ApplicationConnection embedder;
  mojo.MojoHandle incomingServicesHandle = new mojo.MojoHandle(MojoServices.takeIncomingServices());
  mojo.MojoHandle outgoingServicesHandle = new mojo.MojoHandle(MojoServices.takeOutgoingServices());
  if (incomingServicesHandle.isValid && outgoingServicesHandle.isValid) {
    mojom.ServiceProviderProxy incomingServices = new mojom.ServiceProviderProxy.fromHandle(incomingServicesHandle);
    mojom.ServiceProviderStub outgoingServices = new mojom.ServiceProviderStub.fromHandle(outgoingServicesHandle);
    embedder = new ApplicationConnection(outgoingServices, incomingServices);
  }

  assert(shell != null || embedder != null);

  mojom.NetworkServiceProxy result = new mojom.NetworkServiceProxy.unbound();
  if (shell != null) {
    mojom.ServiceProviderProxy services = new mojom.ServiceProviderProxy.unbound();
    shell.connectToApplication('mojo:authenticated_network_service', services, null);
    mojo.MojoMessagePipe pipe = new mojo.MojoMessagePipe();
    result.impl.bind(pipe.endpoints[0]);
    services.ptr.connectToService(result.serviceName, pipe.endpoints[1]);
    services.close();
  } else if (embedder != null) {
    embedder.requestService(result);
  }
  return result;
}

void fetchImage(String url, void callback(Image image)) {
  mojom.UrlRequest request = new mojom.UrlRequest()
    ..url = Uri.base.resolve(url).toString()
    ..autoFollowRedirects = true;
  mojom.UrlLoaderProxy loader = new mojom.UrlLoaderProxy.unbound();
  networkServiceProxy.ptr.createUrlLoader(loader);
  loader.ptr.start(request).then((mojom.UrlLoaderStartResponseParams result) {
    mojom.UrlResponse response = result.response;
    if (response.statusCode != 200)
      return null;
    decodeImageFromDataPipe(response.body.handle.h, callback);
  });
}

class Text {
  Text({ String text, TextStyle textStyle, ParagraphStyle paragraphStyle }) {
    ParagraphBuilder p = new ParagraphBuilder();
    if (textStyle != null)
      p.pushStyle(textStyle);
    p.addText(text);
    _paragraph = p.build(paragraphStyle ?? new ParagraphStyle());
  }

  Paragraph _paragraph;

  double _currentWidth;
  void _layout(double width) {
    assert(width != null);
    if (_currentWidth == width)
      return;
    _currentWidth = width;
    _paragraph.maxWidth = width;
    _paragraph.layout();
  }

  double _naturalMaxWidth;
  double _naturalMinWidth;
  void _ensureNaturalWidths() {
    if (_naturalMinWidth == null) {
      assert(_naturalMaxWidth == null);
      _layout(double.INFINITY);
      _naturalMinWidth = _paragraph.minIntrinsicWidth;
      _naturalMaxWidth = _paragraph.maxIntrinsicWidth;
    }
    assert(_naturalMinWidth != null);
    assert(_naturalMaxWidth != null);
  }
  double get naturalMaxWidth {
    _ensureNaturalWidths();
    return _naturalMaxWidth.ceilToDouble();
  }
  double get naturalMinWidth {
    _ensureNaturalWidths();
    return _naturalMinWidth.ceilToDouble();
  }

  double actualHeight(double width) {
    _layout(width);
    return _paragraph.height.ceilToDouble();
  }

  void paint(Canvas canvas, Rect rect) {
    _layout(rect.width);
    canvas.drawParagraph(_paragraph, rect.topLeft.toOffset());
  }
}

const double captionSize = 24.0;
const double tableTextSize = 16.0;
const double margin = 4.0;
const double iconSize = 24.0;

final TextStyle kCaptionTextStyle = new TextStyle(
  fontSize: tableTextSize,
  fontWeight: FontWeight.bold,
  color: const Color(0xFF000000)
);
final TextStyle kCellTextStyle = new TextStyle(
  fontSize: tableTextSize,
  color: const Color(0xFF004D40)
);

class Train {
  Train(
    String code,
    String imageUrl,
    String description
  ) : code = new Text(
        text: code,
        textStyle: new TextStyle(
          fontSize: tableTextSize,
          color: const Color(0xFF004D40)
        )
      ),
      description = new Text(
        text: description,
        textStyle: kCellTextStyle
      ) {
    fetchImage(imageUrl, (Image resolvedImage) {
      image = resolvedImage;
      window.scheduleFrame();
    });
  }
  final Text code;
  Image image;
  final Text description;

  bool checked = false;

  double yTop;
  double yBottom;
}

final List<Train> kTrainData = <Train>[
  new Train('49954', 'https://static.maerklin.de/media/bc/02/bc028d6e5f98ccaeb344118d64927edd1451859002.jpg', 'Type 100 crane car and type 817 boom tender car.'),
  new Train('26602', 'https://static.maerklin.de/media/cc/b9/ccb96e67093f188d67acb4ca97b407da1452597002.jpg', 'Class Köf II Diesel Locomotive with stake cars loaded with bricks and construction steel mats.'),
  new Train('46925', 'https://static.maerklin.de/media/ad/3f/ad3fa11c35f10737cb54320b9e5c006a1451857433.jpg', 'Set with of two stake cars transporting four brewery tanks (storage tanks).'),
  new Train('46870', 'https://static.maerklin.de/media/ed/36/ed365bf5b8c89cc63d54afa81db80df01451857433.jpg', 'Swiss Federal Railways (SBB) four-axle flat cars with telescoping covers loaded with coils.'),
  new Train('47724', 'https://static.maerklin.de/media/20/fe/20fe74d67d07417352fd08b164f271c41451859002.jpg', 'Swedish State Railways (SJ) two-axle container transport cars loaded with two "Inno freight" WoodTainer XXL containers, painted and lettered for "green cargo".'),
  new Train('47319', 'https://static.maerklin.de/media/6e/32/6e32c9c7153637b9e0d484a1958703191451859002.jpg', 'Four stake cars. One with two sets of short pipes, one with long pipes, one with steel bars, and one with I-beams.'),
];

final Text title = new Text(
  text: 'My 2016 Märklin Trains Wishlist',
  textStyle: new TextStyle(fontSize: captionSize, color: const Color(0xFF4CAF50)),
  paragraphStyle: new ParagraphStyle(textAlign: TextAlign.center)
);
final List<Text> captions = <Text>[
  new Text(text: 'Code', textStyle: kCaptionTextStyle),
  new Text(text: 'Image', textStyle: kCaptionTextStyle),
  new Text(text: 'Description', textStyle: kCaptionTextStyle),
];

void render(Duration duration) {
  final Rect bounds = Point.origin & window.size;
  final PictureRecorder recorder = new PictureRecorder();
  final Canvas c = new Canvas(recorder, bounds);
  Paint background = new Paint()
    ..color = const Color(0xFFFFFFFF);
  c.drawPaint(background);

  final double width = window.size.width - window.padding.left - window.padding.right;

  title.paint(c, new Rect.fromLTWH(
    window.padding.left,
    window.padding.top + margin,
    width,
    captionSize
  ));

  final List<double> columnWidths = captions.map/*<double>*/((Text caption) => caption.naturalMaxWidth + margin * 2.0).toList();
  columnWidths[0] = math.max(columnWidths[0], iconSize + margin * 2.0);
  double imageWidths = 0.0;
  for (int index = 0; index < kTrainData.length; index += 1) {
    Train train = kTrainData[index];
    columnWidths[0] = math.max(columnWidths[0], train.code.naturalMaxWidth + margin * 2.0);
    if (train.image != null)
      imageWidths = math.max(imageWidths, train.image.width.toDouble());
    columnWidths[2] = math.max(columnWidths[2], train.description.naturalMaxWidth + margin * 2.0);
  }
  // make the image column max 40% (and take into account the device pixel ratio)
  columnWidths[1] = math.max(columnWidths[1], math.min(imageWidths / window.devicePixelRatio, width * 0.4));
  columnWidths[2] = width - (columnWidths[0] + columnWidths[1]);

  final Path path = new Path();

  final double tableTop = window.padding.top + margin + title.actualHeight(width) + margin * 2.0;
  double y = tableTop;
  double x = window.padding.left;
  double rowHeight = 0.0;
  for (int index = 0; index < captions.length; index += 1) {
    final double cellInnerWidth = columnWidths[index] - margin * 2.0;
    rowHeight = math.max(rowHeight, captions[index].actualHeight(cellInnerWidth));
    captions[index].paint(c, new Rect.fromLTWH(x + margin, y + margin, cellInnerWidth, rowHeight));
    x += columnWidths[index];
  }
  y += tableTextSize + margin * 2.0;
  for (int index = 0; index < kTrainData.length; index += 1) {
    final Train train = kTrainData[index];
    train.yTop = y;
    x = window.padding.left;
    path.moveTo(x, y);
    y += margin;
    train.code.paint(c, new Rect.fromLTWH(x + margin, y, columnWidths[0] - margin * 2.0, tableTextSize));
    final double codeHeight = train.code.actualHeight(columnWidths[0] - margin * 2.0);
    if (train.checked) {
      Paint paint = new Paint();
      paint.color = const Color(0xFF43A047);
      c.drawCircle(new Point(x + columnWidths[0] / 2.0, y + codeHeight + margin + iconSize / 2.0), iconSize / 2.0, paint);
    }
    final double rowHeight = math.max(
      codeHeight + margin + iconSize,
      train.description.actualHeight(columnWidths[2] - margin * 2.0)
    );
    x += columnWidths[0];
    if (train.image != null) {
      final Rect destRect = new Rect.fromLTWH(x, y - margin, columnWidths[1], rowHeight + margin * 2.0);
      final double sourceHeight = train.image.width.toDouble() * destRect.height / destRect.width;
      final Rect sourceRect = new Rect.fromLTWH(
        0.0,
        (train.image.height.toDouble() - sourceHeight) / 2.0,
        train.image.width.toDouble(),
        sourceHeight
      );
      c.drawImageRect(train.image, sourceRect, destRect, null);
    }
    x += columnWidths[1];
    train.description.paint(c, new Rect.fromLTWH(x + margin, y, columnWidths[2] - margin * 2.0, rowHeight));
    x += columnWidths[2];
    path.lineTo(x, y - margin);
    y += rowHeight + margin;
    train.yBottom = y;
  }
  final double tableBottom = y;

  path.moveTo(window.padding.left + columnWidths[0], tableTop);
  path.lineTo(window.padding.left + columnWidths[0], tableBottom);
  path.moveTo(window.padding.left + columnWidths[0] + columnWidths[1], tableTop);
  path.lineTo(window.padding.left + columnWidths[0] + columnWidths[1], tableBottom);

  Paint lines = new Paint();
  lines.style = PaintingStyle.stroke;
  lines.strokeWidth = 0.0; // hairlines
  c.drawPath(path, lines);

  Picture picture = recorder.endRecording();
  SceneBuilder builder = new SceneBuilder();
  builder.pushTransform(new Float64List.fromList(
    <double>[window.devicePixelRatio, 0.0, 0.0, 0.0,
             0.0, window.devicePixelRatio, 0.0, 0.0,
             0.0, 0.0, 1.0, 0.0,
             0.0, 0.0, 0.0, 1.0]
  ));
  builder.addPicture(Offset.zero, picture);
  Scene scene = builder.build();
  window.render(scene);
}

void handlePointerPacket(ByteData serializedPacket) {
  final mojo.Message message = new mojo.Message(
    serializedPacket,
    const <mojo.MojoHandle>[],
    serializedPacket.lengthInBytes,
    0
  );
  final mojom.PointerPacket packet = mojom.PointerPacket.deserialize(message);
  for (mojom.Pointer event in packet.pointers) {
    if (event.type == mojom.PointerType.down) {
      double y = event.y;
      for (int index = 0; index < kTrainData.length; index += 1) {
        final Train train = kTrainData[index];
        if (train.yTop < y && train.yBottom > y) {
          train.checked = !train.checked;
          window.scheduleFrame();
          break;
        }
      }
    }
  }
}

void main() { 
  window.onBeginFrame = render;
  window.onMetricsChanged = window.scheduleFrame;
  window.onPointerPacket = handlePointerPacket;
  window.scheduleFrame();
}
