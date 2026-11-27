import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
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
    final themeProv = context.watch<ThemeProvider>();
    final isDark = themeProv.isDark;
    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
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

class TokenAvatar extends StatelessWidget {
  final String symbol;
  final String? imageUrl;
  final Color fallbackColor;
  final double size;

  const TokenAvatar({
    super.key,
    required this.symbol,
    this.imageUrl,
    this.fallbackColor = AppColors.primary,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final letter = symbol.isNotEmpty ? symbol[0].toUpperCase() : '?';
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fallbackColor.withValues(alpha: 0.2),
        border: Border.all(color: fallbackColor.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.44,
            fontWeight: FontWeight.w800,
            color: fallbackColor,
          ),
        ),
      ),
    );

    if (!enableNetworkImages ||
        imageUrl == null ||
        imageUrl!.isEmpty ||
        !imageUrl!.startsWith('http')) {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class ChainBadge extends StatelessWidget {
  final String chainSlug;
  final double size;
  const ChainBadge(this.chainSlug, {super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final info = chainInfoFor(chainSlug);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Text(
          info.badgeChar,
          style: TextStyle(
            fontSize: size * 0.56,
            fontWeight: FontWeight.w800,
            color: info.color.computeLuminance() > 0.65
                ? Colors.black
                : Colors.white,
          ),
        ),
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

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
    child: Row(
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.pal.text,
            ),
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    ),
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

Future<void> showLivePairPickerSheet(
  BuildContext context,
  ValueChanged<DexPair> onPick,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.pal.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _LivePairPickerSheet(onPick: onPick),
  );
}

class _LivePairPickerSheet extends StatefulWidget {
  final ValueChanged<DexPair> onPick;
  const _LivePairPickerSheet({required this.onPick});

  @override
  State<_LivePairPickerSheet> createState() => _LivePairPickerSheetState();
}

class _LivePairPickerSheetState extends State<_LivePairPickerSheet> {
  final ctrl = TextEditingController();
  Timer? _debounce;
  late List<DexPair> results = context.read<MarketProvider>().trendingPools;
  bool loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    ctrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    final clean = q.trim();
    if (clean.length < 2) {
      setState(() {
        results = context.read<MarketProvider>().trendingPools;
        loading = false;
      });
      return;
    }
    setState(() => loading = true);
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      final list = await context.read<MarketProvider>().searchPairs(clean);
      if (!mounted) return;
      setState(() {
        results = list;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 12 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: p.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Select Live DEX Pair',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              onChanged: _onSearch,
              style: TextStyle(fontSize: 13, color: p.text),
              decoration: InputDecoration(
                hintText: 'Search symbol, pair or contract address…',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(9),
                  child: FIcon(Flaticons.search, size: 15, color: p.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : results.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No matching pairs found',
                          style: TextStyle(fontSize: 12.5, color: p.textMuted),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: results.length.clamp(0, 20),
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: p.border),
                      itemBuilder: (_, i) {
                        final item = results[i];
                        final ci = chainInfoFor(item.chain);
                        final up = item.change.h24 >= 0;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          leading: TokenAvatar(
                            symbol: item.base.symbol,
                            imageUrl: item.base.image,
                            fallbackColor: ci.color,
                            size: 30,
                          ),
                          title: Row(
                            children: [
                              ChainBadge(item.chain, size: 15),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  item.pairLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: p.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${ci.name} · Liq ${fmtCompactUsd(item.liquidity, decimals: 1)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: p.textMuted),
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                fmtDexPrice(item.price),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: p.text,
                                ),
                              ),
                              Text(
                                '${up ? '+' : ''}${item.change.h24.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: up ? AppColors.green : AppColors.red,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onPick(item);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showPriceAlertDialog(BuildContext context, DexPair pair) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _PriceAlertDialog(pair: pair),
  );
}

class _PriceAlertDialog extends StatefulWidget {
  final DexPair pair;
  const _PriceAlertDialog({required this.pair});

  @override
  State<_PriceAlertDialog> createState() => _PriceAlertDialogState();
}

class _PriceAlertDialogState extends State<_PriceAlertDialog> {
  bool above = true;
  late final targetCtrl = TextEditingController(
    text: (widget.pair.price * 1.05).toStringAsPrecision(5),
  );

  @override
  void dispose() {
    targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AlertDialog(
      backgroundColor: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.border),
      ),
      title: Text(
        'Price Alert · ${widget.pair.pairLabel}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: p.text,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current price: ${fmtDexPrice(widget.pair.price)}',
              style: TextStyle(fontSize: 12, color: p.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => above = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: above ? AppColors.green : p.field,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: above ? AppColors.green : p.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '▲ Above',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: above ? Colors.black : p.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => above = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !above ? AppColors.red : p.field,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !above ? AppColors.red : p.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '▼ Below',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: !above ? Colors.white : p.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(fontSize: 13, color: p.text),
              decoration: const InputDecoration(
                labelText: 'Target Price (USD)',
                suffixText: 'USD',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            final target = double.tryParse(targetCtrl.text.trim()) ?? 0;
            if (target <= 0) {
              showToast(context, 'Enter a valid target price');
              return;
            }
            context.read<PortfolioProvider>().addAlert(
              pair: widget.pair,
              above: above,
              target: target,
            );
            Navigator.pop(context);
            showToast(
              context,
              'Alert set: ${widget.pair.pairLabel} ${above ? 'above' : 'below'} ${fmtDexPrice(target)}',
            );
          },
          child: const Text('Create Alert'),
        ),
      ],
    );
  }
}

/// HyperDEX metallic/emerald "#" brand icon backed by asset PNG.
class DexNovaLogo extends StatelessWidget {
  final double size;
  final bool showBadge;
  const DexNovaLogo({super.key, this.size = 36, this.showBadge = true});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.27);
    final img = ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        'assets/hyperdex_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
    if (!showBadge) return img;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1211),
        borderRadius: radius,
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.35),
          width: (size * 0.032).clamp(0.8, 1.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.2),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      child: img,
    );
  }
}

/// Full HyperDEX "# HYPER DEX" horizontal wordmark badge.
class HyperDexWordmark extends StatelessWidget {
  final double height;
  const HyperDexWordmark({super.key, this.height = 30});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(8);
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111015),
        borderRadius: r,
        border: Border.all(color: AppColors.green.withValues(alpha: 0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/hyperdex_logo.png',
          height: height - 4,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
