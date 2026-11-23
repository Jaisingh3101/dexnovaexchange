import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
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

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
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
                  icon: Flaticons.lock,
                  color: AppColors.primaryLight,
                  title: 'Change Password',
                  sub: '••••••••',
                  subColor: p.textMuted,
                  trailing: FIcon(
                    Flaticons.chevronRight,
                    size: 15,
                    color: p.textMuted,
                  ),
                  onTap: () => showToast(context, 'Change password'),
                ),
                _div(p),
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
                  sub: 'Backup Complete',
                  subColor: AppColors.green,
                  trailing: _check(true),
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
                  sub: 'Import or generate seed',
                  subColor: p.textMuted,
                  trailing: FIcon(
                    Flaticons.chevronRight,
                    size: 15,
                    color: p.textMuted,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateWalletScreen(initialTab: 0),
                    ),
                  ),
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
                    const FBadgeIcon(
                      Flaticons.shieldCheck,
                      color: AppColors.blue,
                      size: 36,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect to Trust Wallet',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manage your assets with Trust Wallet',
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
                  label: 'Connect Wallet',
                  height: 38,
                  onPressed: () => showToast(context, 'Connecting wallet...'),
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
