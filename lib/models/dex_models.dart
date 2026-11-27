import 'dart:math' as math;
import 'package:flutter/material.dart';

class DexChainInfo {
  final String slug;
  final String name;
  final String geckoId;
  final Color color;
  final String symbol;
  final String explorer;
  final int? evmId;
  final String? rpcUrl;

  const DexChainInfo({
    required this.slug,
    required this.name,
    required this.geckoId,
    required this.color,
    required this.symbol,
    required this.explorer,
    this.evmId,
    this.rpcUrl,
  });

  String get badgeChar {
    switch (slug) {
      case 'ethereum':
        return 'Ξ';
      case 'bsc':
        return '◆';
      case 'solana':
        return '≡';
      case 'avalanche':
        return '▲';
      case 'blast':
        return '⚡';
      case 'ton':
        return '◇';
      default:
        return name.substring(0, 1).toUpperCase();
    }
  }
}

const Map<String, DexChainInfo> kDexChains = {
  'ethereum': DexChainInfo(
    slug: 'ethereum',
    name: 'Ethereum',
    geckoId: 'eth',
    color: Color(0xFF627EEA),
    symbol: 'ETH',
    explorer: 'https://etherscan.io',
    evmId: 1,
    rpcUrl: 'https://cloudflare-eth.com',
  ),
  'bsc': DexChainInfo(
    slug: 'bsc',
    name: 'BNB Chain',
    geckoId: 'bsc',
    color: Color(0xFFF3BA2F),
    symbol: 'BNB',
    explorer: 'https://bscscan.com',
    evmId: 56,
    rpcUrl: 'https://bsc-dataseed.binance.org',
  ),
  'solana': DexChainInfo(
    slug: 'solana',
    name: 'Solana',
    geckoId: 'solana',
    color: Color(0xFF14F195),
    symbol: 'SOL',
    explorer: 'https://solscan.io',
  ),
  'base': DexChainInfo(
    slug: 'base',
    name: 'Base',
    geckoId: 'base',
    color: Color(0xFF0052FF),
    symbol: 'ETH',
    explorer: 'https://basescan.org',
    evmId: 8453,
    rpcUrl: 'https://mainnet.base.org',
  ),
  'arbitrum': DexChainInfo(
    slug: 'arbitrum',
    name: 'Arbitrum',
    geckoId: 'arbitrum',
    color: Color(0xFF28A0F0),
    symbol: 'ETH',
    explorer: 'https://arbiscan.io',
    evmId: 42161,
    rpcUrl: 'https://arb1.arbitrum.io/rpc',
  ),
  'polygon': DexChainInfo(
    slug: 'polygon',
    name: 'Polygon',
    geckoId: 'polygon_pos',
    color: Color(0xFF8247E5),
    symbol: 'POL',
    explorer: 'https://polygonscan.com',
    evmId: 137,
    rpcUrl: 'https://polygon-rpc.com',
  ),
  'avalanche': DexChainInfo(
    slug: 'avalanche',
    name: 'Avalanche',
    geckoId: 'avax',
    color: Color(0xFFE84142),
    symbol: 'AVAX',
    explorer: 'https://snowtrace.io',
    evmId: 43114,
    rpcUrl: 'https://api.avax.network/ext/bc/C/rpc',
  ),
  'optimism': DexChainInfo(
    slug: 'optimism',
    name: 'Optimism',
    geckoId: 'optimism',
    color: Color(0xFFFF0420),
    symbol: 'ETH',
    explorer: 'https://optimistic.etherscan.io',
    evmId: 10,
    rpcUrl: 'https://mainnet.optimism.io',
  ),
  'fantom': DexChainInfo(
    slug: 'fantom',
    name: 'Fantom',
    geckoId: 'ftm',
    color: Color(0xFF1969FF),
    symbol: 'FTM',
    explorer: 'https://ftmscan.com',
    evmId: 250,
    rpcUrl: 'https://rpc.ftm.tools',
  ),
  'cronos': DexChainInfo(
    slug: 'cronos',
    name: 'Cronos',
    geckoId: 'cro',
    color: Color(0xFF002D74),
    symbol: 'CRO',
    explorer: 'https://cronoscan.com',
    evmId: 25,
  ),
  'linea': DexChainInfo(
    slug: 'linea',
    name: 'Linea',
    geckoId: 'linea',
    color: Color(0xFF61DFFF),
    symbol: 'ETH',
    explorer: 'https://lineascan.build',
    evmId: 59144,
  ),
  'blast': DexChainInfo(
    slug: 'blast',
    name: 'Blast',
    geckoId: 'blast',
    color: Color(0xFFFCFC03),
    symbol: 'ETH',
    explorer: 'https://blastscan.io',
    evmId: 81457,
  ),
  'zksync': DexChainInfo(
    slug: 'zksync',
    name: 'zkSync',
    geckoId: 'zksync',
    color: Color(0xFF8C8DFC),
    symbol: 'ETH',
    explorer: 'https://explorer.zksync.io',
    evmId: 324,
  ),
  'scroll': DexChainInfo(
    slug: 'scroll',
    name: 'Scroll',
    geckoId: 'scroll',
    color: Color(0xFFFFEEDA),
    symbol: 'ETH',
    explorer: 'https://scrollscan.com',
    evmId: 534352,
  ),
  'mantle': DexChainInfo(
    slug: 'mantle',
    name: 'Mantle',
    geckoId: 'mantle',
    color: Color(0xFF65B3AE),
    symbol: 'MNT',
    explorer: 'https://explorer.mantle.xyz',
    evmId: 5000,
  ),
  'pulsechain': DexChainInfo(
    slug: 'pulsechain',
    name: 'PulseChain',
    geckoId: 'pulsechain',
    color: Color(0xFFFF00FF),
    symbol: 'PLS',
    explorer: 'https://scan.pulsechain.com',
    evmId: 369,
  ),
  'sui': DexChainInfo(
    slug: 'sui',
    name: 'Sui',
    geckoId: 'sui-network',
    color: Color(0xFF4DA2FF),
    symbol: 'SUI',
    explorer: 'https://suiscan.xyz',
  ),
  'ton': DexChainInfo(
    slug: 'ton',
    name: 'TON',
    geckoId: 'ton',
    color: Color(0xFF0098EA),
    symbol: 'TON',
    explorer: 'https://tonscan.org',
  ),
};

