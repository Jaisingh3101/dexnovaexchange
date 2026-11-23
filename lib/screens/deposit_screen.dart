import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});
  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  Coin coin = coins[0];
  String network = networks[0];
  static const address = 'TD7fKc8sXq2LmN4pR9vW1yZ3aB6eH5j9hF8';

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final short =
        '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
        children: [
          _hero(p),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Coin'),
                    SelectorTile(
                      leading: CoinIcon(coin, size: 22),
                      title: coin.symbol,
                      onTap: () async {
                        final c = await pickCoin(context);
                        if (c != null) setState(() => coin = c);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Network'),
                    SelectorTile(
                      leading: const TronIcon(size: 22),
                      title: network,
                      onTap: () async {
                        final n = await pickNetwork(context);
                        if (n != null) setState(() => network = n);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const FIcon(
                  Flaticons.warning,
                  size: 16,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Send only ${coin.symbol} via ${network.split(' ').first} network to this address.',
                    style: TextStyle(fontSize: 11.5, color: p.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: FakeQr(data: address + coin.symbol + network, size: 128),
          ),
          const SizedBox(height: 12),
          GlassCard(
            radius: 10,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            onTap: () {
              Clipboard.setData(const ClipboardData(text: address));
              showToast(context, 'Address copied to clipboard');
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    short,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ),
                FIcon(Flaticons.copy, size: 16, color: p.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GradientButton(
            label: 'Copy Address',
            icon: Flaticons.copy,
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: address));
              showToast(context, 'Address copied to clipboard');
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Minimum Deposit: 1 ${coin.symbol} • Est. Arrival: ~1 min',
              style: TextStyle(fontSize: 11, color: p.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(AppPalette p) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        gradient: p.heroGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 54,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.55),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Center(
              child: FIcon(Flaticons.wallet, size: 24, color: Colors.white),
            ),
          ),
          Positioned(left: 56, bottom: 14, child: CoinIcon(coins[0], size: 26)),
          Positioned(left: 94, top: 12, child: CoinIcon(coins[2], size: 22)),
          Positioned(right: 98, top: 10, child: CoinIcon(coins[1], size: 26)),
          Positioned(right: 60, top: 20, child: CoinIcon(coins[4], size: 24)),
          Positioned(
            right: 46,
            bottom: 14,
            child: CoinIcon(coins[0], size: 22),
          ),
        ],
      ),
    );
  }
}
