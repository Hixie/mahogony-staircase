import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
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


abstract class ColumnWidth {
  const ColumnWidth();

  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth);

  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth);

  double flex(Iterable<RenderBox> cells) => null;
}

class IntrinsicColumnWidth extends ColumnWidth { 
  const IntrinsicColumnWidth();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    double result = 0.0;
    for (RenderBox cell in cells)
      result = math.max(result, cell.getMinIntrinsicWidth(const BoxConstraints()));
    return result;
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    double result = 0.0;
    for (RenderBox cell in cells)
      result = math.max(result, cell.getMaxIntrinsicWidth(const BoxConstraints()));
    return result;
  }
}

class FixedColumnWidth extends ColumnWidth {
  const FixedColumnWidth(this.value);
  final double value;

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value;
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value;
  }
}

class FractionColumnWidth extends ColumnWidth {
  const FractionColumnWidth(this.value);
  final double value;

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    if (!containerWidth.isFinite)
      return 0.0;
    return value * containerWidth;
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    if (!containerWidth.isFinite)
      return 0.0;
    return value * containerWidth;
  }
}

class FlexColumnWidth extends ColumnWidth {
  const FlexColumnWidth([this.value = 1.0]);
  final double value;

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return 0.0;
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return 0.0;
  }

  @override
  double flex(Iterable<RenderBox> cells) {
    return value;
  }
}

class MaxColumnWidth extends ColumnWidth {
  const MaxColumnWidth(this.a, this.b); // at least as big as a or b
  final ColumnWidth a;
  final ColumnWidth b;

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return math.max(
      a.minIntrinsicWidth(cells, containerWidth),
      b.minIntrinsicWidth(cells, containerWidth)
    );
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return math.max(
      a.maxIntrinsicWidth(cells, containerWidth),
      b.maxIntrinsicWidth(cells, containerWidth)
    );
  }

  @override
  double flex(Iterable<RenderBox> cells) {
    double aFlex = a.flex(cells);
    if (aFlex == null)
      return b.flex(cells);
    return math.max(aFlex, b.flex(cells));
  }
}

class MinColumnWidth extends ColumnWidth {
  const MinColumnWidth(this.a, this.b); // at most as big as a or b
  final ColumnWidth a;
  final ColumnWidth b;

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return math.min(
      a.minIntrinsicWidth(cells, containerWidth),
      b.minIntrinsicWidth(cells, containerWidth)
    );
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return math.min(
      a.maxIntrinsicWidth(cells, containerWidth),
      b.maxIntrinsicWidth(cells, containerWidth)
    );
  }

  @override
  double flex(Iterable<RenderBox> cells) {
    double aFlex = a.flex(cells);
    if (aFlex == null)
      return b.flex(cells);
    return math.min(aFlex, b.flex(cells));
  }
}

class RenderTable extends RenderBox {
  RenderTable({
    int columns: 0,
    int rows,
    Map<int, ColumnWidth> columnWidths,
    ColumnWidth defaultColumnWidth: const FlexColumnWidth(1.0),
    List<List<RenderBox>> children
  }) {
    assert(columns != null);
    assert(columns >= 0);
    assert(rows == null || rows >= 0);
    assert(rows == null || children == null);
    assert(defaultColumnWidth != null);
    _columns = columns;
    _rows = rows ?? 0;
    _children = new List<RenderBox>()..length = _columns * _rows;
    _columnWidths = columnWidths ?? new HashMap<int, ColumnWidth>();
    _defaultColumnWidth = defaultColumnWidth;
    for (List<RenderBox> row in children)
      addRow(row);
  }

  // TODO(ianh): Add a 'borders' field on the table, to paint the borders.
  // use a Border subclass with "insideVertical" and "insideHorizontal" fields?

  // TODO(ianh): Add a 'decoration' field to the children's parent data, to paint on each cell.

  // TODO(ianh): Add a 'verticalAlignment' field to the children's parent data, to align the cells.
  // Values would be baseline, top, bottom, middle.

