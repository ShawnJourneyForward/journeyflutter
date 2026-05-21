import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LuxuryCard extends StatelessWidget {
  const LuxuryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = AppColors.card,
    this.borderColor = AppColors.softBorder,
    this.clip = false,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  // Only enable when a child overflows the card bounds (e.g. full-bleed images).
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final inner = Padding(padding: padding, child: child);
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.luxury,
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.luxury,
      ),
      child: clip
          ? ClipRRect(borderRadius: AppRadius.luxury, child: inner)
          : inner,
    );
  }
}

class BotanicalBackground extends StatelessWidget {
  const BotanicalBackground({super.key, this.width = 180, this.height = 110});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: CustomPaint(painter: _BotanicalBranchPainter()),
      );
}

class _BotanicalBranchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = AppColors.forest.withOpacity(.11)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final leaf = Paint()
      ..color = AppColors.forest.withOpacity(.08)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * .12, size.height)
      ..cubicTo(size.width * .28, size.height * .76, size.width * .35,
          size.height * .35, size.width * .52, size.height * .08)
      ..moveTo(size.width * .38, size.height * .52)
      ..cubicTo(size.width * .48, size.height * .48, size.width * .58,
          size.height * .36, size.width * .68, size.height * .18)
      ..moveTo(size.width * .46, size.height * .33)
      ..cubicTo(size.width * .58, size.height * .31, size.width * .72,
          size.height * .22, size.width * .86, size.height * .02);
    canvas.drawPath(path, stem);

    void drawLeaf(Offset center, double rx, double ry, double angle) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final leafPath = Path()
        ..moveTo(0, -ry)
        ..cubicTo(rx, -ry * .35, rx, ry * .35, 0, ry)
        ..cubicTo(-rx, ry * .35, -rx, -ry * .35, 0, -ry);
      canvas.drawPath(leafPath, leaf);
      canvas.restore();
    }

    drawLeaf(Offset(size.width * .28, size.height * .67), 13, 26, -.7);
    drawLeaf(Offset(size.width * .43, size.height * .44), 15, 29, -.3);
    drawLeaf(Offset(size.width * .58, size.height * .28), 15, 31, .2);
    drawLeaf(Offset(size.width * .72, size.height * .17), 15, 30, .35);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    this.color = AppColors.forest,
    this.backgroundColor = AppColors.mintChip,
    this.size = 42,
  });
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.46),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(
      {super.key, required this.title, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: AppTextStyles.overline),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTextStyles.bodyMedium),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

class SoftDivider extends StatelessWidget {
  const SoftDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Divider(color: AppColors.softBorder, height: 1);
}

class SoftInput extends StatelessWidget {
  const SoftInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.tint = AppColors.mintChip,
  });
  final TextEditingController controller;
  final String hintText;
  final Color tint;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: 3,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stoneText),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: tint.withOpacity(0.55),
        ),
      );
}

class StatNumber extends StatelessWidget {
  const StatNumber({super.key, required this.value, this.suffix});
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value, style: AppTextStyles.displayLarge),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(suffix!, style: AppTextStyles.bodyMedium),
            ),
          ],
        ],
      );
}