String? chainSlugFromGecko(String geckoId) {
  for (final e in kDexChains.entries) {
    if (e.value.geckoId == geckoId) return e.key;
  }
  return null;
}

DexChainInfo chainInfoFor(String slug) =>
    kDexChains[slug] ??
    DexChainInfo(
      slug: slug,
      name: slug.isEmpty
          ? 'Unknown'
          : slug[0].toUpperCase() + slug.substring(1),
      geckoId: slug,
      color: const Color(0xFF7B3FF2),
      symbol: slug.toUpperCase(),
      explorer: 'https://etherscan.io',
    );

double parseDexDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int parseDexInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double _d(dynamic v) => parseDexDouble(v);

int _i(dynamic v) => parseDexInt(v);

int? _iOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final parsedInt = int.tryParse(v);
    if (parsedInt != null) return parsedInt;
    final dt = DateTime.tryParse(v);
    return dt?.millisecondsSinceEpoch;
  }
  return null;
}

Map<String, dynamic> _asMap(dynamic v) => v is Map<String, dynamic>
    ? v
    : (v is Map ? Map<String, dynamic>.from(v) : {});

class DexToken {
  final String symbol;
  final String name;
  final String address;
  final String? image;

  const DexToken({
    required this.symbol,
    required this.name,
    required this.address,
    this.image,
  });

  factory DexToken.fromJson(Map<String, dynamic> json) => DexToken(
    symbol: (json['symbol'] ?? '?').toString(),
    name: (json['name'] ?? '').toString(),
    address: (json['address'] ?? '').toString(),
    image: json['image']?.toString(),
  );
}

class DexChange {
  final double m5;
  final double h1;
  final double h6;
  final double h24;

