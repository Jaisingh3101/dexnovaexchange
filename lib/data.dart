import 'dart:math';
import 'package:flutter/material.dart';

class Coin {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double holding;
  final Color color;
  final IconData icon;

  const Coin({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.holding,
    required this.color,
    required this.icon,
  });

  double get value => price * holding;
}

const coins = <Coin>[
  Coin(
    symbol: 'USDT',
    name: 'Tether',
    price: 1.0,
    change: 0.01,
    holding: 12540,
    color: Color(0xFF26A17B),
    icon: Icons.attach_money,
  ),
  Coin(
    symbol: 'BTC',
    name: 'Bitcoin',
    price: 102347.21,
    change: 2.41,
    holding: 0.25,
    color: Color(0xFFF7931A),
    icon: Icons.currency_bitcoin,
  ),
  Coin(
    symbol: 'ETH',
    name: 'Ethereum',
    price: 3412.67,
    change: 1.86,
    holding: 1.0,
    color: Color(0xFF627EEA),
    icon: Icons.diamond_outlined,
  ),
  Coin(
    symbol: 'BNB',
    name: 'BNB',
    price: 686.20,
    change: 1.25,
    holding: 0.5,
    color: Color(0xFFF3BA2F),
    icon: Icons.hexagon_outlined,
  ),
  Coin(
    symbol: 'SOL',
    name: 'Solana',
    price: 204.18,
    change: 3.79,
    holding: 2.0,
    color: Color(0xFF14F195),
    icon: Icons.blur_linear,
  ),
  Coin(
    symbol: 'XRP',
    name: 'Ripple',
    price: 2.34,
    change: -0.82,
    holding: 0,
    color: Color(0xFF8A8F98),
    icon: Icons.close,
  ),
  Coin(
    symbol: 'ADA',
    name: 'Cardano',
    price: 0.98,
    change: -1.45,
    holding: 0,
    color: Color(0xFF0033AD),
    icon: Icons.all_inclusive,
  ),
  Coin(
    symbol: 'DOGE',
    name: 'Dogecoin',
    price: 0.38,
    change: 5.12,
    holding: 0,
    color: Color(0xFFC2A633),
    icon: Icons.pets,
  ),
];

Coin coinBy(String s) => coins.firstWhere((c) => c.symbol == s);

const networks = ['TRC20 (Tron)', 'ERC20 (Ethereum)', 'BEP20 (BSC)', 'Solana'];

const recoveryWords = [
  'apple',
  'tower',
  'nation',
  'galaxy',
  'flower',
  'bitter',
  'such',
  'during',
  'logic',
  'media',
  'forest',
  'random',
];

class Candle {
  final double open, high, low, close;
  Candle(this.open, this.high, this.low, this.close);
}

List<Candle> generateCandles(int count, {int seed = 7, double start = 99500}) {
  final r = Random(seed);
  final list = <Candle>[];
  double last = start;
  for (var i = 0; i < count; i++) {
    final drift = (i / count) * 25; // slight uptrend
    final open = last;
    final close = open + (r.nextDouble() - 0.47) * 700 + drift;
    final high = max(open, close) + r.nextDouble() * 350;
    final low = min(open, close) - r.nextDouble() * 350;
    list.add(Candle(open, high, low, close));
    last = close;
  }
  return list;
}

/// Candles whose last close lands exactly on [price].
List<Candle> candlesFor(double price, {int count = 60, int seed = 7}) {
  final r = Random(seed);
  final vol = price * 0.0035;
  final raw = <Candle>[];
  double last = price * 0.975;
  for (var i = 0; i < count; i++) {
    final trend = i < count * 0.25
        ? -0.3
        : i < count * 0.6
        ? 0.9
        : 0.05;
    final open = last;
    final close = open + (r.nextDouble() - 0.5 + trend * 0.25) * vol * 2;
    final high = max(open, close) + r.nextDouble() * vol;
    final low = min(open, close) - r.nextDouble() * vol;
    raw.add(Candle(open, high, low, close));
    last = close;
  }
  final shift = price - raw.last.close;
  return raw
      .map(
        (c) => Candle(
          c.open + shift,
          c.high + shift,
          c.low + shift,
          c.close + shift,
        ),
      )
      .toList();
}

String fmtUsd(double v, {int decimals = 2}) {
  final s = v.toStringAsFixed(decimals);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}
