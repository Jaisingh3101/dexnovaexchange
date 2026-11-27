import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dexnova/main.dart';
import 'package:dexnova/models/dex_models.dart';
import 'package:dexnova/providers/portfolio_provider.dart';
import 'package:dexnova/providers/theme_provider.dart';
import 'package:dexnova/providers/wallet_provider.dart';
import 'package:dexnova/services/api_service.dart';
import 'package:dexnova/screens/alerts_screen.dart';
import 'package:dexnova/screens/create_wallet_screen.dart';
import 'package:dexnova/screens/more_screen.dart';
import 'package:dexnova/screens/multicharts_screen.dart';
import 'package:dexnova/screens/onboarding_screen.dart';
import 'package:dexnova/screens/security_screen.dart';
import 'package:dexnova/screens/splash_screen.dart';
import 'package:dexnova/screens/swap_bridge_screen.dart';
import 'package:dexnova/screens/trade_screen.dart';
import 'package:dexnova/screens/watchlist_screen.dart';
import 'package:dexnova/widgets/wallet_switcher.dart';

class FakeApiService implements ApiServiceContract {
  static final _now = DateTime(2026, 11, 24, 13, 30).millisecondsSinceEpoch;
  PairWalletBalances pairBalancesResult = const PairWalletBalances(
    loaded: true,
  );

  static final List<DexPair> samplePairs = [
    DexPair(
      chain: 'bsc',
      pair: '0x172fcd41e0913e95784454622d1c3724f546f849',
      dex: 'pancakeswap_v3',
      base: const DexToken(
        symbol: 'WBNB',
        name: 'Wrapped BNB',
        address: '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c',
      ),
      quote: const DexToken(
        symbol: 'USDT',
        name: 'Tether USD',
        address: '0x55d398326f99059fF775485246999027B3197955',
      ),
      price: 684.50,
      priceNative: 1.0,
      change: const DexChange(m5: 0.42, h1: 1.15, h6: 2.1, h24: 3.45),
      volume: const DexVolume(
        m5: 120000,
        h1: 2400000,
        h6: 9800000,
        h24: 48200000,
      ),
      liquidity: 18500000,
      fdv: 98000000000,
      mcap: 98000000000,
      txns: const DexTxns(buys: 4120, sells: 3380),
      createdMs: _now - 86400000 * 30,
    ),
    DexPair(
      chain: 'ethereum',
      pair: '0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640',
      dex: 'uniswap_v3',
      base: const DexToken(
        symbol: 'ETH',
        name: 'Ethereum',
        address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
      ),
      quote: const DexToken(
        symbol: 'USDC',
        name: 'USD Coin',
        address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      ),
      price: 3420.18,
      priceNative: 1.0,
      change: const DexChange(m5: 0.18, h1: 0.72, h6: 1.5, h24: 2.12),
      volume: const DexVolume(
        m5: 450000,
        h1: 8900000,
        h6: 41000000,
        h24: 192000000,
      ),
      liquidity: 215000000,
      fdv: 410000000000,
      mcap: 410000000000,
      txns: const DexTxns(buys: 8900, sells: 7420),
      createdMs: _now - 86400000 * 90,
    ),
    DexPair(
      chain: 'solana',
      pair: '58oQChx4yWmvKdwLLZzBi4ChoCc2fqCUWBkwMihLYQo2',
      dex: 'raydium',
      base: const DexToken(
        symbol: 'SOL',
        name: 'Solana',
        address: 'So11111111111111111111111111111111111111112',
      ),
      quote: const DexToken(
        symbol: 'USDC',
        name: 'USD Coin',
        address: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
      ),
      price: 205.84,
      priceNative: 1.0,
      change: const DexChange(m5: -0.25, h1: 0.9, h6: 2.8, h24: 4.18),
      volume: const DexVolume(
        m5: 380000,
        h1: 5200000,
        h6: 22000000,
        h24: 118000000,
      ),
      liquidity: 64000000,
      fdv: 96000000000,
      mcap: 96000000000,
      txns: const DexTxns(buys: 12100, sells: 9800),
      createdMs: _now - 86400000 * 120,
    ),
    DexPair(
      chain: 'ethereum',
      pair: '0x99ac8ca7087fa4a2a1fb6357269965a2014abc35',
      dex: 'uniswap_v3',
      base: const DexToken(
        symbol: 'WBTC',
        name: 'Wrapped Bitcoin',
        address: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
      ),
      quote: const DexToken(
        symbol: 'USDC',
        name: 'USD Coin',
        address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      ),
      price: 98420.15,
      priceNative: 28.7,
      change: const DexChange(m5: 0.11, h1: 0.45, h6: 1.2, h24: 1.94),
      volume: const DexVolume(
        m5: 250000,
        h1: 4200000,
        h6: 19500000,
        h24: 84000000,
      ),
      liquidity: 91000000,
      fdv: 1940000000000,
      mcap: 1940000000000,
      txns: const DexTxns(buys: 2450, sells: 1920),
      createdMs: _now - 86400000 * 180,
    ),
  ];

