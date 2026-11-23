import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import 'flaticon.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final double radius;
  final VoidCallback? onTap;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.gradient,
    this.radius = 12,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? p.card : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? p.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool outlined;
  final Flaticons? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 40,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final r = BorderRadius.circular(10);
    final textColor = outlined ? p.text : Colors.white;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: r,
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: outlined ? null : AppColors.primaryGradient,
              color: outlined ? p.cardAlt : null,
              borderRadius: r,
              border: outlined ? Border.all(color: p.border) : null,
              boxShadow: outlined
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    FIcon(icon!, size: 15, color: textColor),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: height < 38 ? 12 : 13.5,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  final bool compact;
  const ThemeToggleButton({super.key, this.compact = true});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final isDark = p.isDark;
    return GestureDetector(
      onTap: toggleTheme,
      child: Container(
        height: 30,
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
        decoration: BoxDecoration(
          color: p.cardAlt,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: p.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FIcon(
              isDark ? Flaticons.sun : Flaticons.moon,
              size: 14,
              color: isDark ? AppColors.amber : AppColors.primary,
            ),
            if (!compact) ...[
              const SizedBox(width: 5),
              Text(
                isDark ? 'Light' : 'Dark',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CoinIcon extends StatelessWidget {
  final Coin coin;
  final double size;
  const CoinIcon(this.coin, {super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final isSol = coin.symbol == 'SOL';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSol ? Colors.black : coin.color,
        gradient: isSol
            ? const LinearGradient(
                colors: [Color(0xFF9945FF), Color(0xFF14F195)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Center(
        child: coin.symbol == 'USDT'
            ? Text(
                '₮',
                style: TextStyle(
                  fontSize: size * 0.55,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : Icon(coin.icon, size: size * 0.58, color: Colors.white),
      ),
    );
  }
}

class ChangeText extends StatelessWidget {
  final double change;
  final double size;
  const ChangeText(this.change, {super.key, this.size = 11.5});

  @override
  Widget build(BuildContext context) {
    final up = change >= 0;
    final color = up ? AppColors.green : AppColors.red;
    return Text(
      '${up ? '▲ +' : '▼ '}${change.toStringAsFixed(2)}%',
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4, top: 10),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        color: context.pal.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// Dropdown-looking selector that opens a bottom sheet.
class SelectorTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Flaticons trailing;

  const SelectorTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing = Flaticons.chevronDown,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return GlassCard(
      onTap: onTap,
      radius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: p.textMuted),
              ),
            ),
          ],
          const Spacer(),
          FIcon(trailing, color: p.textSecondary, size: 16),
        ],
      ),
    );
  }
}

class TronIcon extends StatelessWidget {
  final double size;
  const TronIcon({super.key, this.size = 24});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFFEF0027).withValues(alpha: 0.14),
    ),
    child: Icon(
      Icons.change_history,
      color: const Color(0xFFEF0027),
      size: size * 0.58,
    ),
  );
}

/// Compact section header used across screens.
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
    child: Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.pal.text,
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    ),
  );
}

Widget _sheet(BuildContext context, String title, List<Widget> children) {
  final p = context.pal;
  return SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            width: 34,
            height: 4,
            decoration: BoxDecoration(
              color: p.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 6),
      ],
    ),
  );
}

Future<Coin?> pickCoin(BuildContext context) {
  return showModalBottomSheet<Coin>(
    context: context,
    backgroundColor: context.pal.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _sheet(ctx, 'Select Coin', [
      for (final c in coins.take(5))
        ListTile(
          leading: CoinIcon(c, size: 26),
          title: Text(c.symbol),
          subtitle: Text(c.name),
          trailing: Text(
            '\$${fmtUsd(c.price)}',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: ctx.pal.text,
            ),
          ),
          onTap: () => Navigator.pop(ctx, c),
        ),
    ]),
  );
}

