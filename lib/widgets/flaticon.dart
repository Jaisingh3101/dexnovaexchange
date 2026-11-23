import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

enum Flaticons {
  home,
  markets,
  trade,
  wallet,
  more,
  menu,
  bell,
  user,
  sun,
  moon,
  search,
  headset,
  deposit,
  withdraw,
  send,
  receive,
  transfer,
  addWallet,
  recoverWallet,
  key,
  earn,
  eye,
  eyeOff,
  copy,
  qrScan,
  qrCode,
  shieldCheck,
  lock,
  fingerprint,
  settings,
  star,
  starFilled,
  candles,
  fx,
  expand,
  chevronDown,
  chevronRight,
  arrowLeft,
  arrowRight,
  checkCircle,
  closeCircle,
  warning,
  network,
  paste,
  share,
  refresh,
  sparkles,
  check,
}

/// Flaticon UIcons (fi-rr / duotone) vector icon painter with crisp rounded strokes.
class FIcon extends StatelessWidget {
  final Flaticons icon;
  final double size;
  final Color? color;
  final bool duotone;

  const FIcon(
    this.icon, {
    super.key,
    this.size = 18,
    this.color,
    this.duotone = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.pal.text;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FIconPainter(icon, c, duotone)),
    );
  }
}

class FBadgeIcon extends StatelessWidget {
  final Flaticons icon;
  final Color color;
  final double size;
  final double iconSize;
  final double radius;

  const FBadgeIcon(
    this.icon, {
    super.key,
    this.color = AppColors.primary,
    this.size = 32,
    this.iconSize = 16,
    this.radius = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Center(
        child: FIcon(icon, size: iconSize, color: color),
      ),
    );
  }
}

class _FIconPainter extends CustomPainter {
  final Flaticons icon;
  final Color color;
  final bool duotone;

  _FIconPainter(this.icon, this.color, this.duotone);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = (s * 0.095).clamp(1.2, 2.6);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = duotone ? color.withValues(alpha: 0.16) : Colors.transparent
      ..style = PaintingStyle.fill;
    final solid = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Offset p(double x, double y) => Offset(s * x, s * y);
    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(p(x1, y1), p(x2, y2), stroke);