  @override
  Future<({List<DexTicker> ticker, DexGlobalStats stats})>
  getStatsAndTicker() async {
    return (
      ticker: [
        DexTicker(
          chain: 'ethereum',
          pair: samplePairs[3].pair,
          symbol: 'BTC',
          price: samplePairs[3].price,
          change: samplePairs[3].change.h24,
          changes: samplePairs[3].change,
        ),
        DexTicker(
          chain: 'ethereum',
          pair: samplePairs[1].pair,
          symbol: 'ETH',
          price: samplePairs[1].price,
          change: samplePairs[1].change.h24,
          changes: samplePairs[1].change,
        ),
        DexTicker(
          chain: 'bsc',
          pair: samplePairs[0].pair,
          symbol: 'BNB',
          price: samplePairs[0].price,
          change: samplePairs[0].change.h24,
          changes: samplePairs[0].change,
        ),
        DexTicker(
          chain: 'solana',
          pair: samplePairs[2].pair,
          symbol: 'SOL',
          price: samplePairs[2].price,
          change: samplePairs[2].change.h24,
          changes: samplePairs[2].change,
        ),
      ],
      stats: const DexGlobalStats(
        volume24h: 1865200000,
        liquidity: 5440000000,
        pairs: 60,
        txns24h: 142500,
      ),
    );
  }

  @override
  Future<List<DexPair>> getPools({
    String kind = 'trending',
    String? chain,
    int page = 1,
    int pages = 2,
  }) async {
    var rows = chain == null
        ? List<DexPair>.of(samplePairs)
        : samplePairs.where((p) => p.chain == chain).toList();
    if (kind == 'gainers') {
      rows.sort((a, b) => b.change.h24.compareTo(a.change.h24));
    } else if (kind == 'losers') {
      rows.sort((a, b) => a.change.h24.compareTo(b.change.h24));
    }
    return rows;
  }

