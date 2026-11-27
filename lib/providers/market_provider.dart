import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/dex_models.dart';
import '../services/api_service.dart';

class MarketProvider extends ChangeNotifier {
  final ApiServiceContract _api;

  MarketProvider(this._api);

  List<DexTicker> _tickers = [];
  DexGlobalStats _stats = const DexGlobalStats();
  List<DexPair> _trendingPools = [];
  DexPair? _activePair;
  List<DexCandle> _activeCandles = [];
  List<DexTrade> _activeTrades = [];
  String? _activeTradesPairKey;
  String _activeTimeframe = '15m';

  bool _isLoadingMarket = false;
  bool _isLoadingPair = false;
  String? _errorMessage;

  // Markets Screener state
  List<DexPair> _marketPools = [];
  String _marketTab = 'trending'; // trending | gainers | losers | new | volume
  String _rankPeriod = '24h'; // 5m | 1h | 6h | 24h
  String? _selectedChain;
  String _marketSearchQuery = '';
  List<DexPair>? _marketSearchHits;
  bool _isLoadingMarketsList = false;
  double _minLiquidity = 0;
  double _minVolume24h = 0;
  String _dexFilter = '';

  // Multicharts state
  final List<String> _multichartKeys = [];
  final Map<String, DexPair> _multichartPairs = {};
  final Map<String, List<DexCandle>> _multichartCandles = {};
  String _multichartTimeframe = '15m';
  bool _isLoadingMulticharts = false;

  Timer? _pollTimer;
  bool _initialized = false;
  bool _disposed = false;

  // Getters
  List<DexTicker> get tickers => List.unmodifiable(_tickers);
  DexGlobalStats get stats => _stats;
  List<DexPair> get trendingPools => List.unmodifiable(_trendingPools);
  DexPair? get activePair => _activePair;
  List<DexCandle> get activeCandles => List.unmodifiable(_activeCandles);
  List<DexTrade> get activeTrades => List.unmodifiable(_activeTrades);
  String get activeTimeframe => _activeTimeframe;
  bool get isLoadingMarket => _isLoadingMarket;
  bool get isLoadingPair => _isLoadingPair;
  String? get errorMessage => _errorMessage;