    switch (icon) {
      case Flaticons.home:
        final path = Path()
          ..moveTo(s * 0.15, s * 0.44)
          ..lineTo(s * 0.5, s * 0.14)
          ..lineTo(s * 0.85, s * 0.44)
          ..lineTo(s * 0.85, s * 0.82)
          ..quadraticBezierTo(s * 0.85, s * 0.88, s * 0.78, s * 0.88)
          ..lineTo(s * 0.22, s * 0.88)
          ..quadraticBezierTo(s * 0.15, s * 0.88, s * 0.15, s * 0.82)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
        line(0.4, 0.88, 0.4, 0.6);
        line(0.4, 0.6, 0.6, 0.6);
        line(0.6, 0.6, 0.6, 0.88);
      case Flaticons.markets:
        final b1 = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.16, s * 0.52, s * 0.16, s * 0.34),
          Radius.circular(s * 0.05),
        );
        final b2 = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.42, s * 0.22, s * 0.16, s * 0.64),
          Radius.circular(s * 0.05),
        );
        final b3 = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.68, s * 0.38, s * 0.16, s * 0.48),
          Radius.circular(s * 0.05),
        );
        for (final r in [b1, b2, b3]) {
          canvas.drawRRect(r, fill);
          canvas.drawRRect(r, stroke);
        }
      case Flaticons.trade:
      case Flaticons.transfer:
        line(0.16, 0.34, 0.82, 0.34);
        line(0.66, 0.18, 0.82, 0.34);
        line(0.66, 0.50, 0.82, 0.34);
        line(0.84, 0.66, 0.18, 0.66);
        line(0.34, 0.50, 0.18, 0.66);
        line(0.34, 0.82, 0.18, 0.66);
      case Flaticons.wallet:
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.12, s * 0.24, s * 0.76, s * 0.56),
          Radius.circular(s * 0.14),
        );
        canvas.drawRRect(r, fill);
        canvas.drawRRect(r, stroke);
        final flap = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.58, s * 0.43, s * 0.3, s * 0.18),
          Radius.circular(s * 0.07),
        );
        canvas.drawRRect(flap, stroke);
        canvas.drawCircle(p(0.7, 0.52), sw * 0.6, solid);
      case Flaticons.more:
        for (final pos in [
          p(0.16, 0.16),
          p(0.56, 0.16),
          p(0.16, 0.56),
          p(0.56, 0.56),
        ]) {
          final sq = RRect.fromRectAndRadius(
            Rect.fromLTWH(pos.dx, pos.dy, s * 0.28, s * 0.28),
            Radius.circular(s * 0.08),
          );
          canvas.drawRRect(sq, fill);
          canvas.drawRRect(sq, stroke);
        }
      case Flaticons.menu:
        line(0.16, 0.28, 0.84, 0.28);
        line(0.16, 0.50, 0.68, 0.50);
        line(0.16, 0.72, 0.84, 0.72);
      case Flaticons.bell:
        final path = Path()
          ..moveTo(s * 0.25, s * 0.66)
          ..lineTo(s * 0.25, s * 0.44)
          ..cubicTo(s * 0.25, s * 0.22, s * 0.75, s * 0.22, s * 0.75, s * 0.44)
          ..lineTo(s * 0.75, s * 0.66)
          ..lineTo(s * 0.84, s * 0.74)
          ..lineTo(s * 0.16, s * 0.74)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
        canvas.drawArc(
          Rect.fromCenter(
            center: p(0.5, 0.76),
            width: s * 0.22,
            height: s * 0.18,
          ),
          0,
          math.pi,
          false,
          stroke,
        );
      case Flaticons.user:
        canvas.drawCircle(p(0.5, 0.34), s * 0.16, fill);
        canvas.drawCircle(p(0.5, 0.34), s * 0.16, stroke);
        final arc = Path()
          ..moveTo(s * 0.20, s * 0.84)
          ..cubicTo(s * 0.20, s * 0.60, s * 0.80, s * 0.60, s * 0.80, s * 0.84);
        canvas.drawPath(arc, stroke);
      case Flaticons.sun:
        canvas.drawCircle(p(0.5, 0.5), s * 0.19, fill);
        canvas.drawCircle(p(0.5, 0.5), s * 0.19, stroke);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
            Offset(
              s * 0.5 + math.cos(a) * s * 0.29,
              s * 0.5 + math.sin(a) * s * 0.29,
            ),
            Offset(
              s * 0.5 + math.cos(a) * s * 0.39,
              s * 0.5 + math.sin(a) * s * 0.39,
            ),
            stroke,
          );
        }
      case Flaticons.moon:
        final path = Path()
          ..moveTo(s * 0.64, s * 0.18)
          ..cubicTo(s * 0.34, s * 0.20, s * 0.20, s * 0.54, s * 0.42, s * 0.76)
          ..cubicTo(s * 0.58, s * 0.90, s * 0.80, s * 0.80, s * 0.84, s * 0.62)
          ..cubicTo(s * 0.62, s * 0.68, s * 0.46, s * 0.46, s * 0.64, s * 0.18)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
      case Flaticons.search:
        canvas.drawCircle(p(0.44, 0.44), s * 0.26, fill);
        canvas.drawCircle(p(0.44, 0.44), s * 0.26, stroke);
        line(0.64, 0.64, 0.84, 0.84);
      case Flaticons.headset:
        canvas.drawArc(
          Rect.fromCenter(
            center: p(0.5, 0.52),
            width: s * 0.66,
            height: s * 0.66,
          ),
          math.pi,
          math.pi,
          false,
          stroke,
        );
        final l = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.15, s * 0.52, s * 0.15, s * 0.26),
          Radius.circular(s * 0.06),
        );
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.70, s * 0.52, s * 0.15, s * 0.26),
          Radius.circular(s * 0.06),
        );
        canvas.drawRRect(l, fill);
        canvas.drawRRect(r, fill);
        canvas.drawRRect(l, stroke);
        canvas.drawRRect(r, stroke);
      case Flaticons.deposit:
        line(0.5, 0.16, 0.5, 0.66);
        line(0.32, 0.48, 0.5, 0.66);
        line(0.68, 0.48, 0.5, 0.66);
        final tray = Path()
          ..moveTo(s * 0.18, s * 0.68)
          ..lineTo(s * 0.18, s * 0.84)
          ..lineTo(s * 0.82, s * 0.84)
          ..lineTo(s * 0.82, s * 0.68);
        canvas.drawPath(tray, stroke);
      case Flaticons.withdraw:
        line(0.5, 0.66, 0.5, 0.16);
        line(0.32, 0.34, 0.5, 0.16);
        line(0.68, 0.34, 0.5, 0.16);
        final tray = Path()
          ..moveTo(s * 0.18, s * 0.68)
          ..lineTo(s * 0.18, s * 0.84)
          ..lineTo(s * 0.82, s * 0.84)
          ..lineTo(s * 0.82, s * 0.68);
        canvas.drawPath(tray, stroke);
      case Flaticons.send:
        final paper = Path()
          ..moveTo(s * 0.84, s * 0.16)
          ..lineTo(s * 0.14, s * 0.44)
          ..lineTo(s * 0.46, s * 0.54)
          ..lineTo(s * 0.56, s * 0.86)
          ..close();
        canvas.drawPath(paper, fill);
        canvas.drawPath(paper, stroke);
        line(0.46, 0.54, 0.84, 0.16);
      case Flaticons.receive:
        line(0.74, 0.26, 0.30, 0.70);
        line(0.30, 0.42, 0.30, 0.70);
        line(0.58, 0.70, 0.30, 0.70);
        line(0.20, 0.84, 0.80, 0.84);
      case Flaticons.addWallet:
        final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.12, s * 0.24, s * 0.68, s * 0.54),
          Radius.circular(s * 0.12),
        );
        canvas.drawRRect(r, fill);
        canvas.drawRRect(r, stroke);
        canvas.drawCircle(p(0.76, 0.68), s * 0.16, Paint()..color = color);
        final plus = Paint()
          ..color = Colors.white
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p(0.76, 0.60), p(0.76, 0.76), plus);
        canvas.drawLine(p(0.68, 0.68), p(0.84, 0.68), plus);
      case Flaticons.recoverWallet:
        canvas.drawArc(
          Rect.fromCenter(
            center: p(0.5, 0.5),
            width: s * 0.64,
            height: s * 0.64,
          ),
          math.pi * 0.25,
          math.pi * 1.55,
          false,
          stroke,
        );
        line(0.22, 0.22, 0.22, 0.40);
        line(0.22, 0.40, 0.40, 0.40);
        canvas.drawCircle(p(0.50, 0.50), s * 0.12, fill);
        canvas.drawCircle(p(0.50, 0.50), s * 0.12, stroke);
      case Flaticons.key:
        canvas.drawCircle(p(0.32, 0.50), s * 0.17, fill);
        canvas.drawCircle(p(0.32, 0.50), s * 0.17, stroke);
        line(0.49, 0.50, 0.86, 0.50);
        line(0.72, 0.50, 0.72, 0.66);
        line(0.86, 0.50, 0.86, 0.64);
      case Flaticons.earn:
        canvas.drawCircle(p(0.5, 0.5), s * 0.34, fill);
        canvas.drawCircle(p(0.5, 0.5), s * 0.34, stroke);
        line(0.5, 0.28, 0.5, 0.72);
        line(0.38, 0.38, 0.62, 0.38);
        line(0.38, 0.62, 0.62, 0.62);
        line(0.38, 0.38, 0.62, 0.62);
      case Flaticons.eye:
        final eye = Path()
          ..moveTo(s * 0.12, s * 0.5)
          ..quadraticBezierTo(s * 0.5, s * 0.16, s * 0.88, s * 0.5)
          ..quadraticBezierTo(s * 0.5, s * 0.84, s * 0.12, s * 0.5)
          ..close();
        canvas.drawPath(eye, fill);
        canvas.drawPath(eye, stroke);
        canvas.drawCircle(p(0.5, 0.5), s * 0.11, solid);
      case Flaticons.eyeOff:
        final eye = Path()
          ..moveTo(s * 0.12, s * 0.5)
          ..quadraticBezierTo(s * 0.5, s * 0.18, s * 0.88, s * 0.5)
          ..quadraticBezierTo(s * 0.5, s * 0.82, s * 0.12, s * 0.5);
        canvas.drawPath(eye, stroke);
        line(0.2, 0.8, 0.8, 0.2);
      case Flaticons.copy:
        final back = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.18, s * 0.16, s * 0.48, s * 0.54),
          Radius.circular(s * 0.09),
        );
        final front = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.34, s * 0.32, s * 0.48, s * 0.54),
          Radius.circular(s * 0.09),
        );
        canvas.drawRRect(back, stroke);
        canvas.drawRRect(front, fill);
        canvas.drawRRect(front, stroke);
      case Flaticons.qrScan:
        line(0.18, 0.34, 0.18, 0.18);
        line(0.18, 0.18, 0.34, 0.18);
        line(0.66, 0.18, 0.82, 0.18);
        line(0.82, 0.18, 0.82, 0.34);
        line(0.18, 0.66, 0.18, 0.82);
        line(0.18, 0.82, 0.34, 0.82);
        line(0.66, 0.82, 0.82, 0.82);
        line(0.82, 0.82, 0.82, 0.66);
        line(0.24, 0.50, 0.76, 0.50);
      case Flaticons.qrCode:
        for (final pos in [p(0.16, 0.16), p(0.56, 0.16), p(0.16, 0.56)]) {
          final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(pos.dx, pos.dy, s * 0.26, s * 0.26),
            Radius.circular(s * 0.05),
          );
          canvas.drawRRect(r, fill);
          canvas.drawRRect(r, stroke);
        }
        line(0.58, 0.58, 0.72, 0.58);
        line(0.78, 0.66, 0.78, 0.82);
        line(0.58, 0.82, 0.66, 0.82);
      case Flaticons.shieldCheck:
        final shield = Path()
          ..moveTo(s * 0.5, s * 0.14)
          ..lineTo(s * 0.82, s * 0.26)
          ..lineTo(s * 0.82, s * 0.52)
          ..cubicTo(s * 0.82, s * 0.72, s * 0.5, s * 0.88, s * 0.5, s * 0.88)
          ..cubicTo(s * 0.5, s * 0.88, s * 0.18, s * 0.72, s * 0.18, s * 0.52)
          ..lineTo(s * 0.18, s * 0.26)
          ..close();
        canvas.drawPath(shield, fill);
        canvas.drawPath(shield, stroke);
        line(0.36, 0.52, 0.46, 0.62);
        line(0.46, 0.62, 0.66, 0.40);
      case Flaticons.lock:
        final box = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.20, s * 0.44, s * 0.60, s * 0.42),
          Radius.circular(s * 0.10),
        );
        canvas.drawRRect(box, fill);
        canvas.drawRRect(box, stroke);
        canvas.drawArc(
          Rect.fromLTWH(s * 0.32, s * 0.18, s * 0.36, s * 0.46),
          math.pi,
          math.pi,
          false,
          stroke,
        );
        canvas.drawCircle(p(0.5, 0.64), sw * 0.6, solid);
      case Flaticons.fingerprint:
        for (final r in [0.14, 0.26, 0.38]) {
          canvas.drawArc(
            Rect.fromCenter(
              center: p(0.5, 0.54),
              width: s * r * 2,
              height: s * r * 2.1,
            ),
            math.pi * 1.1,
            math.pi * 1.45,
            false,
            stroke,
          );
        }
      case Flaticons.settings:
        canvas.drawCircle(p(0.5, 0.5), s * 0.16, fill);
        canvas.drawCircle(p(0.5, 0.5), s * 0.16, stroke);
        canvas.drawCircle(p(0.5, 0.5), s * 0.32, stroke);
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          canvas.drawLine(
            Offset(
              s * 0.5 + math.cos(a) * s * 0.30,
              s * 0.5 + math.sin(a) * s * 0.30,
            ),
            Offset(
              s * 0.5 + math.cos(a) * s * 0.41,
              s * 0.5 + math.sin(a) * s * 0.41,
            ),
            stroke,
          );
        }
      case Flaticons.star:
      case Flaticons.starFilled:
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final r = i.isEven ? s * 0.38 : s * 0.17;
          final a = -math.pi / 2 + i * math.pi / 5;
          final pt = Offset(
            s * 0.5 + math.cos(a) * r,
            s * 0.5 + math.sin(a) * r,
          );
          i == 0 ? star.moveTo(pt.dx, pt.dy) : star.lineTo(pt.dx, pt.dy);
        }
        star.close();
        if (icon == Flaticons.starFilled) {
          canvas.drawPath(star, solid);
        } else {
          canvas.drawPath(star, fill);
          canvas.drawPath(star, stroke);
        }
      case Flaticons.candles:
        line(0.32, 0.16, 0.32, 0.84);
        final c1 = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.24, s * 0.32, s * 0.16, s * 0.34),
          Radius.circular(s * 0.04),
        );
        canvas.drawRRect(c1, fill);
        canvas.drawRRect(c1, stroke);
        line(0.68, 0.22, 0.68, 0.80);
        final c2 = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.60, s * 0.38, s * 0.16, s * 0.28),
          Radius.circular(s * 0.04),
        );
        canvas.drawRRect(c2, fill);
        canvas.drawRRect(c2, stroke);
      case Flaticons.fx:
        line(0.30, 0.78, 0.42, 0.22);
        line(0.42, 0.22, 0.56, 0.22);
        line(0.28, 0.48, 0.48, 0.48);
        line(0.56, 0.46, 0.78, 0.76);
        line(0.78, 0.46, 0.56, 0.76);
      case Flaticons.expand:
        line(0.18, 0.36, 0.18, 0.18);
        line(0.18, 0.18, 0.36, 0.18);
        line(0.64, 0.18, 0.82, 0.18);
        line(0.82, 0.18, 0.82, 0.36);
        line(0.18, 0.64, 0.18, 0.82);
        line(0.18, 0.82, 0.36, 0.82);
        line(0.64, 0.82, 0.82, 0.82);
        line(0.82, 0.82, 0.82, 0.64);
      case Flaticons.chevronDown:
        line(0.26, 0.38, 0.50, 0.62);
        line(0.50, 0.62, 0.74, 0.38);
      case Flaticons.chevronRight:
        line(0.38, 0.26, 0.62, 0.50);
        line(0.62, 0.50, 0.38, 0.74);
      case Flaticons.arrowLeft:
        line(0.78, 0.50, 0.22, 0.50);
        line(0.42, 0.30, 0.22, 0.50);
        line(0.42, 0.70, 0.22, 0.50);
      case Flaticons.arrowRight:
        line(0.22, 0.50, 0.78, 0.50);
        line(0.58, 0.30, 0.78, 0.50);
        line(0.58, 0.70, 0.78, 0.50);
      case Flaticons.checkCircle:
        canvas.drawCircle(p(0.5, 0.5), s * 0.34, fill);
        canvas.drawCircle(p(0.5, 0.5), s * 0.34, stroke);
        line(0.35, 0.51, 0.45, 0.61);
        line(0.45, 0.61, 0.66, 0.39);
      case Flaticons.closeCircle:
        canvas.drawCircle(p(0.5, 0.5), s * 0.34, fill);
        canvas.drawCircle(p(0.5, 0.5), s * 0.34, stroke);
        line(0.37, 0.37, 0.63, 0.63);
        line(0.63, 0.37, 0.37, 0.63);
      case Flaticons.warning:
        final tri = Path()
          ..moveTo(s * 0.50, s * 0.16)
          ..lineTo(s * 0.85, s * 0.82)
          ..lineTo(s * 0.15, s * 0.82)
          ..close();
        canvas.drawPath(tri, fill);
        canvas.drawPath(tri, stroke);
        line(0.50, 0.42, 0.50, 0.60);
        canvas.drawCircle(p(0.50, 0.72), sw * 0.55, solid);
      case Flaticons.network:
        canvas.drawCircle(p(0.5, 0.5), s * 0.34, fill);
        canvas.drawCircle(p(0.5, 0.5), s * 0.34, stroke);
        canvas.drawOval(
          Rect.fromCenter(
            center: p(0.5, 0.5),
            width: s * 0.32,
            height: s * 0.68,
          ),
          stroke,
        );
        line(0.18, 0.5, 0.82, 0.5);
      case Flaticons.paste:
        final clip = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.22, s * 0.22, s * 0.56, s * 0.64),
          Radius.circular(s * 0.09),
        );
        canvas.drawRRect(clip, fill);
        canvas.drawRRect(clip, stroke);
        final top = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.36, s * 0.14, s * 0.28, s * 0.14),
          Radius.circular(s * 0.05),
        );
        canvas.drawRRect(top, stroke);
      case Flaticons.share:
        canvas.drawCircle(p(0.72, 0.24), s * 0.10, fill);
        canvas.drawCircle(p(0.72, 0.24), s * 0.10, stroke);
        canvas.drawCircle(p(0.26, 0.50), s * 0.10, fill);
        canvas.drawCircle(p(0.26, 0.50), s * 0.10, stroke);
        canvas.drawCircle(p(0.72, 0.76), s * 0.10, fill);
        canvas.drawCircle(p(0.72, 0.76), s * 0.10, stroke);
        line(0.35, 0.45, 0.63, 0.29);
        line(0.35, 0.55, 0.63, 0.71);
      case Flaticons.refresh:
        canvas.drawArc(
          Rect.fromCenter(
            center: p(0.5, 0.5),
            width: s * 0.62,
            height: s * 0.62,
          ),
          -math.pi * 0.75,
          math.pi * 1.55,
          false,
          stroke,
        );
        line(0.74, 0.22, 0.78, 0.40);
        line(0.78, 0.40, 0.60, 0.40);
      case Flaticons.sparkles:
        final star = Path()
          ..moveTo(s * 0.46, s * 0.14)
          ..quadraticBezierTo(s * 0.46, s * 0.46, s * 0.14, s * 0.46)
          ..quadraticBezierTo(s * 0.46, s * 0.46, s * 0.46, s * 0.78)
          ..quadraticBezierTo(s * 0.46, s * 0.46, s * 0.78, s * 0.46)
          ..quadraticBezierTo(s * 0.46, s * 0.46, s * 0.46, s * 0.14)
          ..close();
        canvas.drawPath(star, fill);
        canvas.drawPath(star, stroke);
        line(0.76, 0.70, 0.76, 0.86);
        line(0.68, 0.78, 0.84, 0.78);
      case Flaticons.check:
        line(0.22, 0.52, 0.42, 0.72);
        line(0.42, 0.72, 0.78, 0.30);
    }
  }

  @override
  bool shouldRepaint(covariant _FIconPainter old) =>
      old.icon != icon || old.color != color || old.duotone != duotone;
}
