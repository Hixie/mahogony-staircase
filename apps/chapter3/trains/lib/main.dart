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
  RenderOpacity checkRenderer;
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

class TableBorder extends Border {
  const TableBorder({
    BorderSide top: BorderSide.none,
    BorderSide right: BorderSide.none,
    BorderSide bottom: BorderSide.none,
    BorderSide left: BorderSide.none,
    this.horizontalInside: BorderSide.none,
    this.verticalInside: BorderSide.none
  }) : super(
    top: top,
    right: right,
    bottom: bottom,
    left: left
  );

  factory TableBorder.all({
    Color color: const Color(0xFF000000),
    double width: 1.0
  }) {
    final BorderSide side = new BorderSide(color: color, width: width);
    return new TableBorder(top: side, right: side, bottom: side, left: side, horizontalInside: side, verticalInside: side);
  }

  factory TableBorder.symmetric({
    BorderSide inside: BorderSide.none,
    BorderSide outside: BorderSide.none
  }) {
    return new TableBorder(
      top: outside,
      right: outside,
      bottom: outside,
      left: outside,
      horizontalInside: inside,
      verticalInside: inside
    );
  }

  final BorderSide horizontalInside;

  final BorderSide verticalInside;

  @override
  TableBorder scale(double t) {
    return new TableBorder(
      top: top.copyWith(width: t * top.width),
      right: right.copyWith(width: t * right.width),
      bottom: bottom.copyWith(width: t * bottom.width),
      left: left.copyWith(width: t * left.width),
      horizontalInside: horizontalInside.copyWith(width: t * horizontalInside.width),
      verticalInside: verticalInside.copyWith(width: t * verticalInside.width)
    );
  }

  static TableBorder lerp(TableBorder a, TableBorder b, double t) {
    if (a == null && b == null)
      return null;
    if (a == null)
      return b.scale(t);
    if (b == null)
      return a.scale(1.0 - t);
    return new TableBorder(
      top: BorderSide.lerp(a.top, b.top, t),
      right: BorderSide.lerp(a.right, b.right, t),
      bottom: BorderSide.lerp(a.bottom, b.bottom, t),
      left: BorderSide.lerp(a.left, b.left, t),
      horizontalInside: BorderSide.lerp(a.horizontalInside, b.horizontalInside, t),
      verticalInside: BorderSide.lerp(a.verticalInside, b.verticalInside, t)
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (super != other)
      return false;
    final TableBorder typedOther = other;
    return horizontalInside == typedOther.horizontalInside &&
           verticalInside == typedOther.verticalInside;
  }

  @override
  int get hashCode => hashValues(super.hashCode, horizontalInside, verticalInside);

  @override
  String toString() => 'TableBorder($top, $right, $bottom, $left, $horizontalInside, $verticalInside)';
}

enum CellVerticalAlignment {
  /// Cells with this alignment are placed with their top at the top of the row.
  top,

  /// Cells with this alignment are vertically centered in the row.
  middle,

  /// Cells with this alignment are placed with their bottom at the bottom of the row.
  bottom,

  /// Cells with this alignment are aligned such that they all share the same
  /// baseline. Cells with no baseline are top-aligned instead. The baseline
  /// used is specified by [RenderTable.baseline]. It is not valid to use the
  /// baseline value if [RenderTable.baseline] is not specified.
  baseline,

  /// Cells with this alignment are sized to be as tall as the row, then made to fit the row.
  /// If all the cells have this alignment, then the row will have zero height.
  fill
}

/// Parent data used by [RenderTable] for its children.
class TableCellParentData extends BoxParentData {
  CellVerticalAlignment verticalAlignment = CellVerticalAlignment.top;