  const DexChange({this.m5 = 0, this.h1 = 0, this.h6 = 0, this.h24 = 0});

  factory DexChange.fromJson(Map<String, dynamic> json) => DexChange(
    m5: _d(json['m5']),
    h1: _d(json['h1']),
    h6: _d(json['h6']),
    h24: _d(json['h24']),
  );

  double forPeriod(String period) {
    switch (period) {
      case '5m':
      case 'm5':
        return m5;
      case '1h':
      case 'h1':
        return h1;
      case '6h':
      case 'h6':
        return h6;
      default:
        return h24;
    }
  }
}

class DexVolume {
  final double m5;
  final double h1;
  final double h6;
  final double h24;

  const DexVolume({this.m5 = 0, this.h1 = 0, this.h6 = 0, this.h24 = 0});

  factory DexVolume.fromJson(Map<String, dynamic> json) => DexVolume(
    m5: _d(json['m5']),
    h1: _d(json['h1']),
    h6: _d(json['h6']),
    h24: _d(json['h24']),
  );

  double forPeriod(String period) {
    switch (period) {
      case '5m':
      case 'm5':
        return m5;
      case '1h':
      case 'h1':
        return h1;
      case '6h':
      case 'h6':
        return h6;
      default:
        return h24;
    }
  }
}

class DexTxnWindow {
  final int buys;
  final int sells;
  final int buyers;
  final int sellers;
  const DexTxnWindow({
    this.buys = 0,
    this.sells = 0,
    this.buyers = 0,
    this.sellers = 0,
  });
  int get total => buys + sells;
  int get makersTotal => buyers + sellers;
}

class DexTxns {
  final int buys;
  final int sells;
  final Map<String, DexTxnWindow> windows;

  const DexTxns({this.buys = 0, this.sells = 0, this.windows = const {}});

  factory DexTxns.fromJson(Map<String, dynamic> json) {
    final wins = <String, DexTxnWindow>{};
    for (final k in const ['m5', 'h1', 'h6', 'h24']) {
      final w = _asMap(json[k]);
      if (w.isNotEmpty) {
        wins[k] = DexTxnWindow(
          buys: _i(w['buys']),
          sells: _i(w['sells']),
          buyers: _i(w['buyers']),
          sellers: _i(w['sellers']),
        );
      }
    }
    return DexTxns(
      buys: _i(json['buys']),
      sells: _i(json['sells']),
      windows: wins,
    );
  }

  DexTxnWindow windowFor(String period) =>
      windows[period] ?? DexTxnWindow(buys: buys, sells: sells);
}

class DexPair {
  final String chain;
  final String pair;
  final String dex;
  final DexToken base;
  final DexToken quote;
  final double price;
  final double priceNative;
  final DexChange change;
  final DexVolume volume;
  final double liquidity;
  final double pooledBase;
  final double pooledQuote;
  final double fdv;
  final double mcap;
  final DexTxns txns;
  final int makers;
  final int? createdMs;
  final List<String> websites;
  final List<String> socials;

  const DexPair({
    required this.chain,
    required this.pair,
    required this.dex,
    required this.base,
    required this.quote,
    required this.price,
    this.priceNative = 0,
    this.change = const DexChange(),
    this.volume = const DexVolume(),
    this.liquidity = 0,
    this.pooledBase = 0,
    this.pooledQuote = 0,
    this.fdv = 0,
    this.mcap = 0,
    this.txns = const DexTxns(),
    this.makers = 0,
    this.createdMs,
    this.websites = const [],
    this.socials = const [],
  });

  String get key => '$chain:$pair';
  String get pairLabel => '${base.symbol}/${quote.symbol}';
  int get totalTxns => txns.buys + txns.sells;
  double get displayMcap => mcap > 0 ? mcap : fdv;

  List<double> get sparkPoints {
    final p24 = change.h24;
    final p6 = change.h6;
    final p1 = change.h1;
    final p5 = change.m5;
    return [0.0, p24 * 0.25, p24 * 0.5, p24 - p6, p24 - p1, p24 - p5, p24];
  }