  List<DexPair> get marketPools => List.unmodifiable(_marketPools);
  String get marketTab => _marketTab;
  String get rankPeriod => _rankPeriod;
  String? get selectedChain => _selectedChain;
  String get marketSearchQuery => _marketSearchQuery;
  bool get isLoadingMarketsList => _isLoadingMarketsList;
  double get minLiquidity => _minLiquidity;
  double get minVolume24h => _minVolume24h;
  String get dexFilter => _dexFilter;
  bool get hasActiveFilters =>
      _minLiquidity > 0 || _minVolume24h > 0 || _dexFilter.isNotEmpty;
  List<String> get availableDexes {
    final set = <String>{};
    for (final p in _marketPools.isNotEmpty ? _marketPools : _trendingPools) {
      if (p.dex.trim().isNotEmpty) set.add(p.dex.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> get multichartKeys => List.unmodifiable(_multichartKeys);
  Map<String, DexPair> get multichartPairs =>
      Map.unmodifiable(_multichartPairs);
  Map<String, List<DexCandle>> get multichartCandles =>
      Map.unmodifiable(_multichartCandles);
  String get multichartTimeframe => _multichartTimeframe;
  bool get isLoadingMulticharts => _isLoadingMulticharts;

  DateTime? _lastUpdatedAt;
  DateTime? get lastUpdatedAt => _lastUpdatedAt;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await refreshAll();
    if (enableLivePolling && !_disposed) {
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => refreshAll(silent: true),
      );
    }
  }

  Future<void> refreshAll({bool silent = false}) async {
    if (!silent) {
      _isLoadingMarket = true;
      _errorMessage = null;
      _notify();
    }
    try {
      final results = await Future.wait([
        _api.getStatsAndTicker(),
        _api.getPools(kind: _marketTab, chain: _selectedChain, pages: 2),
      ]);
      final st = results[0] as ({List<DexTicker> ticker, DexGlobalStats stats});
      final pools = results[1] as List<DexPair>;

      if (st.ticker.isNotEmpty) _tickers = st.ticker;
      _stats = st.stats;
      if (pools.isNotEmpty) {
        _marketPools = pools;
        if (_marketTab == 'trending' && _selectedChain == null ||
            _trendingPools.isEmpty) {
          _trendingPools = pools;
        }
        _lastUpdatedAt = DateTime.now();
      }

      if (_activePair == null) {
        final ranked = visibleMarketRows;
        if (ranked.isNotEmpty) {
          await selectPair(ranked.first);
        } else if (pools.isNotEmpty) {
          await selectPair(pools.first);
        } else if (st.ticker.isNotEmpty) {
          await selectPairByKey(st.ticker.first.chain, st.ticker.first.pair);
        }
      } else {
        await _refreshActivePairData();
      }
    } catch (_) {
      if (!silent) _errorMessage = 'Unable to load live market data';
    } finally {
      if (!silent) _isLoadingMarket = false;
      _notify();
    }
  }

  Future<void> selectPair(DexPair pair) async {
    if (_activeTradesPairKey != pair.key) {
      _activeTrades = [];
      _activeTradesPairKey = pair.key;
    }
    _activePair = pair;
    if (_multichartKeys.isEmpty) {
      _multichartKeys.add(pair.key);
    }
    _notify();
    await _refreshActivePairData();
  }

  Future<void> selectPairByKey(String chain, String pairAddress) async {
    final nextKey = '$chain:$pairAddress';
    if (_activeTradesPairKey != nextKey) {
      _activeTrades = [];
      _activeTradesPairKey = nextKey;
    }
    _isLoadingPair = true;
    _notify();
    try {
      final fetched = await _api.getPair(chain, pairAddress);
      if (fetched != null) {
        _activePair = fetched;
      } else {
        for (final p in _trendingPools) {
          if (p.chain == chain && p.pair == pairAddress) {
            _activePair = p;
            break;
          }
        }
      }
      await _refreshActivePairData();
    } finally {
      _isLoadingPair = false;
      _notify();
    }
  }

  void _mergeTrades(String pairKey, List<DexTrade> incoming) {
    if (_activeTradesPairKey != pairKey) {
      _activeTrades = [];
      _activeTradesPairKey = pairKey;
    }
    final byTx = <String, DexTrade>{};
    for (final t in _activeTrades) {
      final k = t.tx.isNotEmpty
          ? t.tx.toLowerCase()
          : '${t.timeMs}_${t.usd}_${t.isBuy}';
      byTx[k] = t;
    }
    for (final t in incoming) {
      final k = t.tx.isNotEmpty
          ? t.tx.toLowerCase()
          : '${t.timeMs}_${t.usd}_${t.isBuy}';
      byTx[k] = t;
    }
    final merged = byTx.values.toList()
      ..sort((a, b) => b.timeMs.compareTo(a.timeMs));
    _activeTrades = merged.length > 200 ? merged.sublist(0, 200) : merged;
  }

  Future<void> refreshActiveTradesAndPair() async {
    final p = _activePair;
    if (p == null) return;
    final keySnapshot = p.key;
    try {
      final res = await Future.wait([
        _api.getPair(p.chain, p.pair),
        _api.getTrades(p.chain, p.pair),
      ]);
      if (_disposed || _activePair?.key != keySnapshot) return;
      final freshPair = res[0] as DexPair?;
      final trades = res[1] as List<DexTrade>;
      if (freshPair != null) _activePair = freshPair;
      _mergeTrades(keySnapshot, trades);
      _notify();
    } catch (_) {}
  }

  Future<void> setTimeframe(String tf) async {
    final clean = tf.toLowerCase();
    _activeTimeframe = clean;
    final p = _activePair;
    if (p == null) {
      _notify();
      return;
    }
    _isLoadingPair = true;
    _notify();
    try {
      _activeCandles = await _api.getOhlcv(p.chain, p.pair, tf: clean);
    } finally {
      _isLoadingPair = false;
      _notify();
    }
  }

  Future<void> _refreshActivePairData() async {
    final p = _activePair;
    if (p == null) return;
    final keySnapshot = p.key;
    _isLoadingPair = true;
    _notify();
    try {
      final res = await Future.wait([
        _api.getPair(p.chain, p.pair),
        _api.getOhlcv(p.chain, p.pair, tf: _activeTimeframe),
        _api.getTrades(p.chain, p.pair),
      ]);
      if (_disposed || _activePair?.key != keySnapshot) return;
      final freshPair = res[0] as DexPair?;
      final candles = res[1] as List<DexCandle>;
      final trades = res[2] as List<DexTrade>;
      if (freshPair != null) _activePair = freshPair;
      _activeCandles = candles;
      _mergeTrades(keySnapshot, trades);
      if (_multichartKeys.isEmpty && _activePair != null) {
        _multichartKeys.add(_activePair!.key);
      }
    } finally {
      _isLoadingPair = false;
      _notify();
    }
  }

  Future<List<DexPair>> searchPairs(String query) => _api.searchPairs(query);

  // ---------------- Markets Screener ----------------

  Future<void> loadMarketPools() async {
    _isLoadingMarketsList = true;
    _notify();
    try {
      final rows = await _api.getPools(
        kind: _marketTab,
        chain: _selectedChain,
        pages: 2,
      );
      if (rows.isNotEmpty || _selectedChain != null) {
        _marketPools = rows;
        if (_marketTab == 'trending' && _selectedChain == null) {
          _trendingPools = rows;
        }
        _lastUpdatedAt = DateTime.now();
      }
    } finally {
      _isLoadingMarketsList = false;
      _notify();
    }
  }

  void setMarketTab(String tab) {
    if (_marketTab == tab) return;
    _marketTab = tab;
    _notify();
    loadMarketPools();
  }

  void ensureMarketTab(String tab) {
    if (_marketTab == tab) return;
    _marketTab = tab;
    _notify();
    loadMarketPools();
  }

  void setScreenerFilters({
    double? minLiquidity,
    double? minVolume24h,
    String? dexFilter,
  }) {
    if (minLiquidity != null) _minLiquidity = minLiquidity;
    if (minVolume24h != null) _minVolume24h = minVolume24h;
    if (dexFilter != null) _dexFilter = dexFilter;
    _notify();
  }

  void resetScreenerFilters() {
    _minLiquidity = 0;
    _minVolume24h = 0;
    _dexFilter = '';
    _notify();
  }

  void setRankPeriod(String period) {
    if (_rankPeriod == period) return;
    _rankPeriod = period;
    _notify();
  }

  void setSelectedChain(String? chain) {
    if (_selectedChain == chain) return;
    _selectedChain = chain;
    _notify();
    loadMarketPools();
  }

  Future<void> searchMarkets(String query) async {
    _marketSearchQuery = query;
    final clean = query.trim();
    if (clean.length < 2) {
      _marketSearchHits = null;
      _notify();
      return;
    }
    _notify();
    final hits = await _api.searchPairs(clean);
    if (_marketSearchQuery.trim() != clean) return;
    _marketSearchHits = hits;
    _notify();
  }

  List<DexPair> get visibleMarketRows {
    final clean = _marketSearchQuery.trim().toLowerCase();
    var list =
        (clean.length >= 2 &&
            _marketSearchHits != null &&
            _marketSearchHits!.isNotEmpty)
        ? List<DexPair>.of(_marketSearchHits!)
        : List<DexPair>.of(
            _marketPools.isNotEmpty ? _marketPools : _trendingPools,
          );

    if (_selectedChain != null && _selectedChain!.isNotEmpty) {
      list = list.where((p) => p.chain == _selectedChain).toList();
    }
    if (_minLiquidity > 0) {
      list = list.where((p) => p.liquidity >= _minLiquidity).toList();
    }
    if (_minVolume24h > 0) {
      list = list.where((p) => p.volume.h24 >= _minVolume24h).toList();
    }
    if (_dexFilter.isNotEmpty) {
      final df = _dexFilter.toLowerCase();
      list = list.where((p) => p.dex.toLowerCase() == df).toList();
    }
    if (clean.isNotEmpty) {
      list = list.where((r) {
        return r.base.symbol.toLowerCase().contains(clean) ||
            r.base.name.toLowerCase().contains(clean) ||
            r.quote.symbol.toLowerCase().contains(clean) ||
            r.pair.toLowerCase().contains(clean) ||
            r.base.address.toLowerCase().contains(clean);
      }).toList();
    }
    if (_marketTab == 'gainers') {
      list.sort(
        (a, b) => b.change
            .forPeriod(_rankPeriod)
            .compareTo(a.change.forPeriod(_rankPeriod)),
      );
    } else if (_marketTab == 'losers') {
      list.sort(
        (a, b) => a.change
            .forPeriod(_rankPeriod)
            .compareTo(b.change.forPeriod(_rankPeriod)),
      );
    } else if (_marketTab == 'new') {
      list.sort((a, b) => (b.createdMs ?? 0).compareTo(a.createdMs ?? 0));
    } else {
      // Match hyperdex/resources/views/home.blade.php: trending & most-traded rank by volume[vk]
      final vk = _rankPeriod == '5m' ? 'h1' : _rankPeriod;
      list.sort(
        (a, b) => b.volume.forPeriod(vk).compareTo(a.volume.forPeriod(vk)),
      );
    }
    return list;
  }

  // ---------------- Multicharts ----------------

  bool addMultichart(String key) {
    if (_multichartKeys.contains(key)) return true;
    if (_multichartKeys.length >= 4) return false;
    _multichartKeys.add(key);
    _notify();
    loadMulticharts();
    return true;
  }

  void removeMultichart(String key) {
    _multichartKeys.remove(key);
    _multichartPairs.remove(key);
    _multichartCandles.remove(key);
    _notify();
  }

  void setMultichartTimeframe(String tf) {
    final clean = tf.toLowerCase();
    if (_multichartTimeframe == clean) return;
    _multichartTimeframe = clean;
    _notify();
    loadMulticharts();
  }

  Future<void> loadMulticharts() async {
    if (_multichartKeys.isEmpty) return;
    _isLoadingMulticharts = true;
    _notify();
    try {
      final keys = List<String>.of(_multichartKeys);
      final batchPairs = await _api.getBatch(keys);
      for (final p in batchPairs) {
        _multichartPairs[p.key] = p;
      }
      await Future.wait(
        keys.map((k) async {
          final parts = k.split(':');
          if (parts.length != 2) return;
          final c = await _api.getOhlcv(
            parts[0],
            parts[1],
            tf: _multichartTimeframe,
          );
          _multichartCandles[k] = c;
        }),
      );
    } finally {
      _isLoadingMulticharts = false;
      _notify();
    }
  }

  double nativeUsdPrice(String symbol) {
    final s = symbol.toUpperCase();
    for (final t in _tickers) {
      if (t.symbol.toUpperCase() == s && t.price > 0) return t.price;
      if (s == 'ETH' && t.symbol.toUpperCase().contains('ETH') && t.price > 0) {
        return t.price;
      }
      if (s == 'BNB' && t.symbol.toUpperCase().contains('BNB') && t.price > 0) {
        return t.price;
      }
      if (s == 'SOL' && t.symbol.toUpperCase().contains('SOL') && t.price > 0) {
        return t.price;
      }
    }
    return 0.0;
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }
}
