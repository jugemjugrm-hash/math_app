import 'package:flutter/material.dart';

enum _Tool { pen, eraser }

/// One continuous finger stroke on the scratch paper.
class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  _Stroke(Offset start, this.color, this.width) : points = [start];
}

/// A small "calculation paper" the user can scribble on with a finger while
/// solving a question — handy when there's no real paper (e.g. on a train).
///
/// Provides a black pen, an eraser, an undo, and a clear-all. The drawing is
/// meant to be scratch work: give the widget a new [Key] per question so it
/// starts blank each time. The expanded/collapsed state is owned by the
/// parent (via [expanded]/[onToggle]) so it persists across questions.
class ScratchPad extends StatefulWidget {
  final bool expanded;
  final VoidCallback onToggle;

  /// When true (e.g. the keyboard is open) only the header is shown, so the
  /// canvas never fights the keyboard for space.
  final bool compact;

  const ScratchPad({
    super.key,
    required this.expanded,
    required this.onToggle,
    this.compact = false,
  });

  @override
  State<ScratchPad> createState() => _ScratchPadState();
}

class _ScratchPadState extends State<ScratchPad> {
  static const _paperColor = Color(0xFFFFFDF7); // faint cream, like paper
  static const _penColor = Color(0xFF1A1A1A); // near-black pencil
  static const _penWidth = 3.0;
  static const _eraserWidth = 24.0;

  final List<_Stroke> _strokes = [];
  _Tool _tool = _Tool.pen;

  void _startStroke(Offset p) {
    final eraser = _tool == _Tool.eraser;
    setState(() {
      _strokes.add(_Stroke(
        p,
        eraser ? _paperColor : _penColor,
        eraser ? _eraserWidth : _penWidth,
      ));
    });
  }

  void _extendStroke(Offset p) {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.last.points.add(p));
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void _clear() {
    if (_strokes.isEmpty) return;
    setState(_strokes.clear);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCanvas = widget.expanded && !widget.compact;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme, showCanvas),
          if (showCanvas) _buildCanvas(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool showCanvas) {
    return InkWell(
      onTap: widget.onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Row(
          children: [
            Icon(Icons.draw, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('計算スペース'),
            const Spacer(),
            if (showCanvas) ...[
              _toolChip('鉛筆', _Tool.pen),
              const SizedBox(width: 6),
              _toolChip('消しゴム', _Tool.eraser),
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: '一手戻す',
                visualDensity: VisualDensity.compact,
                onPressed: _strokes.isEmpty ? null : _undo,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '全部消す',
                visualDensity: VisualDensity.compact,
                onPressed: _strokes.isEmpty ? null : _clear,
              ),
            ],
            Icon(widget.expanded ? Icons.expand_more : Icons.expand_less),
          ],
        ),
      ),
    );
  }

  Widget _toolChip(String label, _Tool tool) {
    final selected = _tool == tool;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onSelected: (_) => setState(() => _tool = tool),
    );
  }

  Widget _buildCanvas(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: _paperColor,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onPanStart: (d) => _startStroke(d.localPosition),
            onPanUpdate: (d) => _extendStroke(d.localPosition),
            child: CustomPaint(
              painter: _ScratchPainter(_strokes),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  final List<_Stroke> strokes;

  _ScratchPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    for (final stroke in strokes) {
      if (stroke.points.length == 1) {
        // A tap with no drag: draw a dot the width of the stroke.
        final dot = Paint()
          ..color = stroke.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(stroke.points.first, stroke.width / 2, dot);
        continue;
      }
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final p in stroke.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ScratchPainter oldDelegate) => true;
}