  @override
  String toString() => '${super.toString()}; $verticalAlignment';
}

class RenderTable extends RenderBox {
  RenderTable({
    int columns,
    int rows,
    Map<int, ColumnWidth> columnWidths,
    ColumnWidth defaultColumnWidth: const FlexColumnWidth(1.0),
    TableBorder border,
    TextBaseline textBaseline,
    List<List<RenderBox>> children
  }) {
    assert(columns != null || (children != null && children.isNotEmpty));
    assert(columns == null || columns >= 0);
    assert(rows == null || rows >= 0);
    assert(rows == null || children == null);
    assert(defaultColumnWidth != null);
    _columns = columns ?? children.first.length;
    _rows = rows ?? 0;
    _children = new List<RenderBox>()..length = _columns * _rows;
    _columnWidths = columnWidths ?? new HashMap<int, ColumnWidth>();
    _defaultColumnWidth = defaultColumnWidth;
    _border = border;
    _textBaseline = textBaseline;
    for (List<RenderBox> row in children)
      addRow(row);
  }

  // TODO(ianh): Add a 'decoration' field to the children's parent data, to paint on each cell.

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

  TableBorder get border => _border;
  TableBorder _border;
  set border(TableBorder value) {
    if (border == value)
      return;
    _border = value;
    markNeedsPaint();
  }

  TextBaseline get textBaseline => _textBaseline;
  TextBaseline _textBaseline;
  void set textBaseline (TextBaseline value) {
    if (_textBaseline == value)
      return;
    _textBaseline = value;
    markNeedsLayout();
  }

  bool debugIsValidCoordinate(int x, int y) {
    assert(x != null);
    assert(y != null);
    return x >= 0 && x < columns && y >= 0 && y < rows;
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! TableCellParentData)
      child.parentData = new TableCellParentData();
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
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (RenderBox child in _children)
      child?.attach(owner);
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

  double _baselineDistance;
  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    // returns the baseline of the first cell that has a baseline in the first row
    assert(!needsLayout);
    return _baselineDistance;
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

  // cache the table geometry for painting purposes
  List<double> _rowTops = <double>[];
  List<double> _columnLefts;