  factory DexPair.fromHyperDexJson(Map<String, dynamic> json) {
    final pooled = _asMap(json['pooled']);
    final webList = <String>[];
    if (json['websites'] is List) {
      for (final w in json['websites'] as List) {
        final m = _asMap(w);
        if (m['url'] != null) webList.add(m['url'].toString());
      }
    }
    final socList = <String>[];
    if (json['socials'] is List) {
      for (final s in json['socials'] as List) {
        final m = _asMap(s);
        if (m['url'] != null) socList.add(m['url'].toString());
      }
    }
    return DexPair(
      chain: (json['chain'] ?? 'ethereum').toString(),
      pair: (json['pair'] ?? '').toString(),
      dex: (json['dex'] ?? '').toString(),
      base: DexToken.fromJson(_asMap(json['base'])),
      quote: DexToken.fromJson(_asMap(json['quote'])),
      price: _d(json['price']),
      priceNative: _d(json['priceNative']),
      change: DexChange.fromJson(_asMap(json['change'])),
      volume: DexVolume.fromJson(_asMap(json['volume'])),
      liquidity: _d(json['liquidity']),
      pooledBase: _d(pooled['base']),
      pooledQuote: _d(pooled['quote']),
      fdv: _d(json['fdv']),
      mcap: _d(json['mcap']),
      txns: DexTxns.fromJson(_asMap(json['txns'])),
      makers: _i(json['makers']),
      createdMs: _iOrNull(json['created']),
      websites: webList,
      socials: socList,
    );
  }

  factory DexPair.fromDexScreener(Map<String, dynamic> p) {
    final tx = _asMap(p['txns']);
    final info = _asMap(p['info']);
    final liq = _asMap(p['liquidity']);
    final baseTok = _asMap(p['baseToken']);
    final quoteTok = _asMap(p['quoteToken']);
    final liqUsd = _d(liq['usd']);
    final pUsd = _d(p['priceUsd']);
    final pNat = _d(p['priceNative']);
    final qUsd = pNat > 0 ? pUsd / pNat : 1.0;

    final h24 = _asMap(tx['h24']);
    final m5 = _asMap(tx['m5']);
    final h1 = _asMap(tx['h1']);
    final h6 = _asMap(tx['h6']);

    final websites = <String>[];
    if (info['websites'] is List) {
      for (final w in info['websites'] as List) {
        final u = _asMap(w)['url']?.toString();
        if (u != null && u.isNotEmpty) websites.add(u);
      }
    }
    final socials = <String>[];
    if (info['socials'] is List) {
      for (final s in info['socials'] as List) {
        final u = _asMap(s)['url']?.toString();
        if (u != null && u.isNotEmpty) socials.add(u);
      }
    }

    return DexPair(
      chain: (p['chainId'] ?? 'ethereum').toString(),
      pair: (p['pairAddress'] ?? '').toString(),
      dex: (p['dexId'] ?? '').toString(),
      base: DexToken(
        symbol: (baseTok['symbol'] ?? '?').toString(),
        name: (baseTok['name'] ?? '').toString(),
        address: (baseTok['address'] ?? '').toString(),
        image: info['imageUrl']?.toString(),
      ),
      quote: DexToken(
        symbol: (quoteTok['symbol'] ?? '?').toString(),
        name: (quoteTok['name'] ?? '').toString(),
        address: (quoteTok['address'] ?? '').toString(),
      ),
      price: pUsd,
      priceNative: pNat,
      change: DexChange.fromJson(_asMap(p['priceChange'])),
      volume: DexVolume.fromJson(_asMap(p['volume'])),
      liquidity: liqUsd,
      pooledBase: _d(liq['base']) > 0
          ? _d(liq['base'])
          : (pUsd > 0 ? (liqUsd / 2) / pUsd : 0),
      pooledQuote: _d(liq['quote']) > 0
          ? _d(liq['quote'])
          : (qUsd > 0 ? (liqUsd / 2) / qUsd : 0),
      fdv: _d(p['fdv']),
      mcap: _d(p['marketCap']),
      txns: DexTxns(
        buys: _i(h24['buys']),
        sells: _i(h24['sells']),
        windows: {
          'm5': DexTxnWindow(buys: _i(m5['buys']), sells: _i(m5['sells'])),
          'h1': DexTxnWindow(buys: _i(h1['buys']), sells: _i(h1['sells'])),
          'h6': DexTxnWindow(buys: _i(h6['buys']), sells: _i(h6['sells'])),
          'h24': DexTxnWindow(buys: _i(h24['buys']), sells: _i(h24['sells'])),
        },
      ),
      createdMs: _iOrNull(p['pairCreatedAt']),
      websites: websites,
      socials: socials,
    );
  }

