import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/flaticon.dart';
import 'create_wallet_screen.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  const RecoveryPhraseScreen({super.key});

  @override
  State<RecoveryPhraseScreen> createState() => _RecoveryPhraseScreenState();
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  bool hidden = false;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Phrase'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleButton(compact: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        children: [
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: const Center(
                child: FIcon(
                  Flaticons.shieldCheck,
                  size: 30,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Backup Your Recovery Phrase',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This 12-word phrase is the only way to recover your wallet. Keep it safe and never share it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: p.textMuted, height: 1.35),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.amber.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const FIcon(
                  Flaticons.warning,
                  size: 15,
                  color: AppColors.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Do not screenshot or store in cloud notes.',
                    style: TextStyle(fontSize: 11.5, color: p.text),
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
                    Expanded(
                      child: Text(
                        '12-Word Secret Key',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: p.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => hidden = !hidden),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.cardAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: p.border),
                        ),
                        child: Row(
                          children: [
                            FIcon(
                              hidden ? Flaticons.eye : Flaticons.eyeOff,
                              size: 12,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hidden ? 'Reveal' : 'Hide',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: p.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: recoveryWords.join(' ')),
                        );
                        showToast(context, 'Recovery phrase copied');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.cardAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: p.border),
                        ),
                        child: Row(
                          children: [
                            const FIcon(
                              Flaticons.copy,
                              size: 12,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: p.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 3.1,
                  children: [
                    for (var i = 0; i < recoveryWords.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: p.field,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: p.border),
                        ),
                        child: Center(
                          child: Text(
                            hidden
                                ? '${i + 1}. ••••'
                                : '${i + 1}. ${recoveryWords[i]}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GradientButton(
            label: "I've Backed It Up",
            icon: Flaticons.checkCircle,
            onPressed: () {
              showToast(context, 'Recovery phrase backup complete');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Create Wallet',
                  icon: Flaticons.addWallet,
                  outlined: true,
                  height: 38,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateWalletScreen(initialTab: 0),
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
                      builder: (_) => const CreateWalletScreen(initialTab: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
