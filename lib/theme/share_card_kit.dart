// Shared Stillwater primitives for the branded share cards (Weekly Summary,
// Training Summary, Milestone). Colours are literal on purpose — these cards
// are pinned brand artifacts that mirror fixed design mockups, not theme-driven
// UI, and must look identical regardless of the active app palette.

import 'dart:math' as math;

import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const Color kScCream = Color(0xFFF4F1E9);
const Color kScForest = Color(0xFF2E5642);
const Color kScForestFaint = Color(0x472E5642); // 0.28
const Color kScForestHair = Color(0x1F2E5642); // 0.12
const Color kScTitleGreen = Color(0xFF1C3B29);
const Color kScBrandGreen = Color(0xFF3B6B4D);
const Color kScDateGrey = Color(0xFF6B716A);
const Color kScStatBox = Color(0xFFEAEEE0);
const Color kScRowLabel = Color(0xFF2C402F);
const Color kScHoney = Color(0xFFC2922E);
const Color kScHoneyDeep = Color(0xFF9A7A26);
const Color kScFooterGrey = Color(0xFF8A9088);
const Color kScChipForestBg = Color(0xFFDDE8D8);
const Color kScChipHoneyBg = Color(0xFFEFE3C6);
const Color kScBarForest = Color(0xFF3B7A57);

// ── Text helpers (explicit families so capture is font-correct in isolation) ──
TextStyle scFrau(double size, Color color,
        {FontWeight w = FontWeight.w600,
        FontStyle style = FontStyle.normal,
        double? height,
        double? ls}) =>
    TextStyle(
        fontFamily: 'Fraunces',
        fontSize: size,
        fontWeight: w,
        fontStyle: style,
        color: color,
        height: height,
        letterSpacing: ls);

TextStyle scInt(double size, Color color,
        {FontWeight w = FontWeight.w400, double? height, double? ls}) =>
    TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: w,
        color: color,
        height: height,
        letterSpacing: ls);

// ── Lotus mark ───────────────────────────────────────────────────────────────
// Stroked lotus from the design templates (120x120 viewBox). The full mark adds
// the enclosing circle + inner petal; the compact footer mark is petals only.
class LotusMark extends CustomPainter {
  const LotusMark({
    required this.color,
    this.includeCircle = true,
    this.strokeWidth = 4,
  });

  final Color color;
  final bool includeCircle;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path petal(List<double> c) => Path()
      ..moveTo(c[0] * s, c[1] * s)
      ..cubicTo(c[2] * s, c[3] * s, c[4] * s, c[5] * s, c[6] * s, c[7] * s)
      ..cubicTo(c[8] * s, c[9] * s, c[10] * s, c[11] * s, c[12] * s, c[13] * s)
      ..close();

    if (includeCircle) {
      canvas.drawCircle(Offset(60 * s, 60 * s), 52 * s, paint);
    }
    canvas.drawPath(
        petal([60, 58, 47, 46, 49, 26, 60, 16, 71, 26, 73, 46, 60, 58]), paint);
    if (includeCircle) {
      canvas.drawPath(
          petal([60, 50, 54, 44, 55, 31, 60, 25, 65, 31, 66, 44, 60, 50]),
          paint);
    }
    canvas.drawPath(
        petal([60, 78, 40, 76, 27, 65, 28, 55, 40, 57, 54, 66, 60, 73]), paint);
    canvas.drawPath(
        petal([60, 78, 80, 76, 93, 65, 92, 55, 80, 57, 66, 66, 60, 73]), paint);
  }

  @override
  bool shouldRepaint(covariant LotusMark old) =>
      old.color != color ||
      old.includeCircle != includeCircle ||
      old.strokeWidth != strokeWidth;
}

