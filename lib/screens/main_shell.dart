import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'alerts_screen.dart';
import 'home_screen.dart';
import 'multicharts_screen.dart';
import 'security_screen.dart';
import 'swap_bridge_screen.dart';
import 'trade_screen.dart';
import 'wallet_screen.dart';
import 'watchlist_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0; // 0 Home | 1 Trade | 2 New Pairs | 3 Convert | 4 Wallet
  String? _lastWalletEth;
  final ValueNotifier<int> _walletTabReq = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MarketProvider>().init();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final eth = context.watch<WalletProvider>().activeWallet?.ethAddress;
    if (eth != _lastWalletEth) {
      _lastWalletEth = eth;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<PortfolioProvider>().refreshOnChainBalances(eth);
      });
    }
  }

  @override
  void dispose() {
    _walletTabReq.dispose();
    super.dispose();
  }

  void go(int i, {String? marketTab, int? walletSubTab}) {
    final mp = context.read<MarketProvider>();
    if (marketTab != null) {
      mp.ensureMarketTab(marketTab);
    } else if (i == 2) {
      mp.ensureMarketTab('new');
    } else if (i == 0 && mp.marketTab == 'new') {
      mp.ensureMarketTab('trending');
    }
    if (i == 4 && walletSubTab != null) {
      _walletTabReq.value = walletSubTab;
    }
    setState(() => index = i);
  }

  void _openPairInTrade(DexPair pair) {
    context.read<MarketProvider>().selectPair(pair);
    go(1);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final pages = [
      HomeScreen(onOpenPair: _openPairInTrade),
      TradeScreen(onOpenScreener: () => go(0, marketTab: 'trending')),
      HomeScreen(onOpenPair: _openPairInTrade, isNewPairsTab: true),
      ConvertTabScreen(onOpenPair: _openPairInTrade, onOpenTrade: () => go(1)),
      WalletScreen(onOpenPair: _openPairInTrade, tabRequest: _walletTabReq),
    ];
    return Scaffold(
      drawer: _AppDrawer(
        currentIndex: index,
        onSelectTab: (tabIdx, {marketTab, walletSubTab}) =>
            go(tabIdx, marketTab: marketTab, walletSubTab: walletSubTab),
        onOpenPair: _openPairInTrade,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.bgSecondary, p.bg],
          ),
        ),
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: _BottomBar(index: index, onTap: (i) => go(i)),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final int currentIndex;
  final void Function(int index, {String? marketTab, int? walletSubTab})
  onSelectTab;
  final ValueChanged<DexPair> onOpenPair;

  const _AppDrawer({
    required this.currentIndex,
    required this.onSelectTab,
    required this.onOpenPair,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final marketTab = context.watch<MarketProvider>().marketTab;
    final wallet = context.watch<WalletProvider>().activeWallet;

    Widget navItem({
      required Flaticons icon,
      required String label,
      bool active = false,
      String? badge,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              gradient: active
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.22),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(9),
              border: active
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                  : null,
            ),
            child: Row(
              children: [
                FIcon(
                  icon,
                  size: 16,
                  color: active ? AppColors.primaryLight : p.textSecondary,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? p.text : p.textSecondary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
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

    return Drawer(
      backgroundColor: p.card,
      width: 268,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: HyperDexWordmark(height: 30),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          wallet?.shortEth ?? 'HYPER DEX · LIVE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: wallet != null
                                ? AppColors.green
                                : p.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: p.field,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: p.border),
                      ),
                      child: Center(
                        child: FIcon(
                          Flaticons.closeCircle,
                          size: 14,
                          color: p.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: p.border, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  navItem(
                    icon: Flaticons.home,
                    label: 'Home',
                    active: currentIndex == 0 && marketTab != 'gainers',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(0, marketTab: 'trending');
                    },
                  ),
                  navItem(
                    icon: Flaticons.candles,
                    label: 'Spot Trade',
                    active: currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(1);
                    },
                  ),
                  navItem(
                    icon: Flaticons.sparkles,
                    label: 'Trending',
                    badge: 'Hot',
                    active: currentIndex == 0 && marketTab == 'trending',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(0, marketTab: 'trending');
                    },
                  ),
                  navItem(
                    icon: Flaticons.trade,
                    label: 'Convert',
                    active: currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(3);
                    },
                  ),
                  navItem(
                    icon: Flaticons.starFilled,
                    label: 'New Pairs',
                    badge: 'New',
                    active: currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(2, marketTab: 'new');
                    },
                  ),
                  navItem(
                    icon: Flaticons.markets,
                    label: 'Gainers & Losers',
                    active:
                        currentIndex == 0 &&
                        (marketTab == 'gainers' || marketTab == 'losers'),
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(0, marketTab: 'gainers');
                    },
                  ),
                  navItem(
                    icon: Flaticons.more,
                    label: 'Multicharts',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultichartsScreen(
                            onOpenPair: (pair) {
                              Navigator.pop(context);
                              onOpenPair(pair);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Divider(color: p.border, height: 1),
                  ),
                  navItem(
                    icon: Flaticons.wallet,
                    label: 'Wallet',
                    active: currentIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(4, walletSubTab: 0);
                    },
                  ),
                  navItem(
                    icon: Flaticons.paste,
                    label: 'Orders',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(4, walletSubTab: 1);
                    },
                  ),
                  navItem(
                    icon: Flaticons.star,
                    label: 'Watchlist',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WatchlistScreen(
                            onOpenPair: (pair) {
                              Navigator.pop(context);
                              onOpenPair(pair);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  navItem(
                    icon: Flaticons.bell,
                    label: 'Alerts & Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlertsScreen(
                            onOpenPair: (pair) {
                              Navigator.pop(context);
                              onOpenPair(pair);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  navItem(
                    icon: Flaticons.shieldCheck,
                    label: 'Security & Vault',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SecurityScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: p.cardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Trade Crypto\nGlobally',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: p.text,
                            ),
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Center(
                            child: FIcon(
                              Flaticons.candles,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final perk in const [
                      'Low Trading Fees (0.10%)',
                      'Real-Time Multi-Chain Liquidity',
                      '18+ DEX Networks Live',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            const FIcon(
                              Flaticons.check,
                              size: 11,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                perk,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: p.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    GradientButton(
                      label: 'Get Started →',
                      height: 34,
                      onPressed: () {
                        Navigator.pop(context);
                        onSelectTab(1);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    const items = [
      (Flaticons.home, 'Home'),
      (Flaticons.candles, 'Trade'),
      (Flaticons.sparkles, 'New Pairs'),
      (Flaticons.trade, 'Convert'),
      (Flaticons.wallet, 'Wallet'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: p.navBg,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == index;
              final color = selected ? AppColors.primaryLight : p.textMuted;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Container(
                    decoration: selected
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.16),
                                Colors.transparent,
                              ],
                            ),
                          )
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FIcon(items[i].$1, color: color, size: 18),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            items[i].$2,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: color,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
