import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import '../widgets/hyper_header.dart';
import '../widgets/wallet_switcher.dart';

class TradeScreen extends StatefulWidget {
  final VoidCallback? onOpenScreener;
  const TradeScreen({super.key, this.onOpenScreener});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  final _chartKey = GlobalKey();
  final _orderKey = GlobalKey();
  final _poolInfoKey = GlobalKey();
  final _txnsKey = GlobalKey();

  int quickSection = 0; // 0 Chart | 1 Buy/Sell | 2 Pool Info | 3 Txns
  int chartSubTab = 0; // 0 Chart | 1 Info | 2 Trading Data
  bool lineMode = false;
  bool showMa = true;

  bool buy = true;
  int orderType = 0; // 0 Limit | 1 Market | 2 Stop-Limit
  bool payWithQuote = true;
  double sliderPct = 0;
  int bottomTab =
      0; // 0 Live Txns | 1 Order Book | 2 Open | 3 History | 4 Top Traders | 5 Wallet
  int txnFilter = 0; // 0 All | 1 Buys | 2 Sells
  String? makerFilter;
  bool showAllTxns = false;
  String poolWin = 'h24';

  final priceCtrl = TextEditingController();
  final amtCtrl = TextEditingController();
  final stopCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final qcBaseCtrl = TextEditingController(text: '1');
  final qcUsdCtrl = TextEditingController();
  String? _lastKey;
  String? _lastPairBalKey;
  String? _ordError;
  String? _ordStep;
  bool _submittingOrder = false;
  Timer? _livePairTimer;