  static List<DexPair> listFromGecko(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! List) return [];
    final inc = <String, Map<String, dynamic>>{};
    if (json['included'] is List) {
      for (final item in json['included'] as List) {
        final m = _asMap(item);
        final key = '${m['type']}:${m['id']}';
        inc[key] = _asMap(m['attributes']);
      }
    }
    final out = <DexPair>[];
    for (final raw in data) {
      final p = _asMap(raw);
      final a = _asMap(p['attributes']);
      final rel = _asMap(p['relationships']);
      final addr = (a['address'] ?? '').toString();
      final id = (p['id'] ?? '').toString();
      if (addr.isEmpty || id.length <= addr.length + 1) continue;
      final netKey = id.substring(0, id.length - addr.length - 1);
      final slug = chainSlugFromGecko(netKey);
      if (slug == null) continue;

      final baseId = _asMap(
        _asMap(rel['base_token'])['data'],
      )['id']?.toString();
      final quoteId = _asMap(
        _asMap(rel['quote_token'])['data'],
      )['id']?.toString();
      final dexId = _asMap(_asMap(rel['dex'])['data'])['id']?.toString() ?? '';

      final baseAttr = baseId != null ? (inc['token:$baseId'] ?? {}) : {};
      final quoteAttr = quoteId != null ? (inc['token:$quoteId'] ?? {}) : {};
      final dexName = (inc['dex:$dexId']?['name'] ?? dexId).toString();

      final nameParts = (a['name'] ?? '').toString().split(' / ');
      final imgRaw = baseAttr['image_url']?.toString();
      final img =
          imgRaw != null && imgRaw != 'missing.png' && imgRaw.startsWith('http')
          ? imgRaw
          : null;

      final pc = _asMap(a['price_change_percentage']);
      final vol = _asMap(a['volume_usd']);
      final tx = _asMap(a['transactions']);
      final txH24 = _asMap(tx['h24']);
      final txM5 = _asMap(tx['m5']);
      final txH1 = _asMap(tx['h1']);
      final txH6 = _asMap(tx['h6']);

      final pUsd = _d(a['base_token_price_usd']);
      final pNat = _d(a['base_token_price_native_currency']);
      final resUsd = _d(a['reserve_in_usd']);
      final qUsd = pNat > 0 ? pUsd / pNat : 1.0;

      out.add(
        DexPair(
          chain: slug,
          pair: addr,
          dex: dexName,
          base: DexToken(
            symbol:
                (baseAttr['symbol'] ??
                        (nameParts.isNotEmpty ? nameParts[0] : '?'))
                    .toString(),
            name: (baseAttr['name'] ?? '').toString(),
            address: (baseAttr['address'] ?? '').toString(),
            image: img,
          ),
          quote: DexToken(
            symbol:
                (quoteAttr['symbol'] ??
                        (nameParts.length > 1 ? nameParts[1] : '?'))
                    .toString(),
            name: (quoteAttr['name'] ?? '').toString(),
            address: (quoteAttr['address'] ?? '').toString(),
          ),
          price: pUsd,
          priceNative: pNat,
          change: DexChange(
            m5: _d(pc['m5']),
            h1: _d(pc['h1']),
            h6: _d(pc['h6']),
            h24: _d(pc['h24']),
          ),
          volume: DexVolume(
            m5: _d(vol['m5']),
            h1: _d(vol['h1']),
            h6: _d(vol['h6']),
            h24: _d(vol['h24']),
          ),
          liquidity: resUsd,
          pooledBase: pUsd > 0 ? (resUsd / 2) / pUsd : 0,
          pooledQuote: qUsd > 0 ? (resUsd / 2) / qUsd : 0,
          fdv: _d(a['fdv_usd']),
          mcap: _d(a['market_cap_usd']),
          txns: DexTxns(
            buys: _i(txH24['buys']),
            sells: _i(txH24['sells']),
            windows: {
              'm5': DexTxnWindow(
                buys: _i(txM5['buys']),
                sells: _i(txM5['sells']),
                buyers: _i(txM5['buyers']),
                sellers: _i(txM5['sellers']),
              ),
              'h1': DexTxnWindow(
                buys: _i(txH1['buys']),
                sells: _i(txH1['sells']),
                buyers: _i(txH1['buyers']),
                sellers: _i(txH1['sellers']),
              ),
              'h6': DexTxnWindow(
                buys: _i(txH6['buys']),
                sells: _i(txH6['sells']),
                buyers: _i(txH6['buyers']),
                sellers: _i(txH6['sellers']),
              ),
              'h24': DexTxnWindow(
                buys: _i(txH24['buys']),
                sells: _i(txH24['sells']),
                buyers: _i(txH24['buyers']),
                sellers: _i(txH24['sellers']),
              ),
            },
          ),
          makers: _i(txH24['buyers']) + _i(txH24['sellers']),
          createdMs: _iOrNull(a['pool_created_at']),
        ),
      );
    }
    return out;
  }
}

