import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class SwapBridgeScreen extends StatefulWidget {
  final int initialTab; // 0 = DEX Swap, 1 = Cross-Chain Bridge
  const SwapBridgeScreen({super.key, this.initialTab = 0});

  @override
  State<SwapBridgeScreen> createState() => _SwapBridgeScreenState();
}

class _SwapBridgeScreenState extends State<SwapBridgeScreen> {
  late int tab = widget.initialTab;
  Coin fromCoin = coins[2]; // ETH
  Coin toCoin = coins[0]; // USDT
  String fromChain = 'Ethereum';
  String toChain = 'Arbitrum';
  double slippage = 0.5;
  final amtCtrl = TextEditingController(text: '0.50');

  static const _chains = [
    'Ethereum',
    'BNB Chain',
    'Solana',
    'Arbitrum',
    'Polygon',
  ];

  @override
  void dispose() {
    amtCtrl.dispose();
    super.dispose();
  }

  double get _inAmt => double.tryParse(amtCtrl.text) ?? 0;
  double get _rate => fromCoin.price / toCoin.price;
  double get _outAmt => _inAmt * _rate;

  void _flip() {
    setState(() {
      final tmpC = fromCoin;
      fromCoin = toCoin;
      toCoin = tmpC;
      final tmpN = fromChain;
      fromChain = toChain;
      toChain = tmpN;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 Swap & Bridge'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: p.cardAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.border),
            ),
            child: Text(
              '$slippage%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
        children: [
          _tabSwitcher(p),
          const SizedBox(height: 10),
          _fromCard(p),
          Center(
            child: Transform.translate(
              offset: const Offset(0, -4),
              child: GestureDetector(
                onTap: _flip,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    border: Border.all(color: p.bg, width: 2.5),
                  ),
                  child: const Center(
                    child: FIcon(
                      Flaticons.trade,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(offset: const Offset(0, -8), child: _toCard(p)),
          _routeCard(p),
          const SizedBox(height: 12),
          GradientButton(
            label: tab == 0
                ? 'Swap ${fromCoin.symbol} to ${toCoin.symbol}'
                : 'Bridge ${fromCoin.symbol} ($fromChain → $toChain)',
            icon: tab == 0 ? Flaticons.trade : Flaticons.network,
            onPressed: () {
              if (_inAmt <= 0) {
                showToast(context, 'Enter valid amount');
                return;
              }
              showToast(
                context,
                tab == 0
                    ? 'Swapped ${amtCtrl.text} ${fromCoin.symbol} → ${_outAmt.toStringAsFixed(2)} ${toCoin.symbol}'
                    : 'Bridged ${amtCtrl.text} ${fromCoin.symbol} from $fromChain to $toChain',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tabSwitcher(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          _tabBtn(p, 0, 'DEX Swap', Flaticons.trade),
          _tabBtn(p, 1, 'Cross-Chain Bridge', Flaticons.network),
        ],
      ),
    );
  }

  Widget _tabBtn(AppPalette p, int i, String label, Flaticons icon) {
    final sel = tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            gradient: sel ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FIcon(icon, size: 14, color: sel ? Colors.white : p.textMuted),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : p.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fromCard(AppPalette p) {
    return GlassCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'From',
                style: TextStyle(
                  fontSize: 11,
                  color: p.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              _chainPill(p, fromChain, () => _pickChain(true)),
              const Spacer(),
              Text(
                'Bal: ${fromCoin.holding.toStringAsFixed(3)}',
                style: TextStyle(fontSize: 11, color: p.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final c = await pickCoin(context);
                  if (c != null) setState(() => fromCoin = c);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: p.cardAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: p.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CoinIcon(fromCoin, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        fromCoin.symbol,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      const SizedBox(width: 4),
                      FIcon(
                        Flaticons.chevronDown,
                        size: 13,
                        color: p.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: amtCtrl,
                  textAlign: TextAlign.right,
                  onChanged: (_) => setState(() {}),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0.0',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final pct in const [0.25, 0.5, 1.0])
                GestureDetector(
                  onTap: () => setState(
                    () => amtCtrl.text = (fromCoin.holding * pct)
                        .toStringAsFixed(4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: p.field,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: p.border),
                    ),
                    child: Text(
                      pct == 1.0 ? 'MAX' : '${(pct * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '≈ \$${fmtUsd(_inAmt * fromCoin.price)}',
                style: TextStyle(fontSize: 11, color: p.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toCard(AppPalette p) {
    return GlassCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'To',
                style: TextStyle(
                  fontSize: 11,
                  color: p.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _chainPill(
                    p,
                    tab == 0 ? fromChain : toChain,
                    tab == 0 ? null : () => _pickChain(false),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  '+0.12% Best Route',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final c = await pickCoin(context);
                  if (c != null) setState(() => toCoin = c);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: p.cardAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: p.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CoinIcon(toCoin, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        toCoin.symbol,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      const SizedBox(width: 4),
                      FIcon(
                        Flaticons.chevronDown,
                        size: 13,
                        color: p.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _outAmt.toStringAsFixed(toCoin.price > 100 ? 4 : 2),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '1 ${fromCoin.symbol} ≈ ${_rate.toStringAsFixed(2)} ${toCoin.symbol}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: p.textMuted),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '≈ \$${fmtUsd(_outAmt * toCoin.price)}',
                style: TextStyle(fontSize: 11, color: p.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routeCard(AppPalette p) {
    final minRecv = _outAmt * (1 - slippage / 100);
    return GlassCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _infoRow(
            p,
            'Aggregator Route',
            tab == 0 ? '1inch + Uniswap v3' : 'LayerZero Stargate',
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Max Slippage',
                  style: TextStyle(fontSize: 11.5, color: p.textMuted),
                ),
              ),
              for (final s in const [0.1, 0.5, 1.0])
                GestureDetector(
                  onTap: () => setState(() => slippage = s),
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: slippage == s ? AppColors.primary : p.field,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: slippage == s ? AppColors.primary : p.border,
                      ),
                    ),
                    child: Text(
                      '$s%',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: slippage == s ? Colors.white : p.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _infoRow(p, 'Price Impact', '< 0.05%'),
          const SizedBox(height: 6),
          _infoRow(p, 'Network Gas Fee', '14 Gwei (≈ \$0.38)'),
          const SizedBox(height: 6),
          _infoRow(
            p,
            'Minimum Received',
            '${minRecv.toStringAsFixed(2)} ${toCoin.symbol}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(AppPalette p, String k, String v) => Row(
    children: [
      Expanded(
        child: Text(k, style: TextStyle(fontSize: 11.5, color: p.textMuted)),
      ),
      Text(
        v,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
      ),
    ],
  );

  Widget _chainPill(AppPalette p, String name, VoidCallback? onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 2),
                const FIcon(
                  Flaticons.chevronDown,
                  size: 10,
                  color: AppColors.primaryLight,
                ),
              ],
            ],
          ),
        ),
      );

  Future<void> _pickChain(bool isFrom) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.pal.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in _chains)
              ListTile(
                leading: const FIcon(
                  Flaticons.network,
                  size: 17,
                  color: AppColors.primaryLight,
                ),
                title: Text(c),
                onTap: () => Navigator.pop(ctx, c),
              ),
          ],
        ),
      ),
    );
    if (chosen != null) {
      setState(() => isFrom ? fromChain = chosen : toChain = chosen);
    }
  }
}