  @override
  void initState() {
    super.initState();
    if (enableLivePolling) {
      _livePairTimer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (mounted) {
          context.read<MarketProvider>().refreshActiveTradesAndPair();
        }
      });
    }
  }

  @override
  void dispose() {
    _livePairTimer?.cancel();
    priceCtrl.dispose();
    amtCtrl.dispose();
    stopCtrl.dispose();
    totalCtrl.dispose();
    qcBaseCtrl.dispose();
    qcUsdCtrl.dispose();
    super.dispose();
  }

  void _syncPairInputs(DexPair? pair) {
    if (pair == null || _lastKey == pair.key) return;
    _lastKey = pair.key;
    priceCtrl.text = _fmtInput(pair.price);
    amtCtrl.clear();
    totalCtrl.clear();
    stopCtrl.clear();
    _ordError = null;
    _ordStep = null;
    sliderPct = 0;
    makerFilter = null;
    showAllTxns = false;
    qcBaseCtrl.text = '1';
    qcUsdCtrl.text = _fmtInput(pair.price);
  }

  void _schedulePairBalancesIfNeeded(DexPair? pair, WalletAccount? wallet) {
    if (pair == null || wallet == null) {
      _lastPairBalKey = null;
      return;
    }
    final walletAddr = wallet.ethAddress;
    final key = '${walletAddr.toLowerCase()}:${pair.key}';
    if (_lastPairBalKey == key) return;
    _lastPairBalKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PortfolioProvider>().refreshPairBalances(
        walletAddress: walletAddr,
        pair: pair,
      );
    });
  }

  String _fmtAmtInput(double v) {
    if (v <= 0 || v.isNaN || v.isInfinite) return '';
    if (v >= 100) {
      return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    }
    if (v >= 1) {
      return v.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return v.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _fmtTotInput(double v) {
    if (v <= 0 || v.isNaN || v.isInfinite) return '';
    return v
        .toStringAsFixed(v >= 1 ? 2 : 4)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double _quoteUsdPrice(DexPair pair, MarketProvider market) {
    final sym = pair.quote.symbol.toUpperCase();
    const stables = {
      'USDT',
      'USDC',
      'BUSD',
      'DAI',
      'USDE',
      'FDUSD',
      'TUSD',
      'USD1',
      'USD',
    };
    if (stables.contains(sym)) return 1.0;
    final native = market.nativeUsdPrice(sym);
    if (native > 0) return native;
    if (pair.priceNative > 0 && pair.price > 0) {
      return pair.price / pair.priceNative;
    }
    return 1.0;
  }

  String _fmtTxAmt(double n) {
    if (n.isNaN || n.isInfinite || n <= 0) return '0';
    if (n >= 1000) return fmtCompactNum(n);
    if (n >= 10) return n.toStringAsFixed(2);
    if (n >= 1) {
      return n
          .toStringAsFixed(4)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    if (n >= 0.0001) {
      return n
          .toStringAsPrecision(4)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    return fmtCompactNum(n);
  }

  String _fmtInput(double price) {
    if (price <= 0) return '0';
    if (price >= 100) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    return price.toStringAsPrecision(5);
  }

  void _jumpTo(int idx, GlobalKey key) {
    setState(() => quickSection = idx);
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  String _fmtAge(int? createdMs) {
    if (createdMs == null || createdMs <= 0) return 'Live Pool';
    final diff = DateTime.now().millisecondsSinceEpoch - createdMs;
    if (diff < 0) return 'New';
    final d = diff ~/ 86400000;
    final h = (diff % 86400000) ~/ 3600000;
    if (d > 0) return '${d}d ${h}h ago';
    if (h > 0) return '${h}h ago';
    final m = math.max(1, diff ~/ 60000);
    return '${m}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final market = context.watch<MarketProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final wallet = context.watch<WalletProvider>().activeWallet;
    final pair = market.activePair;
    _syncPairInputs(pair);
    _schedulePairBalancesIfNeeded(pair, wallet);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const HyperTopBar(),
          Expanded(
            child: pair == null
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : RefreshIndicator(
                    onRefresh: () =>
                        context.read<MarketProvider>().refreshAll(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 20),
                      children: [
                        if (wallet != null) ...[
                          const ActiveWalletStrip(),
                          const SizedBox(height: 6),
                        ],
                        const LiveTickerGrid(),
                        const SizedBox(height: 8),
                        _pairHeaderCard(p, pair, portfolio),
                        const SizedBox(height: 8),
                        _quickSectionSwitcher(p),
                        const SizedBox(height: 8),
                        _chartSectionCard(p, market, pair),
                        const SizedBox(height: 8),
                        _transactionsAndBookCard(
                          p,
                          pair,
                          market.activeTrades,
                          portfolio,
                          market,
                        ),
                        const SizedBox(height: 8),
                        _orderFormCard(p, pair, portfolio, market),
                        const SizedBox(height: 8),
                        _poolInfoCard(p, pair, market.activeTrades),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _pairHeaderCard(
    AppPalette p,
    DexPair pair,
    PortfolioProvider portfolio,
  ) {
    final ci = chainInfoFor(pair.chain);
    final up = pair.change.h24 >= 0;
    final chColor = up ? AppColors.green : AppColors.red;
    final fav = portfolio.isWatched(pair.key);

    Widget iconBox(Flaticons icon, VoidCallback onTap, {Color? color}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            color: p.field,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.border),
          ),
          child: Center(
            child: FIcon(icon, size: 14, color: color ?? p.textSecondary),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              TokenAvatar(
                symbol: pair.base.symbol,
                imageUrl: pair.base.image,
                fallbackColor: ci.color,
                size: 32,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => showLivePairPickerSheet(
                    context,
                    (picked) =>
                        context.read<MarketProvider>().selectPair(picked),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              pair.pairLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: p.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          FIcon(Flaticons.chevronDown, size: 13, color: p.text),
                        ],
                      ),
                      Text(
                        '${pair.base.name.isNotEmpty ? pair.base.name : pair.base.symbol} · ${ci.name} · ${pair.dex.toUpperCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: p.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmtDexPrice(pair.price),
                    style: numStyle(fontSize: 16.5, color: chColor),
                  ),
                  Text(
                    '≈ ${fmtDexPrice(pair.price)}',
                    style: numStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: p.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _miniMetric(
                      p,
                      '24h Change',
                      '${up ? '▲' : '▼'} ${pair.change.h24.abs().toStringAsFixed(2)}%',
                      color: chColor,
                    ),
                    const SizedBox(width: 8),
                    _miniMetric(
                      p,
                      '24h Volume',
                      fmtCompactUsd(pair.volume.h24, decimals: 1),
                    ),
                    const SizedBox(width: 8),
                    _miniMetric(
                      p,
                      'Liquidity',
                      fmtCompactUsd(pair.liquidity, decimals: 1),
                    ),
                  ],
                ),
              ),
              iconBox(
                Flaticons.bell,
                () => showPriceAlertDialog(context, pair),
                color: AppColors.amber,
              ),
              iconBox(Flaticons.candles, () {
                final ok = context.read<MarketProvider>().addMultichart(
                  pair.key,
                );
                showToast(
                  context,
                  ok
                      ? 'Added ${pair.pairLabel} to Multicharts'
                      : 'Multicharts full (max 4)',
                );
              }),
              iconBox(
                fav ? Flaticons.starFilled : Flaticons.star,
                () => context.read<PortfolioProvider>().toggleWatch(pair.key),
                color: fav ? AppColors.amber : p.textMuted,
              ),
              iconBox(Flaticons.copy, () {
                Clipboard.setData(ClipboardData(text: pair.base.address));
                showToast(context, 'Copied ${shortHex(pair.base.address)}');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(AppPalette p, String label, String val, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9.5, color: p.textMuted),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              val,
              style: numStyle(fontSize: 11, color: color ?? p.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickSectionSwitcher(AppPalette p) {
    final btns = [
      (0, 'Chart', _chartKey, AppColors.primary),
      (1, 'Buy / Sell', _orderKey, AppColors.green),
      (2, 'Pool Info', _poolInfoKey, AppColors.primaryLight),
      (3, 'Txns', _txnsKey, AppColors.blue),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < btns.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            Expanded(
              child: GestureDetector(
                onTap: () => _jumpTo(btns[i].$1, btns[i].$3),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    gradient: quickSection == btns[i].$1 && i == 0
                        ? AppColors.primaryGradient
                        : null,
                    color: quickSection == btns[i].$1 && i != 0
                        ? btns[i].$4.withValues(alpha: 0.2)
                        : (quickSection == btns[i].$1 ? null : p.field),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: quickSection == btns[i].$1
                          ? btns[i].$4.withValues(alpha: 0.7)
                          : p.border,
                    ),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          btns[i].$2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: quickSection == btns[i].$1
                                ? (i == 0 ? Colors.white : btns[i].$4)
                                : p.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chartSectionCard(AppPalette p, MarketProvider market, DexPair pair) {
    final candles = market.activeCandles;
    final trades = market.activeTrades;
    final tf = market.activeTimeframe;
    final last = candles.isNotEmpty ? candles.last : null;

    return Container(
      key: _chartKey,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        GestureDetector(
                          onTap: () => setState(() => chartSubTab = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: chartSubTab == i
                                  ? AppColors.primaryGradient
                                  : null,
                              color: chartSubTab == i ? null : p.field,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: chartSubTab == i
                                    ? AppColors.primary
                                    : p.border,
                              ),
                            ),
                            child: Text(
                              const ['Chart', 'Info', 'Trading Data'][i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: chartSubTab == i
                                    ? Colors.white
                                    : p.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '● LIVE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          if (chartSubTab == 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final t in const [
                          '1m',
                          '5m',
                          '15m',
                          '1h',
                          '4h',
                          '1d',
                        ])
                          GestureDetector(
                            onTap: () =>
                                context.read<MarketProvider>().setTimeframe(t),
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: t == tf
                                    ? AppColors.primaryGradient
                                    : null,
                                color: t == tf ? null : p.field,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: t == tf ? Colors.white : p.textMuted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => lineMode = !lineMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      lineMode ? 'Line' : 'Candles',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => showMa = !showMa),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: showMa
                          ? AppColors.amber.withValues(alpha: 0.16)
                          : p.field,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: showMa ? AppColors.amber : p.border,
                      ),
                    ),
                    child: Text(
                      'MA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: showMa ? AppColors.amber : p.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (last != null) ...[
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      '${pair.pairLabel} · ${tf.toUpperCase()}  ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: p.textSecondary,
                      ),
                    ),
                    _ohlcChip('O', fmtDexPrice(last.open), AppColors.green),
                    _ohlcChip('H', fmtDexPrice(last.high), AppColors.green),
                    _ohlcChip('L', fmtDexPrice(last.low), AppColors.red),
                    _ohlcChip('C', fmtDexPrice(last.close), AppColors.green),
                    _ohlcChip(
                      'Vol',
                      fmtCompactUsd(last.volume, decimals: 1),
                      p.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 8),
          SizedBox(
            height: 185,
            child: chartSubTab == 0
                ? CandleChart(
                    candles: candles,
                    twoMa: showMa,
                    lineMode: lineMode,
                  )
                : chartSubTab == 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _metaLine(
                        p,
                        'Base Token',
                        '${pair.base.name} (${pair.base.symbol})',
                      ),
                      _metaLine(
                        p,
                        'Quote Token',
                        '${pair.quote.name} (${pair.quote.symbol})',
                      ),
                      _metaLine(p, 'DEX Protocol', pair.dex.toUpperCase()),
                      _metaLine(
                        p,
                        'Pooled ${pair.base.symbol}',
                        fmtCompactNum(pair.pooledBase),
                      ),
                      _metaLine(
                        p,
                        'Pooled ${pair.quote.symbol}',
                        fmtCompactNum(pair.pooledQuote),
                      ),
                      _metaLine(
                        p,
                        'Market Cap / FDV',
                        fmtCompactUsd(pair.displayMcap, decimals: 1),
                      ),
                    ],
                  )
                : DepthChart(
                    midPrice: pair.price,
                    trades: trades,
                    liquidity: pair.liquidity,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _ohlcChip(String k, String v, Color c) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$k ',
            style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
          ),
          TextSpan(
            text: v,
            style: numStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _transactionsAndBookCard(
    AppPalette p,
    DexPair pair,
    List<DexTrade> trades,
    PortfolioProvider portfolio,
    MarketProvider market,
  ) {
    final openOrders = portfolio.orders
        .where((o) => o.status == 'Open')
        .toList();
    final tabs = [
      'Live Transactions',
      'Order Book',
      'Open Orders (${openOrders.length})',
      'Order History',
      'Top Traders',
      'Wallet & Holdings',
    ];

    final cleanMaker = makerFilter?.toLowerCase();
    final filteredTrades = trades.where((t) {
      if (txnFilter == 1 && !t.isBuy) return false;
      if (txnFilter == 2 && t.isBuy) return false;
      if (cleanMaker != null && t.maker.toLowerCase() != cleanMaker) {
        return false;
      }
      return true;
    }).toList();

    final visibleTrades = showAllTxns
        ? filteredTrades
        : filteredTrades.take(25).toList();

    return Container(
      key: _txnsKey,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < tabs.length; i++)
                GestureDetector(
                  onTap: () => setState(() => bottomTab = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: bottomTab == i
                          ? AppColors.primaryGradient
                          : null,
                      color: bottomTab == i ? null : p.field,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: bottomTab == i ? AppColors.primary : p.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tabs[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: bottomTab == i
                                ? Colors.white
                                : p.textSecondary,
                          ),
                        ),
                        if (i == 0) ...[
                          const SizedBox(width: 5),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'live',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          if (bottomTab == 0) ...[
            Row(
              children: [
                for (var i = 0; i < 3; i++)
                  GestureDetector(
                    onTap: () => setState(() => txnFilter = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: txnFilter == i
                            ? AppColors.primaryGradient
                            : null,
                        color: txnFilter == i ? null : p.field,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        const ['All', 'Buys', 'Sells'][i],
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: txnFilter == i
                              ? Colors.white
                              : (i == 1
                                    ? AppColors.green
                                    : (i == 2
                                          ? AppColors.red
                                          : p.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                if (makerFilter != null)
                  GestureDetector(
                    onTap: () => setState(() => makerFilter = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Trader: ${makerFilter!.length > 6 ? makerFilter!.substring(makerFilter!.length - 6) : makerFilter!} ✕',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  '${filteredTrades.length} txns',
                  style: numStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (filteredTrades.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Waiting for live on-chain swaps…',
                    style: TextStyle(fontSize: 11.5, color: p.textMuted),
                  ),
                ),
              )
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 650,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            _txHdr('DATE', 82, p),
                            _txHdr('TYPE', 62, p),
                            _txHdr('USD', 74, p, right: true),
                            _txHdr(pair.base.symbol, 88, p, right: true),
                            _txHdr(pair.quote.symbol, 88, p, right: true),
                            _txHdr('PRICE', 84, p, right: true),
                            _txHdr('TRADER', 86, p, right: true),
                            _txHdr('TXN', 70, p, right: true),
                          ],
                        ),
                      ),
                      Divider(color: p.border, height: 1),
                      for (final t in visibleTrades) ...[
                        _buildTradeRow(p, pair, t),
                        Divider(color: p.border, height: 1),
                      ],
                    ],
                  ),
                ),
              ),
              if (filteredTrades.length > 25) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => showAllTxns = !showAllTxns),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: p.field,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.border),
                    ),
                    child: Center(
                      child: Text(
                        showAllTxns
                            ? 'Show compact view (25)'
                            : 'Show all ${filteredTrades.length} live txns',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ] else if (bottomTab == 1)
            _dynamicOrderBook(p, pair, trades)
          else if (bottomTab == 2 || bottomTab == 3)
            _ordersTabList(
              p,
              bottomTab == 2 ? openOrders : portfolio.orders,
              bottomTab == 2 ? 'No open orders' : 'No order history yet',
            )
          else if (bottomTab == 4)
            _topTradersTab(p, trades)
          else
            _walletHoldingsTab(p, pair, portfolio, market),
        ],
      ),
    );
  }

  Widget _txHdr(String txt, double w, AppPalette p, {bool right = false}) =>
      SizedBox(
        width: w,
        child: Text(
          txt,
          textAlign: right ? TextAlign.right : TextAlign.left,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: p.textMuted,
          ),
        ),
      );

  Widget _buildTradeRow(AppPalette p, DexPair pair, DexTrade t) {
    final c = t.isBuy ? AppColors.green : AppColors.red;
    final ba = t.isBuy
        ? (t.amountTo > 0
              ? t.amountTo
              : (pair.price > 0 ? t.usd / pair.price : 0.0))
        : (t.amountFrom > 0
              ? t.amountFrom
              : (pair.price > 0 ? t.usd / pair.price : 0.0));
    final qa = t.isBuy
        ? (t.amountFrom > 0 ? t.amountFrom : t.usd)
        : (t.amountTo > 0 ? t.amountTo : t.usd);
    final usdStr = t.usd >= 1000
        ? fmtCompactUsd(t.usd).replaceFirst('\$', '')
        : t.usd.toStringAsFixed(2);
    final traderTag = t.maker.length >= 6
        ? t.maker.substring(t.maker.length - 6)
        : (t.maker.isNotEmpty ? t.maker : '—');
    final txTag = t.tx.isNotEmpty ? shortHex(t.tx) : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              '${fmtAgo(t.timeMs)} ago',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: p.textSecondary),
            ),
          ),
          SizedBox(
            width: 62,
            child: Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      t.isBuy ? '↑' : '↓',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: c,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  t.isBuy ? 'Buy' : 'Sell',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 74,
            child: Text(
              usdStr,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: numStyle(fontSize: 11, color: c),
            ),
          ),
          SizedBox(
            width: 88,
            child: Text(
              _fmtTxAmt(ba),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: numStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ),
          SizedBox(
            width: 88,
            child: Text(
              _fmtTxAmt(qa),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: numStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ),
          SizedBox(
            width: 84,
            child: Text(
              fmtDexPrice(t.price > 0 ? t.price : pair.price),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: numStyle(fontSize: 10.5, color: c),
            ),
          ),
          SizedBox(
            width: 86,
            child: GestureDetector(
              onTap: t.maker.isEmpty
                  ? null
                  : () => setState(() {
                      makerFilter = makerFilter == t.maker ? null : t.maker;
                    }),
              child: Text(
                traderTag,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: numStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: t.maker.isNotEmpty
                      ? AppColors.primaryLight
                      : p.textMuted,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: GestureDetector(
              onTap: t.tx.isEmpty
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: t.tx));
                      showToast(context, 'Copied tx ${shortHex(t.tx)}');
                    },
              child: Text(
                txTag,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: numStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: p.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dynamic Top Traders leaderboard aggregated from live swaps matching pair.blade.php.
  Widget _topTradersTab(AppPalette p, List<DexTrade> trades) {
    if (trades.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No recent swaps to rank traders yet.',
            style: TextStyle(fontSize: 11.5, color: p.textMuted),
          ),
        ),
      );
    }

    final map =
        <
          String,
          ({String addr, int buys, int sells, double boughtUsd, double soldUsd})
        >{};
    for (final t in trades) {
      final addr = t.maker.isNotEmpty ? t.maker : '?';
      final prev =
          map[addr] ??
          (addr: addr, buys: 0, sells: 0, boughtUsd: 0.0, soldUsd: 0.0);
      map[addr] = (
        addr: addr,
        buys: prev.buys + (t.isBuy ? 1 : 0),
        sells: prev.sells + (t.isBuy ? 0 : 1),
        boughtUsd: prev.boughtUsd + (t.isBuy ? t.usd : 0.0),
        soldUsd: prev.soldUsd + (t.isBuy ? 0.0 : t.usd),
      );
    }

    final ranked = map.values.toList()
      ..sort(
        (a, b) => (b.boughtUsd + b.soldUsd).compareTo(a.boughtUsd + a.soldUsd),
      );
    final top = ranked.take(25).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ranked from the last ${trades.length} swaps · Tap trader to filter txns',
          style: TextStyle(fontSize: 10.5, color: p.textMuted),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 540,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      _txHdr('#', 28, p),
                      _txHdr('TRADER', 110, p),
                      _txHdr('BUYS', 54, p, right: true),
                      _txHdr('SELLS', 54, p, right: true),
                      _txHdr('BOUGHT', 94, p, right: true),
                      _txHdr('SOLD', 94, p, right: true),
                      _txHdr('NET', 98, p, right: true),
                    ],
                  ),
                ),
                Divider(color: p.border, height: 1),
                for (var i = 0; i < top.length; i++) ...[
                  InkWell(
                    onTap: () {
                      if (top[i].addr == '?') return;
                      setState(() {
                        makerFilter = top[i].addr;
                        bottomTab = 0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${i + 1}',
                              style: numStyle(
                                fontSize: 10.5,
                                color: p.textMuted,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            child: Text(
                              shortHex(top[i].addr),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: numStyle(
                                fontSize: 11,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 54,
                            child: Text(
                              '${top[i].buys}',
                              textAlign: TextAlign.right,
                              style: numStyle(
                                fontSize: 11,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 54,
                            child: Text(
                              '${top[i].sells}',
                              textAlign: TextAlign.right,
                              style: numStyle(
                                fontSize: 11,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 94,
                            child: Text(
                              fmtCompactUsd(top[i].boughtUsd),
                              textAlign: TextAlign.right,
                              style: numStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: p.text,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 94,
                            child: Text(
                              fmtCompactUsd(top[i].soldUsd),
                              textAlign: TextAlign.right,
                              style: numStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: p.text,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 98,
                            child: Builder(
                              builder: (_) {
                                final net = top[i].boughtUsd - top[i].soldUsd;
                                final pos = net >= 0;
                                return Text(
                                  '${pos ? '+' : '-'}${fmtCompactUsd(net.abs())}',
                                  textAlign: TextAlign.right,
                                  style: numStyle(
                                    fontSize: 11,
                                    color: pos
                                        ? AppColors.green
                                        : AppColors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: p.border, height: 1),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Exact AMM constant-product Order Book depth from live price & pool liquidity (pair.blade.php:683-704).
  Widget _dynamicOrderBook(AppPalette p, DexPair pair, List<DexTrade> trades) {
    final p0 = pair.price;
    final liq = pair.liquidity;
    if (p0 <= 0 || liq <= 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No live pool depth available',
            style: TextStyle(fontSize: 11.5, color: p.textMuted),
          ),
        ),
      );
    }

    final x0 = (liq / 2) / p0;
    const step = 0.0008;
    const nLevels = 8;

    final asks = <({double price, double amt, double total})>[];
    final bids = <({double price, double amt, double total})>[];
    for (var i = 1; i <= nLevels; i++) {
      final apa = p0 * (1 + step * (i - 1));
      final apb = p0 * (1 + step * i);
      final aAmt = (x0 * (math.sqrt(p0 / apa) - math.sqrt(p0 / apb))).abs();
      asks.add((price: apb, amt: aAmt, total: aAmt * apb));

      final bpa = p0 * (1 - step * (i - 1));
      final bpb = p0 * (1 - step * i);
      final bAmt = (x0 * (math.sqrt(p0 / bpb) - math.sqrt(p0 / bpa))).abs();
      bids.add((price: bpb, amt: bAmt, total: bAmt * bpb));
    }

    final maxAmt = math.max(
      asks.map((e) => e.amt).reduce(math.max),
      bids.map((e) => e.amt).reduce(math.max),
    );
    final up = pair.change.h24 >= 0;
    final chColor = up ? AppColors.green : AppColors.red;

    Widget bookRow(({double price, double amt, double total}) lvl, Color c) {
      final fill = maxAmt > 0 ? (lvl.amt / maxAmt).clamp(0.06, 1.0) : 0.1;
      return GestureDetector(
        onTap: () => setState(() {
          priceCtrl.text = _fmtInput(lvl.price);
          _ordError = null;
          final curAmt =
              double.tryParse(amtCtrl.text.replaceAll(',', '').trim()) ?? 0;
          if (curAmt > 0) {
            totalCtrl.text = _fmtTotInput(lvl.price * curAmt);
          }
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: fill,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      fmtDexPrice(lvl.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: numStyle(fontSize: 11, color: c),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      fmtCompactNum(lvl.amt),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: numStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      fmtCompactUsd(lvl.total),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: numStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: p.field,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Mid Market Price:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: p.textMuted),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fmtDexPrice(p0),
                          style: numStyle(fontSize: 13, color: chColor),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${up ? '▲' : '▼'} ${pair.change.h24.abs().toStringAsFixed(2)}%',
                          style: numStyle(fontSize: 10.5, color: chColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                'Price (USD)',
                style: TextStyle(fontSize: 10, color: p.textMuted),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Amt (${pair.base.symbol})',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 10, color: p.textMuted),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Total (USD)',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 10, color: p.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (var i = asks.length - 1; i >= 0; i--)
          bookRow(asks[i], AppColors.red),
        Divider(color: p.border, height: 10),
        for (var i = 0; i < bids.length; i++) bookRow(bids[i], AppColors.green),
      ],
    );
  }

  Widget _ordersTabList(AppPalette p, List<DexOrder> orders, String emptyMsg) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(
            emptyMsg,
            style: TextStyle(fontSize: 11.5, color: p.textMuted),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final o in orders.take(8))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${o.isBuy ? 'Buy' : 'Sell'} ${o.symbol}/${o.quoteSymbol} (${o.orderType})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: o.isBuy ? AppColors.green : AppColors.red,
                    ),
                  ),
                ),
                Text(
                  '${fmtCompactNum(o.amount)} @ ${fmtDexPrice(o.price)}',
                  style: numStyle(fontSize: 11, color: p.text),
                ),
                if (o.status == 'Open') ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () =>
                        context.read<PortfolioProvider>().cancelOrder(o.id),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _walletHoldingsTab(
    AppPalette p,
    DexPair pair,
    PortfolioProvider portfolio,
    MarketProvider market,
  ) {
    final wallet = context.watch<WalletProvider>().activeWallet;
    if (wallet == null) {
      return Center(
        child: TextButton(
          onPressed: () => showWalletSwitcherSheet(context),
          child: const Text('Connect Wallet to View Live On-Chain Balances →'),
        ),
      );
    }
    final ci = chainInfoFor(pair.chain);
    final liveBal = portfolio.pairBalancesFor(wallet.ethAddress, pair.key);
    final quoteUsd = _quoteUsdPrice(pair, market);
    final nativeUsd = market.nativeUsdPrice(ci.symbol);
    final rpcChains = kDexChains.values.where((c) => c.rpcUrl != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: p.field,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: p.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${pair.pairLabel} (${ci.name})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: portfolio.isLoadingPairBalances
                        ? null
                        : () => context
                              .read<PortfolioProvider>()
                              .refreshPairBalances(
                                walletAddress: wallet.ethAddress,
                                pair: pair,
                              ),
                    child: Text(
                      portfolio.isLoadingPairBalances
                          ? 'Refreshing…'
                          : 'Refresh',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _metaLine(
                p,
                '${pair.quote.symbol} Balance',
                '${liveBal.quoteBalance.toStringAsFixed(4)} ${pair.quote.symbol} (${fmtCompactUsd(liveBal.quoteBalance * quoteUsd)})',
              ),
              _metaLine(
                p,
                '${pair.base.symbol} Holding',
                '${fmtCompactNum(liveBal.baseBalance)} ${pair.base.symbol} (${fmtCompactUsd(liveBal.baseBalance * pair.price)})',
              ),
              _metaLine(
                p,
                'Native Gas (${ci.symbol})',
                '${liveBal.nativeBalance.toStringAsFixed(5)} ${ci.symbol} (${fmtCompactUsd(liveBal.nativeBalance * nativeUsd)})',
              ),
              _metaLine(
                p,
                'Router Allowance (${buy ? pair.quote.symbol : pair.base.symbol})',
                (buy
                        ? liveBal.hasUnlimitedQuoteAllowance
                        : liveBal.hasUnlimitedBaseAllowance)
                    ? 'Unlimited ✓'
                    : ((buy ? liveBal.quoteAllowance : liveBal.baseAllowance) >
                              0
                          ? '${fmtCompactNum(buy ? liveBal.quoteAllowance : liveBal.baseAllowance)} ✓'
                          : 'Approval needed on swap'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (final c in rpcChains)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                ChainBadge(c.slug, size: 16),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    c.name,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ),
                Text(
                  '${(portfolio.onChainBalances[c.slug] ?? 0).toStringAsFixed(5)} ${c.symbol}',
                  style: numStyle(fontSize: 11.5, color: p.text),
                ),
                const SizedBox(width: 8),
                Text(
                  fmtCompactUsd(
                    (portfolio.onChainBalances[c.slug] ?? 0) *
                        market.nativeUsdPrice(c.symbol),
                  ),
                  style: numStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _applyPct(
    double pct,
    DexPair pair,
    PairWalletBalances liveBal,
    MarketProvider market,
    WalletAccount? wallet,
  ) {
    final ci = chainInfoFor(pair.chain);
    if (wallet == null) {
      setState(() {
        sliderPct = 0;
        _ordError = '✕ Please connect your Web3 wallet first to trade.';
      });
      showWalletSwitcherSheet(context);
      return;
    }

    final effPrice = (orderType == 1 || pair.price <= 0)
        ? pair.price
        : (double.tryParse(priceCtrl.text.replaceAll(',', '').trim()) ??
              pair.price);

    if (buy) {
      final quoteUsd = _quoteUsdPrice(pair, market);
      final nativeUsd = market.nativeUsdPrice(ci.symbol);
      final activeSym = payWithQuote ? pair.quote.symbol : ci.symbol;
      final otherSym = payWithQuote ? ci.symbol : pair.quote.symbol;
      final spendUsd = payWithQuote
          ? liveBal.quoteBalance * quoteUsd
          : liveBal.nativeBalance * nativeUsd;
      if (spendUsd <= 0) {
        setState(() {
          sliderPct = 0;
          amtCtrl.clear();
          totalCtrl.clear();
          _ordError =
              '✕ Insufficient $activeSym Balance in Wallet (0 $activeSym).\nSwitch to $otherSym or fund your wallet.';
        });
        return;
      }
      final p = effPrice > 0 ? effPrice : pair.price;
      if (p <= 0) return;
      final amt = (spendUsd * (pct / 100) * 0.998) / p;
      setState(() {
        sliderPct = pct;
        _ordError = null;
        if (pct <= 0) {
          amtCtrl.clear();
          totalCtrl.clear();
        } else {
          amtCtrl.text = _fmtAmtInput(amt);
          totalCtrl.text = _fmtTotInput(amt * p);
        }
      });
    } else {
      if (liveBal.baseBalance <= 0) {
        setState(() {
          sliderPct = 0;
          amtCtrl.clear();
          totalCtrl.clear();
          _ordError =
              '✕ Insufficient ${pair.base.symbol} Balance: Your wallet holds 0 ${pair.base.symbol}.';
        });
        return;
      }
      final amt = liveBal.baseBalance * (pct / 100);
      final p = effPrice > 0 ? effPrice : pair.price;
      setState(() {
        sliderPct = pct;
        _ordError = null;
        if (pct <= 0) {
          amtCtrl.clear();
          totalCtrl.clear();
        } else {
          amtCtrl.text = _fmtAmtInput(amt);
          totalCtrl.text = p > 0 ? _fmtTotInput(amt * p) : '';
        }
      });
    }
  }

  Future<void> _submitOrder(
    DexPair pair,
    MarketProvider market,
    WalletAccount? wallet,
  ) async {
    final ci = chainInfoFor(pair.chain);
    if (wallet == null) {
      setState(() {
        _ordError =
            '✕ Please connect your Web3 wallet first to place an order.';
      });
      showWalletSwitcherSheet(context);
      return;
    }

    final effPrice = (orderType == 1
        ? pair.price
        : double.tryParse(priceCtrl.text.replaceAll(',', '').trim()) ??
              pair.price);
    final amt = double.tryParse(amtCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final stopPrice =
        double.tryParse(stopCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

    if (effPrice <= 0) {
      setState(() => _ordError = '✕ Enter a valid price greater than 0.');
      return;
    }
    if (amt <= 0) {
      setState(() => _ordError = '✕ Enter a valid amount greater than 0.');
      return;
    }
    if (orderType == 2 && stopPrice <= 0) {
      setState(
        () => _ordError = '✕ Enter a valid Trigger Stop Price for Stop-Limit.',
      );
      return;
    }

    setState(() {
      _ordError = null;
      _submittingOrder = true;
      _ordStep = 'Step 1/3: Checking live wallet balance on ${ci.name}…';
    });

    final liveBal = await context.read<PortfolioProvider>().refreshPairBalances(
      walletAddress: wallet.ethAddress,
      pair: pair,
    );
    if (!mounted) return;

    final totalUsd = effPrice * amt;
    final quoteUsd = _quoteUsdPrice(pair, market);
    final nativeUsd = market.nativeUsdPrice(ci.symbol);

    if (buy) {
      var useQuote = payWithQuote;
      final reqQuoteIfQuote = quoteUsd > 0 ? totalUsd / quoteUsd : totalUsd;
      final reqNativeIfNative = nativeUsd > 0
          ? totalUsd / nativeUsd
          : double.infinity;

      if (useQuote &&
          liveBal.quoteBalance < reqQuoteIfQuote &&
          nativeUsd > 0 &&
          liveBal.nativeBalance >= reqNativeIfNative) {
        useQuote = false;
        setState(() => payWithQuote = false);
        showToast(
          context,
          'Switched payment to ${ci.symbol} (sufficient balance found)',
        );
      }

      if (useQuote) {
        if (liveBal.quoteBalance < reqQuoteIfQuote) {
          setState(() {
            _submittingOrder = false;
            _ordStep = null;
            _ordError =
                '✕ Insufficient ${pair.quote.symbol} Balance in Wallet!\n'
                'Required: ${reqQuoteIfQuote.toStringAsFixed(4)} ${pair.quote.symbol} (${fmtCompactUsd(totalUsd)})\n'
                'Your Wallet: ${liveBal.quoteBalance.toStringAsFixed(4)} ${pair.quote.symbol} & '
                '${liveBal.nativeBalance.toStringAsFixed(5)} ${ci.symbol} (${fmtCompactUsd(liveBal.nativeBalance * nativeUsd)}).';
          });
          return;
        }
      } else {
        if (liveBal.nativeBalance < reqNativeIfNative) {
          setState(() {
            _submittingOrder = false;
            _ordStep = null;
            _ordError =
                '✕ Insufficient ${ci.symbol} Balance in Wallet!\n'
                'Required: ${reqNativeIfNative.isFinite ? reqNativeIfNative.toStringAsFixed(5) : '—'} ${ci.symbol} (${fmtCompactUsd(totalUsd)})\n'
                'Your Wallet: ${liveBal.nativeBalance.toStringAsFixed(5)} ${ci.symbol} '
                '(${fmtCompactUsd(liveBal.nativeBalance * nativeUsd)}) & '
                '${liveBal.quoteBalance.toStringAsFixed(4)} ${pair.quote.symbol}.';
          });
          return;
        }
      }
    } else {
      if (liveBal.baseBalance < amt) {
        setState(() {
          _submittingOrder = false;
          _ordStep = null;
          _ordError =
              '✕ Insufficient ${pair.base.symbol} Balance in Wallet!\n'
              'Required to Sell: ${fmtCompactNum(amt)} ${pair.base.symbol} (${fmtCompactUsd(totalUsd)})\n'
              'Your Wallet Holding: ${fmtCompactNum(liveBal.baseBalance)} ${pair.base.symbol}.';
        });
        return;
      }
    }

    final typeLabel = const ['Limit', 'Market', 'Stop-Limit'][orderType];
    context.read<PortfolioProvider>().placeOrder(
      pair: pair,
      isBuy: buy,
      orderType: typeLabel,
      price: effPrice,
      amount: amt,
    );
    showToast(
      context,
      '${buy ? 'Buy' : 'Sell'} $typeLabel placed: ${fmtCompactNum(amt)} ${pair.base.symbol}',
    );
    amtCtrl.clear();
    totalCtrl.clear();
    setState(() {
      sliderPct = 0;
      _ordStep = null;
      _ordError = null;
      _submittingOrder = false;
    });
  }

  Widget _orderFormCard(
    AppPalette p,
    DexPair pair,
    PortfolioProvider portfolio,
    MarketProvider market,
  ) {
    final ci = chainInfoFor(pair.chain);
    final wallet = context.watch<WalletProvider>().activeWallet;
    final liveBal = portfolio.pairBalancesFor(wallet?.ethAddress, pair.key);
    final quoteUsd = _quoteUsdPrice(pair, market);
    final nativeUsd = market.nativeUsdPrice(ci.symbol);
    final effPrice = (orderType == 1
        ? pair.price
        : double.tryParse(priceCtrl.text.replaceAll(',', '').trim()) ??
              pair.price);

    final quoteBalUsd = liveBal.quoteBalance * quoteUsd;
    final nativeBalUsd = liveBal.nativeBalance * nativeUsd;
    final spendUsd = payWithQuote ? quoteBalUsd : nativeBalUsd;
    final maxBase = buy
        ? (effPrice > 0 ? spendUsd / effPrice : 0.0)
        : liveBal.baseBalance;
    final maxUsd = buy ? spendUsd : (liveBal.baseBalance * effPrice);

    final allowSym = buy ? pair.quote.symbol : pair.base.symbol;
    final allowAmt = buy ? liveBal.quoteAllowance : liveBal.baseAllowance;
    final allowUnlimited = buy
        ? liveBal.hasUnlimitedQuoteAllowance
        : liveBal.hasUnlimitedBaseAllowance;
    final String allowText;
    if (wallet == null) {
      allowText = 'Wallet not connected';
    } else if (buy && !payWithQuote) {
      allowText = 'Native Gas (No Approval)';
    } else if (allowUnlimited) {
      allowText = 'Unlimited ✓';
    } else if (allowAmt > 0) {
      allowText = '${fmtCompactNum(allowAmt)} $allowSym ✓';
    } else {
      allowText = 'Approval needed on swap';
    }

    return Container(
      key: _orderKey,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: p.field,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [_sideBtn(p, 'Buy', true), _sideBtn(p, 'Sell', false)],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      orderType = i;
                      _ordError = null;
                      _ordStep = null;
                      if (i == 1) {
                        priceCtrl.text = _fmtInput(pair.price);
                        final a =
                            double.tryParse(
                              amtCtrl.text.replaceAll(',', '').trim(),
                            ) ??
                            0;
                        if (a > 0 && pair.price > 0) {
                          totalCtrl.text = _fmtTotInput(pair.price * a);
                        }
                      } else if (i == 2 && stopCtrl.text.trim().isEmpty) {
                        stopCtrl.text = _fmtInput(pair.price);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: orderType == i
                            ? AppColors.primaryGradient
                            : null,
                        color: orderType == i ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            const ['Limit', 'Market', 'Stop-Limit'][i],
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: orderType == i
                                  ? Colors.white
                                  : p.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (orderType == 2) ...[
            const FieldLabel('Trigger Stop Price'),
            TextField(
              controller: stopCtrl,
              textAlign: TextAlign.right,
              onChanged: (_) => setState(() => _ordError = null),
              style: numStyle(fontSize: 13, color: p.text),
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: ' USD ',
                suffixStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.textMuted,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
          const FieldLabel('Price'),
          TextField(
            controller: priceCtrl,
            enabled: orderType != 1,
            textAlign: TextAlign.right,
            onChanged: (v) {
              final pr = double.tryParse(v.replaceAll(',', '').trim()) ?? 0;
              final am =
                  double.tryParse(amtCtrl.text.replaceAll(',', '').trim()) ?? 0;
              totalCtrl.text = (pr > 0 && am > 0) ? _fmtTotInput(pr * am) : '';
              setState(() => _ordError = null);
            },
            style: numStyle(fontSize: 13, color: p.text),
            decoration: InputDecoration(
              hintText: orderType == 1 ? 'Market Price' : '0.00',
              suffixText: ' USD ',
              suffixStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: p.textMuted,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const FieldLabel('Amount'),
          TextField(
            key: const ValueKey('trade_amount_field'),
            controller: amtCtrl,
            textAlign: TextAlign.right,
            onChanged: (v) {
              final am = double.tryParse(v.replaceAll(',', '').trim()) ?? 0;
              final tot = effPrice > 0 && am > 0 ? effPrice * am : 0.0;
              totalCtrl.text = tot > 0 ? _fmtTotInput(tot) : '';
              setState(() => _ordError = null);
            },
            style: numStyle(fontSize: 13, color: p.text),
            decoration: InputDecoration(
              hintText: '0.00',
              suffixText: ' ${pair.base.symbol} ',
              suffixStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: p.textMuted,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: sliderPct,
              min: 0,
              max: 100,
              divisions: 4,
              activeColor: AppColors.primaryLight,
              inactiveColor: p.border,
              onChanged: (v) => _applyPct(v, pair, liveBal, market, wallet),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final pct in const [0, 25, 50, 75, 100])
                GestureDetector(
                  onTap: () =>
                      _applyPct(pct.toDouble(), pair, liveBal, market, wallet),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: sliderPct.round() == pct
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: sliderPct.round() == pct
                            ? AppColors.primaryLight
                            : p.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const FieldLabel('Total'),
          TextField(
            controller: totalCtrl,
            textAlign: TextAlign.right,
            onChanged: (v) {
              final tot = double.tryParse(v.replaceAll(',', '').trim()) ?? 0;
              amtCtrl.text = (tot > 0 && effPrice > 0)
                  ? _fmtAmtInput(tot / effPrice)
                  : '';
              setState(() => _ordError = null);
            },
            style: numStyle(fontSize: 13, color: p.text),
            decoration: InputDecoration(
              hintText: '0.00',
              suffixText: ' USD ',
              suffixStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: p.textMuted,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pay / Settlement Asset:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: p.textMuted),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  payWithQuote = true;
                  _ordError = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: payWithQuote ? AppColors.primaryGradient : null,
                    color: payWithQuote ? null : p.field,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: payWithQuote ? AppColors.primary : p.border,
                    ),
                  ),
                  child: Text(
                    pair.quote.symbol,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: payWithQuote ? Colors.white : p.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => setState(() {
                  payWithQuote = false;
                  _ordError = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: !payWithQuote ? AppColors.primaryGradient : null,
                    color: !payWithQuote ? null : p.field,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: !payWithQuote ? AppColors.primary : p.border,
                    ),
                  ),
                  child: Text(
                    ci.symbol,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: !payWithQuote ? Colors.white : p.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_ordError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.red.withValues(alpha: 0.55),
                ),
              ),
              child: Text(
                _ordError!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  color: p.isDark
                      ? const Color(0xFFFF6B7A)
                      : const Color(0xFFC81E2B),
                ),
              ),
            ),
          ],
          if (_ordStep != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _ordStep!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: p.isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buy ? AppColors.green : AppColors.red,
                foregroundColor: buy ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              onPressed: _submittingOrder
                  ? null
                  : () => _submitOrder(pair, market, wallet),
              child: Text(
                _submittingOrder
                    ? 'Checking Wallet…'
                    : '${buy ? 'Buy' : 'Sell'} ${pair.base.symbol}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _metaLine(
            p,
            'Available (${pair.quote.symbol})',
            wallet == null
                ? '0.00 ${pair.quote.symbol} (Connect Wallet)'
                : '${liveBal.quoteBalance.toStringAsFixed(4)} ${pair.quote.symbol} (${fmtCompactUsd(quoteBalUsd)})',
          ),
          _metaLine(
            p,
            'Wallet ${ci.symbol}',
            wallet == null
                ? 'Not connected'
                : '${liveBal.nativeBalance.toStringAsFixed(5)} ${ci.symbol} (${fmtCompactUsd(nativeBalUsd)})',
          ),
          _metaLine(
            p,
            'Holding (${pair.base.symbol})',
            '${fmtCompactNum(liveBal.baseBalance)} ${pair.base.symbol}',
          ),
          _metaLine(p, 'Allowance ($allowSym)', allowText),
          _metaLine(
            p,
            'Max ${buy ? 'Buy' : 'Sell'}',
            '${fmtCompactNum(maxBase)} ${pair.base.symbol} (${fmtCompactUsd(maxUsd)})',
          ),
          _metaLine(p, 'Fee', '0.10%'),
          Row(
            children: [
              Expanded(
                child: Text(
                  wallet != null
                      ? 'Connected: ${wallet.shortEth}'
                      : 'Wallet not connected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: p.textMuted),
                ),
              ),
              GestureDetector(
                onTap: () => showWalletSwitcherSheet(context),
                child: Text(
                  wallet != null ? 'Switch Wallet →' : 'Connect Wallet →',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _poolInfoCard(AppPalette p, DexPair pair, List<DexTrade> trades) {
    final ci = chainInfoFor(pair.chain);
    final win = pair.txns.windowFor(poolWin);
    final buys = win.buys;
    final sells = win.sells;
    final tot = buys + sells;
    final ratio = tot > 0 ? buys / tot : 0.5;
    final winVol = pair.volume.forPeriod(poolWin);
    final buyVol = winVol * ratio;
    final sellVol = winVol * (1 - ratio);

    var liveBuyers = win.buyers;
    var liveSellers = win.sellers;
    if (win.makersTotal == 0) {
      if (trades.isNotEmpty) {
        final bSet = <String>{};
        final sSet = <String>{};
        for (final t in trades) {
          final id = t.maker.isNotEmpty ? t.maker : t.tx;
          if (t.isBuy) {
            bSet.add(id);
          } else {
            sSet.add(id);
          }
        }
        liveBuyers = bSet.length;
        liveSellers = sSet.length;
      } else if (pair.makers > 0) {
        liveBuyers = (pair.makers * ratio).round();
        liveSellers = math.max(0, pair.makers - liveBuyers);
      }
    }
    final makersTot = win.makersTotal > 0
        ? win.makersTotal
        : (pair.makers > 0 ? pair.makers : (liveBuyers + liveSellers));
    final makersRatio = (liveBuyers + liveSellers) > 0
        ? liveBuyers / (liveBuyers + liveSellers)
        : ratio;

    return Container(
      key: _poolInfoKey,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: pair.base.address));
              showToast(context, 'Copied ${pair.base.symbol} address');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pair.base.symbol,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: p.text,
                  ),
                ),
                const SizedBox(width: 4),
                const FIcon(
                  Flaticons.copy,
                  size: 13,
                  color: AppColors.primaryLight,
                ),
                Text(
                  ' / ${pair.quote.symbol}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: ci.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${ci.name} › ${pair.dex}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statBox(p, 'PRICE USD', fmtDexPrice(pair.price)),
              const SizedBox(width: 6),
              _statBox(
                p,
                'PRICE ${pair.quote.symbol}',
                '${fmtCompactNum(pair.priceNative > 0 ? pair.priceNative : pair.price)} ${pair.quote.symbol}',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _statBox(
                p,
                'LIQUIDITY',
                fmtCompactUsd(pair.liquidity, decimals: 1),
              ),
              const SizedBox(width: 6),
              _statBox(p, 'FDV', fmtCompactUsd(pair.fdv, decimals: 1)),
              const SizedBox(width: 6),
              _statBox(
                p,
                'MKT CAP',
                fmtCompactUsd(pair.displayMcap, decimals: 1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final w in const ['m5', 'h1', 'h6', 'h24']) ...[
                if (w != 'm5') const SizedBox(width: 5),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => poolWin = w),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: poolWin == w ? p.cardAlt : p.field,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: poolWin == w ? AppColors.primary : p.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            w == 'm5'
                                ? '5M'
                                : '${w.substring(1).toUpperCase()}H',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: p.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          ChangeText(pair.change.forPeriod(w), size: 10.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.field,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.border),
            ),
            child: Column(
              children: [
                _splitBarRow(
                  p,
                  title: 'TXNS',
                  totalText: fmtCompactNum(tot),
                  leftLabel: 'BUYS',
                  leftVal: fmtCompactNum(buys),
                  rightLabel: 'SELLS',
                  rightVal: fmtCompactNum(sells),
                  ratio: ratio,
                ),
                Divider(color: p.border, height: 14),
                _splitBarRow(
                  p,
                  title: 'VOLUME',
                  totalText: fmtCompactUsd(winVol, decimals: 1),
                  leftLabel: 'BUY VOL',
                  leftVal: fmtCompactUsd(buyVol, decimals: 1),
                  rightLabel: 'SELL VOL',
                  rightVal: fmtCompactUsd(sellVol, decimals: 1),
                  ratio: ratio,
                ),
                Divider(color: p.border, height: 14),
                _splitBarRow(
                  p,
                  title: 'MAKERS',
                  totalText: fmtCompactNum(makersTot),
                  leftLabel: 'BUYERS',
                  leftVal: fmtCompactNum(liveBuyers),
                  rightLabel: 'SELLERS',
                  rightVal: fmtCompactNum(liveSellers),
                  ratio: makersRatio,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TokenAvatar(
                symbol: pair.base.symbol,
                imageUrl: pair.base.image,
                fallbackColor: ci.color,
                size: 30,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pair.base.name.isNotEmpty ? pair.base.name : pair.base.symbol} (${pair.base.symbol})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    Text(
                      '${ci.name} Liquidity Pool · ${pair.dex.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _metaLine(p, 'Pair created', _fmtAge(pair.createdMs)),
          _metaLine(
            p,
            'Pooled ${pair.base.symbol}',
            '${fmtCompactNum(pair.pooledBase)}  (${fmtCompactUsd(pair.liquidity / 2, decimals: 1)})',
          ),
          _metaLine(
            p,
            'Pooled ${pair.quote.symbol}',
            '${fmtCompactNum(pair.pooledQuote)}  (${fmtCompactUsd(pair.liquidity / 2, decimals: 1)})',
          ),
          _copyAddrRow(p, 'Pair', pair.pair),
          _copyAddrRow(p, pair.base.symbol, pair.base.address),
          _copyAddrRow(p, pair.quote.symbol, pair.quote.address),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.field,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUICK CONVERTER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 7),
                _quickConvField(
                  p,
                  ctrl: qcBaseCtrl,
                  unit: pair.base.symbol,
                  onChanged: (v) {
                    final n = double.tryParse(v) ?? 0;
                    qcUsdCtrl.text = pair.price > 0
                        ? _fmtInput(n * pair.price)
                        : '0';
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Text(
                      '⇅',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _quickConvField(
                  p,
                  ctrl: qcUsdCtrl,
                  unit: 'USD / ${pair.quote.symbol}',
                  onChanged: (v) {
                    final n = double.tryParse(v) ?? 0;
                    qcBaseCtrl.text = pair.price > 0
                        ? (n / pair.price).toStringAsFixed(4)
                        : '0';
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GradientButton(
            label: 'Other pairs (${pair.base.symbol})',
            icon: Flaticons.search,
            outlined: true,
            height: 36,
            onPressed: () => showLivePairPickerSheet(
              context,
              (picked) => context.read<MarketProvider>().selectPair(picked),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickConvField(
    AppPalette p, {
    required TextEditingController ctrl,
    required String unit,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: onChanged,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: numStyle(fontSize: 13, color: p.text),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: p.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyAddrRow(AppPalette p, String label, String addr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 11.5, color: p.textMuted)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: addr));
              showToast(context, 'Copied ${shortHex(addr)}');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: p.field,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: p.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FIcon(
                    Flaticons.copy,
                    size: 11,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    shortHex(addr),
                    style: numStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _splitBarRow(
    AppPalette p, {
    required String title,
    required String totalText,
    required String leftLabel,
    required String leftVal,
    required String rightLabel,
    required String rightVal,
    required double ratio,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 9.5, color: p.textMuted)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  totalText,
                  style: numStyle(fontSize: 13, color: p.text),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$leftLabel $leftVal',
                        style: numStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$rightLabel $rightVal',
                        style: numStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 5,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (ratio * 100).round().clamp(1, 99),
                        child: Container(color: AppColors.green),
                      ),
                      Expanded(
                        flex: ((1 - ratio) * 100).round().clamp(1, 99),
                        child: Container(color: AppColors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox(AppPalette p, String label, String val) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      decoration: BoxDecoration(
        color: p.field,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9.5, color: p.textMuted),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(val, style: numStyle(fontSize: 12, color: p.text)),
          ),
        ],
      ),
    ),
  );

  Widget _metaLine(AppPalette p, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(k, style: TextStyle(fontSize: 11.5, color: p.textMuted)),
        const Spacer(),
        Flexible(
          child: Text(
            v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: numStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sideBtn(AppPalette p, String label, bool isBuy) {
    final sel = buy == isBuy;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          buy = isBuy;
          sliderPct = 0;
          _ordError = null;
          _ordStep = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel
                ? (isBuy ? AppColors.green : AppColors.red)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: sel
                    ? (isBuy ? Colors.black : Colors.white)
                    : p.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
