import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'alerts_screen.dart';
import 'create_wallet_screen.dart';
import 'multicharts_screen.dart';
import 'onboarding_screen.dart';
import 'recovery_phrase_screen.dart';
import 'security_screen.dart';
import 'splash_screen.dart';
import 'swap_bridge_screen.dart';
import 'watchlist_screen.dart';

List<(Flaticons, String, Color, Widget)> moreItems() => [
  (
    Flaticons.trade,
    'Convert & Swap',
    AppColors.primaryLight,
    const SwapBridgeScreen(),
  ),
  (Flaticons.starFilled, 'Watchlist', AppColors.amber, const WatchlistScreen()),
  (Flaticons.bell, 'Price Alerts', AppColors.red, const AlertsScreen()),
  (Flaticons.candles, 'Multicharts', AppColors.blue, const MultichartsScreen()),
  (
    Flaticons.addWallet,
    'Create Wallet',
    AppColors.primary,
    const CreateWalletScreen(initialTab: 0),
  ),
  (
    Flaticons.recoverWallet,
    'Recover Wallet',
    AppColors.blue,
    const CreateWalletScreen(initialTab: 1),
  ),
  (
    Flaticons.key,
    'Recovery Phrase',
    AppColors.amber,
    const RecoveryPhraseScreen(),
  ),
  (Flaticons.shieldCheck, 'Security', AppColors.green, const SecurityScreen()),
  (
    Flaticons.lock,
    'Splash & Lock',
    AppColors.primary,
    const SplashScreen(isPreview: true),
  ),
  (
    Flaticons.sparkles,
    'Onboarding Tour',
    AppColors.primaryLight,
    const OnboardingScreen(isPreview: true),
  ),
];

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final themeProv = context.watch<ThemeProvider>();
    final items = moreItems();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          const SectionTitle('More & Tools'),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            onTap: () => context.read<ThemeProvider>().toggleTheme(),
            child: Row(
              children: [
                FBadgeIcon(
                  themeProv.isDark ? Flaticons.moon : Flaticons.sun,
                  color: themeProv.isDark
                      ? AppColors.primaryLight
                      : AppColors.amber,
                  size: 32,
                  iconSize: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      Text(
                        themeProv.isDark
                            ? 'Dark Theme active'
                            : 'Light Theme active',
                        style: TextStyle(fontSize: 11, color: p.textMuted),
                      ),
                    ],
                  ),
                ),
                const ThemeToggleButton(compact: false),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.12,
            children: [
              for (final it in items)
                GlassCard(
                  padding: const EdgeInsets.all(8),
                  radius: 12,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => it.$4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FBadgeIcon(
                        it.$1,
                        color: it.$3,
                        size: 34,
                        iconSize: 17,
                        radius: 10,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        it.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: p.text,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
