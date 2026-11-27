import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/dex_models.dart';

/// Determinism flags for tests vs live runtime.
bool enableLivePolling = true;
bool enableNetworkImages = true;

/// Single source of truth for all HyperDEX, fallback DEX, and EVM RPC endpoints.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://hyperdex.online/api';
  static const String geckoBaseUrl = 'https://api.geckoterminal.com/api/v2';
  static const String dexScreenerBaseUrl =
      'https://api.dexscreener.com/latest/dex';

  // HyperDEX route paths matching hyperdex/routes/api.php
  static const String stats = '/stats';
  static const String pools = '/pools';
  static const String search = '/search';
  static const String batch = '/batch';
  static String pair(String chain, String address) => '/pair/$chain/$address';
  static String ohlcv(String chain, String address) => '/ohlcv/$chain/$address';
  static String trades(String chain, String address) =>
      '/trades/$chain/$address';

  // ---------------- Typed HyperDEX URIs ----------------

  static Uri hyperStatsUri() => Uri.parse('$baseUrl$stats');

  static Uri hyperPoolsUri({
    String kind = 'trending',
    String? chain,
    int page = 1,
    int pages = 2,
  }) {
    final params = <String, String>{
      'kind': kind,
      'page': '$page',
      'pages': '$pages',
    };
    if (chain != null && chain.isNotEmpty) {
      params['chain'] = chain;
    }
    return Uri.parse('$baseUrl$pools').replace(queryParameters: params);
  }

  static Uri hyperSearchUri(String query) => Uri.parse(
    '$baseUrl$search',
  ).replace(queryParameters: {'q': query.trim()});

  static Uri hyperBatchUri(List<String> keys) {
    final qs = keys.map((k) => 'p[]=${Uri.encodeQueryComponent(k)}').join('&');
    return Uri.parse('$baseUrl$batch?$qs');
  }

  static Uri hyperPairUri(String chain, String address) =>
      Uri.parse('$baseUrl${pair(chain, address)}');

  static Uri hyperOhlcvUri(String chain, String address, {String tf = '15m'}) =>
      Uri.parse(
        '$baseUrl${ohlcv(chain, address)}',
      ).replace(queryParameters: {'tf': tf.toLowerCase()});

  static Uri hyperTradesUri(String chain, String address) =>
      Uri.parse('$baseUrl${trades(chain, address)}');

  // ---------------- Fallback Upstream URIs ----------------

  static Uri screenerPairUri(String chain, String address) =>
      Uri.parse('$dexScreenerBaseUrl/pairs/$chain/$address');

  static Uri screenerSearchUri(String query) => Uri.parse(
    '$dexScreenerBaseUrl/search',
  ).replace(queryParameters: {'q': query.trim()});

  static Uri geckoPoolsUri({required String kind, String? geckoNet}) {
    final path = switch ((kind, geckoNet)) {
      ('new', final net?) => '$geckoBaseUrl/networks/$net/new_pools',
      ('new', null) => '$geckoBaseUrl/networks/new_pools',
      (_, final net?) when kind != 'trending' =>
        '$geckoBaseUrl/networks/$net/pools',
      (_, final net?) => '$geckoBaseUrl/networks/$net/trending_pools',
      (_, null) => '$geckoBaseUrl/networks/trending_pools',
    };
    final params = <String, String>{
      'include': 'base_token,quote_token,dex',
      'page': '1',
    };
    if (kind != 'new' && kind != 'trending' && geckoNet != null) {
      params['sort'] = 'h24_volume_usd_desc';
    }
    return Uri.parse(path).replace(queryParameters: params);
  }

  static Uri geckoOhlcvUri(
    String geckoNet,
    String address,
    String unit,
    int agg,
  ) => Uri.parse('$geckoBaseUrl/networks/$geckoNet/pools/$address/ohlcv/$unit')
      .replace(
        queryParameters: {
          'aggregate': '$agg',
          'limit': '180',
          'currency': 'usd',
        },
      );

  static Uri geckoTradesUri(String geckoNet, String address) =>
      Uri.parse('$geckoBaseUrl/networks/$geckoNet/pools/$address/trades');
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Uri? uri;

  const ApiException(this.message, {this.statusCode, this.uri});

  @override
  String toString() =>
      'ApiException($statusCode): $message${uri != null ? ' [$uri]' : ''}';
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool fromFallback;

  const ApiResponse({
    this.data,
    this.error,
    this.statusCode,
    this.fromFallback = false,
  });

  bool get isSuccess => data != null && error == null;
}

