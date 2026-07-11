import 'package:flutter/material.dart';

/// A run of plain text or a stacked fraction inside a math string.
///
/// Question data writes fractions as `{{numerator}}/{{denominator}}` so that
/// they can be displayed the way textbooks print them (numerator above a
/// horizontal bar, denominator below) instead of with a slash.
class MathSegment {
  final String? text;
  final String? numerator;
  final String? denominator;

  const MathSegment.text(this.text)
      : numerator = null,
        denominator = null;

  const MathSegment.fraction(this.numerator, this.denominator) : text = null;

  bool get isFraction => numerator != null;
}

final _fractionPattern = RegExp(r'\{\{([^{}]+)\}\}/\{\{([^{}]+)\}\}');

/// Splits [input] into plain-text runs and fraction segments.
List<MathSegment> parseMathSegments(String input) {
  final segments = <MathSegment>[];
  var index = 0;
  for (final match in _fractionPattern.allMatches(input)) {
    if (match.start > index) {
      segments.add(MathSegment.text(input.substring(index, match.start)));
    }
    segments.add(MathSegment.fraction(match.group(1)!, match.group(2)!));
    index = match.end;
  }
  if (index < input.length) {
    segments.add(MathSegment.text(input.substring(index)));
  }
  return segments;
}

/// Drop-in replacement for [Text] that renders `{{a}}/{{b}}` markup as a
/// stacked fraction. Strings without the markup render exactly like [Text].
class MathText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;

  const MathText(this.data, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final segments = parseMathSegments(data);
    if (segments.length == 1 && !segments.first.isFraction) {
      return Text(data, style: style, textAlign: textAlign);
    }

    final baseStyle = DefaultTextStyle.of(context).style.merge(style);
    final spans = segments.map<InlineSpan>((segment) {
      if (!segment.isFraction) {
        return TextSpan(text: segment.text);
      }
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        baseline: TextBaseline.alphabetic,
        child: _Fraction(
          numerator: segment.numerator!,
          denominator: segment.denominator!,
          style: baseStyle,
        ),
      );
    }).toList();

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      textAlign: textAlign,
    );
  }
}

class _Fraction extends StatelessWidget {
  final String numerator;
  final String denominator;
  final TextStyle style;

  const _Fraction({
    required this.numerator,
    required this.denominator,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final base = style.fontSize ?? 14;
    final partStyle = style.copyWith(fontSize: base * 0.78, height: 1.1);
    final barColor = style.color ?? Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(numerator, style: partStyle, textAlign: TextAlign.center),
            Container(
              height: 1.2,
              margin: const EdgeInsets.symmetric(vertical: 1),
              color: barColor,
            ),
            Text(denominator, style: partStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
