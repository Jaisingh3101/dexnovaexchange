import 'package:flutter/material.dart';
import '../models/dex_models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'create_wallet_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isPreview;
  const SplashScreen({super.key, this.isPreview = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int mode = 0; // 0 = Welcome, 1 = PIN Lock
  String pin = '';

  void _enterApp() {
    if (widget.isPreview) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  void _pressDigit(String d) {
    if (pin.length >= 6) return;
    setState(() => pin += d);
    if (pin.length == 6) {
      Future.delayed(const Duration(milliseconds: 160), () {
        if (mounted) _enterApp();
      });
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
                    if (widget.isPreview) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: p.cardAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: p.border),
                          ),
                          child: Center(
                            child: FIcon(
                              Flaticons.arrowLeft,
                              size: 15,
                              color: p.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _modeSwitcher(p),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
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
              Expanded(child: mode == 0 ? _buildWelcome(p) : _buildPinLock(p)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeSwitcher(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_modeChip(p, 0, 'Welcome'), _modeChip(p, 1, 'PIN Lock')],
      ),
    );
  }

  Widget _modeChip(AppPalette p, int i, String label) {
    final sel = mode == i;
    return GestureDetector(
      onTap: () => setState(() {
        mode = i;
        pin = '';
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: sel ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: sel ? Colors.white : p.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(AppPalette p) {
    final features = [
      (
        Flaticons.shieldCheck,
        AppColors.green,
        'Self-Custody & BIP-39 Seed',
        'Keys encrypted locally, multi-wallet HD vault',
      ),
      (
        Flaticons.trade,
        AppColors.primaryLight,
        'Live On-Chain DEX & Convert',
        'Real-time pools, OHLCV charts & instant swap across 18 chains',
      ),
      (
        Flaticons.candles,
        AppColors.blue,
        'Multicharts, Watchlist & Alerts',
        'Track live tokens, compare up to 4 charts & set price alerts',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      children: [
        Center(
          child: SizedBox(
            width: 130,
            height: 82,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                DexNovaLogo(size: 72),
                Positioned(
                  left: 4,
                  top: 8,
                  child: ChainBadge('ethereum', size: 22),
                ),
                Positioned(
                  right: 4,
                  top: 8,
                  child: ChainBadge('bsc', size: 22),
                ),
                Positioned(
                  left: 12,
                  bottom: 4,
                  child: ChainBadge('solana', size: 20),
                ),
                Positioned(
                  right: 12,
                  bottom: 4,
                  child: ChainBadge('base', size: 20),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'HyperDEX',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: p.text,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Web3 Exchange & Non-Custodial Wallet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: p.textSecondary),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final chain in kDexChains.values.take(8))
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: chain.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        chain.name,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final f in features)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  FBadgeIcon(f.$1, color: f.$2, size: 34, iconSize: 17),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.$3,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.text,
                          ),
                        ),
                        Text(
                          f.$4,
                          style: TextStyle(fontSize: 11, color: p.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 10),
        GradientButton(
          label: 'Enter HyperDEX Exchange',
          icon: Flaticons.arrowRight,
          onPressed: _enterApp,
        ),
        const SizedBox(height: 8),
        GradientButton(
          label: 'Onboarding Tour',
          icon: Flaticons.sparkles,
          outlined: true,
          height: 36,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OnboardingScreen(isPreview: widget.isPreview),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GradientButton(
                label: 'Create New Wallet',
                icon: Flaticons.addWallet,
                outlined: true,
                height: 38,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateWalletScreen(
                      initialTab: 0,
                      enterShellOnComplete: !widget.isPreview,
                    ),
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
                height: 38,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateWalletScreen(
                      initialTab: 1,
                      enterShellOnComplete: !widget.isPreview,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinLock(AppPalette p) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      children: [
        Center(
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: const Center(
              child: FIcon(
                Flaticons.lock,
                size: 24,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Unlock DexNova Vault',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: p.text,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Enter 6-digit passcode or use biometrics',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.5, color: p.textMuted),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 6; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < pin.length ? AppColors.primary : p.field,
                  border: Border.all(
                    color: i < pin.length ? AppColors.primaryLight : p.border,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 14,
              childAspectRatio: 1.45,
              children: [
                for (final d in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                  _numKey(p, d),
                _iconKey(p, Flaticons.fingerprint, AppColors.green, () {
                  showToast(context, 'Biometric verified');
                  _enterApp();
                }),
                _numKey(p, '0'),
                _iconKey(p, Flaticons.closeCircle, p.textSecondary, () {
                  if (pin.isNotEmpty) {
                    setState(() => pin = pin.substring(0, pin.length - 1));
                  }
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _numKey(AppPalette p, String d) => GestureDetector(
    onTap: () => _pressDigit(d),
    child: Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Center(
        child: Text(
          d,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: p.text,
          ),
        ),
      ),
    ),
  );

  Widget _iconKey(AppPalette p, Flaticons icon, Color c, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: p.cardAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.border),
          ),
          child: Center(child: FIcon(icon, size: 20, color: c)),
        ),
      );
}