class DexTicker {
  final String chain;
  final String pair;
  final String symbol;
  final double price;
  final double change;
  final DexChange changes;

  const DexTicker({
    required this.chain,
    required this.pair,
    required this.symbol,
    required this.price,
    required this.change,
    this.changes = const DexChange(),
  });

  factory DexTicker.fromJson(Map<String, dynamic> json) => DexTicker(
    chain: (json['chain'] ?? 'ethereum').toString(),
    pair: (json['pair'] ?? '').toString(),
    symbol: (json['symbol'] ?? '').toString(),
    price: _d(json['price']),
    change: _d(json['change']),
    changes: DexChange.fromJson(_asMap(json['changes'])),
  );

  List<double> get sparkPoints {
    final p24 = change;
    final p6 = changes.h6 != 0 ? changes.h6 : p24 / 2;
    final p1 = changes.h1 != 0 ? changes.h1 : p24 / 4;
    final p5 = changes.m5;
    return [0.0, p24 * 0.25, p24 * 0.5, p24 - p6, p24 - p1, p24 - p5, p24];
  }
}

class DexGlobalStats {
  final double volume24h;
  final double liquidity;
  final int pairs;
  final int txns24h;

  const DexGlobalStats({
    this.volume24h = 0,
    this.liquidity = 0,
    this.pairs = 0,
    this.txns24h = 0,
  });

  factory DexGlobalStats.fromJson(Map<String, dynamic> json) => DexGlobalStats(
    volume24h: _d(json['volume24h']),
    liquidity: _d(json['liquidity']),
    pairs: _i(json['pairs']),
    txns24h: _i(json['txns24h']),
  );
}

class DexCandle {
  final int time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const DexCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume = 0,
  });

  factory DexCandle.fromJson(Map<String, dynamic> json) => DexCandle(
    time: _i(json['time']),
    open: _d(json['open']),
    high: _d(json['high']),
    low: _d(json['low']),
    close: _d(json['close']),
    volume: _d(json['volume']),
  );
}

class DexTrade {
  final int timeMs;
  final bool isBuy;
  final double usd;
  final double price;
  final double amountFrom;
  final double amountTo;
  final String tx;
  final String maker;

  const DexTrade({
    required this.timeMs,
    required this.isBuy,
    required this.usd,
    required this.price,
    this.amountFrom = 0,
    this.amountTo = 0,
    this.tx = '',
    this.maker = '',
  });