  // Children are stored in row-major order.
  // _children.length must be rows * columns
  List<RenderBox> _children = const <RenderBox>[];

  int get columns => _columns;
  int _columns;
  set columns(int value) {
    assert(value != null);
    assert(value >= 0);
    if (value == columns)
      return;
    int oldColumns = columns;
    List<RenderBox> oldChildren = _children;
    _columns = value;
    _children = new List<RenderBox>()..length = columns * rows;
    int columnsToCopy = math.min(columns, oldColumns);
    for (int y = 0; y < rows; y += 1) {
      for (int x = 0; x < columnsToCopy; x += 1)
        _children[x + y * columns] = oldChildren[x + y * oldColumns];
    }
    markNeedsLayout();
  }

  int get rows => _rows;
  int _rows;
  set rows(int value) {
    assert(value != null);
    assert(value >= 0);
    if (value == rows)
      return;
    _rows = value;
    _children.length = columns * rows;
    markNeedsLayout();
  }

  Map<int, ColumnWidth> _columnWidths;
  void setColumnWidths(Map<int, ColumnWidth> value) {
    if (_columnWidths == value)
      return;
    _columnWidths = value;
    markNeedsLayout();
  }

  void setColumnWidth(int column, ColumnWidth value) {
    if (_columnWidths[column] == value)
      return;
    _columnWidths[column] = value;
    markNeedsLayout();
  }

  ColumnWidth get defaultColumnWidth => _defaultColumnWidth;
  ColumnWidth _defaultColumnWidth;
  set defaultColumnWidth(ColumnWidth value) {
    assert(value != null);
    if (defaultColumnWidth == value)
      return;
    _defaultColumnWidth = value;
    markNeedsLayout();
  }

  bool debugIsValidCoordinate(int x, int y) {
    assert(x != null);
    assert(y != null);
    return x >= 0 && x < columns && y >= 0 && y < rows;
  }

  void setChild(int x, int y, RenderBox value) {
    assert(debugIsValidCoordinate(x, y));
    final int xy = x + y * columns;
    RenderBox oldChild = _children[xy];
    if (oldChild != null)
      dropChild(oldChild);
    _children[xy] = value;
    if (value != null)
      adoptChild(value);
  }

  void addRow(List<RenderBox> cells) {
    assert(cells.length == columns);
    _rows += 1;
    _children.addAll(cells);
    for (RenderBox cell in cells) {
      if (cell != null)
        adoptChild(cell);
    }
    markNeedsLayout();
  }

  @override
  void attach() {
    super.attach();
    for (RenderBox child in _children)
      child?.attach();
  }

  @override
  void detach() {
    super.detach();
    for (RenderBox child in _children)
      child?.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    for (RenderBox child in _children) {
      if (child != null)
        visitor(child);
    }
  }

  @override
  double getMinIntrinsicWidth(BoxConstraints constraints) {
    assert(constraints.debugAssertIsNormalized);
    double totalMinWidth = 0.0;
    for (int x = 0; x < columns; x += 1) {
      ColumnWidth columnWidth = _columnWidths[x] ?? defaultColumnWidth;
      Iterable<RenderBox> columnCells = column(x);
      totalMinWidth += columnWidth.minIntrinsicWidth(columnCells, constraints.maxWidth);
    }
    return constraints.constrainWidth(totalMinWidth);
  }

  @override
  double getMaxIntrinsicWidth(BoxConstraints constraints) {
    assert(constraints.debugAssertIsNormalized);
    double totalMaxWidth = 0.0;
    for (int x = 0; x < columns; x += 1) {
      ColumnWidth columnWidth = _columnWidths[x] ?? defaultColumnWidth;
      Iterable<RenderBox> columnCells = column(x);
      totalMaxWidth += columnWidth.maxIntrinsicWidth(columnCells, constraints.maxWidth);
    }
    return constraints.constrainWidth(totalMaxWidth);
  }