  @override
  Future<List<DexPair>> searchPairs(String query) async {
    final q = query.toLowerCase();
    return samplePairs
        .where(
          (p) =>
              p.base.symbol.toLowerCase().contains(q) ||
              p.base.name.toLowerCase().contains(q) ||
              p.pair.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<DexPair?> getPair(String chain, String address) async {
    for (final p in samplePairs) {
      if (p.chain == chain && p.pair == address) return p;
    }
    return samplePairs.first;
  }

  @override
  Future<List<DexCandle>> getOhlcv(
    String chain,
    String address, {
    String tf = '15m',
  }) async {
    final basePair = await getPair(chain, address) ?? samplePairs.first;
    final basePrice = basePair.price;
    final startSec = (_now ~/ 1000) - 30 * 900;
    return List.generate(30, (i) {
      final delta = (i - 15) * 0.0012;
      final open = basePrice * (0.985 + delta);
      final close = basePrice * (0.986 + delta + (i.isEven ? 0.002 : -0.001));
      final high = (open > close ? open : close) * 1.003;
      final low = (open < close ? open : close) * 0.997;
      return DexCandle(
        time: startSec + i * 900,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: 12500 + i * 650,
      );
    });
  }

  @override
  Future<List<DexTrade>> getTrades(String chain, String address) async {
    final basePair = await getPair(chain, address) ?? samplePairs.first;
    return [
      DexTrade(
        timeMs: _now - 12000,
        isBuy: true,
        usd: 1420.50,
        price: basePair.price,
        amountFrom: 2.0,
        tx: '0xabc1',
        maker: '0x1111',
      ),
      DexTrade(
        timeMs: _now - 34000,
        isBuy: false,
        usd: 680.10,
        price: basePair.price * 0.999,
        amountFrom: 1.0,
        tx: '0xabc2',
        maker: '0x2222',
      ),
    ];
  }

  @override
  Future<List<DexPair>> getBatch(List<String> keys) async {
    return samplePairs.where((p) => keys.contains(p.key)).toList();
  }

  @override
  Future<Map<String, double>> getEvmNativeBalances(String evmAddress) async {
    return {
      'ethereum': pairBalancesResult.nativeBalance,
      'bsc': pairBalancesResult.nativeBalance,
      'base': 0.0,
      'arbitrum': 0.0,
      'polygon': 0.0,
    };
  }

  @override
  Future<PairWalletBalances> getPairWalletBalances({
    required String chain,
    required String walletAddress,
    required String baseAddress,
    required String quoteAddress,
  }) async => pairBalancesResult;

  @override
  void dispose() {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  for (final mode in const [ThemeMode.dark, ThemeMode.light]) {
    for (final size in const [Size(1080, 2340), Size(720, 1480)]) {
      testWidgets(
        'HyperDEX UI + Provider flow in ${mode.name} at ${size.width}x${size.height}',
        (tester) async {
          enableLivePolling = false;
          enableNetworkImages = false;

          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = size.width / 360;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            DexNovaApp(
              showSplash: true,
              apiService: FakeApiService(),
              initialThemeMode: mode,
            ),
          );
          await tester.pumpAndSettle();

          // App starts on Onboarding -> Welcome/Wallet Hub (non-mandatory) -> MainShell
          expect(find.byType(OnboardingScreen), findsOneWidget);
          expect(find.text('Skip'), findsOneWidget);
          for (var i = 0; i < 2; i++) {
            await tester.tap(find.text('Next'));
            await tester.pumpAndSettle();
          }
          expect(find.text('Get Started'), findsOneWidget);
          expect(find.text('Create Wallet'), findsNothing);
          expect(find.text('Recover Wallet'), findsNothing);
          await tester.tap(find.text('Get Started'));
          await tester.pumpAndSettle();

          expect(find.byType(SplashScreen), findsOneWidget);
          expect(find.text('HyperDEX'), findsOneWidget);
          expect(find.text('Create New Wallet'), findsOneWidget);
          expect(find.text('Recover Wallet'), findsOneWidget);
          await tester.tap(find.text('PIN Lock'));
          await tester.pump();
          await tester.tap(find.text('Welcome'));
          await tester.pump();
          await tester.ensureVisible(find.text('Enter HyperDEX Exchange'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Enter HyperDEX Exchange'));
          await tester.pumpAndSettle();

          // Verify non-web quick buttons were removed from Home
          expect(find.text('Deposit'), findsNothing);
          expect(find.text('Withdraw'), findsNothing);
          expect(find.text('Send'), findsNothing);
          expect(find.text('Receive'), findsNothing);

          // Verify HyperDEX Home Live Screener renders via MarketProvider
          expect(find.text('BTC/USDT'), findsWidgets);
          expect(find.text('24h Volume'), findsWidgets);
          expect(find.text('Total Liquidity'), findsWidgets);
          expect(find.text('Filter tokens...'), findsWidgets);
          expect(find.text('All Chains'), findsWidgets);

          // Guest state before creating a wallet
          expect(find.text('Web3 Wallet · Not Connected'), findsWidgets);

          // Create wallet via Multi-Wallet Switcher
          await tester.tap(find.text('Connect Wallet').first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('+ Create Wallet'));
          await tester.pumpAndSettle();
          await tester.drag(find.byType(ListView).last, const Offset(0, -350));
          await tester.pumpAndSettle();
          await tester.tap(
            find.text('I have stored my recovery phrase safely offline'),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Create & Activate Wallet'));
          await tester.pumpAndSettle();

          final navCtx = tester.element(find.byType(Scaffold).first);
          final walletProv = navCtx.read<WalletProvider>();
          final firstWallet = walletProv.activeWallet!;
          expect(find.text(firstWallet.shortEth), findsWidgets);
          expect(find.text('1 Wallet'), findsWidgets);

          // Derive 2nd HD account & switch back
          await tester.tap(find.text('1 Wallet').first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('+ Derive HD Account'));
          await tester.pumpAndSettle();
          expect(walletProv.wallets.length, 2);
          await tester.tap(find.text(firstWallet.name));
          await tester.pumpAndSettle();
          expect(walletProv.activeWallet!.id, firstWallet.id);

          // Screener category & chain filter interactions
          await tester.tap(find.textContaining('Gainers').first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Ethereum').first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('All Chains').first);
          await tester.pumpAndSettle();

          // New Pairs tab
          await tester.tap(find.text('New Pairs').last);
          await tester.pumpAndSettle();

          // Trade tab (Quick switcher, Live Txns, Order Book, Buy/Sell, Pool Info)
          await tester.tap(find.text('Trade').last);
          await tester.pumpAndSettle();
          expect(find.text('Buy / Sell'), findsOneWidget);
          expect(find.text('Pool Info'), findsOneWidget);
          final tradeScroll = find.descendant(
            of: find.byType(TradeScreen),
            matching: find.byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            ),
          );
          await tester.scrollUntilVisible(
            find.text('Live Transactions'),
            240,
            scrollable: tradeScroll,
          );
          await tester.pumpAndSettle();
          expect(find.text('Live Transactions'), findsOneWidget);
          expect(find.text('Order Book'), findsOneWidget);
          expect(find.text('Top Traders'), findsOneWidget);
          await tester.tap(find.text('Order Book'));
          await tester.pumpAndSettle();
          expect(find.text('Mid Market Price:'), findsOneWidget);
          await tester.tap(find.text('Top Traders'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Live Transactions'));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Buy ETH'),
            240,
            scrollable: tradeScroll,
          );
          await tester.pumpAndSettle();
          expect(find.text('Buy ETH'), findsOneWidget);
          await tester.scrollUntilVisible(
            find.text('QUICK CONVERTER'),
            240,
            scrollable: tradeScroll,
          );
          await tester.pumpAndSettle();
          expect(find.text('QUICK CONVERTER'), findsOneWidget);

          // Convert tab
          await tester.tap(find.text('Convert').last);
          await tester.pumpAndSettle();
          expect(find.text('Convert & Instant Swap'), findsOneWidget);
          expect(find.text('Instant Convert Now'), findsOneWidget);

          // Wallet tab
          await tester.tap(find.text('Wallet').last);
          await tester.pumpAndSettle();
          expect(find.text('Deposit'), findsNothing);
          expect(find.text('Withdraw'), findsNothing);
          await tester.tap(find.text('Orders').last);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Watchlist').last);
          await tester.pumpAndSettle();

          // Drawer verification
          final scaffoldState = tester.state<ScaffoldState>(
            find.byType(Scaffold).first,
          );
          scaffoldState.openDrawer();
          await tester.pumpAndSettle();
          expect(find.text('Spot Trade'), findsOneWidget);
          expect(find.text('Multicharts'), findsOneWidget);
          expect(find.text('Get Started →'), findsOneWidget);
          await tester.tap(find.text('Get Started →'));
          await tester.pumpAndSettle();

          // Back to Home
          await tester.tap(find.text('Home').last);
          await tester.pumpAndSettle();

          // Push & pop every screen in moreItems()
          final nav = tester.state<NavigatorState>(
            find.byType(Navigator).first,
          );
          for (final item in moreItems()) {
            nav.push(MaterialPageRoute(builder: (_) => item.$4));
            await tester.pumpAndSettle();
            nav.pop();
            await tester.pumpAndSettle();
          }

          // SecurityScreen
          nav.push(MaterialPageRoute(builder: (_) => const SecurityScreen()));
          await tester.pumpAndSettle();
          expect(find.text('Change Password'), findsNothing);
          await tester.ensureVisible(find.text('Manage / Switch Wallet'));
          await tester.tap(find.text('Manage / Switch Wallet'));
          await tester.pumpAndSettle();
          expect(find.textContaining('Web3 Multi-Wallet (2)'), findsOneWidget);
          nav.pop();
          await tester.pumpAndSettle();
          nav.pop();
          await tester.pumpAndSettle();

          // Standalone screens
          for (final screen in const [
            WatchlistScreen(),
            AlertsScreen(),
            MultichartsScreen(),
            SwapBridgeScreen(),
            SplashScreen(isPreview: true),
            OnboardingScreen(isPreview: true),
            CreateWalletScreen(initialTab: 0),
          ]) {
            nav.push(MaterialPageRoute(builder: (_) => screen));
            await tester.pumpAndSettle();
            nav.pop();
            await tester.pumpAndSettle();
          }

          expect(showWalletSwitcherSheet, isNotNull);
        },
      );
    }
  }

  testWidgets(
    'TradeScreen enforces real on-chain balance on Buy/Sell and blocks zero-balance orders',
    (tester) async {
      enableLivePolling = false;
      enableNetworkImages = false;
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final fakeApi = FakeApiService();
      await tester.pumpWidget(
        DexNovaApp(showSplash: false, apiService: fakeApi),
      );
      await tester.pumpAndSettle();

      // Skip onboarding overlay if shown or go directly via WalletProvider
      final ctx = tester.element(find.byType(Scaffold).first);
      expect(ctx.read<ThemeProvider>().mode, ThemeMode.light);
      expect(ThemeProvider().mode, ThemeMode.light);
      final wp = ctx.read<WalletProvider>();
      final pp = ctx.read<PortfolioProvider>();
      wp.createAndActivateWallet(
        name: 'Real Wallet',
        words: const ['apple', 'tower', 'nation', 'galaxy'],
      );
      await tester.pumpAndSettle();

      // Open Trade tab (ETH/USDC pool)
      await tester.tap(find.text('Trade').last);
      await tester.pumpAndSettle();

      final tradeScroll = find.descendant(
        of: find.byType(TradeScreen),
        matching: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Buy ETH'),
        240,
        scrollable: tradeScroll,
      );
      await tester.pumpAndSettle();

      // Enter 1 ETH amount
      final amountField = find.byKey(const ValueKey('trade_amount_field'));
      await tester.ensureVisible(amountField);
      await tester.pumpAndSettle();
      await tester.enterText(amountField, '1');
      await tester.pumpAndSettle();

      // Attempt Buy with 0 USDC & 0 ETH balance -> must show red inline error & place 0 fake orders
      await tester.ensureVisible(find.text('Buy ETH'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buy ETH'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Insufficient USDC Balance in Wallet!'),
        findsOneWidget,
      );
      expect(pp.orders, isEmpty);

      // Switch to Sell with 0 ETH holding -> must show Insufficient ETH error & place 0 fake orders
      await tester.ensureVisible(find.text('Sell').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sell').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(amountField);
      await tester.pumpAndSettle();
      await tester.enterText(amountField, '1');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sell ETH'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sell ETH'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Insufficient ETH Balance in Wallet!'),
        findsOneWidget,
      );
      expect(pp.orders, isEmpty);

      // Fund wallet on-chain via FakeApiService and retry Buy -> succeeds cleanly
      fakeApi.pairBalancesResult = const PairWalletBalances(
        nativeBalance: 2.0,
        quoteBalance: 10000.0,
        baseBalance: 5.0,
        quoteAllowance: 1e18,
        baseAllowance: 1e18,
        loaded: true,
      );
      await tester.ensureVisible(find.text('Buy').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buy').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(amountField);
      await tester.pumpAndSettle();
      await tester.enterText(amountField, '1');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Buy ETH'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buy ETH'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Insufficient USDC Balance in Wallet!'),
        findsNothing,
      );
      expect(pp.openOrders.length, 1);
    },
  );
}
