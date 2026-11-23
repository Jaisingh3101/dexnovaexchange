import 'dart:math';
import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';

class CandleChart extends StatelessWidget {
  final List<Candle> candles;
  final bool twoMa;
  const CandleChart({super.key, required this.candles, this.twoMa = false});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return CustomPaint(
      painter: _CandlePainter(
        candles,
        twoMa,
        isDark: p.isDark,
        textColor: p.textMuted,
      ),
      size: Size.infinite,
    );
  }
}

class _CandlePainter extends CustomPainter {
  final List<Candle> candles;
  final bool twoMa;
  final bool isDark;
  final Color textColor;

  _CandlePainter(
    this.candles,
    this.twoMa, {
    required this.isDark,
    required this.textColor,
  });

  Path _ma(int period, double step, double Function(double) y) {
    final p = Path();
    for (var i = 0; i < candles.length; i++) {
      final from = max(0, i - period + 1);
      final s = candles.sublist(from, i + 1);
      final avg = s.map((c) => c.close).reduce((a, b) => a + b) / s.length;
      final o = Offset(step * i + step / 2, y(avg));
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final axisW = twoMa ? 68.0 : 62.0;
    final volH = twoMa ? 26.0 : 30.0;
    final chartW = size.width - axisW;
    final chartH = size.height - volH - 8;

    final hi = candles.map((c) => c.high).reduce(max);
    final lo = candles.map((c) => c.low).reduce(min);
    final range = max(hi - lo, 0.01);
    double y(double v) => chartH - (v - lo) / range * chartH;

    final grid = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    final labelStyle = TextStyle(color: textColor, fontSize: 10);
    for (var i = 0; i <= 4; i++) {
      final gy = chartH * i / 4;
      canvas.drawLine(Offset(0, gy), Offset(chartW, gy), grid);
      if (twoMa && (i == 0 || i == 4)) continue;
      final val = hi - range * i / 4;
      final tp = TextPainter(
        text: TextSpan(
          text: fmtUsd(val, decimals: twoMa ? 2 : 0),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(chartW + 6, gy - tp.height / 2));
    }
    for (var i = 1; i < 6; i++) {
      final gx = chartW * i / 6;
      canvas.drawLine(Offset(gx, 0), Offset(gx, size.height), grid);
    }

    final step = chartW / candles.length;
    final bodyW = step * 0.6;
    final maxVol = candles.map((c) => (c.close - c.open).abs()).reduce(max) + 1;

    final ma = Path();
    for (var i = 0; i < candles.length; i++) {
      final from = max(0, i - 7);
      final slice = candles.sublist(from, i + 1);
      final avg =
          slice.map((c) => c.close).reduce((a, b) => a + b) / slice.length;
      final p = Offset(step * i + step / 2, y(avg));
      i == 0 ? ma.moveTo(p.dx, p.dy) : ma.lineTo(p.dx, p.dy);
    }

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final up = c.close >= c.open;
      final paint = Paint()..color = up ? AppColors.green : AppColors.red;
      final cx = step * i + step / 2;
      canvas.drawLine(
        Offset(cx, y(c.high)),
        Offset(cx, y(c.low)),
        paint..strokeWidth = 1,
      );
      final top = y(max(c.open, c.close));
      final bot = y(min(c.open, c.close));
      canvas.drawRect(
        Rect.fromLTRB(cx - bodyW / 2, top, cx + bodyW / 2, max(bot, top + 1)),
        paint,
      );
      final vh = (c.close - c.open).abs() / maxVol * volH;
      canvas.drawRect(
        Rect.fromLTRB(
          cx - bodyW / 2,
          size.height - vh,
          cx + bodyW / 2,
          size.height,
        ),
        Paint()
          ..color = (up ? AppColors.green : AppColors.red).withValues(
            alpha: 0.45,
          ),
      );
    }

    if (twoMa) {
      canvas.drawPath(
        _ma(7, step, y),
        Paint()
          ..color = const Color(0xFF6366F1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.drawPath(
        _ma(20, step, y),
        Paint()
          ..color = const Color(0xFFF59E0B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    } else {
      canvas.drawPath(
        ma,
        Paint()
          ..color = AppColors.primaryLight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    final last = candles.last.close;
    final ly = y(last);
    final dash = Paint()
      ..color = AppColors.green.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (double x = 0; x < chartW; x += 6) {
      canvas.drawLine(Offset(x, ly), Offset(x + 3, ly), dash);
    }
    final tp = TextPainter(
      text: TextSpan(
        text: fmtUsd(last),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(chartW + 2, ly - 9, axisW - 2, 18),
      const Radius.circular(4),
    );
    canvas.drawRRect(r, Paint()..color = AppColors.green);
    tp.paint(
      canvas,
      Offset(chartW + 2 + (axisW - 2 - tp.width) / 2, ly - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CandlePainter old) =>
      old.candles != candles || old.isDark != isDark;
}

/// Bid/Ask market depth curve chart.
class DepthChart extends StatelessWidget {
  final double midPrice;
  const DepthChart({super.key, required this.midPrice});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return CustomPaint(
      painter: _DepthPainter(midPrice, p.textMuted, p.border),
      size: Size.infinite,
    );
  }
}

class _DepthPainter extends CustomPainter {
  final double midPrice;
  final Color textColor;
  final Color borderColor;
  _DepthPainter(this.midPrice, this.textColor, this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - 20;
    final w = size.width;
    final mid = w * 0.5;

    final grid = Paint()
      ..color = borderColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(mid, 0), Offset(mid, h), grid);
    canvas.drawLine(Offset(0, h), Offset(w, h), grid);

    // Bid curve (left, green)
    final bid = Path()
      ..moveTo(0, h * 0.14)
      ..lineTo(w * 0.15, h * 0.18)
      ..lineTo(w * 0.15, h * 0.36)
      ..lineTo(w * 0.30, h * 0.38)
      ..lineTo(w * 0.30, h * 0.58)
      ..lineTo(w * 0.42, h * 0.62)
      ..lineTo(w * 0.42, h * 0.85)
      ..lineTo(mid - 3, h);
    final bidFill = Path.from(bid)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      bidFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.green.withValues(alpha: 0.32),
            AppColors.green.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, mid, h)),
    );
    canvas.drawPath(
      bid,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Ask curve (right, red)
    final ask = Path()
      ..moveTo(mid + 3, h)
      ..lineTo(w * 0.58, h * 0.82)
      ..lineTo(w * 0.58, h * 0.60)
      ..lineTo(w * 0.72, h * 0.55)
      ..lineTo(w * 0.72, h * 0.34)
      ..lineTo(w * 0.86, h * 0.30)
      ..lineTo(w * 0.86, h * 0.14)
      ..lineTo(w, h * 0.10);
    final askFill = Path.from(ask)
      ..lineTo(w, h)
      ..lineTo(mid + 3, h)
      ..close();
    canvas.drawPath(
      askFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.red.withValues(alpha: 0.32),
            AppColors.red.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(mid, 0, mid, h)),
    );
    canvas.drawPath(
      ask,
      Paint()
        ..color = AppColors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    void label(String txt, double dx) {
      final tp = TextPainter(
        text: TextSpan(
          text: txt,
          style: TextStyle(color: textColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(dx - tp.width / 2, h + 4));
    }

    label(fmtUsd(midPrice * 0.98), w * 0.16);
    label(fmtUsd(midPrice), mid);
    label(fmtUsd(midPrice * 1.02), w * 0.84);
  }

  @override
  bool shouldRepaint(covariant _DepthPainter old) =>
      old.midPrice != midPrice || old.textColor != textColor;
}

/// Small area line used in wallet balance card & tickers.
class SparkLine extends StatelessWidget {
  final List<double> values;
  final Color color;
  const SparkLine({
    super.key,
    required this.values,
    this.color = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _SparkPainter(values, color), size: Size.infinite);
}

class _SparkPainter extends CustomPainter {
  final List<double> v;
  final Color color;
  _SparkPainter(this.v, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final hi = v.reduce(max), lo = v.reduce(min);
    final range = max(hi - lo, 0.001);
    final path = Path();
    for (var i = 0; i < v.length; i++) {
      final p = Offset(
        size.width * i / (v.length - 1),
        size.height - (v[i] - lo) / range * size.height,
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.36), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Decorative QR-like code (deterministic from data string).
class FakeQr extends StatelessWidget {
  final String data;
  final double size;
  const FakeQr({super.key, required this.data, this.size = 130});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.pal.border),
    ),
    child: CustomPaint(
      size: Size.square(size),
      painter: _QrPainter(data.hashCode),
    ),
  );
}

class _QrPainter extends CustomPainter {
  final int seed;
  _QrPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    const n = 29;
    final cell = size.width / n;
    final r = Random(seed);
    final black = Paint()..color = Colors.black;
    bool inFinder(int x, int y) =>
        (x < 8 && y < 8) || (x >= n - 8 && y < 8) || (x < 8 && y >= n - 8);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (inFinder(x, y)) continue;
        if (r.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.3, cell + 0.3),
            black,
          );
        }
      }
    }
    void finder(double ox, double oy) {
      canvas.drawRect(Rect.fromLTWH(ox, oy, cell * 7, cell * 7), black);
      canvas.drawRect(
        Rect.fromLTWH(ox + cell, oy + cell, cell * 5, cell * 5),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(ox + cell * 2, oy + cell * 2, cell * 3, cell * 3),
        black,
      );
    }

    finder(0, 0);
    finder((n - 7) * cell, 0);
    finder(0, (n - 7) * cell);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
