import 'package:flutter/material.dart';

class Train {
  Train(this.code, this.imageUrl, this.description);
  final String code;
  final String imageUrl;
  final String description;

  bool checked = false;
}

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
  const TextCell({
    Key? key,
    required this.text,
    required this.style,
    TextAlign? textAlign,
  })  : textAlign = textAlign ?? TextAlign.left,
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
        textAlign: textAlign,
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'My 2016 Märklin Trains Wishlist',
      theme: ThemeData(
        brightness: Brightness?.light,
        primarySwatch: Colors.green
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const Wishlist()
      }
    )
  );
}

class Wishlist extends StatefulWidget {
  const Wishlist({ Key? key }) : super(key: key);

  @override
  _WishlistState createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {

  final List<Train> kTrainData = <Train>[
    Train('49954', 'https://static.maerklin.de/damcontent/bc/02/bc028d6e5f98ccaeb344118d64927edd1451859002.jpg', 'Type 100 crane car and type 817 boom tender car.'),
    Train('26602', 'https://static.maerklin.de/damcontent/cc/b9/ccb96e67093f188d67acb4ca97b407da1452597002.jpg', 'Class Köf II Diesel Locomotive with stake cars loaded with bricks and construction steel mats.'),
    Train('46925', 'https://static.maerklin.de/damcontent/24/1e/241eb14c3ba5f460a8b4b2ece797c77b1464794782.jpg', 'Set with of two stake cars transporting four brewery tanks (storage tanks).'),
    Train('46870', 'https://static.maerklin.de/damcontent/ed/36/ed365bf5b8c89cc63d54afa81db80df01451857433.jpg', 'Swiss Federal Railways (SBB) four-axle flat cars with telescoping covers loaded with coils.'),
    Train('47724', 'https://static.maerklin.de/damcontent/20/fe/20fe74d67d07417352fd08b164f271c41451859002.jpg', 'Swedish State Railways (SJ) two-axle container transport cars loaded with two "Inno freight" WoodTainer XXL containers, painted and lettered for "green cargo".'),
    Train('47319', 'https://static.maerklin.de/damcontent/6e/32/6e32c9c7153637b9e0d484a1958703191451859002.jpg', 'Four stake cars. One with two sets of short pipes, one with long pipes, one with steel bars, and one with I-beams.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My 2016 Märklin Trains Wishlist')
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Table(
              border: TableBorder.symmetric(inside: const BorderSide(width: 0.0)),
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(),
                1: FractionColumnWidth(0.4),
                2: FlexColumnWidth(),
              },
              children: buildTableChildren().toList(growable: false)
            )
          ]
        ),
      )
    );
  }

  Iterable<TableRow> buildTableChildren() sync* {
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
          Column(
            children: <Widget>[
              TextCell(
                text: train.code,
                style: kCellTextStyle
              ),
              Center(
                child: Checkbox(
                  value: train.checked,
                  onChanged: (bool? value) { setState(() { train.checked = value!; }); }
                )
              )
            ]
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.fill,
            child: InkWell(
              onTap: () { setState(() { train.checked = !train.checked; }); },
              child: Image.network(
                train.imageUrl,
                fit: BoxFit.fitWidth,
              )
            )
          ),
          InkWell(
            onTap: () { setState(() { train.checked = !train.checked; }); },
            child: TextCell(
              text: train.description,
              style: kCellTextStyle
            )
          ),
        ]
      );
    }
  }
}
