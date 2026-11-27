import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import '../widgets/wallet_switcher.dart';
import 'create_wallet_screen.dart';
import 'recovery_phrase_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool twoFa = true;
  bool biometric = true;

  void _openWalletSetup(int tab) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CreateWalletScreen(initialTab: tab)),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final walletProv = context.watch<WalletProvider>();
    final wallets = walletProv.wallets;
    final wallet = walletProv.activeWallet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Settings'),
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
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _tile(
                  p: p,
                  icon: Flaticons.shieldCheck,
                  color: AppColors.green,
                  title: 'Two-Factor Authentication',
                  sub: twoFa ? 'Enabled' : 'Disabled',
                  subColor: twoFa ? AppColors.green : AppColors.red,
                  trailing: _check(twoFa),
                  onTap: () => setState(() => twoFa = !twoFa),
                ),
                _div(p),
                _tile(
                  p: p,
                  icon: Flaticons.fingerprint,
                  color: AppColors.green,
                  title: 'Biometric Login',
                  sub: biometric ? 'Enabled' : 'Disabled',
                  subColor: biometric ? AppColors.green : AppColors.red,
                  trailing: _check(biometric),
                  onTap: () => setState(() => biometric = !biometric),
                ),
                _div(p),
                _tile(
                  p: p,
                  icon: Flaticons.key,
                  color: AppColors.green,
                  title: 'Recovery Phrase',
                  sub: wallet != null ? 'Backed Up' : 'View / Backup Seed',
                  subColor: wallet != null ? AppColors.green : p.textMuted,
                  trailing: _check(wallet != null),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecoveryPhraseScreen(),
                    ),
                  ),
                ),
                _div(p),
                _tile(
                  p: p,
                  icon: Flaticons.recoverWallet,
                  color: AppColors.blue,
                  title: 'Create / Recover Wallet',
                  sub: wallet != null
                      ? '${wallet.name} • ${wallet.shortEth} (${wallets.length})'
                      : '${wallets.length} wallets • Tap to setup',
                  subColor: wallet != null ? AppColors.green : p.textMuted,
                  trailing: FIcon(
                    Flaticons.chevronRight,
                    size: 15,
                    color: p.textMuted,
                  ),
                  onTap: () => wallets.isNotEmpty
                      ? showWalletSwitcherSheet(context)
                      : _openWalletSetup(0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    FBadgeIcon(
                      wallet != null ? Flaticons.wallet : Flaticons.shieldCheck,
                      color: wallet != null ? AppColors.green : AppColors.blue,
                      size: 36,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wallet != null
                                ? '${wallet.name} Connected'
                                : 'Connect Web3 Wallet',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            wallet != null
                                ? '${wallet.shortEth} • ${wallets.length} ${wallets.length == 1 ? 'Wallet' : 'Wallets'}'
                                : 'Create a new wallet or recover with seed phrase',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: p.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GradientButton(
                  label: wallets.isNotEmpty
                      ? 'Manage / Switch Wallet'
                      : 'Connect Wallet',
                  icon: Flaticons.addWallet,
                  height: 38,
                  onPressed: () => wallets.isNotEmpty
                      ? showWalletSwitcherSheet(context)
                      : _openWalletSetup(0),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Recover Seed',
                        icon: Flaticons.recoverWallet,
                        outlined: true,
                        height: 34,
                        onPressed: () => _openWalletSetup(1),
                      ),
                    ),
                    if (wallet != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: GradientButton(
                          label: 'Disconnect',
                          icon: Flaticons.closeCircle,
                          outlined: true,
                          height: 34,
                          onPressed: () {
                            context.read<WalletProvider>().disconnectWallet();
                            showToast(context, 'Wallet disconnected');
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: FIcon(
                    Flaticons.settings,
                    size: 18,
                    color: p.textSecondary,
                  ),
                  title: const Text('Advanced Settings'),
                  trailing: FIcon(
                    Flaticons.chevronRight,
                    size: 15,
                    color: p.textMuted,
                  ),
                  onTap: () => showToast(context, 'Advanced settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _div(AppPalette p) => Divider(height: 1, color: p.border);

  Widget _check(bool on) => FIcon(
    on ? Flaticons.checkCircle : Flaticons.closeCircle,
    size: 18,
    color: on ? AppColors.green : AppColors.red,
  );

  Widget _tile({
    required AppPalette p,
    required Flaticons icon,
    required Color color,
    required String title,
    required String sub,
    required Color subColor,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: FBadgeIcon(
        icon,
        color: color,
        size: 30,
        iconSize: 15,
        radius: 8,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
      ),
      subtitle: Text(sub, style: TextStyle(color: subColor, fontSize: 11.5)),
      trailing: trailing,
    );
  }
}
