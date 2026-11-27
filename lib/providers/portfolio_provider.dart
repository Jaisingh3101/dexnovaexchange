import 'package:flutter/foundation.dart';
import '../models/dex_models.dart';
import '../services/api_service.dart';

class PortfolioProvider extends ChangeNotifier {
  final ApiServiceContract _api;

  PortfolioProvider(this._api);

  final Set<String> _watchlistKeys = {};
  List<DexPair> _watchlistPairs = [];
  bool _isLoadingWatchlist = false;

  final List<PriceAlert> _alerts = [];
  final List<DexOrder> _orders = [];

  Map<String, double> _onChainBalances = {};
  bool _isLoadingBalances = false;
  final Map<String, PairWalletBalances> _pairBalances = {};
  bool _isLoadingPairBalances = false;
  bool _disposed = false;

  // Getters
  Set<String> get watchlistKeys => Set.unmodifiable(_watchlistKeys);
  List<DexPair> get watchlistPairs => List.unmodifiable(_watchlistPairs);
  bool get isLoadingWatchlist => _isLoadingWatchlist;

  List<PriceAlert> get alerts => List.unmodifiable(_alerts);
  int get activeAlertCount => _alerts.where((a) => !a.triggered).length;
  bool get hasTriggeredAlerts => _alerts.any((a) => a.triggered);

  List<DexOrder> get orders => List.unmodifiable(_orders);
  List<DexOrder> get openOrders =>
      _orders.where((o) => o.status == 'Open').toList(growable: false);

  Map<String, double> get onChainBalances => Map.unmodifiable(_onChainBalances);
  bool get isLoadingBalances => _isLoadingBalances;
  bool get isLoadingPairBalances => _isLoadingPairBalances;

  PairWalletBalances pairBalancesFor(String? walletAddress, String pairKey) {
    if (walletAddress == null || walletAddress.isEmpty) {
      return const PairWalletBalances();
    }
    return _pairBalances['${walletAddress.toLowerCase()}:$pairKey'] ??
        const PairWalletBalances();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ---------------- Watchlist ----------------

  bool isWatched(String key) => _watchlistKeys.contains(key);

  bool toggleWatch(String key) {
    final added = !_watchlistKeys.remove(key);
    if (added) {
      _watchlistKeys.add(key);
    } else {
      _watchlistPairs.removeWhere((p) => p.key == key);
    }
    _notify();
    loadWatchlistPairs();
    return added;
  }

  Future<void> loadWatchlistPairs() async {
    if (_watchlistKeys.isEmpty) {
      _watchlistPairs = [];
      _isLoadingWatchlist = false;
      _notify();
      return;
    }
    _isLoadingWatchlist = true;
    _notify();
    try {
      _watchlistPairs = await _api.getBatch(_watchlistKeys.toList());
    } finally {
      _isLoadingWatchlist = false;
      _notify();
    }
  }

  // ---------------- Price Alerts ----------------

  void addAlert({
    required DexPair pair,
    required bool above,
    required double target,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _alerts.insert(
      0,
      PriceAlert(
        id: 'al_${now}_${_alerts.length}',
        chain: pair.chain,
        pair: pair.pair,
        symbol: pair.pairLabel,
        above: above,
        target: target,
        createdMs: now,
      ),
    );
    _notify();
  }

  void removeAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    _notify();
  }

  void clearTriggeredAlerts() {
    _alerts.removeWhere((a) => a.triggered);
    _notify();
  }

  Future<List<PriceAlert>> checkAlerts() async {
    final active = _alerts.where((a) => !a.triggered).toList();
    if (active.isEmpty) return [];
    final keys = active.map((a) => a.key).toSet().toList();
    final pairs = await _api.getBatch(keys);
    final prices = {for (final p in pairs) p.key: p.price};
    final fired = <PriceAlert>[];
    for (var i = 0; i < _alerts.length; i++) {
      final a = _alerts[i];
      if (a.triggered) continue;
      final price = prices[a.key];
      if (price == null || price <= 0) continue;
      final hit = a.above ? price >= a.target : price <= a.target;
      if (hit) {
        final updated = a.copyWith(triggered: true, firedPrice: price);
        _alerts[i] = updated;
        fired.add(updated);
      }
    }
    if (fired.isNotEmpty) _notify();
    return fired;
  }

  // ---------------- Orders & Conversions ----------------

  void placeOrder({
    required DexPair pair,
    required bool isBuy,
    required String orderType,
    required double price,
    required double amount,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final status = (orderType == 'Market' || orderType == 'Convert')
        ? 'Filled'
        : 'Open';
    _orders.insert(
      0,
      DexOrder(
        id: 'ord_${now}_${_orders.length}',
        chain: pair.chain,
        pair: pair.pair,
        symbol: pair.base.symbol,
        quoteSymbol: pair.quote.symbol,
        isBuy: isBuy,
        orderType: orderType,
        price: price,
        amount: amount,
        totalUsd: price * amount,
        status: status,
        createdMs: now,
      ),
    );
    _notify();
  }

  void cancelOrder(String id) {
    for (var i = 0; i < _orders.length; i++) {
      if (_orders[i].id == id) {
        _orders[i] = _orders[i].copyWith(status: 'Cancelled');
        _notify();
        return;
      }
    }
  }

  // ---------------- On-Chain EVM Balances ----------------

  Future<void> refreshOnChainBalances(String? evmAddress) async {
    if (evmAddress == null || evmAddress.isEmpty) {
      if (_onChainBalances.isNotEmpty || _pairBalances.isNotEmpty) {
        _onChainBalances = {};
        _pairBalances.clear();
        _notify();
      }
      return;
    }
    _isLoadingBalances = true;
    _notify();
    try {
      _onChainBalances = await _api.getEvmNativeBalances(evmAddress);
    } finally {
      _isLoadingBalances = false;
      _notify();
    }
  }

  Future<PairWalletBalances> refreshPairBalances({
    required String? walletAddress,
    required DexPair pair,
  }) async {
    if (walletAddress == null || walletAddress.isEmpty) {
      return const PairWalletBalances();
    }
    _isLoadingPairBalances = true;
    _notify();
    try {
      final res = await _api.getPairWalletBalances(
        chain: pair.chain,
        walletAddress: walletAddress,
        baseAddress: pair.base.address,
        quoteAddress: pair.quote.address,
      );
      _pairBalances['${walletAddress.toLowerCase()}:${pair.key}'] = res;
      if (kDexChains[pair.chain]?.rpcUrl != null) {
        _onChainBalances[pair.chain] = res.nativeBalance;
      }
      return res;
    } finally {
      _isLoadingPairBalances = false;
      _notify();
    }
  }

  double totalOnChainUsd(double Function(String symbol) priceLookup) {
    var sum = 0.0;
    _onChainBalances.forEach((slug, bal) {
      final sym = kDexChains[slug]?.symbol ?? '';
      sum += bal * priceLookup(sym);
    });
    return sum;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
