import 'dart:math';
import 'package:flutter/material.dart';
import '../models/dex_models.dart';
import '../theme.dart';

class CandleChart extends StatelessWidget {
  final List<DexCandle> candles;
  final bool twoMa;
  final bool lineMode;

  const CandleChart({
    super.key,
    required this.candles,
    this.twoMa = false,
    this.lineMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    if (candles.isEmpty) {
      return Center(
        child: Text(
          'Loading live candles…',
          style: TextStyle(fontSize: 12, color: p.textMuted),
        ),
      );
    }
    return CustomPaint(
      painter: _CandlePainter(
        candles,
        twoMa,
        lineMode,
        isDark: p.isDark,
        textColor: p.textMuted,
      ),
      size: Size.infinite,
    );
  }
}

class _CandlePainter extends CustomPainter {
  final List<DexCandle> candles;
  final bool twoMa;
  final bool lineMode;
  final bool isDark;
  final Color textColor;

  _CandlePainter(
    this.candles,
    this.twoMa,
    this.lineMode, {
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
    if (candles.isEmpty || size.width <= 80 || size.height <= 50) return;
    const axisW = 70.0;
    const volH = 26.0;
    const timeH = 16.0;
    final chartW = size.width - axisW;
    final plotBottom = size.height - timeH;
    final chartH = plotBottom - volH - 8;

    final hi = candles.map((c) => c.high).reduce(max);
    final lo = candles.map((c) => c.low).reduce(min);
    final range = (hi - lo) > 0 ? (hi - lo) : (hi > 0 ? hi * 0.02 : 1.0);
    double y(double v) => chartH - (v - lo) / range * chartH;

    final grid = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    final labelStyle = TextStyle(color: textColor, fontSize: 9.5);
    for (var i = 0; i <= 4; i++) {
      final gy = chartH * i / 4;
      canvas.drawLine(Offset(0, gy), Offset(chartW, gy), grid);
      if (twoMa && (i == 0 || i == 4)) continue;
      final val = hi - range * i / 4;
      final tp = TextPainter(
        text: TextSpan(text: fmtDexPrice(val), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: axisW - 6);
      tp.paint(canvas, Offset(chartW + 5, gy - tp.height / 2));
    }
    for (var i = 1; i < 6; i++) {
      final gx = chartW * i / 6;
      canvas.drawLine(Offset(gx, 0), Offset(gx, plotBottom), grid);
    }

    final step = chartW / candles.length;
    final bodyW = max(1.5, step * 0.6);
    final maxRawVol = candles.map((c) => c.volume).reduce(max);
    final useRealVol = maxRawVol > 0;
    final maxVol = useRealVol
        ? maxRawVol
        : max(
            candles.map((c) => (c.close - c.open).abs()).reduce(max),
            range * 0.01,
          );

    if (lineMode) {
      final linePath = Path();
      for (var i = 0; i < candles.length; i++) {
        final cx = step * i + step / 2;
        final cy = y(candles[i].close);
        i == 0 ? linePath.moveTo(cx, cy) : linePath.lineTo(cx, cy);
      }
      final fillPath = Path.from(linePath)
        ..lineTo(chartW, chartH)
        ..lineTo(0, chartH)
        ..close();
      final upOverall = candles.last.close >= candles.first.open;
      final lc = upOverall ? AppColors.green : AppColors.red;
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lc.withValues(alpha: 0.28), lc.withValues(alpha: 0.0)],
          ).createShader(Rect.fromLTWH(0, 0, chartW, chartH)),
      );
      canvas.drawPath(
        linePath,
        Paint()
          ..color = lc
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final up = c.close >= c.open;
      final cx = step * i + step / 2;
      if (!lineMode) {
        final paint = Paint()..color = up ? AppColors.green : AppColors.red;
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
      }
      final vVal = useRealVol ? c.volume : (c.close - c.open).abs();
      final vh = (vVal / maxVol).clamp(0.0, 1.0) * volH;
      canvas.drawRect(
        Rect.fromLTRB(
          cx - bodyW / 2,
          plotBottom - vh,
          cx + bodyW / 2,
          plotBottom,
        ),
        Paint()
          ..color = (up ? AppColors.green : AppColors.red).withValues(
            alpha: 0.42,
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
        _ma(25, step, y),
        Paint()
          ..color = const Color(0xFFF59E0B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    final lastCandle = candles.last;
    final last = lastCandle.close;
    final lastUp = lastCandle.close >= lastCandle.open;
    final pillColor = lastUp ? AppColors.green : AppColors.red;
    final ly = y(last).clamp(9.0, max(9.0, chartH - 9.0)).toDouble();
    final dash = Paint()
      ..color = pillColor.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    for (double x = 0; x < chartW; x += 6) {
      canvas.drawLine(Offset(x, ly), Offset(min(x + 3, chartW), ly), dash);
    }
    final tp = TextPainter(
      text: TextSpan(
        text: fmtDexPrice(last),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: axisW - 4);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(chartW + 2, ly - 9, axisW - 2, 18),
      const Radius.circular(4),
    );
    canvas.drawRRect(r, Paint()..color = pillColor);
    tp.paint(
      canvas,
      Offset(chartW + 2 + (axisW - 2 - tp.width) / 2, ly - tp.height / 2),
    );

    if (lastCandle.volume > 0) {
      final vTxt = fmtCompactUsd(lastCandle.volume).replaceFirst('\$', '');
      final vtp = TextPainter(
        text: TextSpan(
          text: vTxt,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: axisW - 4);
      final vy = (plotBottom - 16).clamp(chartH + 4, plotBottom - 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(chartW + 2, vy.toDouble(), axisW - 2, 16),
          const Radius.circular(4),
        ),
        Paint()..color = pillColor,
      );
      vtp.paint(
        canvas,
        Offset(
          chartW + 2 + (axisW - 2 - vtp.width) / 2,
          vy + (16 - vtp.height) / 2,
        ),
      );
    }

    String fmtTs(int sec) {
      if (sec <= 0) return '';
      final dt = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
      if (dt.hour == 0 && dt.minute == 0) {
        return dt.day.toString().padLeft(2, '0');
      }
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    final idxList = [0, candles.length ~/ 2, candles.length - 1];
    for (var j = 0; j < idxList.length; j++) {
      final label = fmtTs(candles[idxList[j]].time);
      if (label.isEmpty) continue;
      final ttp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = j == 0
          ? 2.0
          : (j == 1
                ? (chartW - ttp.width) / 2
                : max(2.0, chartW - ttp.width - 2));
      ttp.paint(canvas, Offset(x, plotBottom + 3));
    }
  }

  @override
  bool shouldRepaint(covariant _CandlePainter old) =>
      old.candles != candles ||
      old.isDark != isDark ||
      old.twoMa != twoMa ||
      old.lineMode != lineMode;
}

/// Dynamic Bid/Ask AMM + Swap depth chart computed from live trades & liquidity.
class DepthChart extends StatelessWidget {
  final double midPrice;
  final List<DexTrade> trades;
  final double liquidity;

  const DepthChart({
    super.key,
    required this.midPrice,
    this.trades = const [],
    this.liquidity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return CustomPaint(
      painter: _DepthPainter(
        midPrice,
        trades,
        liquidity,
        p.textMuted,
        p.border,
      ),
      size: Size.infinite,
    );
  }
}

class _DepthPainter extends CustomPainter {
  final double midPrice;
  final List<DexTrade> trades;
  final double liquidity;
  final Color textColor;
  final Color borderColor;

  _DepthPainter(
    this.midPrice,
    this.trades,
    this.liquidity,
    this.textColor,
    this.borderColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - 20;
    final w = size.width;
    final mid = w * 0.5;
    if (h <= 10 || w <= 40 || midPrice <= 0) return;

    final grid = Paint()
      ..color = borderColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(mid, 0), Offset(mid, h), grid);
    canvas.drawLine(Offset(0, h), Offset(w, h), grid);

    // Derive cumulative bid/ask buckets dynamically from live trades + AMM reserve depth.
    const levels = 6;
    final baseDepth = max(1.0, liquidity > 0 ? liquidity * 0.02 : 1000.0);
    final bids = List<double>.filled(levels, baseDepth / levels);
    final asks = List<double>.filled(levels, baseDepth / levels);
    for (final t in trades) {
      final p = t.price > 0 ? t.price : midPrice;
      final pct = ((p - midPrice).abs() / midPrice) / 0.02;
      final idx = (pct * (levels - 1)).floor().clamp(0, levels - 1);
      final weight = max(t.usd, 50.0);
      if (t.isBuy) {
        bids[idx] += weight;
      } else {
        asks[idx] += weight;
      }
    }

    // Cumulative depth outward from midPrice.
    final cumBid = <double>[];
    final cumAsk = <double>[];
    var rb = 0.0;
    var ra = 0.0;
    for (var i = 0; i < levels; i++) {
      rb += bids[i];
      ra += asks[i];
      cumBid.add(rb);
      cumAsk.add(ra);
    }
    final maxDepth = max(cumBid.last, cumAsk.last);

    final bid = Path()..moveTo(mid - 2, h);
    for (var i = 0; i < levels; i++) {
      final x = mid - 2 - (mid - 2) * ((i + 1) / levels);
      final y = h - (cumBid[i] / maxDepth) * (h * 0.86);
      final prevX = mid - 2 - (mid - 2) * (i / levels);
      bid.lineTo(prevX, y);
      bid.lineTo(x, y);
    }
    final bidFill = Path.from(bid)
      ..lineTo(0, h)
      ..lineTo(mid - 2, h)
      ..close();
    canvas.drawPath(
      bidFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.green.withValues(alpha: 0.30),
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

    final ask = Path()..moveTo(mid + 2, h);
    for (var i = 0; i < levels; i++) {
      final x = mid + 2 + (mid - 2) * ((i + 1) / levels);
      final y = h - (cumAsk[i] / maxDepth) * (h * 0.86);
      final prevX = mid + 2 + (mid - 2) * (i / levels);
      ask.lineTo(prevX, y);
      ask.lineTo(x, y);
    }
    final askFill = Path.from(ask)
      ..lineTo(w, h)
      ..lineTo(mid + 2, h)
      ..close();
    canvas.drawPath(
      askFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.red.withValues(alpha: 0.30),
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

    label(fmtDexPrice(midPrice * 0.98), w * 0.16);
    label(fmtDexPrice(midPrice), mid);
    label(fmtDexPrice(midPrice * 1.02), w * 0.84);
  }

  @override
  bool shouldRepaint(covariant _DepthPainter old) =>
      old.midPrice != midPrice ||
      old.trades != trades ||
      old.liquidity != liquidity ||
      old.textColor != textColor;
}

class SparkLine extends StatelessWidget {
  final List<double> values;
  final Color color;
  const SparkLine({
    super.key,
    required this.values,
    this.color = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.shrink();
    return CustomPaint(
      painter: _SparkPainter(values, color),
      size: Size.infinite,
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> v;
  final Color color;
  _SparkPainter(this.v, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (v.length < 2) return;
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
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.v != v || oldDelegate.color != color;
}
