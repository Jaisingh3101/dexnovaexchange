import 'package:flutter_test/flutter_test.dart';
import 'package:dexnova/models/dex_models.dart';
import 'package:dexnova/providers/market_provider.dart';
import 'package:dexnova/providers/portfolio_provider.dart';
import 'package:dexnova/providers/wallet_provider.dart';
import 'package:dexnova/services/api_service.dart';

class _StubApiService implements ApiServiceContract {
  static final _pair = DexPair(
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
    price: 700.0,
    change: const DexChange(m5: 0.4, h1: 1.2, h6: 2.0, h24: 4.5),
    volume: const DexVolume(h24: 45000000),
    liquidity: 15000000,
  );

  @override
  Future<List<DexPair>> getBatch(List<String> keys) async => [_pair];

  @override
  Future<Map<String, double>> getEvmNativeBalances(String evmAddress) async => {
    'bsc': 2.0,
    'ethereum': 1.0,
  };

  @override
  Future<PairWalletBalances> getPairWalletBalances({
    required String chain,
    required String walletAddress,
    required String baseAddress,
    required String quoteAddress,
  }) async => const PairWalletBalances(
    nativeBalance: 2.0,
    quoteBalance: 1500.0,
    baseBalance: 3.5,
    quoteDecimals: 18,
    baseDecimals: 18,
    quoteAllowance: 1e18,
    baseAllowance: 0.0,
    loaded: true,
  );

  @override
  Future<List<DexCandle>> getOhlcv(
    String chain,
    String address, {
    String tf = '15m',
  }) async => [
    const DexCandle(
      time: 1700000000,
      open: 690,
      high: 705,
      low: 688,
      close: 700,
      volume: 1000,
    ),
  ];

  @override
  Future<DexPair?> getPair(String chain, String address) async => _pair;

  @override
  Future<List<DexPair>> getPools({
    String kind = 'trending',
    String? chain,
    int page = 1,
    int pages = 2,
  }) async => [_pair];

  @override
  Future<({List<DexTicker> ticker, DexGlobalStats stats})>
  getStatsAndTicker() async => (
    ticker: [
      const DexTicker(
        chain: 'bsc',
        pair: '0x172fcd41e0913e95784454622d1c3724f546f849',
        symbol: 'BNB',
        price: 700.0,
        change: 4.5,
      ),
    ],
    stats: const DexGlobalStats(volume24h: 1000000, liquidity: 5000000),
  );

  @override
  Future<List<DexTrade>> getTrades(String chain, String address) async => [
    const DexTrade(timeMs: 1700000000000, isBuy: true, usd: 500, price: 700),
  ];

  @override
  Future<List<DexPair>> searchPairs(String query) async => [_pair];

  @override
  void dispose() {}
}

