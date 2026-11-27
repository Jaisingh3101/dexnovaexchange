import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/dex_models.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/wallet_provider.dart';
import '../screens/create_wallet_screen.dart';
import '../theme.dart';
import 'common.dart';
import 'flaticon.dart';

Future<void> showWalletSwitcherSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.pal.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final walletProv = ctx.watch<WalletProvider>();
      final portfolio = ctx.watch<PortfolioProvider>();
      final market = ctx.read<MarketProvider>();
      final wallets = walletProv.wallets;
      final active = walletProv.activeWallet;
      final p = ctx.pal;
      final hasMnemonic = walletProv.hasMnemonic;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 34,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const FBadgeIcon(
                    Flaticons.wallet,
                    color: AppColors.primary,
                    size: 28,
                    iconSize: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Web3 Multi-Wallet (${wallets.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'HD Vault',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (wallets.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No Web3 wallet yet — Create or Recover to generate your multi-chain addresses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: p.textMuted),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: wallets.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final w = wallets[i];
                      final isSelected = active?.id == w.id;
                      return GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        borderColor: isSelected ? AppColors.primary : p.border,
                        onTap: () {
                          ctx.read<WalletProvider>().switchWallet(w.id);
                          Navigator.pop(ctx);
                          showToast(
                            context,
                            'Switched to ${w.name} (${w.shortEth})',
                          );
                        },
                        child: Row(
                          children: [
                            FIcon(
                              isSelected
                                  ? Flaticons.checkCircle
                                  : Flaticons.wallet,
                              size: 18,
                              color: isSelected ? AppColors.green : p.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          w.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: p.text,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: p.cardAlt,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          w.source,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: p.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${w.shortEth} • ${w.derivationPath}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: p.textMuted,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(text: w.ethAddress),
                                          );
                                          showToast(
                                            context,
                                            'Copied ${w.shortEth}',
                                          );
                                        },
                                        child: const FIcon(
                                          Flaticons.copy,
                                          size: 11,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSelected
                                  ? fmtCompactUsd(
                                      portfolio.totalOnChainUsd(
                                        market.nativeUsdPrice,
                                      ),
                                    )
                                  : 'On-Chain',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.green
                                    : p.textMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                ctx.read<WalletProvider>().removeWallet(w.id);
                                showToast(context, 'Removed ${w.name}');
                              },
                              child: FIcon(
                                Flaticons.closeCircle,
                                size: 15,
                                color: p.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (hasMnemonic) ...[
                const SizedBox(height: 8),
                GradientButton(
                  label: '+ Derive HD Account',
                  icon: Flaticons.sparkles,
                  outlined: true,
                  height: 36,
                  onPressed: () {
                    final derived = ctx
                        .read<WalletProvider>()
                        .addDerivedHdAccount();
                    if (derived != null) {
                      showToast(
                        context,
                        'Derived ${derived.name} (${derived.shortEth})',
                      );
                    }
                  },
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      label: '+ Create Wallet',
                      icon: Flaticons.addWallet,
                      height: 38,
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CreateWalletScreen(initialTab: 0),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GradientButton(
                      label: 'Recover Seed',
                      icon: Flaticons.recoverWallet,
                      outlined: true,
                      height: 38,
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CreateWalletScreen(initialTab: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ActiveWalletStrip extends StatelessWidget {
  const ActiveWalletStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final walletProv = context.watch<WalletProvider>();
    final wallets = walletProv.wallets;
    final wallet = walletProv.activeWallet;

    if (wallet == null) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        radius: 10,
        onTap: () => showWalletSwitcherSheet(context),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.amber,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Web3 Wallet · Not Connected',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.textSecondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                wallets.isNotEmpty
                    ? 'Switch (${wallets.length})'
                    : 'Connect Wallet',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      radius: 10,
      onTap: () => showWalletSwitcherSheet(context),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              wallet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: wallet.ethAddress));
              showToast(context, 'Copied ${wallet.shortEth}');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: p.field,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: p.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wallet.shortEth,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: p.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const FIcon(
                    Flaticons.copy,
                    size: 10,
                    color: AppColors.primaryLight,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: p.cardAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${wallets.length} ${wallets.length == 1 ? 'Wallet' : 'Wallets'}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 2),
                const FIcon(
                  Flaticons.chevronDown,
                  size: 10,
                  color: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