  @override
  void performLayout() {
    final List<double> widths = computeColumnWidths(constraints);
    final List<double> positions = new List<double>(columns);
    _rowTops.clear();
    positions[0] = 0.0;
    for (int x = 1; x < columns; x += 1)
      positions[x] = positions[x-1] + widths[x-1];
    _columnLefts = positions;
    assert(!positions.any((double value) => value == null));
    _baselineDistance = null;
    // then, lay out each row
    double rowTop = 0.0;
    for (int y = 0; y < rows; y += 1) {
      _rowTops.add(rowTop);
      double rowHeight = 0.0;
      bool haveBaseline = false;
      double beforeBaselineDistance = 0.0;
      double afterBaselineDistance = 0.0;
      List<double> baselines = new List<double>(columns);
      for (int x = 0; x < columns; x += 1) {
        final int xy = x + y * columns;
        RenderBox child = _children[xy];
        if (child != null) {
          TableCellParentData childParentData = child.parentData;
          switch (childParentData.verticalAlignment) {
            case CellVerticalAlignment.baseline:
              assert(textBaseline != null);
              child.layout(new BoxConstraints.tightFor(width: widths[x]), parentUsesSize: true);
              double childBaseline = child.getDistanceToBaseline(textBaseline, onlyReal: true);
              if (childBaseline != null) {
                beforeBaselineDistance = math.max(beforeBaselineDistance, childBaseline);
                afterBaselineDistance = math.max(afterBaselineDistance, child.size.height - childBaseline);
                baselines[x] = childBaseline;
                haveBaseline = true;
              } else {
                rowHeight = math.max(rowHeight, child.size.height);
                childParentData.offset = new Offset(positions[x], rowTop);
              }
              break;
            case CellVerticalAlignment.top:
            case CellVerticalAlignment.middle:
            case CellVerticalAlignment.bottom:
              child.layout(new BoxConstraints.tightFor(width: widths[x]), parentUsesSize: true);
              rowHeight = math.max(rowHeight, child.size.height);
              break;
            case CellVerticalAlignment.fill:
              break;
          }
        }
      }
      if (haveBaseline) {
        if (y == 0)
          _baselineDistance = beforeBaselineDistance;
        rowHeight = math.max(rowHeight, beforeBaselineDistance + afterBaselineDistance);
      }
      for (int x = 0; x < columns; x += 1) {
        final int xy = x + y * columns;
        RenderBox child = _children[xy];
        if (child != null) {
          final TableCellParentData childParentData = child.parentData;
          switch (childParentData.verticalAlignment) {
            case CellVerticalAlignment.baseline:
              if (baselines[x] != null)
                childParentData.offset = new Offset(positions[x], rowTop + beforeBaselineDistance - baselines[x]);
              break;
            case CellVerticalAlignment.top:
              childParentData.offset = new Offset(positions[x], rowTop);
              break;
            case CellVerticalAlignment.middle:
              childParentData.offset = new Offset(positions[x], rowTop + (rowHeight - child.size.height) / 2.0);
              break;
            case CellVerticalAlignment.bottom:
              childParentData.offset = new Offset(positions[x], rowTop + rowHeight - child.size.height);
              break;
            case CellVerticalAlignment.fill:
              child.layout(new BoxConstraints.tightFor(width: widths[x], height: rowHeight));
              childParentData.offset = new Offset(positions[x], rowTop);
              break;
          }
        }
      }
      rowTop += rowHeight;
    }
    size = constraints.constrain(new Size(positions.last + widths.last, rowTop));
    assert(_rowTops.length == rows);
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
    assert(_rowTops.length == rows);
    for (int index = 0; index < _children.length; index += 1) {
      RenderBox child = _children[index];
      if (child != null) {
        final BoxParentData childParentData = child.parentData; 
        context.paintChild(child, childParentData.offset + offset);
      }
    }
    Rect bounds = offset & size;
    Canvas canvas = context.canvas;
    canvas.saveLayer(bounds, new Paint());
    switch (border.verticalInside.style) {
      case BorderStyle.solid:
        Paint paint = new Paint()
          ..color = border.verticalInside.color
          ..strokeWidth = border.verticalInside.width
          ..style = PaintingStyle.stroke;
        Path path = new Path();
        for (int x = 1; x < columns; x += 1) {
          path.moveTo(bounds.left + _columnLefts[x], bounds.top);
          path.lineTo(bounds.left + _columnLefts[x], bounds.bottom);
        }
        canvas.drawPath(path, paint);
        break;
      case BorderStyle.none: break;
    }
    switch (border.horizontalInside.style) {
      case BorderStyle.solid:
        Paint paint = new Paint()
          ..color = border.horizontalInside.color
          ..strokeWidth = border.horizontalInside.width
          ..style = PaintingStyle.stroke;
        Path path = new Path();
        for (int y = 1; y < rows; y += 1) {
          path.moveTo(bounds.left, bounds.top + _rowTops[y]);
          path.lineTo(bounds.right, bounds.top + _rowTops[y]);
        }
        canvas.drawPath(path, paint);
        break;
      case BorderStyle.none: break;
    }
    border.paint(canvas, bounds);
    canvas.restore();
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

void handlePointerDown(Train train) {
  train.checked = !train.checked;
  train.checkRenderer?.opacity = train.checked ? 1.0 : 0.0;
}

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
                      new RenderPointerListener(
                        onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                        child: new RenderPadding(
                          padding: new EdgeInsets.all(4.0),
                          child: new RenderBlock(
                            children: <RenderBox>[
                              new RenderParagraph(
                                new TextSpan(
                                  text: train.code,
                                  style: kCellTextStyle
                                )
                              ),
                              train.checkRenderer = new RenderOpacity(
                                opacity: train.checked ? 1.0 : 0.0,
                                child: new RenderPadding(
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
                              )
                            ]
                          )
                        )
                      ),
                      new RenderPointerListener(
                        onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                        child: train.imageRenderer = new RenderImage(
                          fit: ImageFit.fitWidth
                        )
                      )..parentData = (new TableCellParentData()..verticalAlignment = CellVerticalAlignment.fill),
                      new RenderPointerListener(
                        onPointerDown: (PointerDownEvent event) => handlePointerDown(train),
                        child: new RenderPadding(
                          padding: new EdgeInsets.all(4.0),
                          child: new RenderParagraph(
                            new TextSpan(
                              text: train.description,
                              style: kCellTextStyle
                            )
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