  factory DexTrade.fromJson(Map<String, dynamic> json) => DexTrade(
    timeMs: _i(json['time']),
    isBuy: json['type']?.toString().toLowerCase() == 'buy',
    usd: _d(json['usd']),
    price: _d(json['price']),
    amountFrom: _d(json['amountFrom']),
    amountTo: _d(json['amountTo']),
    tx: (json['tx'] ?? '').toString(),
    maker: (json['maker'] ?? '').toString(),
  );
}

class PriceAlert {
  final String id;
  final String chain;
  final String pair;
  final String symbol;
  final bool above;
  final double target;
  final bool triggered;
  final double? firedPrice;
  final int createdMs;

  const PriceAlert({
    required this.id,
    required this.chain,
    required this.pair,
    required this.symbol,
    required this.above,
    required this.target,
    this.triggered = false,
    this.firedPrice,
    required this.createdMs,
  });

  String get key => '$chain:$pair';

  PriceAlert copyWith({bool? triggered, double? firedPrice}) => PriceAlert(
    id: id,
    chain: chain,
    pair: pair,
    symbol: symbol,
    above: above,
    target: target,
    triggered: triggered ?? this.triggered,
    firedPrice: firedPrice ?? this.firedPrice,
    createdMs: createdMs,
  );
}

class DexOrder {
  final String id;
  final String chain;
  final String pair;
  final String symbol;
  final String quoteSymbol;
  final bool isBuy;
  final String orderType; // 'Limit' | 'Market' | 'Stop-Limit' | 'Convert'
  final double price;
  final double amount;
  final double totalUsd;
  final String status; // 'Open' | 'Filled' | 'Cancelled'
  final int createdMs;

  const DexOrder({
    required this.id,
    required this.chain,
    required this.pair,
    required this.symbol,
    required this.quoteSymbol,
    required this.isBuy,
    required this.orderType,
    required this.price,
    required this.amount,
    required this.totalUsd,
    required this.status,
    required this.createdMs,
  });

  DexOrder copyWith({String? status}) => DexOrder(
    id: id,
    chain: chain,
    pair: pair,
    symbol: symbol,
    quoteSymbol: quoteSymbol,
    isBuy: isBuy,
    orderType: orderType,
    price: price,
    amount: amount,
    totalUsd: totalUsd,
    status: status ?? this.status,
    createdMs: createdMs,
  );
}

class DexRouterConfig {
  final String name;
  final String router;
  final String wnative;
  final String usdt;

  const DexRouterConfig({
    required this.name,
    required this.router,
    required this.wnative,
    required this.usdt,
  });
}

/// On-chain DEX router addresses matching hyperdex/public/js/dex.js.
const Map<String, DexRouterConfig> kDexRouters = {
  'bsc': DexRouterConfig(
    name: 'PancakeSwap V2',
    router: '0x10ED43C718714eb63d5aA57B78B54704E256024E',
    wnative: '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c',
    usdt: '0x55d398326f99059fF775485246999027B3197955',
  ),
  'ethereum': DexRouterConfig(
    name: 'Uniswap V2',
    router: '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D',
    wnative: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    usdt: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
  ),
  'base': DexRouterConfig(
    name: 'BaseSwap V2',
    router: '0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24',
    wnative: '0x4200000000000000000000000000000000000006',
    usdt: '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913',
  ),
  'arbitrum': DexRouterConfig(
    name: 'Uniswap V2',
    router: '0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24',
    wnative: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
    usdt: '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9',
  ),
  'polygon': DexRouterConfig(
    name: 'QuickSwap',
    router: '0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff',
    wnative: '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270',
    usdt: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
  ),
  'avalanche': DexRouterConfig(
    name: 'TraderJoe',
    router: '0x60aE616a2155Ee3d9A68541Ba4544862310933d4',
    wnative: '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7',
    usdt: '0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7',
  ),
  'optimism': DexRouterConfig(
    name: 'Uniswap V2',
    router: '0x4A7b5Da61326A6379179b40d00F57E5bbDC962c2',
    wnative: '0x4200000000000000000000000000000000000006',
    usdt: '0x94b008aA00579c1307B0EF2c499aD98a8ce58e58',
  ),
  'fantom': DexRouterConfig(
    name: 'SpookySwap',
    router: '0xF491e7B69E4244ad4002BC14e878a34207E38c29',
    wnative: '0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83',
    usdt: '0x049d68029688eAbF473097a2fC38ef61633A3C7A',
  ),
};

