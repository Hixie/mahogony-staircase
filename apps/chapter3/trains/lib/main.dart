import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:http/http.dart' as http;

class Train {
  Train(this.code, this.imageUrl, this.description);

  final String code;
  final String imageUrl;
  final String description;

  ui.Image? image;
  RenderImage? imageRenderer;
}

final List<Train> kTrainData = <Train>[
  Train(
      '49954',
      'https://static.maerklin.de/damcontent/bc/02/bc028d6e5f98ccaeb344118d64927edd1451859002.jpg',
      'Type 100 crane car and type 817 boom tender car.'),
  Train(
      '26602',
      'https://static.maerklin.de/damcontent/cc/b9/ccb96e67093f188d67acb4ca97b407da1452597002.jpg',
      'Class Köf II Diesel Locomotive with stake cars loaded with bricks and construction steel mats.'),
  Train(
      '46925',
      'https://static.maerklin.de/damcontent/24/1e/241eb14c3ba5f460a8b4b2ece797c77b1464794782.jpg',
      'Set with of two stake cars transporting four brewery tanks (storage tanks).'),
  Train(
      '46870',
      'https://static.maerklin.de/damcontent/ed/36/ed365bf5b8c89cc63d54afa81db80df01451857433.jpg',
      'Swiss Federal Railways (SBB) four-axle flat cars with telescoping covers loaded with coils.'),
  Train(
      '47724',
      'https://static.maerklin.de/damcontent/20/fe/20fe74d67d07417352fd08b164f271c41451859002.jpg',
      'Swedish State Railways (SJ) two-axle container transport cars loaded with two "Inno freight" WoodTainer XXL containers, painted and lettered for "green cargo".'),
  Train(
      '47319',
      'https://static.maerklin.de/damcontent/6e/32/6e32c9c7153637b9e0d484a1958703191451859002.jpg',
      'Four stake cars. One with two sets of short pipes, one with long pipes, one with steel bars, and one with I-beams.'),
];

const double captionSize = 24.0;
const double tableTextSize = 16.0;
const double margin = 4.0;

const TextStyle kCaptionTextStyle = TextStyle(
  fontSize: tableTextSize,
  fontWeight: FontWeight.bold,
  color: Color(0xFF000000),
);
const TextStyle kCellTextStyle = TextStyle(
  fontSize: tableTextSize,
  color: Color(0xFF004D40),
);

void main() {
  RenderingFlutterBinding(
    root: RenderDecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
      child: RenderPadding(
        padding: EdgeInsets.fromLTRB(
          ui.window.padding.left / ui.window.devicePixelRatio,
          ui.window.padding.top / ui.window.devicePixelRatio,
          ui.window.padding.right / ui.window.devicePixelRatio,
          ui.window.padding.bottom / ui.window.devicePixelRatio,
        ),
        child: RenderViewport(
          crossAxisDirection: AxisDirection.right,
          offset: ViewportOffset.zero(),
          children: [
            RenderSliverToBoxAdapter(
              child: RenderPadding(
                padding: const EdgeInsets.fromLTRB(
                    margin, margin, margin, margin * 2.0),
                child: RenderParagraph(
                  const TextSpan(
                    text: 'My 2016 Märklin Trains Wishlist',
                    style: TextStyle(
                      fontSize: captionSize,
                      color: Color(0xFF4CAF50),
                      // align: TextAlign.center,
                    ),
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
            RenderSliverToBoxAdapter(
              child: RenderTable(
                textDirection: TextDirection.ltr,
                border:
                    TableBorder.symmetric(inside: const BorderSide(width: 0.0)),
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                  1: FractionColumnWidth(0.4),
                  2: FlexColumnWidth(),
                },
                children: List<List<RenderBox>>.from((() sync* {
                  yield <RenderBox>[
                    RenderPadding(
                      padding: const EdgeInsets.all(margin),
                      child: RenderParagraph(
                        const TextSpan(text: 'Code', style: kCaptionTextStyle),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    RenderPadding(
                      padding: const EdgeInsets.all(margin),
                      child: RenderParagraph(
                          const TextSpan(
                              text: 'Image', style: kCaptionTextStyle),
                          textDirection: TextDirection.ltr),
                    ),
                    RenderPadding(
                      padding: const EdgeInsets.all(margin),
                      child: RenderParagraph(
                          const TextSpan(
                              text: 'Description', style: kCaptionTextStyle),
                          textDirection: TextDirection.ltr),
                    ),
                  ];
                  for (Train train in kTrainData) {
                    yield <RenderBox>[
                      RenderPadding(
                          padding: const EdgeInsets.all(margin),
                          child: RenderParagraph(
                            TextSpan(text: train.code, style: kCellTextStyle),
                            textDirection: TextDirection.ltr,
                          )),
                      train.imageRenderer = RenderImage(fit: BoxFit.fitWidth)
                        ..parentData = (TableCellParentData()
                          ..verticalAlignment =
                              TableCellVerticalAlignment.fill),
                      RenderPadding(
                        padding: const EdgeInsets.all(margin),
                        child: RenderParagraph(
                          TextSpan(
                              text: train.description, style: kCellTextStyle),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ];
                  }
                })()),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  for (Train train in kTrainData) {
    fetchImage(train.imageUrl).then((ui.Image image) {
      if (train.imageRenderer != null) {
        train.imageRenderer!.image = image;
      }
    });
  }

  SchedulerBinding.instance!.ensureVisualUpdate();
}

Future<ui.Image> fetchImage(String url) async {
  final response = await http.get(Uri.parse(url));
  return decodeImageFromList(response.bodyBytes);
}
