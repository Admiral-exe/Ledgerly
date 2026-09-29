import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LedgerlyLogo extends StatelessWidget {
  final double size;
  final bool showBadge;

  const LedgerlyLogo({
    super.key,
    this.size = 110,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = SizedBox(
      width: size,
      height: size * 0.95,
      child: CustomPaint(
        painter: _LedgerlyBookPainter(),
      ),
    );

    if (!showBadge) return logo;

    return Container(
      width: size * 1.35,
      height: size * 1.35,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(size * 0.35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: logo,
    );
  }
}

class _LedgerlyBookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Red book cover outline / background
    final coverPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill;

    final coverShadowPaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.fill;

    // Draw book bottom shadow / 3D edge
    final coverRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(coverRect, coverShadowPaint);

    final coverTopRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h - h * 0.05),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(coverTopRect, coverPaint);

    // 2. White Pages inside
    final pagePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pageMarginX = w * 0.08;
    final pageMarginY = h * 0.09;
    final pageRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        pageMarginX,
        pageMarginY,
        w - (pageMarginX * 2),
        h - (pageMarginY * 2) - (h * 0.04),
      ),
      Radius.circular(w * 0.1),
    );
    canvas.drawRRect(pageRect, pagePaint);

    // Subtle spine divider in the center of the book
    final spinePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(w * 0.5, pageMarginY + 2),
      Offset(w * 0.5, h - pageMarginY - (h * 0.04) - 2),
      spinePaint,
    );

    // 3. Indian Rupee Symbol (₹)
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 38,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textOffset = Offset(
      (w - textPainter.width) / 2 - 2,
      (h - textPainter.height) / 2 - (h * 0.04),
    );
    textPainter.paint(canvas, textOffset);

    // 4. Vibrant Green Checkmark (✓) cutting across
    final checkPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(w * 0.40, h * 0.52);
    checkPath.lineTo(w * 0.49, h * 0.63);
    checkPath.lineTo(w * 0.64, h * 0.36);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