class PairWalletBalances {
  final double nativeBalance;
  final double quoteBalance;
  final double baseBalance;
  final int quoteDecimals;
  final int baseDecimals;
  final double quoteAllowance;
  final double baseAllowance;
  final bool loaded;
  final String? rpcError;

  const PairWalletBalances({
    this.nativeBalance = 0.0,
    this.quoteBalance = 0.0,
    this.baseBalance = 0.0,
    this.quoteDecimals = 18,
    this.baseDecimals = 18,
    this.quoteAllowance = 0.0,
    this.baseAllowance = 0.0,
    this.loaded = false,
    this.rpcError,
  });

  bool get hasUnlimitedQuoteAllowance => quoteAllowance >= 1e15;
  bool get hasUnlimitedBaseAllowance => baseAllowance >= 1e15;
}

// ------------------------------------------------------------------ formatting helpers

String _commaInt(String digits) =>
    digits.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

const _subDigits = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];

String fmtDexPrice(double p) {
  if (p <= 0 || p.isNaN || p.isInfinite) return '\$0.00';
  if (p >= 1000) {
    final s = p.toStringAsFixed(2);
    final parts = s.split('.');
    return '\$${_commaInt(parts[0])}.${parts[1]}';
  }
  if (p >= 1) return '\$${p.toStringAsFixed(4)}';
  if (p >= 0.01) return '\$${p.toStringAsFixed(5)}';
  final s = p.toStringAsFixed(18);
  final m = RegExp(r'^0\.(0+)(\d{1,4})').firstMatch(s);
  if (m != null && m.group(1)!.length >= 4) {
    final zeros = m.group(1)!.length.toString();
    final sub = zeros.split('').map((d) => _subDigits[int.parse(d)]).join();
    return '\$0.0$sub${m.group(2)}';
  }
  return '\$${p.toStringAsPrecision(4)}';
}

String fmtCompactUsd(double n, {int decimals = 2}) {
  if (n.isNaN || n.isInfinite) return '\$0.00';
  final abs = n.abs();
  final sign = n < 0 ? '-' : '';
  if (abs >= 1e12) return '$sign\$${(abs / 1e12).toStringAsFixed(decimals)}T';
  if (abs >= 1e9) return '$sign\$${(abs / 1e9).toStringAsFixed(decimals)}B';
  if (abs >= 1e6) return '$sign\$${(abs / 1e6).toStringAsFixed(decimals)}M';
  if (abs >= 1e3) return '$sign\$${(abs / 1e3).toStringAsFixed(decimals)}K';
  return '$sign\$${abs.toStringAsFixed(decimals)}';
}

String fmtCompactNum(num n) {
  final d = n.toDouble();
  if (d >= 1e9) return '${(d / 1e9).toStringAsFixed(2)}B';
  if (d >= 1e6) return '${(d / 1e6).toStringAsFixed(2)}M';
  if (d >= 1e3) return '${(d / 1e3).toStringAsFixed(2)}K';
  if (d == d.roundToDouble()) return _commaInt(d.toInt().toString());
  return d.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
}

String fmtAgo(int? tsMs) {
  if (tsMs == null || tsMs <= 0) return '—';
  final s = math.max(1, (DateTime.now().millisecondsSinceEpoch - tsMs) ~/ 1000);
  if (s < 60) return '${s}s';
  if (s < 3600) {
    final m = s ~/ 60;
    final rs = s % 60;
    return m < 10 && rs > 0 ? '${m}m ${rs}s' : '${m}m';
  }
  if (s < 86400) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }
  final d = s ~/ 86400;
  final h = (s % 86400) ~/ 3600;
  return h > 0 ? '${d}d ${h}h' : '${d}d';
}

String shortHex(String addr) {
  if (addr.length <= 12) return addr;
  return '${addr.substring(0, 6)}…${addr.substring(addr.length - 4)}';
}
