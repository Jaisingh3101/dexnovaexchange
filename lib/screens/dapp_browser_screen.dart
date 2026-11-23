import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class DappBrowserScreen extends StatefulWidget {
  const DappBrowserScreen({super.key});

  @override
  State<DappBrowserScreen> createState() => _DappBrowserScreenState();
}

class _DappBrowserScreenState extends State<DappBrowserScreen> {
  final urlCtrl = TextEditingController(text: 'https://app.uniswap.org');
  String category = 'All';
  String activeNet = 'ETH Mainnet';

  static const _cats = ['All', 'DEX', 'Lending', 'Staking', 'NFT', 'Bridge'];
  static const _dapps = [
    (
      'Uniswap v3',
      'DEX',
      'Ethereum',
      'TVL \$4.8B',
      AppColors.primary,
      'app.uniswap.org',
    ),
    (
      'PancakeSwap',
      'DEX',
      'BNB Chain',
      'TVL \$2.1B',
      AppColors.amber,
      'pancakeswap.finance',
    ),
    (
      'Aave v3',
      'Lending',
      'Multi-Chain',
      'TVL \$11.4B',
      AppColors.blue,
      'app.aave.com',
    ),
    (
      'Lido Finance',
      'Staking',
      'Ethereum',
      '3.4% APR',
      AppColors.green,
      'stake.lido.fi',
    ),
    (
      'Raydium',
      'DEX',
      'Solana',
      'TVL \$1.6B',
      AppColors.primaryLight,
      'raydium.io',
    ),
    ('OpenSea', 'NFT', 'Ethereum', 'NFT Market', AppColors.blue, 'opensea.io'),
    (
      '1inch Network',
      'DEX',
      'Aggregator',
      'Best Rates',
      AppColors.red,
      'app.1inch.io',
    ),
    (
      'Stargate',
      'Bridge',
      'LayerZero',
      'Omnichain',
      AppColors.green,
      'stargate.finance',
    ),
  ];

  @override
  void dispose() {
    urlCtrl.dispose();
    super.dispose();
  }

  void _openSignSheet(String dappName, String domain) {
    final p = context.pal;
    showModalBottomSheet(
      context: context,
      backgroundColor: p.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const FBadgeIcon(
                    Flaticons.shieldCheck,
                    color: AppColors.primary,
                    size: 32,
                    iconSize: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WalletConnect Signature',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        Text(
                          '$dappName ($domain)',
                          style: TextStyle(fontSize: 11, color: p.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Method: eth_signTypedData_v4',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Account: 0x7a9E...3b2F ($activeNet)',
                      style: TextStyle(fontSize: 11, color: p.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Est. Gas: \$0.00 (Off-chain Signature)',
                      style: TextStyle(fontSize: 11, color: AppColors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      label: 'Reject',
                      outlined: true,
                      height: 38,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GradientButton(
                      label: 'Approve Sign',
                      icon: Flaticons.checkCircle,
                      height: 38,
                      onPressed: () {
                        Navigator.pop(ctx);
                        showToast(context, 'Signed request for $dappName');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final visible = _dapps
        .where((d) => category == 'All' || d.$2 == category)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 DApp Browser'),
        actions: [
          GestureDetector(
            onTap: () => setState(
              () => activeNet = activeNet == 'ETH Mainnet'
                  ? 'BNB Chain'
                  : 'ETH Mainnet',
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: p.cardAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activeNet,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ],
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: urlCtrl,
                  style: TextStyle(fontSize: 12.5, color: p.text),
                  decoration: InputDecoration(
                    hintText: 'Search DApp or enter https://...',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(9),
                      child: FIcon(
                        Flaticons.lock,
                        size: 15,
                        color: AppColors.green,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const FIcon(
                        Flaticons.arrowRight,
                        size: 16,
                        color: AppColors.primaryLight,
                      ),
                      onPressed: () =>
                          _openSignSheet('Custom DApp', urlCtrl.text.trim()),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GlassCard(
            gradient: p.heroGradient,
            padding: const EdgeInsets.all(10),
            borderColor: AppColors.primary.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const FBadgeIcon(
                      Flaticons.network,
                      color: Colors.white,
                      size: 28,
                      iconSize: 14,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WalletConnect v2 Active',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '3 sessions • 0x7a9E...3b2F',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _openSignSheet('Uniswap v3', 'app.uniswap.org'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Text(
                          'Sign Demo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () =>
                          showToast(context, 'Scan WalletConnect QR code'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+ Pair QR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _cats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final sel = category == _cats[i];
                return GestureDetector(
                  onTap: () => setState(() => category = _cats[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: sel ? AppColors.primaryGradient : null,
                      color: sel ? null : p.card,
                      borderRadius: BorderRadius.circular(14),
                      border: sel ? null : Border.all(color: p.border),
                    ),
                    child: Center(
                      child: Text(
                        _cats[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : p.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          for (final d in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                onTap: () => _openSignSheet(d.$1, d.$6),
                child: Row(
                  children: [
                    FBadgeIcon(
                      Flaticons.sparkles,
                      color: d.$5,
                      size: 32,
                      iconSize: 16,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  d.$1,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: p.text,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: d.$5.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  d.$2,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: d.$5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${d.$3} • ${d.$4}',
                            style: TextStyle(fontSize: 11, color: p.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: p.cardAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: p.border),
                      ),
                      child: Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
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
}
