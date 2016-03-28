import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

class Train {
  Train(this.code, this.imageUrl, this.description);
  final String code;
  final String imageUrl;
  final String description;

  ui.Image image;
  RenderImage imageRenderer;
}

final List<Train> kTrainData = <Train>[
  new Train('49954', 'https://static.maerklin.de/media/bc/02/bc028d6e5f98ccaeb344118d64927edd1451859002.jpg', 'Type 100 crane car and type 817 boom tender car.'),
  new Train('26602', 'https://static.maerklin.de/media/cc/b9/ccb96e67093f188d67acb4ca97b407da1452597002.jpg', 'Class Köf II Diesel Locomotive with stake cars loaded with bricks and construction steel mats.'),
  new Train('46925', 'https://static.maerklin.de/media/ad/3f/ad3fa11c35f10737cb54320b9e5c006a1451857433.jpg', 'Set with of two stake cars transporting four brewery tanks (storage tanks).'),
  new Train('46870', 'https://static.maerklin.de/media/ed/36/ed365bf5b8c89cc63d54afa81db80df01451857433.jpg', 'Swiss Federal Railways (SBB) four-axle flat cars with telescoping covers loaded with coils.'),
  new Train('47724', 'https://static.maerklin.de/media/20/fe/20fe74d67d07417352fd08b164f271c41451859002.jpg', 'Swedish State Railways (SJ) two-axle container transport cars loaded with two "Inno freight" WoodTainer XXL containers, painted and lettered for "green cargo".'),
  new Train('47319', 'https://static.maerklin.de/media/6e/32/6e32c9c7153637b9e0d484a1958703191451859002.jpg', 'Four stake cars. One with two sets of short pipes, one with long pipes, one with steel bars, and one with I-beams.'),
];

const double captionSize = 24.0;
const double tableTextSize = 16.0;
const double horizontalPadding = 4.0;
const double verticalPadding = 4.0;
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

void main() { 
  new RenderingFlutterBinding(
    root: new RenderDecoratedBox(
      decoration: new BoxDecoration(
        backgroundColor: const Color(0xFFFFFFFF)
      ),
      child: new RenderPadding(
        padding: new EdgeInsets.fromLTRB(
          ui.window.padding.left,
          ui.window.padding.top,
          ui.window.padding.right,
          ui.window.padding.bottom
        ),
        child: new RenderViewport(
          child: new RenderBlock(
            children: <RenderBox>[
              new RenderPadding(
                padding: new EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0),
                child: new RenderParagraph(
                  new TextSpan(
                    text: 'My 2016 Märklin Trains Wishlist',
                    style: new TextStyle(
                      fontSize: captionSize,
                      color: const Color(0xFF4CAF50),
                      textAlign: TextAlign.center
                    )
                  )
                )
              ),
              new RenderTable(
                border: new TableBorder.symmetric(inside: new BorderSide(width: 1.0)),
                columnWidths: const <int, TableColumnWidth>{
                  0: const IntrinsicColumnWidth(),
                  1: const MaxColumnWidth(const IntrinsicColumnWidth(), const FractionColumnWidth(0.4)),
                  2: const FlexColumnWidth(),
                },
                children: new List<List<RenderBox>>.from((() sync* {
                  yield <RenderBox>[
                    new RenderPadding(
                      padding: new EdgeInsets.all(4.0),
                      child: new RenderParagraph(
                        new TextSpan(
                          text: 'Code',
                          style: kCaptionTextStyle
                        )
                      )
                    ),
                    new RenderPadding(
                      padding: new EdgeInsets.all(4.0),
                      child: new RenderParagraph(
                        new TextSpan(
                          text: 'Image',
                          style: kCaptionTextStyle
                        )
                      )
                    ),
                    new RenderPadding(
                      padding: new EdgeInsets.all(4.0),
                      child: new RenderParagraph(
                        new TextSpan(
                          text: 'Description',
                          style: kCaptionTextStyle
                        )
                      )
                    ),
                  ];
                  for (Train train in kTrainData) {
                    yield <RenderBox>[
                      new RenderPadding(
                        padding: new EdgeInsets.all(4.0),
                        child: new RenderParagraph(
                          new TextSpan(
                            text: train.code,
                            style: kCellTextStyle
                          )
                        )
                      ),
                      train.imageRenderer = new RenderImage(
                        fit: ImageFit.fitWidth
                      )..parentData = (new TableCellParentData()..verticalAlignment = TableCellVerticalAlignment.fill),
                      new RenderPadding(
                        padding: new EdgeInsets.all(4.0),
                        child: new RenderParagraph(
                          new TextSpan(
                            text: train.description,
                            style: kCellTextStyle
                          )
                        )
                      ),
                    ];
                  }
                })())
              ),
            ]
          )
        )
      )
    )
  );
  for (Train train in kTrainData) {
    ImageResource resource = imageCache.load(train.imageUrl);
    resource.first.then((ImageInfo imageInfo) {
      train.imageRenderer.image = imageInfo.image;
    });
  }
}