// ── Botanical sprig watermark ────────────────────────────────────────────────
// A stylised twig with leaves fanning out — drawn at low opacity behind card
// content. Strokes only, so it stays cheap and scales to any size.
class BotanicalSprig extends CustomPainter {
  const BotanicalSprig({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.014
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final stem = Path()
      ..moveTo(w * 0.15, h * 0.95)
      ..cubicTo(w * 0.30, h * 0.70, w * 0.55, h * 0.45, w * 0.85, h * 0.10);
    canvas.drawPath(stem, stroke);

    void drawLeaf(double tx, double ty, double angle, double leafLen) {
      canvas.save();
      canvas.translate(tx, ty);
      canvas.rotate(angle);
      final lw = leafLen * 0.42;
      final p = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(leafLen * 0.5, -lw, leafLen, 0)
        ..quadraticBezierTo(leafLen * 0.5, lw, 0, 0);
      canvas.drawPath(p, stroke);
      canvas.restore();
    }

    drawLeaf(w * 0.22, h * 0.82, -0.95, w * 0.32);
    drawLeaf(w * 0.32, h * 0.66, 0.55, w * 0.30);
    drawLeaf(w * 0.46, h * 0.52, -1.10, w * 0.34);
    drawLeaf(w * 0.58, h * 0.38, 0.40, w * 0.30);
    drawLeaf(w * 0.72, h * 0.22, -1.20, w * 0.28);
  }

  @override
  bool shouldRepaint(covariant BotanicalSprig old) => old.color != color;
}

// ── Growing plant ────────────────────────────────────────────────────────────
// A lush potted plant rendered as filled, gently-curved leaves fanning up from
// the base. [stage] (0..1) drives growth: a tiny sprout near 0, a full leafy
// plant near 1 — so a milestone card's plant reflects how far the streak has
// come. Drawn as a soft silhouette (the caller wraps it in a low Opacity), with
// back leaves dimmer than front ones for depth.
class GrowingPlant extends CustomPainter {
  const GrowingPlant({required this.color, required this.stage});
  final Color color;
  final double stage; // 0..1

  /// Map a sober-day count to a growth stage on a gentle log curve, so early
  /// milestones (1 / 3 / 7…) still read as visibly different sprouts.
  static double stageForDays(int days) {
    if (days <= 0) return 0.08;
    final s = math.log(days + 1) / math.log(1100);
    return s.clamp(0.08, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = stage.clamp(0.0, 1.0);
    final base = Offset(w * 0.5, h * 0.99);

    final count = (3 + (t * 10).round()).clamp(3, 13);
    final fan = 0.55 + 0.85 * t; // half-spread (radians) widens as it grows
    final maxLen = h * (0.42 + 0.56 * t);

    // Build leaves outer→inner so centre (front) leaves paint last/brightest.
    final order = List<int>.generate(count, (i) => i);
    order.sort((a, b) {
      double centre(int i) => (count == 1) ? 0 : (i / (count - 1) - 0.5).abs();
      return centre(b).compareTo(centre(a));
    });

    for (final i in order) {
      final f = count == 1 ? 0.5 : i / (count - 1); // 0..1 across the fan
      final ang = (f - 0.5) * 2 * fan; // -fan..+fan from vertical
      final centreness = 1 - (f - 0.5).abs() * 2; // 1 centre → 0 edge
      final len = maxLen * (0.62 + 0.38 * centreness);
      final wid = len * 0.30;
      final bend = ang * 0.18 * len; // sideways sweep for a natural arc
      final depth = 0.55 + 0.45 * centreness; // dimmer at the edges

      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(ang);

      final leaf = Path()
        ..moveTo(0, 0)
        ..cubicTo(-wid, -len * 0.34, bend - wid * 0.45, -len * 0.82, bend, -len)
        ..cubicTo(bend + wid * 0.45, -len * 0.82, wid, -len * 0.34, 0, 0)
        ..close();
      canvas.drawPath(
          leaf,
          Paint()
            ..style = PaintingStyle.fill
            // ignore: deprecated_member_use
            ..color = color.withOpacity(depth));

      // Midrib vein — a slightly darker hairline up the centre of the leaf.
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(bend * 0.5, -len * 0.5, bend, -len * 0.96),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = len * 0.018
          ..strokeCap = StrokeCap.round
          // ignore: deprecated_member_use
          ..color = kScCream.withOpacity(0.18 * depth),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant GrowingPlant old) =>
      old.color != color || old.stage != stage;
}