Future<String?> pickNetwork(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.pal.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _sheet(ctx, 'Select Network', [
      for (final n in networks)
        ListTile(
          leading: const FIcon(
            Flaticons.network,
            size: 18,
            color: AppColors.primaryLight,
          ),
          title: Text(n),
          onTap: () => Navigator.pop(ctx, n),
        ),
    ]),
  );
}

void showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
}

/// 3D faceted hexagonal DexNova "D" emblem on a glowing gradient squircle.
class DexNovaLogo extends StatelessWidget {
  final double size;
  final bool showBadge;
  const DexNovaLogo({super.key, this.size = 36, this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DexNovaLogoPainter(showBadge)),
    );
    if (!showBadge) return mark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.27),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1572), Color(0xFF140933)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.45),
          width: (size * 0.035).clamp(1.0, 2.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.32,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: CustomPaint(painter: _DexNovaLogoPainter(true)),
    );
  }
}

class _DexNovaLogoPainter extends CustomPainter {
  final bool framed;
  _DexNovaLogoPainter(this.framed);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final pad = framed ? s * 0.17 : s * 0.04;
    final w = s - pad * 2;
    final h = s - pad * 2;
    Offset p(double x, double y) => Offset(pad + w * x, pad + h * y);

    final outer = Path()
      ..moveTo(p(0.14, 0.04).dx, p(0.14, 0.04).dy)
      ..lineTo(p(0.62, 0.04).dx, p(0.62, 0.04).dy)
      ..lineTo(p(0.95, 0.30).dx, p(0.95, 0.30).dy)
      ..lineTo(p(0.95, 0.70).dx, p(0.95, 0.70).dy)
      ..lineTo(p(0.62, 0.96).dx, p(0.62, 0.96).dy)
      ..lineTo(p(0.06, 0.96).dx, p(0.06, 0.96).dy)
      ..lineTo(p(0.24, 0.74).dx, p(0.24, 0.74).dy)
      ..lineTo(p(0.24, 0.26).dx, p(0.24, 0.26).dy)
      ..close();

    final inner = Path()
      ..moveTo(p(0.45, 0.28).dx, p(0.45, 0.28).dy)
      ..lineTo(p(0.60, 0.28).dx, p(0.60, 0.28).dy)
      ..lineTo(p(0.74, 0.40).dx, p(0.74, 0.40).dy)
      ..lineTo(p(0.74, 0.60).dx, p(0.74, 0.60).dy)
      ..lineTo(p(0.60, 0.72).dx, p(0.60, 0.72).dy)
      ..lineTo(p(0.45, 0.72).dx, p(0.45, 0.72).dy)
      ..close();

    final body = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawShadow(body, const Color(0xFF4F7BFF), s * 0.14, false);
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF7B3FF2), Color(0xFF5B21D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(pad, pad, w, h)),
    );

    // Top-right specular facet for 3D prism depth
    final topFacet = Path()
      ..moveTo(p(0.14, 0.04).dx, p(0.14, 0.04).dy)
      ..lineTo(p(0.62, 0.04).dx, p(0.62, 0.04).dy)
      ..lineTo(p(0.95, 0.30).dx, p(0.95, 0.30).dy)
      ..lineTo(p(0.74, 0.40).dx, p(0.74, 0.40).dy)
      ..lineTo(p(0.60, 0.28).dx, p(0.60, 0.28).dy)
      ..lineTo(p(0.24, 0.26).dx, p(0.24, 0.26).dy)
      ..close();
    canvas.drawPath(
      topFacet,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF14F195).withValues(alpha: 0.48),
            const Color(0xFF60A5FA).withValues(alpha: 0.22),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(pad, pad, w, h)),
    );

    // Crisp bottom highlight edge
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (s * 0.025).clamp(0.7, 1.8),
    );
  }

  @override
  bool shouldRepaint(covariant _DexNovaLogoPainter old) => old.framed != framed;
}
