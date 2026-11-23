import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';

class EarnScreen extends StatelessWidget {
  const EarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final products = [
      ('USDT', 8.0, 'Flexible'),
      ('ETH', 4.2, '30 Days'),
      ('SOL', 6.8, '60 Days'),
      ('BNB', 3.1, 'Flexible'),
      ('BTC', 2.5, '90 Days'),
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          const SectionTitle(
            'Earn',
            trailing: ThemeToggleButton(compact: true),
          ),
          GlassCard(
            gradient: p.heroGradient,
            radius: 14,
            padding: const EdgeInsets.all(12),
            borderColor: AppColors.primary.withValues(alpha: 0.35),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Earnings',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$1,284.56',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Up to 8% APY on stablecoins',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                FIcon(Flaticons.earn, size: 36, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (final item in products)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                radius: 11,
                child: Row(
                  children: [
                    CoinIcon(coinBy(item.$1), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: p.text,
                            ),
                          ),
                          Text(
                            item.$3,
                            style: TextStyle(fontSize: 11, color: p.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.$2}%',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'APY',
                          style: TextStyle(fontSize: 10, color: p.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 68,
                      child: GradientButton(
                        label: 'Stake',
                        height: 32,
                        onPressed: () => showToast(
                          context,
                          'Staking ${item.$1} at ${item.$2}% APY',
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