abstract class ApiServiceContract {
  Future<({List<DexTicker> ticker, DexGlobalStats stats})> getStatsAndTicker();
  Future<List<DexPair>> getPools({
    String kind = 'trending',
    String? chain,
    int page = 1,
    int pages = 2,
  });
  Future<List<DexPair>> searchPairs(String query);
  Future<DexPair?> getPair(String chain, String address);
  Future<List<DexCandle>> getOhlcv(
    String chain,
    String address, {
    String tf = '15m',
  });
  Future<List<DexTrade>> getTrades(String chain, String address);
  Future<List<DexPair>> getBatch(List<String> keys);
  Future<Map<String, double>> getEvmNativeBalances(String evmAddress);
  Future<PairWalletBalances> getPairWalletBalances({
    required String chain,
    required String walletAddress,
    required String baseAddress,
    required String quoteAddress,
  });
  void dispose();
}

class ApiService implements ApiServiceContract {
  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  ApiService({http.Client? client, this.timeout = const Duration(seconds: 18)})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  @override
  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<dynamic> _getJson(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final res = await _client
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'DexNovaMobile/1.0',
            ...headers,
          },
        )
        .timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'Request failed with HTTP ${res.statusCode}',
        statusCode: res.statusCode,
        uri: uri,
      );
    }
    return jsonDecode(res.body);
  }

  Future<dynamic> _getJsonWithRetry(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    try {
      return await _getJson(uri, headers: headers);
    } catch (_) {
      return await _getJson(uri, headers: headers);
    }
  }

  Future<dynamic> _postJson(Uri uri, Map<String, dynamic> payload) async {
    final res = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'RPC failed with HTTP ${res.statusCode}',
        statusCode: res.statusCode,
        uri: uri,
      );
    }
    return jsonDecode(res.body);
  }

  List<DexPair> _parseHyperPairList(dynamic json) {
    if (json is! Map) return [];
    final data = json['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => DexPair.fromHyperDexJson(Map<String, dynamic>.from(e)))
        .where((p) => p.pair.isNotEmpty)
        .toList();
  }

  @override
  Future<({List<DexTicker> ticker, DexGlobalStats stats})>
  getStatsAndTicker() async {
    try {
      final json = await _getJsonWithRetry(ApiEndpoints.hyperStatsUri());
      if (json is Map<String, dynamic>) {
        final rawTicker = json['ticker'];
        final tickers = rawTicker is List
            ? rawTicker
                  .whereType<Map>()
                  .map((e) => DexTicker.fromJson(Map<String, dynamic>.from(e)))
                  .toList()
            : <DexTicker>[];
        final rawStats = json['stats'];
        final stats = rawStats is Map
            ? DexGlobalStats.fromJson(Map<String, dynamic>.from(rawStats))
            : const DexGlobalStats();
        if (tickers.isNotEmpty) {
          return (ticker: tickers, stats: stats);
        }
      }
    } catch (_) {}

    // Fallback dynamically from live pools (zero hardcoded pair addresses or stats)
    final pools = await getPools(kind: 'trending');
    if (pools.isEmpty) {
      return (ticker: const <DexTicker>[], stats: const DexGlobalStats());
    }
    final dynamicTickers = pools
        .take(4)
        .map(
          (row) => DexTicker(
            chain: row.chain,
            pair: row.pair,
            symbol: row.base.symbol,
            price: row.price,
            change: row.change.h24,
            changes: row.change,
          ),
        )
        .toList();
    var totVol = 0.0;
    var totLiq = 0.0;
    var totTxns = 0;
    for (final p in pools) {
      totVol += p.volume.h24;
      totLiq += p.liquidity;
      totTxns += p.totalTxns;
    }
    return (
      ticker: dynamicTickers,
      stats: DexGlobalStats(
        volume24h: totVol,
        liquidity: totLiq,
        pairs: pools.length,
        txns24h: totTxns,
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
    try {
      final json = await _getJsonWithRetry(
        ApiEndpoints.hyperPoolsUri(
          kind: kind,
          chain: chain,
          page: page,
          pages: pages,
        ),
      );
      final rows = _parseHyperPairList(json);
      if (rows.isNotEmpty) return _sortPools(rows, kind);
    } catch (_) {}

    // Fallback: GeckoTerminal dynamic pools endpoint
    try {
      final net = chain != null ? kDexChains[chain]?.geckoId : null;
      final json = await _getJson(
        ApiEndpoints.geckoPoolsUri(kind: kind, geckoNet: net),
        headers: const {'Accept': 'application/json;version=20230302'},
      );
      if (json is Map<String, dynamic>) {
        final rows = DexPair.listFromGecko(json);
        if (rows.isNotEmpty) return _sortPools(rows, kind);
      }
    } catch (_) {}

    return const [];
  }

  List<DexPair> _sortPools(List<DexPair> list, String kind) {
    final rows = List<DexPair>.of(list);
    switch (kind) {
      case 'gainers':
        rows.sort((a, b) => b.change.h24.compareTo(a.change.h24));
      case 'losers':
        rows.sort((a, b) => a.change.h24.compareTo(b.change.h24));
      case 'new':
        rows.sort((a, b) => (b.createdMs ?? 0).compareTo(a.createdMs ?? 0));
      case 'volume':
      default:
        rows.sort((a, b) => b.volume.h24.compareTo(a.volume.h24));
    }
    return rows;
  }

  @override
  Future<List<DexPair>> searchPairs(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];
    try {
      final json = await _getJson(ApiEndpoints.hyperSearchUri(clean));
      final rows = _parseHyperPairList(json);
      if (rows.isNotEmpty) return rows;
    } catch (_) {}

    try {
      final json = await _getJson(ApiEndpoints.screenerSearchUri(clean));
      if (json is Map && json['pairs'] is List) {
        return (json['pairs'] as List)
            .whereType<Map>()
            .map((e) => DexPair.fromDexScreener(Map<String, dynamic>.from(e)))
            .where((p) => p.pair.isNotEmpty && kDexChains.containsKey(p.chain))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<DexPair?> getPair(String chain, String address) async {
    try {
      final json = await _getJson(ApiEndpoints.hyperPairUri(chain, address));
      if (json is Map) {
        final data = json['data'] is Map ? json['data'] as Map : json;
        if (data['pair'] != null || data['base'] != null) {
          return DexPair.fromHyperDexJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (_) {}

    try {
      final json = await _getJson(ApiEndpoints.screenerPairUri(chain, address));
      if (json is Map &&
          json['pairs'] is List &&
          (json['pairs'] as List).isNotEmpty) {
        return DexPair.fromDexScreener(
          Map<String, dynamic>.from((json['pairs'] as List).first as Map),
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<List<DexCandle>> getOhlcv(
    String chain,
    String address, {
    String tf = '15m',
  }) async {
    final normTf = tf.toLowerCase();
    try {
      final json = await _getJson(
        ApiEndpoints.hyperOhlcvUri(chain, address, tf: normTf),
      );
      if (json is Map && json['data'] is List) {
        final list = (json['data'] as List)
            .whereType<Map>()
            .map((e) => DexCandle.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (list.length >= 2) return _stitchCandles(list);
      }
    } catch (_) {}

    final net = kDexChains[chain]?.geckoId;
    if (net == null) return [];
    const tfMap = {
      '1m': ('minute', 1),
      '5m': ('minute', 5),
      '15m': ('minute', 15),
      '1h': ('hour', 1),
      '4h': ('hour', 4),
      '1d': ('day', 1),
    };
    final spec = tfMap[normTf] ?? tfMap['15m']!;
    final variants = address.toLowerCase() == address
        ? [address]
        : [address.toLowerCase(), address];

    Future<List<DexCandle>> tryGecko(String unit, int agg) async {
      for (final addr in variants) {
        try {
          final json = await _getJson(
            ApiEndpoints.geckoOhlcvUri(net, addr, unit, agg),
            headers: const {'Accept': 'application/json;version=20230302'},
          );
          final list = (json is Map)
              ? ((json['data']?['attributes']?['ohlcv_list']) as List? ?? [])
              : const [];
          if (list.length >= 2) {
            return list
                .whereType<List>()
                .where((c) => c.length >= 6)
                .map(
                  (c) => DexCandle(
                    time: parseDexInt(c[0]),
                    open: parseDexDouble(c[1]),
                    high: parseDexDouble(c[2]),
                    low: parseDexDouble(c[3]),
                    close: parseDexDouble(c[4]),
                    volume: parseDexDouble(c[5]),
                  ),
                )
                .toList();
          }
        } catch (_) {}
      }
      return [];
    }

    var raw = await tryGecko(spec.$1, spec.$2);
    if (raw.length < 2 && spec.$1 != 'hour') raw = await tryGecko('hour', 1);
    if (raw.length < 2 && spec.$1 != 'day') raw = await tryGecko('day', 1);
    if (raw.isEmpty) return [];
    return _stitchCandles(raw);
  }

  List<DexCandle> _stitchCandles(List<DexCandle> input) {
    final out = List<DexCandle>.of(input)
      ..sort((a, b) => a.time.compareTo(b.time));
    for (var i = 1; i < out.length; i++) {
      final prevClose = out[i - 1].close;
      if (prevClose > 0) {
        final c = out[i];
        out[i] = DexCandle(
          time: c.time,
          open: prevClose,
          high: math.max(c.high, math.max(prevClose, c.close)),
          low: math.min(c.low, math.min(prevClose, c.close)),
          close: c.close,
          volume: c.volume,
        );
      }
    }
    return out;
  }

  @override
  Future<List<DexTrade>> getTrades(String chain, String address) async {
    try {
      final json = await _getJsonWithRetry(
        ApiEndpoints.hyperTradesUri(chain, address),
      );
      if (json is Map && json['data'] is List) {
        final rows = (json['data'] as List)
            .whereType<Map>()
            .map((e) => DexTrade.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (rows.isNotEmpty) return rows;
      }
    } catch (_) {}

    final net = kDexChains[chain]?.geckoId;
    if (net == null) return [];
    final variants = address.toLowerCase() == address
        ? [address]
        : [address.toLowerCase(), address];
    for (final addr in variants) {
      try {
        final json = await _getJson(
          ApiEndpoints.geckoTradesUri(net, addr),
          headers: const {'Accept': 'application/json;version=20230302'},
        );
        if (json is Map && json['data'] is List) {
          final rows = <DexTrade>[];
          for (final item in (json['data'] as List).take(60)) {
            if (item is! Map) continue;
            final a = item['attributes'] as Map? ?? {};
            final isBuy = a['kind']?.toString().toLowerCase() == 'buy';
            final dt = DateTime.tryParse(
              (a['block_timestamp'] ?? '').toString(),
            );
            rows.add(
              DexTrade(
                timeMs:
                    dt?.millisecondsSinceEpoch ??
                    DateTime.now().millisecondsSinceEpoch,
                isBuy: isBuy,
                usd: parseDexDouble(a['volume_in_usd']),
                price: parseDexDouble(
                  isBuy ? a['price_to_in_usd'] : a['price_from_in_usd'],
                ),
                amountFrom: parseDexDouble(a['from_token_amount']),
                amountTo: parseDexDouble(a['to_token_amount']),
                tx: (a['tx_hash'] ?? '').toString(),
                maker: (a['tx_from_address'] ?? '').toString(),
              ),
            );
          }
          if (rows.isNotEmpty) return rows;
        }
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<List<DexPair>> getBatch(List<String> keys) async {
    if (keys.isEmpty) return [];
    try {
      final json = await _getJson(ApiEndpoints.hyperBatchUri(keys));
      final rows = _parseHyperPairList(json);
      if (rows.isNotEmpty) return rows;
    } catch (_) {}

    final out = <DexPair>[];
    await Future.wait(
      keys.take(15).map((k) async {
        final parts = k.split(':');
        if (parts.length != 2) return;
        final pair = await getPair(parts[0], parts[1]);
        if (pair != null) out.add(pair);
      }),
    );
    return out;
  }

  @override
  Future<Map<String, double>> getEvmNativeBalances(String evmAddress) async {
    final result = <String, double>{};
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(evmAddress)) {
      return result;
    }
    final evmChains = kDexChains.values.where((c) => c.rpcUrl != null).toList();
    await Future.wait(
      evmChains.map((c) async {
        try {
          final json = await _postJson(Uri.parse(c.rpcUrl!), {
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'eth_getBalance',
            'params': [evmAddress, 'latest'],
          });
          if (json is Map && json['result'] != null) {
            final hexStr = json['result'].toString().replaceFirst('0x', '');
            if (hexStr.isNotEmpty) {
              final wei = BigInt.parse(hexStr, radix: 16);
              result[c.slug] = wei / BigInt.from(10).pow(18);
              return;
            }
          }
          result[c.slug] = 0.0;
        } catch (_) {
          result[c.slug] = 0.0;
        }
      }),
    );
    return result;
  }

  static final RegExp _evmHexRe = RegExp(r'^0x[0-9a-fA-F]{40}$');

  String _pad32(String hexAddr) {
    final clean = hexAddr.toLowerCase().replaceFirst('0x', '');
    return clean.padLeft(64, '0');
  }

  Future<BigInt> _ethCallBigInt(Uri rpc, String to, String data) async {
    try {
      final json = await _postJson(rpc, {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'eth_call',
        'params': [
          {'to': to, 'data': data},
          'latest',
        ],
      });
      if (json is Map && json['result'] != null) {
        final raw = json['result'].toString().replaceFirst('0x', '').trim();
        if (raw.isEmpty) return BigInt.zero;
        return BigInt.tryParse(raw, radix: 16) ?? BigInt.zero;
      }
    } catch (_) {}
    return BigInt.zero;
  }

  double _scaleToken(BigInt raw, int decimals) {
    if (raw <= BigInt.zero) return 0.0;
    if (decimals <= 0) return raw.toDouble();
    final unlimitedThreshold = BigInt.from(10).pow(decimals + 15);
    if (raw >= unlimitedThreshold) return 1e18;
    return raw / BigInt.from(10).pow(decimals);
  }

  Future<({double balance, double allowance, int decimals})> _readErc20(
    Uri rpc,
    String tokenAddr,
    String owner,
    String? spender,
  ) async {
    if (!_evmHexRe.hasMatch(tokenAddr)) {
      return (balance: 0.0, allowance: 0.0, decimals: 18);
    }
    final calls = await Future.wait([
      _ethCallBigInt(rpc, tokenAddr, '0x313ce567'),
      _ethCallBigInt(rpc, tokenAddr, '0x70a08231${_pad32(owner)}'),
      spender != null && _evmHexRe.hasMatch(spender)
          ? _ethCallBigInt(
              rpc,
              tokenAddr,
              '0xdd62ed3e${_pad32(owner)}${_pad32(spender)}',
            )
          : Future.value(BigInt.zero),
    ]);
    final rawDec = calls[0].toInt();
    final decimals = (rawDec <= 0 || rawDec > 36) ? 18 : rawDec;
    return (
      balance: _scaleToken(calls[1], decimals),
      allowance: _scaleToken(calls[2], decimals),
      decimals: decimals,
    );
  }

  @override
  Future<PairWalletBalances> getPairWalletBalances({
    required String chain,
    required String walletAddress,
    required String baseAddress,
    required String quoteAddress,
  }) async {
    final rpcUrl = kDexChains[chain]?.rpcUrl;
    if (!_evmHexRe.hasMatch(walletAddress) || rpcUrl == null) {
      return const PairWalletBalances(loaded: true);
    }
    final rpc = Uri.parse(rpcUrl);
    final routerCfg = kDexRouters[chain];
    final effectiveQuote = _evmHexRe.hasMatch(quoteAddress)
        ? quoteAddress
        : (routerCfg?.usdt ?? '');

    Future<double> readNative() async {
      try {
        final json = await _postJson(rpc, {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_getBalance',
          'params': [walletAddress, 'latest'],
        });
        if (json is Map && json['result'] != null) {
          final hexStr = json['result'].toString().replaceFirst('0x', '');
          if (hexStr.isNotEmpty) {
            final wei = BigInt.tryParse(hexStr, radix: 16) ?? BigInt.zero;
            return wei / BigInt.from(10).pow(18);
          }
        }
      } catch (_) {}
      return 0.0;
    }

    try {
      final results = await Future.wait([
        readNative(),
        _readErc20(rpc, effectiveQuote, walletAddress, routerCfg?.router),
        _readErc20(rpc, baseAddress, walletAddress, routerCfg?.router),
      ]);
      final nativeBal = results[0] as double;
      final q =
          results[1] as ({double balance, double allowance, int decimals});
      final b =
          results[2] as ({double balance, double allowance, int decimals});
      return PairWalletBalances(
        nativeBalance: nativeBal,
        quoteBalance: q.balance,
        baseBalance: b.balance,
        quoteDecimals: q.decimals,
        baseDecimals: b.decimals,
        quoteAllowance: q.allowance,
        baseAllowance: b.allowance,
        loaded: true,
      );
    } catch (e) {
      return PairWalletBalances(loaded: true, rpcError: e.toString());
    }
  }
}
