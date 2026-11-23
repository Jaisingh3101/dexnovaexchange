import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'create_wallet_screen.dart';
import 'dapp_browser_screen.dart';
import 'deposit_screen.dart';
import 'nft_gallery_screen.dart';
import 'security_screen.dart';
import 'send_receive_screen.dart';
import 'swap_bridge_screen.dart';
import 'token_manager_screen.dart';
import 'withdraw_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onTab;
  const HomeScreen({super.key, required this.onTab});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Coin pair = coins[1];
  String tf = '1h';
  int chartTab = 0;
  bool fav = false;
  late List<Candle> candles = candlesFor(pair.price, seed: 11);

  int bookTab = 0;
  bool buy = true;
  int orderType = 0;
  double slider = 0;
  late final priceCtrl = TextEditingController(text: fmtUsd(pair.price));
  final amtCtrl = TextEditingController();

  @override
  void dispose() {
    priceCtrl.dispose();
    amtCtrl.dispose();
    super.dispose();
  }

  void _selectPair(Coin c) => setState(() {
    pair = c;
    candles = candlesFor(c.price, seed: c.symbol.hashCode);
    priceCtrl.text = fmtUsd(c.price);
    amtCtrl.clear();
    slider = 0;
  });

  void _push(Widget w) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => w));

  BoxDecoration _box(AppPalette p, {double r = 12}) => BoxDecoration(
    color: p.card,
    borderRadius: BorderRadius.circular(r),
    border: Border.all(color: p.border),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
        children: [
          _header(p),
          const SizedBox(height: 8),
          _search(p),
          const SizedBox(height: 8),
          _quickActions(p),
          const SizedBox(height: 6),
          _web3Hub(p),
          const SizedBox(height: 8),
          _tickers(p),
          const SizedBox(height: 8),
          _chartCard(p),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _orderBook(p)),
                const SizedBox(width: 6),
                Expanded(child: _orderPanel(p)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _walletCard(p),
        ],
      ),
    );
  }

  // ---------------- header ----------------
  Widget _header(AppPalette p) {
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: FIcon(Flaticons.menu, size: 22, color: p.text),
        ),
        const DexNovaLogo(size: 34),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DexNova',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: p.text,
                ),
              ),
              Text(
                'Global Exchange',
                maxLines: 1,
                style: TextStyle(fontSize: 10.5, color: p.textMuted),
              ),
            ],
          ),
        ),
        const ThemeToggleButton(compact: true),
        const SizedBox(width: 4),
        Stack(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => showToast(context, 'No new notifications'),
              icon: FIcon(Flaticons.bell, size: 21, color: p.text),
            ),
            Positioned(
              right: 9,
              top: 8,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _push(const SecurityScreen()),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Center(
              child: FIcon(Flaticons.user, size: 17, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 2),
      ],
    );
  }

  Widget _search(AppPalette p) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: _box(p, r: 10),
      child: Row(
        children: [
          FIcon(Flaticons.search, size: 16, color: p.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: 12.5, color: p.text),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search coins, pairs or contracts...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- compact quick actions bar ----------------
  Widget _quickActions(AppPalette p) {
    final actions = [
      (
        Flaticons.deposit,
        'Deposit',
        AppColors.primary,
        () => _push(const DepositScreen()),
      ),
      (
        Flaticons.withdraw,
        'Withdraw',
        AppColors.blue,
        () => _push(const WithdrawScreen()),
      ),
      (
        Flaticons.send,
        'Send',
        AppColors.green,
        () => _push(const SendReceiveScreen(initialTab: 0)),
      ),
      (
        Flaticons.receive,
        'Receive',
        AppColors.amber,
        () => _push(const SendReceiveScreen(initialTab: 1)),
      ),
      (
        Flaticons.addWallet,
        'Create',
        AppColors.primaryLight,
        () => _push(const CreateWalletScreen(initialTab: 0)),
      ),
      (
        Flaticons.recoverWallet,
        'Recover',
        AppColors.red,
        () => _push(const CreateWalletScreen(initialTab: 1)),
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: _box(p, r: 12),
      child: Row(
        children: [
          for (final a in actions)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: a.$4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FBadgeIcon(
                      a.$1,
                      color: a.$3,
                      size: 30,
                      iconSize: 15,
                      radius: 8,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: p.textSecondary,
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

  // ---------------- tickers ----------------
  Widget _tickers(AppPalette p) {
    final list = [coins[1], coins[2], coins[4], coins[3]];
    const sparkColors = [
      AppColors.green,
      Color(0xFF3B82F6),
      Color(0xFF9D4DFF),
      AppColors.green,
    ];
    const sparks = [
      [1.0, 1.4, 1.2, 1.9, 1.6, 2.4, 2.1, 3.0, 2.8, 3.6],
      [1.0, 1.3, 1.1, 1.7, 1.5, 2.2, 2.0, 2.7, 3.0, 3.5],
      [1.0, 1.2, 1.5, 1.3, 2.0, 1.8, 2.6, 2.4, 3.2, 3.8],
      [1.0, 1.1, 1.6, 1.4, 1.8, 2.3, 2.0, 2.6, 2.9, 3.1],
    ];
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final c = list[i];
          return GestureDetector(
            onTap: () => _selectPair(c),
            child: Container(
              width: 136,
              padding: const EdgeInsets.fromLTRB(9, 8, 6, 6),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: c == pair
                      ? AppColors.primary.withValues(alpha: 0.75)
                      : p.border,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 14,
                    width: 42,
                    height: 30,
                    child: SparkLine(values: sparks[i], color: sparkColors[i]),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CoinIcon(c, size: 17),
                            const SizedBox(width: 5),
                            Text(
                              '${c.symbol}/USDT',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: p.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '\$${fmtUsd(c.price)}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        Text(
                          '▲ +${c.change.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- chart card ----------------
  Widget _chartCard(AppPalette p) {
    const tabs = ['Chart', 'Depth', 'Trades', 'Info'];
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: _box(p, r: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinIcon(pair, size: 28),
              const SizedBox(width: 8),
              Flexible(
                flex: 0,
                fit: FlexFit.loose,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 112),
                  child: GestureDetector(
                    onTap: () async {
                      final c = await pickCoin(context);
                      if (c != null && c.symbol != 'USDT') _selectPair(c);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${pair.symbol}/USDT',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: p.text,
                                ),
                              ),
                              const SizedBox(width: 2),
                              FIcon(
                                Flaticons.chevronDown,
                                size: 14,
                                color: p.text,
                              ),
                            ],
                          ),
                          Text(
                            pair.name,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fmtUsd(pair.price),
                          style: const TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),
                        Text(
                          '≈ \$${fmtUsd(pair.price)}',
                          style: TextStyle(fontSize: 10.5, color: p.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  '▲ +${pair.change.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => fav = !fav),
                child: FIcon(
                  fav ? Flaticons.starFilled : Flaticons.star,
                  size: 18,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _segmented(p, tabs, chartTab, (i) => setState(() => chartTab = i)),
          const SizedBox(height: 8),
          if (chartTab == 0) ...[
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
                          '1D',
                        ])
                          GestureDetector(
                            onTap: () => setState(() {
                              tf = t;
                              candles = candlesFor(
                                pair.price,
                                seed: t.hashCode,
                              );
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: t == tf
                                    ? AppColors.primary.withValues(alpha: 0.22)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: t == tf
                                      ? AppColors.primaryLight
                                      : p.textMuted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                FIcon(Flaticons.candles, size: 16, color: p.textSecondary),
                const SizedBox(width: 10),
                FIcon(Flaticons.fx, size: 16, color: p.textSecondary),
                const SizedBox(width: 10),
                FIcon(Flaticons.expand, size: 16, color: p.textSecondary),
              ],
            ),
            const SizedBox(height: 6),
          ],
          SizedBox(height: 148, child: _chartTabBody(p)),
          if (chartTab == 0) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 68),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Nov 14',
                    style: TextStyle(fontSize: 10, color: p.textMuted),
                  ),
                  Text(
                    'Nov 15',
                    style: TextStyle(fontSize: 10, color: p.textMuted),
                  ),
                  Text(
                    'Nov 16',
                    style: TextStyle(fontSize: 10, color: p.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _web3Hub(AppPalette p) {
    final hub = [
      (
        Flaticons.trade,
        'DEX Swap',
        AppColors.primaryLight,
        () => _push(const SwapBridgeScreen()),
      ),
      (
        Flaticons.network,
        'DApps',
        AppColors.blue,
        () => _push(const DappBrowserScreen()),
      ),
      (
        Flaticons.sparkles,
        'NFTs',
        AppColors.amber,
        () => _push(const NftGalleryScreen()),
      ),
      (
        Flaticons.settings,
        'Tokens & Gas',
        AppColors.green,
        () => _push(const TokenManagerScreen()),
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < hub.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: hub[i].$4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: _box(p, r: 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FIcon(hub[i].$1, size: 13, color: hub[i].$3),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hub[i].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _chartTabBody(AppPalette p) {
    if (chartTab == 0) return CandleChart(candles: candles, twoMa: true);
    if (chartTab == 1) return DepthChart(midPrice: pair.price);
    if (chartTab == 2) {
      final trades = [
        (pair.price + 1.2, 0.2410, true, '13:01:42'),
        (pair.price - 0.5, 0.8120, false, '13:01:38'),
        (pair.price + 0.8, 0.1450, true, '13:01:31'),
        (pair.price - 1.1, 0.5200, false, '13:01:25'),
        (pair.price + 0.3, 0.6710, true, '13:01:19'),
      ];
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Price (USDT)',
                  style: TextStyle(fontSize: 10.5, color: p.textMuted),
                ),
              ),
              Expanded(
                child: Text(
                  'Amount (${pair.symbol})',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: p.textMuted),
                ),
              ),
              Expanded(
                child: Text(
                  'Time',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10.5, color: p.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final t in trades)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fmtUsd(t.$1),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: t.$3 ? AppColors.green : AppColors.red,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t.$2.toStringAsFixed(4),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: p.text),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t.$4,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, color: p.textMuted),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _infoStat(p, '24h High', '\$${fmtUsd(pair.price * 1.032)}'),
        _infoStat(p, '24h Low', '\$${fmtUsd(pair.price * 0.968)}'),
        _infoStat(p, '24h Volume', '42,819 ${pair.symbol}'),
        _infoStat(p, 'Market Cap', '\$2.01T'),
      ],
    );
  }

  Widget _infoStat(AppPalette p, String k, String v) => Row(
    children: [
      Text(k, style: TextStyle(fontSize: 11.5, color: p.textMuted)),
      const Spacer(),
      Text(
        v,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
      ),
    ],
  );

  Widget _segmented(
    AppPalette p,
    List<String> labels,
    int sel,
    ValueChanged<int> onTap, {
    double fontSize = 12,
  }) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: p.field,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final s = i == sel;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: s ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: s ? Colors.white : p.textSecondary,
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

  // ---------------- order book ----------------
  Widget _orderBook(AppPalette p) {
    final pr = pair.price;
    final asks = [
      (pr + 1.69, 0.5087, 0.55),
      (pr + 1.16, 0.3412, 0.35),
      (pr + 0.91, 0.1200, 0.75),
      (pr + 0.67, 0.8643, 0.6),
      (pr + 0.34, 0.2031, 0.85),
    ];
    final bids = [
      (pr - 0.44, 0.2865, 0.9),
      (pr - 0.92, 0.4521, 0.75),
      (pr - 1.30, 0.7410, 0.6),
      (pr - 1.76, 0.1634, 0.8),
      (pr - 2.22, 0.6098, 0.5),
    ];
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: _box(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _segmented(
            p,
            ['Order Book', 'Recent Trades'],
            bookTab,
            (i) => setState(() => bookTab = i),
            fontSize: 10.5,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _Fit(
                  Text(
                    'Price (USDT)',
                    style: TextStyle(fontSize: 10, color: p.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _Fit(
                  Text(
                    'Amt (${pair.symbol})',
                    style: TextStyle(fontSize: 10, color: p.textMuted),
                  ),
                  right: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final a in asks) _bookRow(p, a.$1, a.$2, a.$3, AppColors.red),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fmtUsd(pr),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '↑ +${pair.change.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final b in bids) _bookRow(p, b.$1, b.$2, b.$3, AppColors.green),
        ],
      ),
    );
  }

  Widget _bookRow(
    AppPalette p,
    double price,
    double amt,
    double depth,
    Color c,
  ) {
    return SizedBox(
      height: 19,
      child: Stack(
        children: [
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: depth,
              child: Container(color: c.withValues(alpha: 0.14)),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _Fit(
                  Text(
                    fmtUsd(price),
                    style: TextStyle(
                      fontSize: 11,
                      color: c,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: _Fit(
                  Text(
                    amt.toStringAsFixed(4),
                    style: TextStyle(fontSize: 11, color: p.text),
                  ),
                  right: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- buy / sell panel ----------------
  Widget _orderPanel(AppPalette p) {
    final sideColor = buy ? AppColors.green : AppColors.red;
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: _box(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: p.field,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [_sideBtn(p, 'Buy', true), _sideBtn(p, 'Sell', false)],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Flexible(flex: 2, child: _typeChip(p, 'Limit', 0)),
              const SizedBox(width: 3),
              Flexible(flex: 2, child: _typeChip(p, 'Market', 1)),
              const SizedBox(width: 3),
              Flexible(
                flex: 3,
                child: _typeChip(p, 'Stop-Limit', 2, dropdown: true),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _inputRow(p, 'Price', priceCtrl, 'USDT', enabled: orderType != 1),
          const SizedBox(height: 6),
          _inputRow(p, 'Amount', amtCtrl, pair.symbol),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              activeTrackColor: AppColors.primaryLight,
              inactiveTrackColor: p.border,
              thumbColor: AppColors.primary,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              tickMarkShape: const RoundSliderTickMarkShape(
                tickMarkRadius: 2.5,
              ),
              activeTickMarkColor: AppColors.primaryLight,
              inactiveTickMarkColor: p.border,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
              child: Slider(
                value: slider,
                divisions: 4,
                onChanged: (v) => setState(() {
                  slider = v;
                  amtCtrl.text = v == 0
                      ? ''
                      : (buy
                                ? coins[0].holding * v / pair.price
                                : pair.holding * v)
                            .toStringAsFixed(4);
                }),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 1),
              for (final pct in const ['25%', '50%', '75%', '100%'])
                Text(pct, style: TextStyle(fontSize: 9, color: p.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          _totalRow(p),
          const Spacer(),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _placeOrder,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [sideColor, sideColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: sideColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${buy ? 'Buy' : 'Sell'} ${pair.symbol}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: buy ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder() {
    final amt = double.tryParse(amtCtrl.text) ?? 0;
    if (amt <= 0) {
      showToast(context, 'Enter amount');
      return;
    }
    showToast(
      context,
      '${buy ? 'Buy' : 'Sell'} ${['Limit', 'Market', 'Stop-Limit'][orderType]} order placed: $amt ${pair.symbol}',
    );
    setState(() {
      amtCtrl.clear();
      slider = 0;
    });
  }

  Widget _sideBtn(AppPalette p, String label, bool isBuy) {
    final s = buy == isBuy;
    final c = isBuy ? AppColors.green : AppColors.red;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => buy = isBuy),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: s
                ? LinearGradient(colors: [c, c.withValues(alpha: 0.8)])
                : null,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: s
                    ? (isBuy ? Colors.black : Colors.white)
                    : p.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(AppPalette p, String label, int i, {bool dropdown = false}) {
    final s = orderType == i;
    return GestureDetector(
      onTap: () => setState(() => orderType = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          gradient: s ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(7),
          border: s ? null : Border.all(color: p.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: s ? Colors.white : p.textSecondary,
                ),
              ),
            ),
            if (dropdown) ...[
              const SizedBox(width: 2),
              FIcon(
                Flaticons.chevronDown,
                size: 10,
                color: s ? Colors.white : p.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fieldBox(AppPalette p, List<Widget> children) => Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: p.field,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: p.border),
    ),
    child: Row(children: children),
  );

  Widget _inputRow(
    AppPalette p,
    String label,
    TextEditingController ctrl,
    String unit, {
    bool enabled = true,
  }) {
    return _fieldBox(p, [
      Text(label, style: TextStyle(fontSize: 11, color: p.textSecondary)),
      const SizedBox(width: 4),
      Expanded(
        child: TextField(
          controller: ctrl,
          enabled: enabled,
          textAlign: TextAlign.right,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: enabled ? '' : 'Market',
          ),
        ),
      ),
      const SizedBox(width: 4),
      Text(unit, style: TextStyle(fontSize: 10, color: p.textMuted)),
    ]);
  }

  Widget _totalRow(AppPalette p) {
    final price =
        double.tryParse(priceCtrl.text.replaceAll(',', '')) ?? pair.price;
    final total = price * (double.tryParse(amtCtrl.text) ?? 0);
    return _fieldBox(p, [
      Text('Total', style: TextStyle(fontSize: 11, color: p.textSecondary)),
      const Spacer(),
      if (total > 0)
        Text(
          fmtUsd(total),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
        ),
      const SizedBox(width: 4),
      Text('USDT', style: TextStyle(fontSize: 10, color: p.textMuted)),
    ]);
  }

  // ---------------- wallet card ----------------
  Widget _walletCard(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: p.heroGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: FIcon(Flaticons.wallet, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Wallet',
                      style: TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                    SizedBox(height: 1),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(
                          '\$48,392.32',
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '▲ +5.21%',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' (24h)',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            style: TextStyle(fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onTab(3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'View Wallet',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      FIcon(
                        Flaticons.arrowRight,
                        size: 13,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _walletAction(
                Flaticons.deposit,
                'Deposit',
                () => _push(const DepositScreen()),
                filled: true,
              ),
              const SizedBox(width: 5),
              _walletAction(
                Flaticons.withdraw,
                'Withdraw',
                () => _push(const WithdrawScreen()),
              ),
              const SizedBox(width: 5),
              _walletAction(
                Flaticons.send,
                'Send',
                () => _push(const SendReceiveScreen(initialTab: 0)),
              ),
              const SizedBox(width: 5),
              _walletAction(
                Flaticons.receive,
                'Receive',
                () => _push(const SendReceiveScreen(initialTab: 1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletAction(
    Flaticons icon,
    String label,
    VoidCallback onTap, {
    bool filled = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            gradient: filled ? AppColors.primaryGradient : null,
            color: filled ? null : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: filled
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FIcon(icon, size: 13, color: Colors.white),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
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
}

class _Fit extends StatelessWidget {
  final Widget child;
  final bool right;
  const _Fit(this.child, {this.right = false});
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: right ? Alignment.centerRight : Alignment.centerLeft,
    child: child,
  );
}
