import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class WatchlistScreen extends StatefulWidget {
  final ValueChanged<DexPair>? onOpenPair;
  const WatchlistScreen({super.key, this.onOpenPair});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PortfolioProvider>().loadWatchlistPairs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final portfolio = context.watch<PortfolioProvider>();
    final watchKeys = portfolio.watchlistKeys;
    final items = portfolio.watchlistPairs;
    final loading = portfolio.isLoadingWatchlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<PortfolioProvider>().loadWatchlistPairs(),
            icon: FIcon(Flaticons.refresh, size: 17, color: p.text),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PortfolioProvider>().loadWatchlistPairs(),
        child: watchKeys.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 40),
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const FBadgeIcon(
                          Flaticons.starFilled,
                          color: AppColors.amber,
                          size: 44,
                          iconSize: 22,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your Watchlist is Empty',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tap the ★ star icon on any pair in Home, Markets, or Trade to track live prices here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: p.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : (loading && items.isEmpty)
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final pair = items[i];
                  final ci = chainInfoFor(pair.chain);
                  final up = pair.change.h24 >= 0;
                  return GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    onTap: () {
                      context.read<MarketProvider>().selectPair(pair);
                      if (widget.onOpenPair != null) {
                        widget.onOpenPair!(pair);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context
                              .read<PortfolioProvider>()
                              .toggleWatch(pair.key),
                          child: const FIcon(
                            Flaticons.starFilled,
                            size: 16,
                            color: AppColors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChainBadge(pair.chain, size: 17),
                        const SizedBox(width: 6),
                        TokenAvatar(
                          symbol: pair.base.symbol,
                          imageUrl: pair.base.image,
                          fallbackColor: ci.color,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pair.pairLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: p.text,
                                ),
                              ),
                              Text(
                                '${ci.name} · Liq ${fmtCompactUsd(pair.liquidity, decimals: 1)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: p.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: up ? AppColors.green : AppColors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