  @override
  double getMinIntrinsicHeight(BoxConstraints constraints) {
    // winner of the 2016 world's most expensive intrinsic dimension function award
    // honorable mention, most likely to improve if taught about memoization award
    assert(constraints.debugAssertIsNormalized);
    final List<double> widths = computeColumnWidths(constraints);
    double rowTop = 0.0;
    for (int y = 0; y < rows; y += 1) {
      double rowHeight = 0.0;
      for (int x = 0; x < columns; x += 1) {
        final int xy = x + y * columns;
        RenderBox child = _children[xy];
        if (child != null)
          rowHeight = math.max(rowHeight, child.getMaxIntrinsicHeight(new BoxConstraints.tightFor(width: widths[x])));
      }
      rowTop += rowHeight;
    }
    return constraints.constrainHeight(rowTop);
  }

  @override
  double getMaxIntrinsicHeight(BoxConstraints constraints) {
    return getMinIntrinsicHeight(constraints);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    // returns the baseline of the first cell that has a baseline in the first row
    assert(!needsLayout);
    for (int x = 0; x < columns; x += 1) {
      RenderBox child = _children[x];
      if (child != null) {
        // TODO(ianh): skip children that aren't aligned to the baseline
        double result = child.getDistanceToActualBaseline(baseline);
        if (result != null) {
          final BoxParentData childParentData = child.parentData;
          return result + childParentData.offset.dy;
        }
      }
    }
    return null;
  }

  Iterable<RenderBox> column(int x) sync* {
    for (int y = 0; y < rows; y += 1) {
      final int xy = x + y * columns;
      RenderBox child = _children[xy];
      if (child != null)
        yield child;
    }
  }

  Iterable<RenderBox> row(int y) sync* {
    final int start = y * columns;
    final int end = (y + 1) * columns;
    for (int xy = start; xy < end; xy += 1) {
      RenderBox child = _children[xy];
      if (child != null)
        yield child;
    }
  }

  List<double> computeColumnWidths(BoxConstraints constraints) {
    final List<double> widths = new List<double>(columns);
    final List<double> flexes = new List<double>(columns);
    double totalMinWidth = 0.0;
    double totalMaxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
    double totalFlex = 0.0;
    for (int x = 0; x < columns; x += 1) {
      ColumnWidth columnWidth = _columnWidths[x] ?? defaultColumnWidth;
      Iterable<RenderBox> columnCells = column(x);
      double minIntrinsicWidth = columnWidth.minIntrinsicWidth(columnCells, constraints.maxWidth);
      widths[x] = minIntrinsicWidth;
      totalMinWidth += minIntrinsicWidth;
      if (!constraints.maxWidth.isFinite) {
        double maxIntrinsicWidth = columnWidth.maxIntrinsicWidth(columnCells, constraints.maxWidth);
        assert(minIntrinsicWidth <= maxIntrinsicWidth);
        totalMaxWidth += maxIntrinsicWidth;
      }
      double flex = columnWidth.flex(columnCells);
      if (flex != null) {
        assert(flex != 0.0);
        flexes[x] = flex;
        totalFlex += flex;
      }
    }
    assert(!widths.any((double value) => value == null));
    // table is going to be the biggest of:
    //  - the incoming minimum width
    //  - the sum of the cells' minimum widths
    //  - the incoming maximum width if it is finite, or else the table's ideal shrink-wrap width
    double tableWidth = math.max(constraints.minWidth, math.max(totalMinWidth, totalMaxWidth));
    double remainingWidth = tableWidth - totalMinWidth;
    if (remainingWidth > 0.0) {
      if (totalFlex > 0.0) {
        for (int x = 0; x < columns; x += 1) {
          if (flexes[x] != null) {
            widths[x] += math.max((flexes[x] / totalFlex) * remainingWidth - widths[x], 0.0);
          }
        }
      } else {
        for (int x = 0; x < columns; x += 1)
          widths[x] += remainingWidth / columns;
      }
    }
    return widths;
  }

