import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'create_wallet_screen.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isPreview;
  const OnboardingScreen({super.key, this.isPreview = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final ctrl = PageController();
  int page = 0;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void _enterApp() {
    if (widget.isPreview) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.bgSecondary, p.bg],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                child: Row(
                  children: [
                    const DexNovaLogo(size: 30),
                    const SizedBox(width: 8),
                    Text(
                      'DexNova',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'WEB3',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const ThemeToggleButton(compact: true),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _enterApp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: p.cardAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: p.border),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: p.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: ctrl,
                  itemCount: 4,
                  onPageChanged: (i) => setState(() => page = i),
                  itemBuilder: (_, i) => _buildSlide(p, i),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 4; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == page ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == page ? AppColors.primary : p.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GradientButton(
                      label: page == 3 ? 'Enter DexNova Exchange' : 'Next',
                      icon: Flaticons.arrowRight,
                      onPressed: () {
                        if (page < 3) {
                          ctrl.nextPage(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOut,
                          );
                        } else {
                          _enterApp();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Create New Wallet',
                            icon: Flaticons.addWallet,
                            outlined: true,
                            height: 36,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CreateWalletScreen(initialTab: 0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GradientButton(
                            label: 'Recover Wallet',
                            icon: Flaticons.recoverWallet,
                            outlined: true,
                            height: 36,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CreateWalletScreen(initialTab: 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(AppPalette p, int i) {
    final titles = [
      'Pro Crypto Exchange\n& Spot Trading',
      'True Self-Custody\nWeb3 Wallet',
      '1-Tap Cross-Chain\nDEX Swap & Bridge',
      'Web3 DApp Browser,\nDeFi & NFTs',
    ];
    final subtitles = [
      'Trade 250+ spot & perpetual pairs with ultra-low latency orderbooks and live depth charts.',
      'Your keys, your crypto. Generate or recover BIP-39 12/24-word seeds encrypted on-device.',
      'Aggregate 50+ DEXs and bridges with automatic best-route pricing and MEV protection.',
      'Connect instantly via WalletConnect v2, manage NFTs, stake yields, and track live gas.',
    ];
    final tags = [
      ['0.05% Fee', '250+ Pairs', 'Live Orderbook'],
      ['Non-Custodial', 'BIP-39 Seed', 'Biometric Lock'],
      ['50+ DEXs', 'MEV Guard', 'Live Gas'],
      ['WalletConnect v2', 'NFT Gallery', 'DeFi Yield'],
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      children: [
        _previewCard(p, i),
        const SizedBox(height: 14),
        Text(
          titles[i],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: p.text,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitles[i],
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: p.textSecondary, height: 1.38),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final t in tags[i])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.border),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _previewCard(AppPalette p, int i) {
    if (i == 0) {
      return GlassCard(
        gradient: p.heroGradient,
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.primary.withValues(alpha: 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CoinIcon(coins[1], size: 24),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'BTC / USDT Spot',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    '▲ +2.41%',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '\$102,347.21',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              height: 54,
              child: SparkLine(
                values: [2, 2.5, 2.1, 3.2, 2.9, 4.1, 3.8, 5.2, 4.9, 6.4],
                color: AppColors.green,
              ),
            ),
          ],
        ),
      );
    }
    if (i == 1) {
      return GlassCard(
        gradient: p.heroGradient,
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.primary.withValues(alpha: 0.4),
        child: Column(
          children: [
            const Row(
              children: [
                DexNovaLogo(size: 38),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Multi-Chain Vault',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'BIP-39 12/24-Word Encrypted Seed',
                        style: TextStyle(fontSize: 10.5, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                FIcon(Flaticons.shieldCheck, size: 20, color: AppColors.green),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final c in coins.take(5)) CoinIcon(c, size: 28)],
            ),
          ],
        ),
      );
    }
    if (i == 2) {
      return GlassCard(
        gradient: p.heroGradient,
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.primary.withValues(alpha: 0.4),
        child: Column(
          children: [
            Row(
              children: [
                CoinIcon(coins[2], size: 24),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    '0.50 ETH',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const FIcon(
                  Flaticons.arrowRight,
                  size: 15,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                CoinIcon(coins[0], size: 24),
                const SizedBox(width: 6),
                const Text(
                  '1,706.33 USDT',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  FIcon(Flaticons.sparkles, size: 14, color: AppColors.green),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '1inch + LayerZero Best Route',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                  Text(
                    '+0.12%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return GlassCard(
      gradient: p.heroGradient,
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.primary.withValues(alpha: 0.4),
      child: Column(
        children: [
          const Row(
            children: [
              FBadgeIcon(
                Flaticons.network,
                color: Colors.white,
                size: 32,
                iconSize: 16,
              ),
              SizedBox(width: 8),
              Expanded(
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
                      'Uniswap • Aave • OpenSea • Lido',
                      style: TextStyle(fontSize: 10.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Text(
                '24% APY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final badge in const [
                'DApp Browser',
                'NFT Vault',
                'DeFi LP',
              ]) ...[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: badge == 'DeFi LP' ? 0 : 6),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
