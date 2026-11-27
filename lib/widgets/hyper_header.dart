import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/wallet_provider.dart';
import '../screens/alerts_screen.dart';
import '../theme.dart';
import 'common.dart';
import 'flaticon.dart';
import 'wallet_switcher.dart';

class HyperTopBar extends StatefulWidget {
  final ValueChanged<DexPair>? onSelectPair;
  const HyperTopBar({super.key, this.onSelectPair});

  @override
  State<HyperTopBar> createState() => _HyperTopBarState();
}

class _HyperTopBarState extends State<HyperTopBar> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<DexPair> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    final clean = q.trim();
    if (clean.length < 2) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      final list = await context.read<MarketProvider>().searchPairs(clean);
      if (!mounted) return;
      setState(() {
        _results = list;
        _searching = false;
      });
    });
  }

  Widget _iconBtn(
    AppPalette p, {
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: p.border),
        ),
        child: Center(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final portfolio = context.watch<PortfolioProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final walletProv = context.watch<WalletProvider>();
    final wallet = walletProv.activeWallet;
    final hasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Row(
            children: [
              if (hasDrawer) ...[
                _iconBtn(
                  p,
                  onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
                  child: FIcon(Flaticons.menu, size: 15, color: p.text),
                ),
                const SizedBox(width: 5),
              ],
              const DexNovaLogo(size: 28),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: p.field,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: p.border),
                  ),
                  child: Row(
                    children: [
                      FIcon(Flaticons.search, size: 13, color: p.textMuted),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _onSearch,
                          style: TextStyle(fontSize: 11.5, color: p.text),
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search...',
                          ),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() {
                              _results = [];
                              _searching = false;
                            });
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
              const SizedBox(width: 5),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _iconBtn(
                    p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AlertsScreen()),
                    ),
                    child: FIcon(Flaticons.bell, size: 14, color: p.text),
                  ),
                  if (portfolio.activeAlertCount > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 5),
              _iconBtn(
                p,
                onTap: () => context.read<ThemeProvider>().toggleTheme(),
                child: FIcon(
                  themeProv.isDark ? Flaticons.moon : Flaticons.sun,
                  size: 14,
                  color: themeProv.isDark ? p.textSecondary : AppColors.amber,
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => showWalletSwitcherSheet(context),
                child: Container(
                  height: 30,
                  constraints: const BoxConstraints(maxWidth: 102),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (wallet != null)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: const BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                              ),
                            )
                          else ...[
                            const FIcon(
                              Flaticons.wallet,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            wallet?.shortEth ?? 'Connect',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_searching || _results.isNotEmpty) _searchDropdown(p),
      ],
    );
  }

  Widget _searchDropdown(AppPalette p) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: _searching && _results.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Column(
              children: [
                for (final item in _results.take(6))
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    leading: TokenAvatar(
                      symbol: item.base.symbol,
                      imageUrl: item.base.image,
                      fallbackColor: chainInfoFor(item.chain).color,
                      size: 24,
                    ),
                    title: Row(
                      children: [
                        ChainBadge(item.chain, size: 13),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            item.pairLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: p.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${chainInfoFor(item.chain).name} · Liq ${fmtCompactUsd(item.liquidity, decimals: 1)}',
                      style: TextStyle(fontSize: 10, color: p.textMuted),
                    ),
                    trailing: Text(
                      fmtDexPrice(item.price),
                      style: numStyle(fontSize: 11.5, color: p.text),
                    ),
                    onTap: () {
                      context.read<MarketProvider>().selectPair(item);
                      _searchCtrl.clear();
                      setState(() {
                        _results = [];
                        _searching = false;
                      });
                      widget.onSelectPair?.call(item);
                    },
                  ),
              ],
            ),
    );
  }
}

class LiveTickerGrid extends StatelessWidget {
  final ValueChanged<DexPair>? onTapPair;
  const LiveTickerGrid({super.key, this.onTapPair});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final market = context.watch<MarketProvider>();
    final tickers = market.tickers;
    final stats = market.stats;
    final active = market.activePair;

    if (tickers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: p.border),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 1.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Connecting to live multi-chain DEX feed…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: p.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    Widget tickerCell(DexTicker t) {
      final up = t.change >= 0;
      final chColor = up ? AppColors.green : AppColors.red;
      final ci = chainInfoFor(t.chain);
      final isSel = active != null && active.pair == t.pair;

      return Expanded(
        child: GestureDetector(
          onTap: () async {
            final mp = context.read<MarketProvider>();
            await mp.selectPairByKey(t.chain, t.pair);
            final selected = mp.activePair;
            if (selected != null) onTapPair?.call(selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSel
                    ? AppColors.primary.withValues(alpha: 0.75)
                    : p.border,
              ),
            ),
            child: Row(
              children: [
                TokenAvatar(
                  symbol: t.symbol,
                  fallbackColor: ci.color,
                  size: 24,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${t.symbol}/USDT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: p.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${up ? '▲' : '▼'} ${t.change.abs().toStringAsFixed(2)}%',
                            style: numStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: chColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          fmtDexPrice(t.price),
                          style: numStyle(fontSize: 12.5, color: chColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget statCell({
      required String label,
      required String value,
      String? liveTag,
      required Flaticons icon,
      required Color accent,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: p.textMuted),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value,
                            style: numStyle(fontSize: 13, color: p.text),
                          ),
                          if (liveTag != null) ...[
                            const SizedBox(width: 4),
                            Text(
                              liveTag,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Center(child: FIcon(icon, size: 12, color: accent)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tickers.isNotEmpty)
          Row(
            children: [
              tickerCell(tickers[0]),
              const SizedBox(width: 6),
              if (tickers.length > 1)
                tickerCell(tickers[1])
              else
                const Spacer(),
            ],
          ),
        if (tickers.length > 2) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              tickerCell(tickers[2]),
              const SizedBox(width: 6),
              if (tickers.length > 3)
                tickerCell(tickers[3])
              else
                const Spacer(),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            statCell(
              label: '24h Volume',
              value: fmtCompactUsd(stats.volume24h),
              icon: Flaticons.trade,
              accent: AppColors.primaryLight,
            ),
            const SizedBox(width: 6),
            statCell(
              label: 'Total Liquidity',
              value: fmtCompactUsd(stats.liquidity),
              liveTag: '▲Live',
              icon: Flaticons.network,
              accent: AppColors.green,
            ),
          ],
        ),
      ],
    );
  }
}