void main() {
  test('ApiEndpoints builds all 7 HyperDEX URIs accurately', () {
    expect(
      ApiEndpoints.hyperStatsUri().toString(),
      'https://hyperdex.online/api/stats',
    );
    expect(
      ApiEndpoints.hyperPoolsUri(kind: 'gainers', chain: 'bsc').toString(),
      'https://hyperdex.online/api/pools?kind=gainers&page=1&pages=2&chain=bsc',
    );
    expect(
      ApiEndpoints.hyperPoolsUri(kind: 'trending', pages: 2).toString(),
      'https://hyperdex.online/api/pools?kind=trending&page=1&pages=2',
    );
    expect(
      ApiEndpoints.hyperSearchUri('WBNB').toString(),
      'https://hyperdex.online/api/search?q=WBNB',
    );
    expect(
      ApiEndpoints.hyperBatchUri(['bsc:0x123', 'ethereum:0x456']).toString(),
      'https://hyperdex.online/api/batch?p%5B%5D=bsc%3A0x123&p%5B%5D=ethereum%3A0x456',
    );
    expect(
      ApiEndpoints.hyperBatchUri([
        'bsc:0x123',
        'ethereum:0x456',
      ]).queryParametersAll['p[]'],
      ['bsc:0x123', 'ethereum:0x456'],
    );
    expect(
      ApiEndpoints.hyperPairUri('bsc', '0x123').toString(),
      'https://hyperdex.online/api/pair/bsc/0x123',
    );
    expect(
      ApiEndpoints.hyperOhlcvUri('bsc', '0x123', tf: '1h').toString(),
      'https://hyperdex.online/api/ohlcv/bsc/0x123?tf=1h',
    );
    expect(
      ApiEndpoints.hyperTradesUri('bsc', '0x123').toString(),
      'https://hyperdex.online/api/trades/bsc/0x123',
    );
  });

  test(
    'MarketProvider initializes, switches timeframe, and resolves USD',
    () async {
      enableLivePolling = false;
      final api = _StubApiService();
      final market = MarketProvider(api);
      await market.init();

      expect(market.tickers.length, 1);
      expect(market.activePair?.base.symbol, 'WBNB');
      expect(market.activeCandles.length, 1);
      expect(market.nativeUsdPrice('BNB'), 700.0);

      await market.setTimeframe('4h');
      expect(market.activeTimeframe, '4h');
      market.dispose();
    },
  );

  test(
    'PortfolioProvider manages watchlist, alerts, orders, and balances',
    () async {
      final api = _StubApiService();
      final portfolio = PortfolioProvider(api);
      final pair = _StubApiService._pair;

      final added = portfolio.toggleWatch(pair.key);
      expect(added, true);
      expect(portfolio.isWatched(pair.key), true);

      portfolio.addAlert(pair: pair, above: true, target: 650.0);
      expect(portfolio.activeAlertCount, 1);
      final fired = await portfolio.checkAlerts();
      expect(fired.length, 1);
      expect(portfolio.activeAlertCount, 0);

      portfolio.placeOrder(
        pair: pair,
        isBuy: true,
        orderType: 'Limit',
        price: 680,
        amount: 1.5,
      );
      expect(portfolio.openOrders.length, 1);
      portfolio.cancelOrder(portfolio.openOrders.first.id);
      expect(portfolio.openOrders, isEmpty);

      await portfolio.refreshOnChainBalances(
        '0x1234567890abcdef1234567890abcdef12345678',
      );
      expect(portfolio.onChainBalances['bsc'], 2.0);

      final pairBal = await portfolio.refreshPairBalances(
        walletAddress: '0x1234567890abcdef1234567890abcdef12345678',
        pair: pair,
      );
      expect(pairBal.quoteBalance, 1500.0);
      expect(pairBal.baseBalance, 3.5);
      expect(pairBal.hasUnlimitedQuoteAllowance, true);
      expect(
        kDexRouters['bsc']?.router,
        '0x10ED43C718714eb63d5aA57B78B54704E256024E',
      );
      portfolio.dispose();
    },
  );

  test(
    'DexTxnWindow parses buyers/sellers & MarketProvider ranks trending by volume',
    () async {
      enableLivePolling = false;
      final parsed = DexPair.fromHyperDexJson({
        'chain': 'bsc',
        'pair': '0xpool',
        'dex': 'pancakeswap',
        'base': {'symbol': 'LOW', 'name': 'Low Vol', 'address': '0x1'},
        'quote': {'symbol': 'USDT', 'address': '0x2'},
        'price': 1.0,
        'volume': {'h24': 1000},
        'txns': {
          'buys': 10,
          'sells': 5,
          'h24': {'buys': 10, 'sells': 5, 'buyers': 8, 'sellers': 4},
        },
      });
      expect(parsed.txns.windowFor('h24').buyers, 8);
      expect(parsed.txns.windowFor('h24').sellers, 4);
      expect(parsed.txns.windowFor('h24').makersTotal, 12);

      final api = _StubApiService();
      final market = MarketProvider(api);
      await market.init();
      expect(market.visibleMarketRows.first.volume.h24, 45000000);
      await market.refreshActiveTradesAndPair();
      expect(market.activeTrades.length, 1);
      market.dispose();
    },
  );

  test('WalletProvider creates, derives HD accounts, and switches wallets', () {
    final wp = WalletProvider();
    final w1 = wp.createAndActivateWallet(
      name: 'Main Vault',
      words: const ['apple', 'tower', 'nation', 'galaxy'],
    );
    expect(wp.wallets.length, 1);
    expect(wp.activeWallet?.id, w1.id);

    final w2 = wp.addDerivedHdAccount();
    expect(w2, isNotNull);
    expect(wp.wallets.length, 2);
    expect(wp.activeWallet?.id, w2!.id);

    wp.switchWallet(w1.id);
    expect(wp.activeWallet?.id, w1.id);
    wp.dispose();
  });
}
