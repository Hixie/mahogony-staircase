import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class NetworkImage extends StatefulWidget {
  const NetworkImage({ Key? key, required this.src, required this.fit }) : super(key: key);

  final String src;
  final BoxFit fit;

  @override
  NetworkImageState createState() => NetworkImageState();
}

class NetworkImageState extends State<NetworkImage> {

  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    loadImage();
  }


  @override
  void didUpdateWidget(NetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      loadImage();
    }
  }

  void loadImage() async {
    final response = await http.get(Uri.parse(widget.src));
    final image = await decodeImageFromList(response.bodyBytes);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: _image,
      fit: widget.fit
    );
  }
}

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

void main() {
  runApp(
    DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF)
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ui.window.padding.left / ui.window.devicePixelRatio,
          ui.window.padding.top / ui.window.devicePixelRatio,
          ui.window.padding.right / ui.window.devicePixelRatio,
          ui.window.padding.bottom / ui.window.devicePixelRatio
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(margin, margin, margin, margin * 2.0),
                    child: RichText(
                        text: const TextSpan(
                            text: 'My 2016 Märklin Trains Wishlist',
                            style: TextStyle(
                                fontSize: captionSize,
                                color: Color(0xFF4CAF50),
                            ),
                        ),
                        textAlign: TextAlign.center
                    )
                ),
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      void handlePointerDown(Train train) {
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
                            yield TableRow(
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.all(margin),
                                      child: RichText(
                                          text: const TextSpan(
                                              text: 'Code',
                                              style: kCaptionTextStyle
                                          )
                                      )
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(margin),
                                      child: RichText(
                                          text: const TextSpan(
                                              text: 'Image',
                                              style: kCaptionTextStyle
                                          )
                                      )
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(margin),
                                      child: RichText(
                                          text: const TextSpan(
                                              text: 'Description',
                                              style: kCaptionTextStyle
                                          )
                                      )
                                  ),
                                ]
                            );
                            for (Train train in kTrainData) {
                              yield TableRow(
                                  children: <Widget>[
                                    Listener(
                                        onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                                        child: Column(
                                            children: <Widget>[
                                              Padding(
                                                  padding: const EdgeInsets.all(margin),
                                                  child: RichText(
                                                      text: TextSpan(
                                                          text: train.code,
                                                          style: kCellTextStyle
                                                      )
                                                  )
                                              ),
                                              Opacity(
                                                  opacity: train.checked ? 1.0 : 0.0,
                                                  child: Padding(
                                                      padding: const EdgeInsets.only(bottom: margin),
                                                      child: Align(
                                                          child: ConstrainedBox(
                                                              constraints: BoxConstraints.tight(const Size(iconSize, iconSize)),
                                                              child: const DecoratedBox(
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      color: Color(0xFF43A047)
                                                                  )
                                                              )
                                                          )
                                                      )
                                                  )
                                              )
                                            ]
                                        )
                                    ),
                                    TableCell(
                                        verticalAlignment: TableCellVerticalAlignment.fill,
                                        child: Listener(
                                            onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                                            child: NetworkImage(
                                                fit: BoxFit.fitWidth,
                                                src: train.imageUrl
                                            )
                                        )
                                    ),
                                    Listener(
                                        onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                                        child: Padding(
                                            padding: const EdgeInsets.all(margin),
                                            child: RichText(
                                                text:TextSpan(
                                                    text: train.description,
                                                    style: kCellTextStyle
                                                )
                                            )
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
          ),
        )
      )
    )
  );
}
