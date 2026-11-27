import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import '../widgets/hyper_header.dart';
import '../widgets/wallet_switcher.dart';
import 'create_wallet_screen.dart';
import 'recovery_phrase_screen.dart';
import 'security_screen.dart';

class WalletScreen extends StatefulWidget {
  final ValueChanged<DexPair>? onOpenPair;
  final ValueNotifier<int>? tabRequest;
  const WalletScreen({super.key, this.onOpenPair, this.tabRequest});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int tab = 0; // 0 On-Chain | 1 Orders | 2 Watchlist
  bool hidden = false;

  @override
  void initState() {
    super.initState();
    widget.tabRequest?.addListener(_onTabRequested);
  }

  @override
  void didUpdateWidget(covariant WalletScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabRequest != widget.tabRequest) {
      oldWidget.tabRequest?.removeListener(_onTabRequested);
      widget.tabRequest?.addListener(_onTabRequested);
    }
  }

  @override
  void dispose() {
    widget.tabRequest?.removeListener(_onTabRequested);
    super.dispose();
  }

  void _onTabRequested() {
    final req = widget.tabRequest?.value ?? 0;
    if (mounted && req >= 0 && req <= 2) {
      setState(() => tab = req);
    }
  }

  void _push(Widget w) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final walletProv = context.watch<WalletProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final market = context.watch<MarketProvider>();
    final wallets = walletProv.wallets;
    final wallet = walletProv.activeWallet;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          HyperTopBar(onSelectPair: widget.onOpenPair),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 8, 2),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'My Wallet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: GestureDetector(
                    onTap: () => showWalletSwitcherSheet(context),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: p.cardAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FIcon(
                              Flaticons.wallet,
                              size: 12,
                              color: wallet != null
                                  ? AppColors.green
                                  : AppColors.primaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              wallet != null
                                  ? '${wallet.name} (${wallets.length})'
                                  : (wallets.isNotEmpty
                                        ? 'Switch (${wallets.length})'
                                        : 'Connect Wallet'),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: p.text,
                              ),
                            ),
                            const SizedBox(width: 2),
                            FIcon(
                              Flaticons.chevronDown,
                              size: 11,
                              color: p.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => _push(const SecurityScreen()),
                  icon: FIcon(Flaticons.shieldCheck, size: 18, color: p.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              children: [
                _balanceHero(p, wallet, portfolio, market),
                const SizedBox(height: 10),
                _tabs(p),
                const SizedBox(height: 8),
                ..._tabContent(p, wallet, portfolio, market),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceHero(
    AppPalette p,
    WalletAccount? wallet,
    PortfolioProvider portfolio,
    MarketProvider market,
  ) {
    final totalUsd = portfolio.totalOnChainUsd(market.nativeUsdPrice);
    final isLoading = portfolio.isLoadingBalances;

    return GlassCard(
      gradient: p.heroGradient,
      radius: 14,
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.primary.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        wallet != null
                            ? '${wallet.name} · On-Chain'
                            : 'On-Chain Web3 Wallet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => hidden = !hidden),
                      child: FIcon(
                        hidden ? Flaticons.eyeOff : Flaticons.eye,
                        size: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (wallet != null)
                GestureDetector(
                  onTap: () => context
                      .read<PortfolioProvider>()
                      .refreshOnChainBalances(wallet.ethAddress),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FIcon(
                          Flaticons.refresh,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLoading ? 'Syncing…' : 'Sync RPC',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hidden ? '\$ ••••••' : fmtCompactUsd(totalUsd),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (wallet != null) ...[
            Row(
              children: [
                _chainAddrChip('EVM', wallet.shortEth, wallet.ethAddress),
                const SizedBox(width: 6),
                _chainAddrChip('BTC', wallet.shortBtc, wallet.btcAddress),
                const SizedBox(width: 6),
                _chainAddrChip(
                  'SOL',
                  wallet.shortAddress(wallet.solAddress),
                  wallet.solAddress,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _heroBtn(
                  Flaticons.wallet,
                  'Switch / Add Wallet',
                  () => showWalletSwitcherSheet(context),
                  filled: true,
                ),
                const SizedBox(width: 8),
                _heroBtn(
                  Flaticons.key,
                  'Backup Phrase',
                  () => _push(const RecoveryPhraseScreen()),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Connect or create a self-custody wallet to query live EVM RPC balances.',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _heroBtn(
                  Flaticons.addWallet,
                  'Create Wallet',
                  () => _push(const CreateWalletScreen(initialTab: 0)),
                  filled: true,
                ),
                const SizedBox(width: 8),
                _heroBtn(
                  Flaticons.recoverWallet,
                  'Recover Seed',
                  () => _push(const CreateWalletScreen(initialTab: 1)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chainAddrChip(String tag, String shortAddr, String fullAddr) =>
      Expanded(
        child: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: fullAddr));
            showToast(context, 'Copied $tag: $shortAddr');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    shortAddr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _heroBtn(
    Flaticons icon,
    String label,
    VoidCallback onTap, {
    bool filled = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            gradient: filled ? AppColors.primaryGradient : null,
            color: filled ? null : Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
            border: filled
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FIcon(icon, size: 13, color: Colors.white),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs(AppPalette p) {
    const labels = ['On-Chain', 'Orders', 'Watchlist'];
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final sel = i == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  gradient: sel ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : p.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _tabContent(
    AppPalette p,
    WalletAccount? wallet,
    PortfolioProvider portfolio,
    MarketProvider market,
  ) {
    if (tab == 0) {
      final rpcChains = kDexChains.values
          .where((c) => c.rpcUrl != null)
          .toList();
      final balances = portfolio.onChainBalances;
      return [
        if (wallet == null)
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Text(
              'No active wallet — tap Create Wallet or Recover Seed above to check live EVM balances.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: p.textMuted),
            ),
          )
        else
          for (final c in rpcChains)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    ChainBadge(c.slug, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: p.text,
                            ),
                          ),
                          Text(
                            'Native Gas (${c.symbol})',
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
                          '${(balances[c.slug] ?? 0).toStringAsFixed(5)} ${c.symbol}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        Text(
                          fmtCompactUsd(
                            (balances[c.slug] ?? 0) *
                                market.nativeUsdPrice(c.symbol),
                          ),
                          style: TextStyle(fontSize: 10.5, color: p.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ];
    }

    if (tab == 1) {
      final orders = portfolio.orders;
      if (orders.isEmpty) {
        return [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No orders yet — place a Spot Trade or Convert order to track it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: p.textMuted),
            ),
          ),
        ];
      }
      return [
        for (final o in orders)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  ChainBadge(o.chain, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${o.isBuy ? 'Buy' : 'Sell'} ${o.symbol}/${o.quoteSymbol} · ${o.orderType}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        Text(
                          '${fmtCompactNum(o.amount)} @ ${fmtDexPrice(o.price)}',
                          style: TextStyle(fontSize: 11, color: p.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        fmtCompactUsd(o.totalUsd),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      Text(
                        o.status,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: o.status == 'Filled'
                              ? AppColors.green
                              : o.status == 'Cancelled'
                              ? AppColors.red
                              : AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                  if (o.status == 'Open') ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () =>
                          context.read<PortfolioProvider>().cancelOrder(o.id),
                      child: const FIcon(
                        Flaticons.closeCircle,
                        size: 15,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ];
    }

    final watchPairs = portfolio.watchlistPairs;
    if (watchPairs.isEmpty) {
      return [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Your watchlist is empty. Tap ★ on any pair to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: p.textMuted),
          ),
        ),
      ];
    }

    return [
      for (final item in watchPairs)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            onTap: () {
              context.read<MarketProvider>().selectPair(item);
              widget.onOpenPair?.call(item);
            },
            child: Row(
              children: [
                ChainBadge(item.chain, size: 18),
                const SizedBox(width: 8),
                TokenAvatar(
                  symbol: item.base.symbol,
                  imageUrl: item.base.image,
                  fallbackColor: chainInfoFor(item.chain).color,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
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
                Column(
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
                    ChangeText(item.change.h24, size: 10.5),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
