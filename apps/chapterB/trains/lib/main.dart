import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

class Train {
  Train(this.code, this.imageUrl, this.description);
  final String code;
  final String imageUrl;
  final String description;

  bool checked = false;
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

class TextCell extends StatelessWidget {
  TextCell({ this.text, this.style });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.all(margin),
      child: new RichText(
        text: new TextSpan(
          text: text,
          style: style
        )
      )
    );
  }
}

void main() {
  runApp(
    new DecoratedBox(
      decoration: new BoxDecoration(
        backgroundColor: const Color(0xFFFFFFFF)
      ),
      child: new Padding(
        padding: new EdgeInsets.fromLTRB(
          ui.window.padding.left,
          ui.window.padding.top,
          ui.window.padding.right,
          ui.window.padding.bottom
        ),
        child: new Viewport(
          child: new BlockBody(
            children: <Widget>[
              new TextCell(
                text: 'My 2016 Märklin Trains Wishlist',
                style: new TextStyle(
                  fontSize: captionSize,
                  color: const Color(0xFF4CAF50),
                  textAlign: TextAlign.center
                )
              ),
              new Padding(
                padding: new EdgeInsets.only(bottom: margin)
              ),
              new StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  void handlePointerDown(Train train) {
                    setState(() {
                      train.checked = !train.checked;
                    });
                  }
                  return new Table(
                    border: new TableBorder.symmetric(inside: new BorderSide(width: 0.0)),
                    columnWidths: const <int, TableColumnWidth>{
                      0: const IntrinsicColumnWidth(),
                      1: const MaxColumnWidth(const IntrinsicColumnWidth(), const FractionColumnWidth(0.4)),
                      2: const FlexColumnWidth(),
                    },
                    children: new List<TableRow>.from((() sync* {
                      yield new TableRow(
                        children: <Widget>[
                          new TextCell(
                            text: 'Code',
                            style: kCaptionTextStyle
                          ),
                          new TextCell(
                            text: 'Image',
                            style: kCaptionTextStyle
                          ),
                          new TextCell(
                            text: 'Description',
                            style: kCaptionTextStyle
                          ),
                        ]
                      );
                      for (Train train in kTrainData) {
                        yield new TableRow(
                          children: <Widget>[
                            new Listener(
                              onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                              child: new BlockBody(
                                children: <Widget>[
                                  new TextCell(
                                    text: train.code,
                                    style: kCellTextStyle
                                  ),
                                  new Opacity(
                                    opacity: train.checked ? 1.0 : 0.0,
                                    child: new Padding(
                                      padding: new EdgeInsets.only(top: margin),
                                      child: new Align(
                                        child: new ConstrainedBox(
                                          constraints: new BoxConstraints.tight(const Size(iconSize, iconSize)),
                                          child: new DecoratedBox(
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              backgroundColor: const Color(0xFF43A047)
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                ]
                              )
                            ),
                            new Cell(
                              verticalAlignment: TableCellVerticalAlignment.fill,
                              child: new Listener(
                                onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                                child: new NetworkImage(
                                  fit: ImageFit.fitWidth,
                                  src: train.imageUrl
                                )
                              )
                            ),
                            new Listener(
                              onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                              child: new TextCell(
                                text: train.description,
                                style: kCellTextStyle
                              )
                            ),
                          ]
                        );
                      }
                    })())
                  );
                }
              )
            ]
          )
        )
      )
    )
  );
}