  @override
  void performLayout() {
    final List<double> widths = computeColumnWidths(constraints);
    final List<double> positions = new List<double>(columns);
    positions[0] = 0.0;
    for (int x = 1; x < columns; x += 1)
      positions[x] = positions[x-1] + widths[x-1];
    assert(!positions.any((double value) => value == null));
    // then, lay out each row
    double rowTop = 0.0;
    for (int y = 0; y < rows; y += 1) {
      double rowHeight = 0.0;
      for (int x = 0; x < columns; x += 1) {
        final int xy = x + y * columns;
        RenderBox child = _children[xy];
        if (child != null) {
          child.layout(new BoxConstraints.tightFor(width: widths[x]), parentUsesSize: true);
          rowHeight = math.max(rowHeight, child.size.height);
        }
      }
      for (int x = 0; x < columns; x += 1) {
        final int xy = x + y * columns;
        RenderBox child = _children[xy];
        if (child != null) {
          final BoxParentData childParentData = child.parentData;
          // TODO(ianh): cell vertical alignment in the row
          childParentData.offset = new Offset(positions[x], rowTop);
        }
      }
      rowTop += rowHeight;
    }
    size = constraints.constrain(new Size(positions.last + widths.last, rowTop));
  }

  @override
  bool hitTestChildren(HitTestResult result, { Point position }) {
    for (int index = _children.length - 1; index >= 0; index -= 1) {
      RenderBox child = _children[index];
      if (child != null) {
        final BoxParentData childParentData = child.parentData;
        Point transformed = new Point(position.x - childParentData.offset.dx,
                                      position.y - childParentData.offset.dy);
        if (child.hitTest(result, position: transformed))
          return true;
      }
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (int index = 0; index < _children.length; index += 1) {
      RenderBox child = _children[index];
      if (child != null) {
        final BoxParentData childParentData = child.parentData; 
        context.paintChild(child, childParentData.offset + offset);
      }
    }
    // TODO(ianh): paint borders
  }

  @override
  String debugDescribeChildren(String prefix) {
    String result = '$prefix \u2502\n';
    int lastIndex = _children.length - 1;
    for (int y = 0; y < rows; y += 1) {
      for (int x = 0; x < columns; x += 1) {
        final int xy = x + y * columns;
        RenderBox child = _children[xy];
        if (child != null) {
          if (xy < lastIndex) {
            result += '${child.toStringDeep("$prefix \u251C\u2500child ($x, $y): ", "$prefix \u2502")}';
          } else {
            result += '${child.toStringDeep("$prefix \u2514\u2500child ($x, $y): ", "$prefix  ")}';
          }
        }
      }
    }
    return result;
  }
}

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
        padding: new EdgeInsets.TRBL(
          ui.window.padding.top,
          ui.window.padding.right,
          ui.window.padding.bottom,
          ui.window.padding.left
        ),
        child: new RenderViewport(
          child: new RenderBlock(
            children: <RenderBox>[
              new RenderPadding(
                padding: new EdgeInsets.TRBL(4.0, 4.0, 8.0, 4.0),
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
                columns: 3,
                columnWidths: const <int, ColumnWidth>{
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
                        child: new RenderBlock(
                          children: <RenderBox>[
                            new RenderParagraph(
                              new TextSpan(
                                text: train.code,
                                style: kCellTextStyle
                              )
                            ),
                            new RenderPadding(
                              padding: new EdgeInsets.only(top: 4.0),
                              child: new RenderPositionedBox(
                                child: new RenderConstrainedBox(
                                  additionalConstraints: new BoxConstraints.tight(const Size(iconSize, iconSize)),
                                  child: new RenderDecoratedBox(
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      backgroundColor: const Color(0xFF43A047)
                                    )
                                  )
                                )
                              )
                            )
                          ]
                        )
                      ),
                      train.imageRenderer = new RenderImage(),
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
  // TODO(ianh): interactivity on the rows to toggle the circle icons
  new Timer(new Duration(seconds: 1), debugDumpRenderTree);
}
