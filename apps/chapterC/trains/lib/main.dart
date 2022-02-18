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
  Train('49954', 'https://static.maerklin.de/damcontent/bc/02/bc028d6e5f98ccaeb344118d64927edd1451859002.jpg', 'Type 100 crane car and type 817 boom tender car.'),
  Train('26602', 'https://static.maerklin.de/damcontent/cc/b9/ccb96e67093f188d67acb4ca97b407da1452597002.jpg', 'Class Köf II Diesel Locomotive with stake cars loaded with bricks and construction steel mats.'),
  Train('46925', 'https://static.maerklin.de/damcontent/24/1e/241eb14c3ba5f460a8b4b2ece797c77b1464794782.jpg', 'Set with of two stake cars transporting four brewery tanks (storage tanks).'),
  Train('46870', 'https://static.maerklin.de/damcontent/ed/36/ed365bf5b8c89cc63d54afa81db80df01451857433.jpg', 'Swiss Federal Railways (SBB) four-axle flat cars with telescoping covers loaded with coils.'),
  Train('47724', 'https://static.maerklin.de/damcontent/20/fe/20fe74d67d07417352fd08b164f271c41451859002.jpg', 'Swedish State Railways (SJ) two-axle container transport cars loaded with two "Inno freight" WoodTainer XXL containers, painted and lettered for "green cargo".'),
  Train('47319', 'https://static.maerklin.de/damcontent/6e/32/6e32c9c7153637b9e0d484a1958703191451859002.jpg', 'Four stake cars. One with two sets of short pipes, one with long pipes, one with steel bars, and one with I-beams.'),
];

const double captionSize = 24.0;
const double tableTextSize = 16.0;
const double margin = 4.0;
const double iconSize = 24.0;

const TextStyle kCaptionTextStyle = TextStyle(
  fontSize: tableTextSize,
  fontWeight: FontWeight.bold,
  color: Color(0xFF000000)
);

const TextStyle kCellTextStyle = TextStyle(
  fontSize: tableTextSize,
  color: Color(0xFF004D40)
);

class TextCell extends StatelessWidget {
  const TextCell(
      {Key? key, required this.text, required this.style, TextAlign? textAlign})
      : textAlign = textAlign ?? TextAlign.left,
        super(key: key);

  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(margin),
      child: RichText(
        text: TextSpan(
          text: text,
          style: style,
        ),
      ),
    );
  }
}

void main() {
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF)
        ),
        padding: EdgeInsets.fromLTRB(
          ui.window.padding.left / ui.window.devicePixelRatio,
          ui.window.padding.top / ui.window.devicePixelRatio,
          ui.window.padding.right / ui.window.devicePixelRatio,
          ui.window.padding.bottom / ui.window.devicePixelRatio
        ),
        child: Column(
          children: <Widget>[
            const TextCell(
              text: 'My 2016 Märklin Trains Wishlist',
              style: TextStyle(
                fontSize: captionSize,
                color: Color(0xFF4CAF50),
              ),
              textAlign: TextAlign.center,
            ),
            Container(height: margin),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                void handleTrainTap(Train train) {
                  setState(() {
                    train.checked = !train.checked;
                  });
                }
                return Table(
                  border: TableBorder.symmetric(inside: const BorderSide(width: 0.0)),
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: FractionColumnWidth(0.4),
                    2: FlexColumnWidth(),
                  },
                  children: List<TableRow>.from((() sync* {
                    yield const TableRow(
                      children: <Widget>[
                        TextCell(
                          text: 'Code',
                          style: kCaptionTextStyle
                        ),
                        TextCell(
                          text: 'Image',
                          style: kCaptionTextStyle
                        ),
                        TextCell(
                          text: 'Description',
                          style: kCaptionTextStyle
                        ),
                      ]
                    );
                    for (Train train in kTrainData) {
                      yield TableRow(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => handleTrainTap(train),
                            child: Column(
                              children: <Widget>[
                                TextCell(
                                  text: train.code,
                                  style: kCellTextStyle
                                ),
                                Center(
                                  child: AnimatedOpacity(
                                    opacity: train.checked ? 1.0 : 0.0,
                                    curve: Curves.ease,
                                    duration: const Duration(milliseconds: 100),
                                    child: Container(
                                      padding: const EdgeInsets.only(bottom: margin),
                                      height: iconSize,
                                      width: iconSize,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF43A047)
                                      )
                                    )
                                  )
                                )
                              ]
                            )
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.fill,
                            child: GestureDetector(
                              onTap: () => handleTrainTap(train),
                              child: Image.network(
                                train.imageUrl,
                                fit: BoxFit.fitWidth,
                              )
                            )
                          ),
                          GestureDetector(
                            onTap: () => handleTrainTap(train),
                            child: TextCell(
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
      ),
    )
  );
}
