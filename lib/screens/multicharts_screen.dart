import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class MultichartsScreen extends StatefulWidget {
  final ValueChanged<DexPair>? onOpenPair;
  const MultichartsScreen({super.key, this.onOpenPair});

  @override
  State<MultichartsScreen> createState() => _MultichartsScreenState();
}

class _MultichartsScreenState extends State<MultichartsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MarketProvider>().loadMulticharts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final market = context.watch<MarketProvider>();
    final keys = market.multichartKeys;
    final tf = market.multichartTimeframe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multicharts'),
        actions: [
          IconButton(
            tooltip: 'Add Pair (max 4)',
            onPressed: () {
              showLivePairPickerSheet(context, (pair) {
                final ok = context.read<MarketProvider>().addMultichart(
                  pair.key,
                );
                if (!ok) {
                  showToast(context, 'Max 4 charts — remove one first');
                }
              });
            },
            icon: const FIcon(
              Flaticons.addWallet,
              size: 18,
              color: AppColors.primaryLight,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<MarketProvider>().loadMulticharts(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          children: [
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final t in const ['5m', '15m', '1h', '4h', '1d'])
                          GestureDetector(
                            onTap: () => context
                                .read<MarketProvider>()
                                .setMultichartTimeframe(t),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: tf == t
                                    ? AppColors.primaryGradient
                                    : null,
                                color: tf == t ? null : p.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: tf == t ? AppColors.primary : p.border,
                                ),
                              ),
                              child: Text(
                                t.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: tf == t
                                      ? Colors.white
                                      : p.textSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Text(
                  '${keys.length}/4',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (keys.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const FBadgeIcon(
                      Flaticons.candles,
                      color: AppColors.primaryLight,
                      size: 42,
                      iconSize: 20,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Compare Up to 4 Live Charts',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GradientButton(
                      label: '+ Add Pair to Multicharts',
                      icon: Flaticons.addWallet,
                      height: 36,
                      onPressed: () {
                        showLivePairPickerSheet(
                          context,
                          (pair) => context
                              .read<MarketProvider>()
                              .addMultichart(pair.key),
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              for (final k in keys) _chartPanel(p, market, k),
          ],
        ),
      ),
    );
  }

  Widget _chartPanel(AppPalette p, MarketProvider market, String key) {
    final pair = market.multichartPairs[key];
    final candles = market.multichartCandles[key] ?? const <DexCandle>[];
    final parts = key.split(':');
    final chainSlug = parts.isNotEmpty ? parts[0] : 'ethereum';
    final ci = chainInfoFor(chainSlug);
    final up = (pair?.change.h24 ?? 0) >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(10),
        onTap: pair == null
            ? null
            : () {
                context.read<MarketProvider>().selectPair(pair);
                widget.onOpenPair?.call(pair);
              },
        child: Column(
          children: [
            Row(
              children: [
                ChainBadge(chainSlug, size: 17),
                const SizedBox(width: 6),
                TokenAvatar(
                  symbol: pair?.base.symbol ?? '?',
                  imageUrl: pair?.base.image,
                  fallbackColor: ci.color,
                  size: 24,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pair?.pairLabel ?? shortHex(key),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      Text(
                        ci.name,
                        style: TextStyle(fontSize: 10, color: p.textMuted),
                      ),
                    ],
                  ),
                ),
                if (pair != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fmtDexPrice(pair.price),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      Text(
                        '${up ? '+' : ''}${pair.change.h24.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: up ? AppColors.green : AppColors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                GestureDetector(
                  onTap: () =>
                      context.read<MarketProvider>().removeMultichart(key),
                  child: FIcon(
                    Flaticons.closeCircle,
                    size: 16,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: CandleChart(candles: candles, twoMa: false),
            ),
          ],
        ),
      ),
    );
  }
}
