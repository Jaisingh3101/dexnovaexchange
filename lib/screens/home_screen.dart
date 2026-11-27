import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import '../widgets/hyper_header.dart';
import '../widgets/wallet_switcher.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<DexPair>? onOpenPair;
  final bool isNewPairsTab;
  const HomeScreen({super.key, this.onOpenPair, this.isNewPairsTab = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _filterCtrl = TextEditingController();
  Timer? _debounce;

  static const _tabs = [
    ('trending', 'Trending', '🔥 '),
    ('gainers', 'Gainers', '↑ '),
    ('losers', 'Losers', '↓ '),
    ('new', 'New Pairs', '✦ '),
    ('volume', 'Most Traded', '◈ '),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final market = context.read<MarketProvider>();
      if (widget.isNewPairsTab) {
        market.ensureMarketTab('new');
      } else if (market.marketPools.isEmpty) {
        market.loadMarketPools();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _filterCtrl.dispose();
    super.dispose();
  }

  void _onFilterChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      context.read<MarketProvider>().searchMarkets(val);
    });
  }

  Future<void> _openFilterSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.pal.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final mp = ctx.watch<MarketProvider>();
        final p = ctx.pal;
        final dexes = mp.availableDexes;
        const liqOpts = [
          (0.0, 'Any'),
          (10000.0, '>\$10K'),
          (100000.0, '>\$100K'),
          (1000000.0, '>\$1M'),
        ];
        const volOpts = [
          (0.0, 'Any'),
          (50000.0, '>\$50K'),
          (500000.0, '>\$500K'),
          (5000000.0, '>\$5M'),
        ];

        Widget chip({
          required String label,
          required bool sel,
          required VoidCallback onTap,
        }) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: sel ? AppColors.primaryGradient : null,
                color: sel ? null : p.field,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sel ? AppColors.primary : p.border),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : p.textSecondary,
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Screener Filters',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          ctx.read<MarketProvider>().resetScreenerFilters(),
                      child: const Text('Reset All'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Minimum Liquidity',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final o in liqOpts)
                      chip(
                        label: o.$2,
                        sel: mp.minLiquidity == o.$1,
                        onTap: () => ctx
                            .read<MarketProvider>()
                            .setScreenerFilters(minLiquidity: o.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Minimum 24h Volume',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final o in volOpts)
                      chip(
                        label: o.$2,
                        sel: mp.minVolume24h == o.$1,
                        onTap: () => ctx
                            .read<MarketProvider>()
                            .setScreenerFilters(minVolume24h: o.$1),
                      ),
                  ],
                ),
                if (dexes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'DEX Protocol',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: p.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      chip(
                        label: 'All DEXes',
                        sel: mp.dexFilter.isEmpty,
                        onTap: () => ctx
                            .read<MarketProvider>()
                            .setScreenerFilters(dexFilter: ''),
                      ),
                      for (final d in dexes.take(10))
                        chip(
                          label: d.toUpperCase(),
                          sel: mp.dexFilter.toLowerCase() == d.toLowerCase(),
                          onTap: () => ctx
                              .read<MarketProvider>()
                              .setScreenerFilters(dexFilter: d),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                GradientButton(
                  label: 'Apply Filters',
                  height: 38,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final market = context.watch<MarketProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final rows = market.visibleMarketRows;
    final tab = market.marketTab;
    final period = market.rankPeriod;
    final selectedChain = market.selectedChain;
    final loading = market.isLoadingMarketsList;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          HyperTopBar(onSelectPair: widget.onOpenPair),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final mp = context.read<MarketProvider>();
                final pp = context.read<PortfolioProvider>();
                await mp.refreshAll();
                await mp.loadMarketPools();
                await pp.checkAlerts();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 14),
                children: [
                  const ActiveWalletStrip(),
                  const SizedBox(height: 6),
                  LiveTickerGrid(onTapPair: widget.onOpenPair),
                  const SizedBox(height: 8),
                  _categoryPills(p, tab),
                  const SizedBox(height: 7),
                  _filterAndRankRow(p, period),
                  const SizedBox(height: 7),
                  _chainChipsRow(p, selectedChain, market.hasActiveFilters),
                  const SizedBox(height: 8),
                  _pairsTable(p, rows, loading, portfolio, market.errorMessage),
                  const SizedBox(height: 6),
                  _statusFooter(p, rows.length, market.lastUpdatedAt),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryPills(AppPalette p, String activeTab) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final t = _tabs[i];
          final sel = activeTab == t.$1;
          return GestureDetector(
            onTap: () => context.read<MarketProvider>().setMarketTab(t.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: sel ? AppColors.primaryGradient : null,
                color: sel ? null : p.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sel ? AppColors.primary : p.border),
              ),
              child: Center(
                child: Text(
                  '${t.$3}${t.$2}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : p.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterAndRankRow(AppPalette p, String period) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _filterCtrl,
                    onChanged: _onFilterChanged,
                    style: TextStyle(fontSize: 11.5, color: p.text),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Filter tokens...',
                    ),
                  ),
                ),
                if (_filterCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _filterCtrl.clear();
                      context.read<MarketProvider>().searchMarkets('');
                    },
                    child: FIcon(
                      Flaticons.closeCircle,
                      size: 13,
                      color: p.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Rank',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: p.textMuted,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          height: 30,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final pr in const ['5m', '1h', '6h', '24h'])
                GestureDetector(
                  onTap: () => context.read<MarketProvider>().setRankPeriod(pr),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: period == pr ? AppColors.primaryGradient : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pr.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: period == pr ? Colors.white : p.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chainChipsRow(
    AppPalette p,
    String? selectedChain,
    bool hasActiveFilters,
  ) {
    Widget chip(String? slug, String label, Color dot) {
      final sel = selectedChain == slug;
      return GestureDetector(
        onTap: () => context.read<MarketProvider>().setSelectedChain(slug),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            gradient: sel ? AppColors.primaryGradient : null,
            color: sel ? null : p.card,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: sel ? AppColors.primary : p.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6.5,
                height: 6.5,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : p.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                chip(null, 'All Chains', AppColors.primaryLight),
                const SizedBox(width: 5),
                for (final c in kDexChains.values) ...[
                  chip(c.slug, c.name, c.color),
                  const SizedBox(width: 5),
                ],
              ],
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => _openFilterSheet(context),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : p.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasActiveFilters ? AppColors.primary : p.border,
                ),
              ),
              child: Center(
                child: FIcon(
                  Flaticons.settings,
                  size: 13,
                  color: hasActiveFilters
                      ? AppColors.primaryLight
                      : p.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusFooter(AppPalette p, int count, DateTime? updatedAt) {
    final ts = updatedAt == null
        ? 'Live'
        : '${updatedAt.hour.toString().padLeft(2, '0')}:${updatedAt.minute.toString().padLeft(2, '0')}:${updatedAt.second.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              '$count live pairs · $ts',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: p.textMuted),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              'Tap any row to trade',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 10, color: p.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pairsTable(
    AppPalette p,
    List<DexPair> rows,
    bool loading,
    PortfolioProvider portfolio,
    String? errorMsg,
  ) {
    if (loading && rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: p.border),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (rows.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              errorMsg ?? 'No matching live pairs right now',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: p.textMuted),
            ),
            const SizedBox(height: 8),
            GradientButton(
              label: 'Retry Live Feed',
              icon: Flaticons.refresh,
              height: 34,
              onPressed: () {
                final mp = context.read<MarketProvider>();
                mp.resetScreenerFilters();
                mp.loadMarketPools();
              },
            ),
          ],
        ),
      );
    }

    Widget hdrCell(String txt, double w, {bool right = false}) => SizedBox(
      width: w,
      child: Text(
        txt,
        textAlign: right ? TextAlign.right : TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: p.textMuted,
        ),
      ),
    );

    Widget pctCell(double val, double w) {
      final up = val >= 0;
      return SizedBox(
        width: w,
        child: Text(
          '${up ? '+' : ''}${val.toStringAsFixed(2)}%',
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: numStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: up ? AppColors.green : AppColors.red,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 680,
            child: Column(
              children: [
                Container(
                  color: p.cardAlt.withValues(alpha: 0.65),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      hdrCell('#', 28),
                      hdrCell('', 22),
                      hdrCell('TOKEN', 150),
                      hdrCell('PRICE', 78, right: true),
                      hdrCell('VOLUME', 66, right: true),
                      hdrCell('5M', 54, right: true),
                      hdrCell('1H', 54, right: true),
                      hdrCell('6H', 54, right: true),
                      hdrCell('24H', 58, right: true),
                      hdrCell('LIQ', 60, right: true),
                      hdrCell('MCAP', 60, right: true),
                    ],
                  ),
                ),
                Divider(color: p.border, height: 1),
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) Divider(color: p.border, height: 1),
                  _buildTableRow(
                    p: p,
                    pair: rows[i],
                    rank: i + 1,
                    watched: portfolio.isWatched(rows[i].key),
                    pctCell: pctCell,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow({
    required AppPalette p,
    required DexPair pair,
    required int rank,
    required bool watched,
    required Widget Function(double val, double w) pctCell,
  }) {
    final ci = chainInfoFor(pair.chain);
    final ch24 = pair.change.h24;
    final up = ch24 >= 0;
    final strongMove = ch24.abs() >= 5;
    final rowTint = strongMove
        ? (up
              ? AppColors.green.withValues(alpha: 0.08)
              : AppColors.red.withValues(alpha: 0.08))
        : null;

    return InkWell(
      onTap: () {
        context.read<MarketProvider>().selectPair(pair);
        widget.onOpenPair?.call(pair);
      },
      child: Container(
        color: rowTint,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#$rank',
                style: numStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: p.textMuted,
                ),
              ),
            ),
            SizedBox(
              width: 22,
              child: GestureDetector(
                onTap: () =>
                    context.read<PortfolioProvider>().toggleWatch(pair.key),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FIcon(
                    watched ? Flaticons.starFilled : Flaticons.star,
                    size: 13,
                    color: watched ? AppColors.amber : p.textMuted,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: Row(
                children: [
                  ChainBadge(pair.chain, size: 15),
                  const SizedBox(width: 5),
                  TokenAvatar(
                    symbol: pair.base.symbol,
                    imageUrl: pair.base.image,
                    fallbackColor: ci.color,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: pair.base.symbol,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: p.text,
                            ),
                          ),
                          TextSpan(
                            text: ' /${pair.quote.symbol}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 78,
              child: Text(
                fmtDexPrice(pair.price),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: numStyle(
                  fontSize: 11.5,
                  color: strongMove
                      ? (up ? AppColors.green : AppColors.red)
                      : (ch24 < 0 ? AppColors.red : p.text),
                ),
              ),
            ),
            SizedBox(
              width: 66,
              child: Text(
                fmtCompactUsd(pair.volume.h24, decimals: 1),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: numStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ),
            pctCell(pair.change.m5, 54),
            pctCell(pair.change.h1, 54),
            pctCell(pair.change.h6, 54),
            pctCell(ch24, 58),
            SizedBox(
              width: 60,
              child: Text(
                fmtCompactUsd(pair.liquidity, decimals: 1),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: numStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.textSecondary,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                fmtCompactUsd(pair.displayMcap, decimals: 1),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: numStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
